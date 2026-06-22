# ember — Account Screens · Flutter Handoff

Design reference for three new account/onboarding screens, built to drop into the existing **Flutter** ember app:

1. **Sign in** — Apple + Google, with default / connecting / error states
2. **Handle setup** — immutable `@handle` with live availability (checking / available / taken / invalid)
3. **Profile** — identity, **Insights** + **Appearance** theme switch, Sign out, and a destructive **Delete account** flow

---

## What this bundle is

The reference is built in **HTML/React (Babel-in-the-browser)** — a prototype that shows the intended look and behavior. It is **not production code to copy**, and it is **not Flutter**. The components are inline-styled React purely for prototyping.

**Your task:** recreate these screens as **native Flutter widgets** using the app's existing patterns — its `ThemeData`, widget library, navigation (Navigator / go_router), and state management (Provider / Riverpod / Bloc — whatever is already in the project). Translate the tokens below into the app's theme. `lib/ember_theme.dart` in this bundle is a ready starter.

> The app already has an ember design language (Space Grotesk, JetBrains Mono micro-labels, the warm ember accent, dark surfaces, the activity-color system). These screens use **exactly** that system — reuse the existing tokens/widgets rather than introducing new ones. Where this doc and the live app disagree, the **app wins**; tell me and I'll reconcile.

---

## Canvas & Units — read this first

- The mockups are authored on a **980 × 2120 pt canvas** inside a fake phone frame. That canvas is **≈2.5× a real iPhone** (~392 pt logical width).
- **Every px in the `.jsx` source is ~2.5× too large for Flutter logical points. Divide by 2.5.** (980 ÷ 2.5 ≈ 392.) The type/spacing tables below are **already converted to logical points**; `lib/ember_theme.dart` is too.
- The **status bar (12:43, signal, battery)**, the **dynamic island**, and the **phone bezel** are mockup chrome only. **Do not build them** — use `Scaffold` + `SafeArea` and the real OS status bar.
- Lay out fluidly to device width with sensible logical sizes; don't hard-code 392.

---

## Colors

Full set is in `lib/ember_theme.dart` as `EmberColors`. Summary:

| Token | Hex | Use |
|---|---|---|
| `bg` | `#070809` | scaffold background |
| `card` | `#101316` | cards, list rows, bottom sheet |
| `cardHi` | `#171B1F` | icon tiles, ghost buttons, disabled primary |
| `field` | `#15191D` | input fields, segmented track, Google button |
| `border` | `rgba(150,165,180,.10)` | 1px hairline on cards/fields |
| `text` | `#EEF1F4` | primary text |
| `dim` | `#8A95A0` | secondary text |
| `dimmer` | `#4C555E` | tertiary / placeholder / `@` prefix |
| **`neon`** | `#FF6B1A` | brand accent (the `.` in wordmark, highlights) |
| **`bright`→`deep`** | `#FF8A45`→`#E85600` | the ~155° gradient on every primary fill |
| `ink` | `#1E0A00` | dark text **on** bright ember fills |
| `danger` | `#FF6B6B` | destructive + error |
| `dangerDeep` | `#E84545` | delete-button gradient end |
| `good` | `#5FC56B` | handle "available" (green) |

Hex-alpha note: a `#RRGGBBaa` suffix in the source is opacity — `…0.10` ≈ `withOpacity(0.10)` (`1A`), `0.09`→`17`, `0.34`→`57`, `0.22`→`38`.

---

## Type

- **Display:** Space Grotesk (w600 mostly, w400 for body copy). Negative tracking on headings (~−0.02 to −0.04em).
- **Mono micro-label:** JetBrains Mono, **UPPERCASE**, letter-spacing `0.14em` — used for "STEP 2 OF 2", "letters, numbers…", "TYPE @MARA_B TO CONFIRM". Helper `mono()` in the starter.

Type scale (logical pt, already ÷2.5):

| Role | pt | Weight |
|---|---|---|
| Hero headline (Sign in) | 30 | 600 |
| Screen title (Handle / sheet) | 25 | 600 |
| Profile name | 22 | 600 |
| Section / card title | 14 | 600 |
| Button label | 13 | 600 |
| Body / subtext | 12–13 | 400–500 |
| Handle field value (mono) | 20 | 500 |
| Mono micro-label | 9 | 500 |

---

## Buttons (shared)

All full-width, centered icon+label, radius ~11pt.

- **Apple** (`AuthButton apple`): **white** `#FFFFFF` fill, black text + black Apple glyph. Per Apple HIG, the white button is used on dark backgrounds, and Apple is listed **first**.
- **Google**: `field` fill `#15191D`, 1px `border`, white text, the **4-color Google "G"**. Disabled → `opacity 0.4`.
- **Primary** (ember): `EmberColors.brandFill` gradient, text color `ink` `#1E0A00`, `BoxShadow(color: neon@0.27, blur: 14, offset (0,5))`. **Disabled** → fill `cardHi`, text `dimmer`, no shadow.
- **Ghost** (Sign out): `cardHi` fill, 1px `border`, text `text`.
- **Danger solid** (Delete): `EmberColors.dangerFill` gradient, white text, soft red glow.
- **Danger ghost** (Delete account row on profile): `dangerTint` fill, 1px `dangerLine`, text `dangerSoft`.

```dart
// Primary ember button
Widget emberPrimary(String label, {bool enabled = true, VoidCallback? onTap}) {
  return GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        gradient: enabled ? EmberColors.brandFill : null,
        color: enabled ? null : EmberColors.cardHi,
        borderRadius: BorderRadius.circular(11),
        border: enabled ? null : Border.all(color: EmberColors.border),
        boxShadow: enabled
            ? [BoxShadow(color: EmberColors.neon.withOpacity(0.27), blurRadius: 14, offset: const Offset(0, 5))]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(label, style: disp(14, color: enabled ? EmberColors.ink : EmberColors.dimmer)),
    ),
  );
}
```

Apple/Google glyphs: the reference draws them as inline SVG paths (`AppleLogo`, `GoogleG` in `account/ember-account.jsx`). In Flutter, use the **`sign_in_button`** or **`flutter_signin_button`** package, or `SvgPicture.string()` with those paths, or your own asset. Don't recolor the Google G — it must keep its four brand colors.

---

## Screen 1 · Sign in

Layout (top→bottom, `SafeArea`, ~26pt horizontal padding):
- small `ember•` wordmark, centered.
- centered hero: a 80pt rounded-square ember-gradient tile with the white **flame** glyph + a radial glow behind it; headline "Better with friends." (the `.` is `neon`); subtext in `dim`.
- bottom button stack: **Apple**, **Google**, then a legal line in `dimmer` (Terms / Privacy in `dim`).

States:
- **connecting** — Apple button shows a `CircularProgressIndicator` (≈14pt, black) + "Connecting…"; Google button `opacity 0.4` + disabled. Drive from an `isLoading` flag while the OAuth round-trip runs.
- **error** — insert an error card above the buttons: `dangerTint` fill, 1px `dangerLine`, warning triangle, "Sign-in failed" (`dangerSoft`) + "Something went wrong. Please try again." (`dim`). Show on auth failure.

The flame glyph path is in `store-atoms.jsx` (`Flame`) — reuse the app's existing flame asset.

---

## Screen 2 · Handle setup (shown right after first sign-in)

- mono "STEP 2 OF 2" in `neon`; title "Claim your handle."; subtext "This is how friends find you on ember."
- **field**: `field` fill, **2px** border whose color reflects state, radius ~10pt. Row = dim `@` prefix · the typed value (mono, `text`) · a blinking caret (`neon`) · trailing status icon.
- **status line** below (one line, ~11pt): the message in the state color.
- **format hint** (mono micro-label, `dimmer`): `letters, numbers, _ · 3–20`.
- **immutable note**: ember-tinted box (`rgba(255,107,26,.07)` fill, `rgba(255,107,26,.22)` border) + lock icon + "**Handles are permanent.** You can't change this later."
- bottom **Primary "Continue →"**, disabled until valid **and** available.

State → field border / status / icon:

| State | Border | Status text | Icon | Continue |
|---|---|---|---|---|
| checking | `border` | "Checking availability…" (`dim`) | spinner | disabled |
| available | `good@0.6` + green glow | "@handle is available" (`good`) | ✓ in `good@13%` chip | **enabled** |
| taken | `dangerLine` | "@handle is taken — try another" (`dangerSoft`) | ✗ in red chip | disabled |
| invalid | `dangerLine` | "Only letters, numbers and _ allowed" (`dangerSoft`) | ✗ in red chip | disabled |

**Logic (build this for real):**
- Validation regex: `^[a-z0-9_]{3,20}$` (lowercase; lowercase the input as they type). In the **invalid** state the reference highlights the offending characters red — optional but nice: color any char failing `[A-Za-z0-9_]` with `danger`.
- Availability: **debounce ~400ms** after the last keystroke, then call your backend; show `checking` while the request is in flight. Only enable Continue when `regexValid && available == true`.
- Handles are **immutable** server-side — enforce on the backend, not just the client.

---

## Screen 3 · Profile

- `TopNav` with a close (✕) button left, "Profile" centered.
- centered identity: 74pt circular **avatar** (ember gradient + initials "MB" in white, radial glow), display name (22pt), `@mara_b` (mono, `dim`).
- a list (cards, radius ~11pt, 1px `border`, 78→31pt icon tile left):
  - **Insights** row — bar-chart icon (ember tile tint `rgba(255,107,26,.10)`), "See where you showed up", chevron right. *(Moved here from the home header.)*
  - **Appearance** row — theme/contrast icon, "Match the mood you're in", and a full-width **segmented control** below: `Auto · Light · Dark`, selected segment uses `brandFill` + `ink` text. *(The theme switch, moved here.)* Wire to your existing `ThemeMode`.
- bottom: **Ghost "Sign out"** (door-arrow icon), then **Danger-ghost "Delete account"** (trash icon).

Segmented control = a `Row` of 3 `Expanded` `GestureDetector` pills inside a `field`-filled, rounded track; selected pill gets the gradient. (Or `CupertinoSlidingSegmentedControl` themed to ember.)

### Delete-account confirmation
Present with `showModalBottomSheet` (rounded top ~21pt, `card` fill, scrim `rgba(2,4,6,.74)`):
- grab handle bar; a red warning triangle in a `dangerTint` circle.
- "Delete account?" (25pt); body: "This permanently erases your account, every activity, and your entire history. **This can't be undone.**" (last clause `dangerSoft`).
- **type-to-confirm**: mono label "TYPE @MARA_B TO CONFIRM" + a `field` input with a red caret. Enable the Delete button **only** when the typed text equals the user's handle.
- **Danger-solid "Delete account"** then **Ghost "Cancel"**.

---

## CSS → Flutter quick map

| Reference (CSS/React) | Flutter |
|---|---|
| `border-radius: n` (÷2.5) | `BorderRadius.circular(n)` |
| `1px solid border` | `Border.all(color: EmberColors.border, width: 1)` |
| `linear-gradient(155deg, bright, deep)` | `EmberColors.brandFill` |
| `radial-gradient` glow | a `Container` with `RadialGradient`, or `BoxShadow` blur |
| `box-shadow: 0 5px 14px neon@.27` | `BoxShadow(color: neon.withOpacity(.27), blurRadius:14, offset: Offset(0,5))` |
| inline SVG icon | `SvgPicture.string(...)` (flutter_svg) or `CustomPaint` |
| `.ember-spin` keyframe | `CircularProgressIndicator(strokeWidth: …)` |
| `.ember-caret` blink | `AnimatedOpacity` toggled by a 1.05s `Timer.periodic`, or a `TweenAnimationBuilder` loop |
| segmented control | `Row` of `Expanded` pills, or `CupertinoSlidingSegmentedControl` |
| `showModalBottomSheet` overlay | `showModalBottomSheet(isScrollControlled: true, backgroundColor: Colors.transparent, …)` |
| emoji / initials avatar | `Container` + `Text` (initials), gradient decoration |

---

## Suggested structure
```
lib/theme/ember_theme.dart          // from this bundle
lib/widgets/ember_buttons.dart       // apple / google / primary / ghost / danger
lib/widgets/ember_flame.dart         // the flame glyph + gradient tile (reuse app's)
lib/screens/sign_in_screen.dart
lib/screens/handle_setup_screen.dart // + availability controller (debounce)
lib/screens/profile_screen.dart      // + delete bottom sheet
```

## Don't port
- `reference/design-canvas.jsx` — the pan/zoom gallery wrapper. **Tooling only.**
- `Phone`, `StatusBar`, dynamic island, bezel in `store-atoms.jsx` — mockup chrome. Use `Scaffold`/`SafeArea`.

## Files in this bundle
- `reference/Ember Account Screens.html` — open in a browser to see all nine states live (visual source of truth).
- `reference/account/ember-account.jsx` — exact values (colors, sizes, shadows, the SVG glyph paths) for these screens. **Read for numbers; don't ship.**
- `reference/store/store-atoms.jsx` — the shared ember atoms (palette `S`, `BRAND`, activity colors `A`, `Flame`, `mlabel`, `Wordmark`, `TopNav`). The real token source.
- `lib/ember_theme.dart` — ready-to-use Dart tokens + text helpers (already in logical points).
