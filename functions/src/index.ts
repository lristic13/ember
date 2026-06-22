import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";
import {getMessaging} from "firebase-admin/messaging";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions/v2";

initializeApp();
const db = getFirestore();

// All callables run in this region. Keep it close to the Firestore location.
// Must match `kCloudFunctionsRegion` on the client.
const REGION = "europe-west1";

// Mirror of HandleRules on the client. Lowercase letters/digits/underscore,
// 3–20 chars. The backend is the source of truth for validity + uniqueness.
const HANDLE_RE = /^[a-z0-9_]{3,20}$/;

/**
 * Atomically reserves a unique @handle for the caller.
 *
 * Throws:
 *  - unauthenticated   — not signed in
 *  - invalid-argument  — handle fails the format check
 *  - failed-precondition — caller already has a handle (handles are immutable)
 *  - already-exists    — handle is taken (mapped to HandleTakenFailure client-side)
 */
export const claimHandle = onCall({region: REGION}, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const handle = String(request.data?.handle ?? "").trim().toLowerCase();
  if (!HANDLE_RE.test(handle)) {
    throw new HttpsError("invalid-argument", "Invalid handle.");
  }

  const handleRef = db.collection("handles").doc(handle);
  const userRef = db.collection("users").doc(uid);

  await db.runTransaction(async (tx) => {
    const [handleSnap, userSnap] = await Promise.all([
      tx.get(handleRef),
      tx.get(userRef),
    ]);

    // Immutability: a user who already has a handle cannot claim another.
    if (userSnap.get("handle")) {
      throw new HttpsError(
        "failed-precondition",
        "You already have a handle."
      );
    }
    if (handleSnap.exists) {
      throw new HttpsError("already-exists", "That handle is taken.");
    }

    const token = request.auth!.token;
    tx.set(handleRef, {uid, createdAt: FieldValue.serverTimestamp()});
    tx.set(
      userRef,
      {
        handle,
        handleLower: handle,
        displayName: token.name ?? null,
        photoUrl: token.picture ?? null,
        createdAt: FieldValue.serverTimestamp(),
      },
      {merge: true}
    );
  });

  return {handle};
});

/**
 * Deletes the caller's account: frees their handle, deletes their profile doc,
 * revokes every invite they sent or received, then deletes the auth user
 * (admin privilege — no client reauth needed).
 *
 * A callable (not an Auth onDelete trigger) so it can run in [REGION]; 1st-gen
 * Auth triggers are restricted to us-central1.
 *
 * TODO (Phase 5): also remove the uid from every shared habit's participantIds.
 */
export const deleteAccount = onCall({region: REGION}, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const userRef = db.collection("users").doc(uid);
  const snap = await userRef.get();
  const handle = snap.get("handleLower") as string | undefined;

  // Detach from every shared habit: habits the user owns are deleted for
  // everyone; habits they merely joined just drop their membership.
  const habits = await db
    .collection("habits")
    .where("participantIds", "array-contains", uid)
    .get();
  for (const doc of habits.docs) {
    if (doc.get("ownerId") === uid) {
      await purgeSharedHabit(doc.id);
    } else {
      await doc.ref.update({
        participantIds: FieldValue.arrayRemove(uid),
        [`participants.${uid}`]: FieldValue.delete(),
      });
    }
  }

  // Any invites still referencing the user (e.g. for habits they didn't own).
  const [sent, received] = await Promise.all([
    db.collection("invites").where("fromUid", "==", uid).get(),
    db.collection("invites").where("toUid", "==", uid).get(),
  ]);

  const batch = db.batch();
  if (handle) {
    batch.delete(db.collection("handles").doc(handle));
  }
  for (const doc of [...sent.docs, ...received.docs]) {
    batch.delete(doc.ref);
  }
  batch.delete(userRef);
  await batch.commit();

  await getAuth().deleteUser(uid);
  return {ok: true};
});

/**
 * Deletes a shared habit and everything that references it: its `entries`
 * subcollection (via recursiveDelete) and every invite for it.
 */
async function purgeSharedHabit(habitId: string): Promise<void> {
  const invites = await db
    .collection("invites")
    .where("habitId", "==", habitId)
    .get();
  if (!invites.empty) {
    const batch = db.batch();
    invites.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }
  await db.recursiveDelete(db.collection("habits").doc(habitId));
}

/**
 * Cancels a pending invite the caller sent.
 *
 * Throws:
 *  - unauthenticated     — not signed in
 *  - invalid-argument    — missing invite id
 *  - permission-denied   — the caller didn't send this invite
 *  - failed-precondition — invite was already accepted/declined
 */
export const cancelInvite = onCall({region: REGION}, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const inviteId = String(request.data?.inviteId ?? "").trim();
  if (!inviteId) {
    throw new HttpsError("invalid-argument", "Missing invite.");
  }

  const ref = db.collection("invites").doc(inviteId);
  const snap = await ref.get();
  if (!snap.exists) {
    return {ok: true};
  }
  const invite = snap.data()!;
  if (invite.fromUid !== uid) {
    throw new HttpsError("permission-denied", "Not your invite.");
  }
  if (invite.status !== "pending") {
    throw new HttpsError("failed-precondition", "Already handled.");
  }

  await ref.delete();
  return {ok: true};
});

/**
 * Removes the caller from a shared habit they joined. Owners can't leave (they
 * delete the habit instead).
 *
 * Throws:
 *  - unauthenticated     — not signed in
 *  - invalid-argument    — missing habit id
 *  - not-found           — habit doesn't exist
 *  - failed-precondition — caller is the owner, or not a member
 */
export const leaveHabit = onCall({region: REGION}, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const habitId = String(request.data?.habitId ?? "").trim();
  if (!habitId) {
    throw new HttpsError("invalid-argument", "Missing habit.");
  }

  const ref = db.collection("habits").doc(habitId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) {
      throw new HttpsError("not-found", "Habit not found.");
    }
    const habit = snap.data()!;
    if (habit.ownerId === uid) {
      throw new HttpsError(
        "failed-precondition",
        "Owners can't leave — delete the habit instead."
      );
    }
    const participantIds = (habit.participantIds ?? []) as string[];
    if (!participantIds.includes(uid)) {
      throw new HttpsError("failed-precondition", "You're not a member.");
    }
    tx.update(ref, {
      participantIds: FieldValue.arrayRemove(uid),
      [`participants.${uid}`]: FieldValue.delete(),
    });
  });

  return {ok: true};
});

/**
 * Owner removes another participant from a shared habit.
 *
 * Throws:
 *  - unauthenticated     — not signed in
 *  - invalid-argument    — missing habit id or target uid
 *  - not-found           — habit doesn't exist
 *  - permission-denied   — caller isn't the owner
 *  - failed-precondition — target is the owner (can't remove yourself this way)
 */
export const removeParticipant = onCall({region: REGION}, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const habitId = String(request.data?.habitId ?? "").trim();
  const targetUid = String(request.data?.uid ?? "").trim();
  if (!habitId || !targetUid) {
    throw new HttpsError("invalid-argument", "Missing habit or member.");
  }

  const ref = db.collection("habits").doc(habitId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) {
      throw new HttpsError("not-found", "Habit not found.");
    }
    const habit = snap.data()!;
    if (habit.ownerId !== uid) {
      throw new HttpsError("permission-denied", "Only the owner can do that.");
    }
    if (targetUid === uid) {
      throw new HttpsError("failed-precondition", "You can't remove yourself.");
    }
    tx.update(ref, {
      participantIds: FieldValue.arrayRemove(targetUid),
      [`participants.${targetUid}`]: FieldValue.delete(),
    });
  });

  return {ok: true};
});

/**
 * Owner deletes a shared habit for everyone (entries + invites + the doc).
 *
 * Throws:
 *  - unauthenticated    — not signed in
 *  - invalid-argument   — missing habit id
 *  - permission-denied  — caller isn't the owner
 */
export const deleteSharedHabit = onCall({region: REGION}, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const habitId = String(request.data?.habitId ?? "").trim();
  if (!habitId) {
    throw new HttpsError("invalid-argument", "Missing habit.");
  }

  const ref = db.collection("habits").doc(habitId);
  const snap = await ref.get();
  if (!snap.exists) {
    return {ok: true};
  }
  if (snap.get("ownerId") !== uid) {
    throw new HttpsError("permission-denied", "Only the owner can delete this.");
  }

  await purgeSharedHabit(habitId);
  return {ok: true};
});

/**
 * Owner edits a shared habit's metadata (name, emoji, gradient, unit, tracking
 * type). Only these fields can change — never participants/owner.
 *
 * Throws:
 *  - unauthenticated    — not signed in
 *  - invalid-argument   — missing habit id or nothing to update
 *  - not-found          — habit doesn't exist
 *  - permission-denied  — caller isn't the owner
 */
export const updateSharedHabit = onCall({region: REGION}, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const habitId = String(request.data?.habitId ?? "").trim();
  if (!habitId) {
    throw new HttpsError("invalid-argument", "Missing habit.");
  }

  const ref = db.collection("habits").doc(habitId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Habit not found.");
  }
  if (snap.get("ownerId") !== uid) {
    throw new HttpsError("permission-denied", "Only the owner can edit this.");
  }

  const data = request.data ?? {};
  const update: Record<string, unknown> = {};

  const name = typeof data.name === "string" ? data.name.trim() : "";
  if (name) {
    update.name = name;
  }
  if ("emoji" in data) {
    update.emoji = data.emoji ?? null;
  }
  if (typeof data.gradientId === "string") {
    update.gradientId = data.gradientId;
  }
  if ("unit" in data) {
    update.unit = data.unit ?? null;
  }
  if (data.trackingType === "completion" || data.trackingType === "quantity") {
    update.trackingType = data.trackingType;
  }
  if (data.completionMode === "any" || data.completionMode === "all") {
    update.completionMode = data.completionMode;
  }

  if (Object.keys(update).length === 0) {
    throw new HttpsError("invalid-argument", "Nothing to update.");
  }

  await ref.update(update);
  return {ok: true};
});

/**
 * Invites the user with [toHandle] to collaborate on the caller's shared
 * habit [habitId]. The habit must already exist in Firestore (the client
 * promotes a personal habit to shared before calling this) and the caller
 * must be a participant.
 *
 * Throws:
 *  - unauthenticated     — not signed in
 *  - invalid-argument    — missing habit id or malformed handle
 *  - not-found           — no user owns that handle, or the habit is missing
 *  - failed-precondition — inviting yourself
 *  - permission-denied   — caller isn't a participant of the habit
 *  - already-exists      — invitee is already in the habit or already invited
 */
export const sendInvite = onCall({region: REGION}, async (request) => {
  const fromUid = request.auth?.uid;
  if (!fromUid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const habitId = String(request.data?.habitId ?? "").trim();
  const toHandle = String(request.data?.toHandle ?? "").trim().toLowerCase();
  if (!habitId || !HANDLE_RE.test(toHandle)) {
    throw new HttpsError("invalid-argument", "Missing habit or handle.");
  }

  const handleSnap = await db.collection("handles").doc(toHandle).get();
  if (!handleSnap.exists) {
    throw new HttpsError("not-found", "User not found");
  }
  const toUid = handleSnap.get("uid") as string;
  if (toUid === fromUid) {
    throw new HttpsError("failed-precondition", "You can't invite yourself.");
  }

  const habitRef = db.collection("habits").doc(habitId);
  const habitSnap = await habitRef.get();
  if (!habitSnap.exists) {
    throw new HttpsError("not-found", "Habit not found.");
  }
  const habit = habitSnap.data()!;
  const participantIds = (habit.participantIds ?? []) as string[];
  if (!participantIds.includes(fromUid)) {
    throw new HttpsError("permission-denied", "Not your habit.");
  }
  if (participantIds.includes(toUid)) {
    throw new HttpsError("already-exists", "They're already in this habit.");
  }

  const dup = await db
    .collection("invites")
    .where("habitId", "==", habitId)
    .where("toUid", "==", toUid)
    .where("status", "==", "pending")
    .limit(1)
    .get();
  if (!dup.empty) {
    throw new HttpsError("already-exists", "They've already been invited.");
  }

  const fromSnap = await db.collection("users").doc(fromUid).get();

  await db.collection("invites").add({
    habitId,
    habitName: habit.name ?? "",
    habitEmoji: habit.emoji ?? null,
    fromUid,
    fromHandle: fromSnap.get("handle") ?? null,
    fromDisplayName: fromSnap.get("displayName") ?? null,
    toUid,
    toHandle,
    status: "pending",
    createdAt: FieldValue.serverTimestamp(),
  });

  return {ok: true};
});

/**
 * Accepts or declines a pending invite addressed to the caller. Accepting adds
 * the caller to the habit's participantIds/participants (admin write — they
 * aren't a participant yet, so client rules couldn't allow it). Runs in a
 * transaction so the invite can't be double-processed.
 *
 * Throws:
 *  - unauthenticated     — not signed in
 *  - invalid-argument    — missing invite id
 *  - not-found           — invite (or its habit) no longer exists
 *  - permission-denied   — invite isn't addressed to the caller
 *  - failed-precondition — invite was already accepted/declined
 */
export const respondToInvite = onCall({region: REGION}, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const inviteId = String(request.data?.inviteId ?? "").trim();
  const accept = request.data?.accept === true;
  if (!inviteId) {
    throw new HttpsError("invalid-argument", "Missing invite.");
  }

  const inviteRef = db.collection("invites").doc(inviteId);

  await db.runTransaction(async (tx) => {
    const inviteSnap = await tx.get(inviteRef);
    if (!inviteSnap.exists) {
      throw new HttpsError("not-found", "Invite not found.");
    }
    const invite = inviteSnap.data()!;
    if (invite.toUid !== uid) {
      throw new HttpsError("permission-denied", "Not your invite.");
    }
    if (invite.status !== "pending") {
      throw new HttpsError("failed-precondition", "Already handled.");
    }

    if (!accept) {
      tx.update(inviteRef, {
        status: "declined",
        respondedAt: FieldValue.serverTimestamp(),
      });
      return;
    }

    const habitRef = db.collection("habits").doc(invite.habitId as string);
    const habitSnap = await tx.get(habitRef);
    if (!habitSnap.exists) {
      throw new HttpsError("not-found", "Habit no longer exists.");
    }

    const userSnap = await tx.get(db.collection("users").doc(uid));
    const handle = userSnap.get("handle") ?? null;
    const displayName = userSnap.get("displayName") ?? null;

    tx.update(habitRef, {
      participantIds: FieldValue.arrayUnion(uid),
      [`participants.${uid}`]: {role: "member", handle, displayName},
    });
    tx.update(inviteRef, {
      status: "accepted",
      respondedAt: FieldValue.serverTimestamp(),
    });
  });

  return {ok: true};
});

/** Private per-user doc holding FCM device tokens (never client-readable). */
function pushDoc(uid: string) {
  return db.collection("users").doc(uid).collection("private").doc("push");
}

/**
 * Stores an FCM device token for the caller so they can receive push
 * notifications. Tokens live in the private `users/{uid}/private/push` doc (a
 * set via arrayUnion) — NOT on the public profile doc — so no other user can
 * read them. The invite trigger prunes dead ones.
 */
export const registerDeviceToken = onCall({region: REGION}, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }
  const token = String(request.data?.token ?? "").trim();
  if (!token) {
    throw new HttpsError("invalid-argument", "Missing token.");
  }
  await pushDoc(uid).set(
    {fcmTokens: FieldValue.arrayUnion(token)},
    {merge: true}
  );
  // Migrate off the old public location so tokens stop being world-readable.
  await db
    .collection("users")
    .doc(uid)
    .update({fcmTokens: FieldValue.delete()})
    .catch(() => {});
  return {ok: true};
});

/**
 * Pushes a notification to the invitee whenever a pending invite is created.
 * Dead/expired tokens are removed from the user's `fcmTokens` on failure.
 */
export const onInviteCreated = onDocumentCreated(
  {region: REGION, document: "invites/{inviteId}"},
  async (event) => {
    const invite = event.data?.data();
    if (!invite || invite.status !== "pending") return;

    const toUid = invite.toUid as string;
    const pushSnap = await pushDoc(toUid).get();
    const tokens = (pushSnap.get("fcmTokens") ?? []) as string[];
    if (tokens.length === 0) return;

    const fromName =
      invite.fromDisplayName ||
      (invite.fromHandle ? `@${invite.fromHandle}` : "Someone");
    const habitName = invite.habitName || "a habit";

    const response = await getMessaging().sendEachForMulticast({
      tokens,
      notification: {
        title: "New habit invite",
        body: `${fromName} invited you to ${habitName}`,
      },
      data: {type: "invite", inviteId: event.params.inviteId},
      apns: {payload: {aps: {sound: "default"}}},
    });

    const invalid: string[] = [];
    response.responses.forEach((res, i) => {
      const code = res.error?.code;
      if (
        !res.success &&
        (code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token")
      ) {
        invalid.push(tokens[i]);
      }
    });
    if (invalid.length > 0) {
      await pushDoc(toUid).update({
        fcmTokens: FieldValue.arrayRemove(...invalid),
      });
      logger.info("onInviteCreated:prunedTokens", {count: invalid.length});
    }
  }
);

/**
 * Sets the caller's own contribution for a day (`yyyy-MM-dd`) on an "Everyone"
 * shared habit: [value] is 1 for a check-in (completion) or the logged amount
 * (quantity); 0 clears it. The group's `value` is recomputed so the day only
 * "counts" once *every* participant has logged something — 1 for completion,
 * the sum of amounts for quantity, else 0. A participant only ever writes their
 * own contribution.
 *
 * Throws:
 *  - unauthenticated    — not signed in
 *  - invalid-argument   — missing/invalid habit id, date or value
 *  - not-found          — habit doesn't exist
 *  - permission-denied  — caller isn't a participant
 */
export const setTogetherEntry = onCall({region: REGION}, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const habitId = String(request.data?.habitId ?? "").trim();
  const date = String(request.data?.date ?? "").trim();
  const value = Number(request.data?.value ?? 0);
  if (
    !habitId ||
    !/^\d{4}-\d{2}-\d{2}$/.test(date) ||
    !Number.isFinite(value) ||
    value < 0
  ) {
    throw new HttpsError("invalid-argument", "Missing habit, date or value.");
  }

  const habitRef = db.collection("habits").doc(habitId);
  const entryRef = habitRef.collection("entries").doc(date);

  await db.runTransaction(async (tx) => {
    const habitSnap = await tx.get(habitRef);
    if (!habitSnap.exists) {
      throw new HttpsError("not-found", "Habit not found.");
    }
    const participantIds = (habitSnap.get("participantIds") ?? []) as string[];
    if (!participantIds.includes(uid)) {
      throw new HttpsError("permission-denied", "Not your habit.");
    }
    const trackingType = habitSnap.get("trackingType");

    const entrySnap = await tx.get(entryRef);
    const raw = (entrySnap.exists ? entrySnap.get("checks") : null) ?? {};
    const checks: Record<string, number> = {};
    for (const [k, v] of Object.entries(raw)) {
      // Tolerate the legacy boolean form (`true` → 1).
      const n = typeof v === "number" ? v : v === true ? 1 : 0;
      if (n > 0) checks[k] = n;
    }

    if (value > 0) {
      checks[uid] = value;
    } else {
      delete checks[uid];
    }

    const amounts = participantIds.map((p) => checks[p] ?? 0);
    const allLogged = amounts.every((a) => a > 0);
    const sum = amounts.reduce((s, a) => s + a, 0);
    const groupValue = !allLogged ? 0 : trackingType === "quantity" ? sum : 1;

    tx.set(entryRef, {
      checks,
      value: groupValue,
      loggedBy: uid,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  return {ok: true};
});

/**
 * Logs an entry on an "Anyone" shared habit (last-write-wins). Routed through a
 * function so the `entries` subcollection can deny direct participant writes —
 * a participant can only log via this, which stamps `loggedBy` to the caller.
 *
 * Throws:
 *  - unauthenticated    — not signed in
 *  - invalid-argument   — missing/invalid habit id, date or value
 *  - not-found          — habit doesn't exist
 *  - permission-denied  — caller isn't a participant
 */
export const logSharedEntry = onCall({region: REGION}, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const habitId = String(request.data?.habitId ?? "").trim();
  const date = String(request.data?.date ?? "").trim();
  const value = Number(request.data?.value ?? 0);
  if (
    !habitId ||
    !/^\d{4}-\d{2}-\d{2}$/.test(date) ||
    !Number.isFinite(value) ||
    value < 0
  ) {
    throw new HttpsError("invalid-argument", "Missing habit, date or value.");
  }

  const habitRef = db.collection("habits").doc(habitId);
  const habitSnap = await habitRef.get();
  if (!habitSnap.exists) {
    throw new HttpsError("not-found", "Habit not found.");
  }
  const participantIds = (habitSnap.get("participantIds") ?? []) as string[];
  if (!participantIds.includes(uid)) {
    throw new HttpsError("permission-denied", "Not your habit.");
  }

  await habitRef.collection("entries").doc(date).set({
    value,
    loggedBy: uid,
    updatedAt: FieldValue.serverTimestamp(),
  });
  return {ok: true};
});
