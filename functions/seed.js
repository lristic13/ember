// One-off dev seed: creates a test SHARED habit for a user so Phase 2's read
// path can be verified before the sharing UI exists. Safe to delete later.
//
// Prereq: application-default credentials, e.g.
//   gcloud auth application-default login
// Run from the functions/ directory:
//   node seed.js <your-handle>
const admin = require('firebase-admin');

admin.initializeApp({ projectId: 'ember-36b86' });
const db = admin.firestore();

(async () => {
  const handle = (process.argv[2] || '').toLowerCase();
  if (!handle) {
    console.error('Usage: node seed.js <your-handle>');
    process.exit(1);
  }

  const handleSnap = await db.collection('handles').doc(handle).get();
  const uid = handleSnap.exists ? handleSnap.data().uid : null;
  if (!uid) {
    console.error(`No user found with handle @${handle}`);
    process.exit(1);
  }
  const userSnap = await db.collection('users').doc(uid).get();
  const displayName = userSnap.data()?.displayName || 'You';

  const habit = db.collection('habits').doc();
  await habit.set({
    name: 'Tennis',
    emoji: '🎾',
    trackingType: 'completion',
    gradientId: 'ember',
    ownerId: uid,
    participantIds: [uid],
    participants: { [uid]: { handle, displayName, role: 'owner' } },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const batch = db.batch();
  const today = new Date();
  for (const offset of [0, 1, 3, 4, 6, 8, 11, 13]) {
    const d = new Date(today);
    d.setDate(today.getDate() - offset);
    const id = d.toISOString().slice(0, 10); // yyyy-MM-dd
    batch.set(habit.collection('entries').doc(id), {
      value: 1,
      loggedBy: uid,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();

  console.log(`Seeded shared habit ${habit.id} for @${handle} (${uid})`);
  process.exit(0);
})();
