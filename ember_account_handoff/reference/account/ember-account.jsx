// ember-account.jsx — account/onboarding screens in the ember design system.
// Loads after store-atoms.jsx (Phone, Screen, TopNav, Wordmark, BRAND, A, S, DISP, MONO, mlabel, Flame).
const { BRAND, A, S, DISP, MONO, mlabel, Flame, Phone, Screen, TopNav, Wordmark } = window;

const DANGER = { base: "#FF6B6B", soft: "#FF8A8A", deep: "#E84545", bgTint: "rgba(255,107,107,0.09)", line: "rgba(255,107,107,0.34)" };
const GOOD = A.workout; // green for "available"

// ── shared atoms ────────────────────────────────────────────────────────────
function Spinner({ size = 36, color = "#000", track }) {
  return (
    <div className="ember-spin" style={{
      width: size, height: size, borderRadius: "50%", flexShrink: 0,
      border: `${Math.max(3, size * 0.11)}px solid ${track || "rgba(0,0,0,0.18)"}`,
      borderTopColor: color,
    }} />
  );
}

function AppleLogo({ size = 34, fill = "#000" }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M17.05 12.04c-.03-2.9 2.37-4.3 2.48-4.36-1.35-1.98-3.46-2.25-4.21-2.28-1.79-.18-3.5 1.05-4.41 1.05-.91 0-2.31-1.03-3.8-1-1.96.03-3.77 1.14-4.78 2.9-2.04 3.54-.52 8.78 1.46 11.65.97 1.4 2.12 2.98 3.63 2.92 1.46-.06 2.01-.94 3.77-.94 1.76 0 2.26.94 3.8.91 1.57-.03 2.56-1.43 3.52-2.84 1.11-1.63 1.57-3.21 1.59-3.29-.03-.02-3.05-1.17-3.08-4.64z" fill={fill}/>
      <path d="M14.13 3.93c.81-.98 1.35-2.34 1.2-3.7-1.16.05-2.57.78-3.4 1.76-.75.86-1.4 2.25-1.23 3.57 1.29.1 2.62-.66 3.43-1.63z" fill={fill}/>
    </svg>
  );
}

function GoogleG({ size = 34 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24">
      <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
      <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
      <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/>
      <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
    </svg>
  );
}

function AuthButton({ variant, label, loadingLabel, loading, disabled }) {
  const apple = variant === "apple";
  return (
    <button disabled={loading || disabled} style={{
      width: "100%", border: apple ? "none" : `1px solid ${S.border}`,
      borderRadius: 28, padding: "32px 28px", cursor: "pointer",
      background: apple ? "#fff" : S.field, color: apple ? "#000" : S.text,
      fontFamily: DISP, fontWeight: 600, fontSize: 33, letterSpacing: "-0.01em",
      display: "flex", alignItems: "center", justifyContent: "center", gap: 18,
      opacity: disabled ? 0.4 : 1,
    }}>
      {loading
        ? <><Spinner size={34} color={apple ? "#000" : S.text} track={apple ? "rgba(0,0,0,0.18)" : "rgba(255,255,255,0.18)"} /> {loadingLabel}</>
        : <>{apple ? <AppleLogo size={36} /> : <GoogleG size={34} />} {label}</>}
    </button>
  );
}

function PrimaryButton({ children, disabled, onDark = BRAND.ink }) {
  return (
    <button disabled={disabled} style={{
      width: "100%", border: disabled ? `1px solid ${S.border}` : "none", borderRadius: 26,
      padding: "34px 28px", cursor: disabled ? "default" : "pointer",
      background: disabled ? S.cardHi : `linear-gradient(155deg, ${BRAND.bright}, ${BRAND.deep})`,
      color: disabled ? S.dimmer : onDark,
      fontFamily: DISP, fontWeight: 600, fontSize: 34, letterSpacing: "-0.01em",
      display: "flex", alignItems: "center", justifyContent: "center", gap: 14,
      boxShadow: disabled ? "none" : `0 12px 34px ${BRAND.neon}44`,
    }}>{children}</button>
  );
}

function WarnTriangle({ size = 34, color = DANGER.base }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M12 3.2 22 20H2L12 3.2Z" stroke={color} strokeWidth="2" strokeLinejoin="round"/>
      <path d="M12 10v4.4" stroke={color} strokeWidth="2.2" strokeLinecap="round"/>
      <circle cx="12" cy="17.4" r="1.2" fill={color}/>
    </svg>
  );
}

// ── 1 · SIGN IN ─────────────────────────────────────────────────────────────
function BigMark() {
  return (
    <div style={{ position: "relative", width: 200, height: 200 }}>
      <div style={{ position: "absolute", inset: -40, background: `radial-gradient(circle, ${BRAND.neon}55, transparent 68%)` }} />
      <div style={{
        position: "relative", width: 200, height: 200, borderRadius: 60,
        background: `linear-gradient(155deg, ${BRAND.bright}, ${BRAND.deep})`,
        display: "flex", alignItems: "center", justifyContent: "center",
        boxShadow: `0 24px 60px ${BRAND.neon}55, inset 0 2px 0 rgba(255,255,255,0.25)`,
      }}>
        <Flame size={108} />
      </div>
    </div>
  );
}

function SignIn({ state = "default" }) {
  return (
    <Phone>
      <Screen pad="150px 64px 70px">
        <div style={{ display: "flex", justifyContent: "center", marginTop: 36 }}><Wordmark size={46} /></div>

        <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
          <BigMark />
          <h1 style={{ margin: "60px 0 0", fontFamily: DISP, fontWeight: 600, fontSize: 76, lineHeight: 1.04, letterSpacing: "-0.04em", textAlign: "center", color: S.text }}>
            Better with<br />friends<span style={{ color: BRAND.neon }}>.</span>
          </h1>
          <p style={{ margin: "28px 0 0", fontFamily: DISP, fontWeight: 400, fontSize: 31, lineHeight: 1.4, textAlign: "center", color: S.dim, maxWidth: 720 }}>
            Sign in to share your activities, follow friends, and keep each other showing up.
          </p>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 22 }}>
          {state === "error" && (
            <div style={{ display: "flex", alignItems: "center", gap: 18, background: DANGER.bgTint, border: `1px solid ${DANGER.line}`, borderRadius: 22, padding: "26px 28px" }}>
              <WarnTriangle size={38} />
              <div>
                <div style={{ fontFamily: DISP, fontWeight: 600, fontSize: 29, color: DANGER.soft }}>Sign-in failed</div>
                <div style={{ fontFamily: DISP, fontSize: 25, color: S.dim, marginTop: 4 }}>Something went wrong. Please try again.</div>
              </div>
            </div>
          )}
          <AuthButton variant="apple" label="Continue with Apple" loadingLabel="Connecting…" loading={state === "loading"} />
          <AuthButton variant="google" label="Continue with Google" disabled={state === "loading"} />
          <p style={{ margin: "10px 0 0", fontFamily: DISP, fontSize: 23, lineHeight: 1.45, textAlign: "center", color: S.dimmer }}>
            By continuing you agree to our <span style={{ color: S.dim }}>Terms</span> &amp; <span style={{ color: S.dim }}>Privacy Policy</span>.
          </p>
        </div>
      </Screen>
    </Phone>
  );
}

// ── 2 · HANDLE SETUP ────────────────────────────────────────────────────────
function HandleValue({ value }) {
  return (
    <span style={{ fontFamily: MONO, fontSize: 50, fontWeight: 500, letterSpacing: "-0.01em", color: S.text }}>
      {[...value].map((ch, i) => (
        <span key={i} style={{ color: /[A-Za-z0-9_]/.test(ch) ? S.text : DANGER.base }}>{ch}</span>
      ))}
      <span className="ember-caret" style={{ display: "inline-block", width: 3, height: 50, marginLeft: 4, verticalAlign: "-8px", background: BRAND.neon }} />
    </span>
  );
}

function StatusIcon({ state }) {
  if (state === "checking") return <Spinner size={40} color={S.dim} track="rgba(255,255,255,0.12)" />;
  const ok = state === "available";
  const c = ok ? GOOD.base : DANGER.base;
  return (
    <div style={{ width: 46, height: 46, borderRadius: "50%", background: `${c}22`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
      {ok
        ? <svg width="24" height="24" viewBox="0 0 16 16" fill="none"><path d="M3 8.5l3.2 3.2L13 4.5" stroke={c} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
        : <svg width="22" height="22" viewBox="0 0 16 16" fill="none"><path d="M4 4l8 8M12 4l-8 8" stroke={c} strokeWidth="2.6" strokeLinecap="round"/></svg>}
    </div>
  );
}

const HANDLE_STATES = {
  checking:  { value: "mara_b", border: S.border,    msg: "Checking availability…",            color: S.dim,      valid: false },
  available: { value: "mara_b", border: `${GOOD.base}99`,   msg: "@mara_b is available",       color: GOOD.base,  valid: true },
  taken:     { value: "alex",   border: DANGER.line, msg: "@alex is taken — try another",       color: DANGER.soft, valid: false },
  invalid:   { value: "Me!",    border: DANGER.line, msg: "Only letters, numbers and _ allowed", color: DANGER.soft, valid: false },
};

function HandleSetup({ state = "available" }) {
  const d = HANDLE_STATES[state];
  return (
    <Phone>
      <Screen pad="150px 64px 70px">
        <div style={{ marginTop: 30 }}>
          <div style={mlabel(24, BRAND.neon)}>Step 2 of 2</div>
          <h1 style={{ margin: "22px 0 0", fontFamily: DISP, fontWeight: 600, fontSize: 62, letterSpacing: "-0.03em", color: S.text }}>
            Claim your handle<span style={{ color: BRAND.neon }}>.</span>
          </h1>
          <p style={{ margin: "18px 0 0", fontFamily: DISP, fontSize: 30, lineHeight: 1.4, color: S.dim }}>
            This is how friends find you on ember.
          </p>
        </div>

        {/* field */}
        <div style={{ marginTop: 56 }}>
          <div style={{
            display: "flex", alignItems: "center", gap: 6,
            background: S.field, border: `2px solid ${d.border}`, borderRadius: 26, padding: "34px 32px",
            boxShadow: state === "available" ? `0 0 30px ${GOOD.base}22` : "none",
          }}>
            <span style={{ fontFamily: MONO, fontSize: 50, fontWeight: 500, color: S.dimmer }}>@</span>
            <span style={{ flex: 1, minWidth: 0 }}><HandleValue value={d.value} /></span>
            <StatusIcon state={state} />
          </div>

          {/* status message */}
          <div style={{ marginTop: 22, fontFamily: DISP, fontSize: 28, fontWeight: 500, color: d.color, minHeight: 34 }}>{d.msg}</div>

          {/* format hint */}
          <div style={{ ...mlabel(22, S.dimmer), marginTop: 20 }}>letters, numbers, _ · 3–20</div>
        </div>

        {/* immutable note */}
        <div style={{ marginTop: 40, display: "flex", alignItems: "center", gap: 18, background: `rgba(${BRAND.rgb},0.07)`, border: `1px solid rgba(${BRAND.rgb},0.22)`, borderRadius: 22, padding: "26px 28px" }}>
          <svg width="30" height="30" viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }}>
            <rect x="4" y="10.5" width="16" height="11" rx="2.5" stroke={BRAND.bright} strokeWidth="2"/>
            <path d="M8 10.5V8a4 4 0 0 1 8 0v2.5" stroke={BRAND.bright} strokeWidth="2"/>
          </svg>
          <span style={{ fontFamily: DISP, fontSize: 26, lineHeight: 1.35, color: S.dim }}>
            <span style={{ color: BRAND.bright, fontWeight: 600 }}>Handles are permanent.</span> You can’t change this later.
          </span>
        </div>

        <div style={{ flex: 1 }} />
        <PrimaryButton disabled={!d.valid}>Continue →</PrimaryButton>
      </Screen>
    </Phone>
  );
}

// ── 3 · PROFILE ─────────────────────────────────────────────────────────────
function Avatar({ size = 184, initials = "MB" }) {
  return (
    <div style={{ position: "relative", width: size, height: size }}>
      <div style={{ position: "absolute", inset: -26, background: `radial-gradient(circle, ${BRAND.neon}44, transparent 70%)` }} />
      <div style={{
        position: "relative", width: size, height: size, borderRadius: "50%",
        background: `linear-gradient(155deg, ${BRAND.bright}, ${BRAND.deep})`,
        display: "flex", alignItems: "center", justifyContent: "center",
        boxShadow: `0 16px 44px ${BRAND.neon}44, inset 0 2px 0 rgba(255,255,255,0.25)`,
      }}>
        <span style={{ fontFamily: DISP, fontWeight: 600, fontSize: size * 0.4, color: "#fff", letterSpacing: "-0.02em" }}>{initials}</span>
      </div>
    </div>
  );
}

function Chevron() {
  return <svg width="20" height="32" viewBox="0 0 18 30" fill="none"><path d="M4 3l11 12-11 12" stroke={S.dimmer} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/></svg>;
}

function RowTile({ children, tint }) {
  return (
    <div style={{ width: 78, height: 78, borderRadius: 20, flexShrink: 0, background: tint || S.cardHi, border: `1px solid ${S.border}`, display: "flex", alignItems: "center", justifyContent: "center" }}>{children}</div>
  );
}

function ListRow({ icon, tint, label, sub, right }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 24, background: S.card, border: `1px solid ${S.border}`, borderRadius: 28, padding: "28px 30px" }}>
      <RowTile tint={tint}>{icon}</RowTile>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: DISP, fontSize: 35, fontWeight: 600, letterSpacing: "-0.01em", color: S.text }}>{label}</div>
        {sub && <div style={{ fontFamily: DISP, fontSize: 25, color: S.dim, marginTop: 5 }}>{sub}</div>}
      </div>
      {right}
    </div>
  );
}

const InsightsIcon = () => (
  <svg width="34" height="34" viewBox="0 0 26 26" fill="none">
    <rect x="3" y="13" width="5" height="9" rx="1.5" fill={BRAND.bright}/>
    <rect x="10.5" y="8" width="5" height="14" rx="1.5" fill={BRAND.bright} opacity="0.85"/>
    <rect x="18" y="4" width="5" height="18" rx="1.5" fill={BRAND.bright} opacity="0.7"/>
  </svg>
);
const ThemeIcon = () => (
  <svg width="34" height="34" viewBox="0 0 26 26" fill="none">
    <path d="M13 3a10 10 0 1 0 0 20 7.5 7.5 0 0 1 0-20z" fill={S.text} opacity="0.9"/>
    <circle cx="13" cy="13" r="10" stroke={S.dim} strokeWidth="1.6"/>
  </svg>
);

function ThemeRow() {
  const opts = ["Auto", "Light", "Dark"];
  const sel = "Dark";
  return (
    <div style={{ background: S.card, border: `1px solid ${S.border}`, borderRadius: 28, padding: "28px 30px" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 24 }}>
        <RowTile><ThemeIcon /></RowTile>
        <div style={{ flex: 1 }}>
          <div style={{ fontFamily: DISP, fontSize: 35, fontWeight: 600, color: S.text }}>Appearance</div>
          <div style={{ fontFamily: DISP, fontSize: 25, color: S.dim, marginTop: 5 }}>Match the mood you’re in</div>
        </div>
      </div>
      <div style={{ display: "flex", gap: 10, marginTop: 26, background: S.field, borderRadius: 20, padding: 10 }}>
        {opts.map((o) => {
          const on = o === sel;
          return (
            <div key={o} style={{
              flex: 1, textAlign: "center", padding: "20px 0", borderRadius: 14,
              fontFamily: DISP, fontWeight: 600, fontSize: 29,
              background: on ? `linear-gradient(155deg, ${BRAND.bright}, ${BRAND.deep})` : "transparent",
              color: on ? BRAND.ink : S.dim,
              boxShadow: on ? `0 6px 18px ${BRAND.neon}33` : "none",
            }}>{o}</div>
          );
        })}
      </div>
    </div>
  );
}

function ProfileBody() {
  return (
    <>
      <TopNav title="Profile" left="close" right={null} />
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", marginTop: 36 }}>
        <Avatar />
        <div style={{ fontFamily: DISP, fontSize: 54, fontWeight: 600, letterSpacing: "-0.03em", marginTop: 30, color: S.text, whiteSpace: "nowrap" }}>Mara Bishop</div>
        <div style={{ fontFamily: MONO, fontSize: 30, color: S.dim, marginTop: 12, letterSpacing: "0.04em", whiteSpace: "nowrap" }}>@mara_b</div>
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 20, marginTop: 56 }}>
        <ListRow icon={<InsightsIcon />} tint={`rgba(${BRAND.rgb},0.10)`} label="Insights" sub="See where you showed up" right={<Chevron />} />
        <ThemeRow />
      </div>

      <div style={{ marginTop: "auto", display: "flex", flexDirection: "column", gap: 20, paddingTop: 40 }}>
        <button style={{ width: "100%", border: `1px solid ${S.border}`, background: S.cardHi, color: S.text, borderRadius: 26, padding: "30px", fontFamily: DISP, fontWeight: 600, fontSize: 32, display: "flex", alignItems: "center", justifyContent: "center", gap: 16, cursor: "pointer" }}>
          <svg width="30" height="30" viewBox="0 0 24 24" fill="none"><path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h8" stroke={S.dim} strokeWidth="2" strokeLinecap="round"/><path d="M17 8l4 4-4 4M21 12H9" stroke={S.dim} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
          Sign out
        </button>
        <button style={{ width: "100%", border: `1px solid ${DANGER.line}`, background: DANGER.bgTint, color: DANGER.soft, borderRadius: 26, padding: "30px", fontFamily: DISP, fontWeight: 600, fontSize: 32, display: "flex", alignItems: "center", justifyContent: "center", gap: 16, cursor: "pointer" }}>
          <svg width="30" height="30" viewBox="0 0 24 24" fill="none"><path d="M4 7h16M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2M6 7l1 13a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-13" stroke={DANGER.base} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
          Delete account
        </button>
      </div>
    </>
  );
}

function Profile() {
  return <Phone><Screen pad="150px 56px 56px"><ProfileBody /></Screen></Phone>;
}

// ── delete confirmation sheet ───────────────────────────────────────────────
function ProfileDelete() {
  return (
    <Phone>
      <Screen pad="150px 56px 56px"><div style={{ filter: "saturate(0.7)" }}><ProfileBody /></div></Screen>
      {/* scrim */}
      <div style={{ position: "absolute", inset: 0, background: "rgba(2,4,6,0.74)", backdropFilter: "blur(2px)", zIndex: 20 }} />
      {/* sheet */}
      <div style={{
        position: "absolute", left: 0, right: 0, bottom: 0, zIndex: 21,
        background: S.card, borderTop: `1px solid ${S.border}`,
        borderTopLeftRadius: 52, borderTopRightRadius: 52, padding: "30px 56px 72px",
        boxShadow: "0 -30px 80px rgba(0,0,0,0.6)",
      }}>
        <div style={{ width: 88, height: 7, borderRadius: 4, background: S.dimmer, opacity: 0.6, margin: "0 auto 40px" }} />
        <div style={{ display: "flex", justifyContent: "center" }}>
          <div style={{ width: 116, height: 116, borderRadius: "50%", background: DANGER.bgTint, border: `1px solid ${DANGER.line}`, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <WarnTriangle size={56} />
          </div>
        </div>
        <h2 style={{ margin: "32px 0 0", textAlign: "center", fontFamily: DISP, fontWeight: 600, fontSize: 52, letterSpacing: "-0.03em", color: S.text }}>Delete account?</h2>
        <p style={{ margin: "20px 0 0", textAlign: "center", fontFamily: DISP, fontSize: 29, lineHeight: 1.45, color: S.dim }}>
          This permanently erases your account, every activity, and your entire history. <span style={{ color: DANGER.soft }}>This can’t be undone.</span>
        </p>

        <div style={{ marginTop: 40 }}>
          <div style={{ ...mlabel(22, S.dimmer), marginBottom: 16 }}>Type @mara_b to confirm</div>
          <div style={{ display: "flex", alignItems: "center", gap: 6, background: S.field, border: `2px solid ${DANGER.line}`, borderRadius: 22, padding: "28px 30px" }}>
            <span style={{ fontFamily: MONO, fontSize: 40, fontWeight: 500, color: S.dimmer }}>@</span>
            <span style={{ fontFamily: MONO, fontSize: 40, fontWeight: 500, color: S.text }}>mara_b</span>
            <span className="ember-caret" style={{ display: "inline-block", width: 3, height: 42, marginLeft: 4, background: DANGER.base }} />
          </div>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 18, marginTop: 40 }}>
          <button style={{ width: "100%", border: "none", borderRadius: 26, padding: "32px", background: `linear-gradient(155deg, ${DANGER.base}, ${DANGER.deep})`, color: "#fff", fontFamily: DISP, fontWeight: 600, fontSize: 33, cursor: "pointer", boxShadow: `0 12px 34px ${DANGER.base}3a` }}>Delete account</button>
          <button style={{ width: "100%", border: `1px solid ${S.border}`, borderRadius: 26, padding: "32px", background: S.cardHi, color: S.text, fontFamily: DISP, fontWeight: 600, fontSize: 33, cursor: "pointer" }}>Cancel</button>
        </div>
      </div>
    </Phone>
  );
}

Object.assign(window, { SignIn, HandleSetup, Profile, ProfileDelete });
