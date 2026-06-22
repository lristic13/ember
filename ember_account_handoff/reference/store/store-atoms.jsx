// store-screens.jsx — ember App Store marketing panels (new design)
// Recreates the 6 existing store screenshots with the redesigned look & feel.
// Exports: StorePanel + all screen components to window.

const BRAND = { neon: "#FF6B1A", bright: "#FF8A45", deep: "#E85600", ink: "#1E0A00", rgb: "255,107,26" };

// Activity identity colors — matched to the real app.
const A = {
  water:    { base: "#4F9BF0", deep: "#2D72D9", ink: "#04121E", rgb: "79,155,240" },
  reading:  { base: "#E8B931", deep: "#C9990F", ink: "#241A00", rgb: "232,185,49" },
  workout:  { base: "#5FC56B", deep: "#36A646", ink: "#04210C", rgb: "95,197,107" },
  studying: { base: "#FF6B6B", deep: "#E84545", ink: "#2A0808", rgb: "255,107,107" },
  sleep:    { base: "#8B6FF5", deep: "#6B47E0", ink: "#120A2E", rgb: "139,111,245" },
  walk:     { base: "#C07A3A", deep: "#9A5A1F", ink: "#1E1000", rgb: "192,122,58" },
};

const S = {
  bg: "#070809",
  card: "#101316",
  cardHi: "#171B1F",
  border: "rgba(150,165,180,0.10)",
  borderSoft: "rgba(150,165,180,0.05)",
  field: "#15191D",
  text: "#EEF1F4",
  dim: "#8A95A0",
  dimmer: "#4C555E",
};

const DISP = "'Space Grotesk', sans-serif";
const MONO = "'JetBrains Mono', monospace";

const mlabel = (size = 22, color = S.dim, weight = 500) => ({
  fontFamily: MONO, fontSize: size, fontWeight: weight,
  letterSpacing: "0.14em", textTransform: "uppercase", color,
});

// ── flame glyph (the ember mark, white on colored tile) ─────────────────────
function Flame({ size = 44, color = "#fff" }) {
  return (
    <svg width={size} height={size} viewBox="0 0 32 32" fill="none">
      <path
        d="M16 3.5c1.6 4.2 6.2 6 6.2 11.4 0 1.7-.5 3.2-1.4 4.4.2-.7.3-1.5.3-2.2 0-3-2.3-4.6-3.3-7.2-.5 2.4-2 3.6-3.1 5C13.4 17.5 13 19 13 20.3c0 .9.2 1.7.6 2.4-1.9-1-3.2-3-3.2-5.4 0-2.6 1.5-4.3 2.7-6 1.2-1.7 2.3-3.4 2.3-5.6 0-.7-.1-1.5-.3-2.2.4 0 .8 0 1.1.1-.1-.04-.2-.06-.3-.1z"
        fill={color}
      />
      <path
        d="M16 28.5c3.9 0 7-2.9 7-6.6 0-2-1-3.9-2.3-5.6-.3 1-1 1.7-1.9 1.8 1-2.6-.3-5.6-2.8-7-.3 2.4-1.7 4-3.2 5.6-1.2 1.4-2.3 2.7-2.3 4.6 0 .5.1 1 .3 1.5-.9-.5-1.5-1.5-1.5-2.6-1 1.4-1.6 3-1.6 4.5 0 3.7 3.1 6.4 8.3 6.4z"
        fill={color}
        opacity="0.92"
      />
    </svg>
  );
}

function IconTile({ color, size = 92, radius = 0.3 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: size * radius, flexShrink: 0,
      background: `linear-gradient(155deg, ${color.base}, ${color.deep})`,
      display: "flex", alignItems: "center", justifyContent: "center",
      boxShadow: `0 8px 22px ${color.base}38`,
    }}>
      <Flame size={size * 0.5} />
    </div>
  );
}

function Check({ done, color, size = 64 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.3, flexShrink: 0,
      display: "flex", alignItems: "center", justifyContent: "center",
      background: done ? `linear-gradient(155deg, ${color.base}, ${color.deep})` : S.cardHi,
      border: done ? "none" : `1.5px solid ${S.border}`,
      boxShadow: done ? `0 0 22px ${color.base}66` : "none",
    }}>
      {done ? (
        <svg width={size * 0.46} height={size * 0.46} viewBox="0 0 16 16" fill="none">
          <path d="M3 8.5l3.2 3.2L13 4.5" stroke={color.ink} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      ) : (
        <span style={{ fontSize: size * 0.5, fontWeight: 300, color: color.base, lineHeight: 1, marginTop: -2 }}>+</span>
      )}
    </div>
  );
}

const WK = ["M", "T", "W", "T", "F", "S", "S"];

function WeekRow({ done, color, todayIdx = 4 }) {
  return (
    <div style={{ display: "grid", gridTemplateColumns: "repeat(7,1fr)", gap: 12, marginTop: 26 }}>
      {WK.map((l, i) => {
        const future = i > todayIdx;
        const today = i === todayIdx;
        const on = !future && done[i] === 1;
        return (
          <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 12 }}>
            <span style={mlabel(18, today ? BRAND.neon : S.dimmer)}>{l}</span>
            <div style={{
              width: "100%", aspectRatio: "1", borderRadius: 18,
              background: on ? `linear-gradient(155deg, ${color.base}, ${color.deep})` : S.cardHi,
              border: today ? `2px solid ${BRAND.neon}` : on ? "none" : `1px solid ${S.borderSoft}`,
              opacity: future ? 0.4 : 1,
              boxShadow: on ? `0 3px 12px ${color.base}40` : "none",
            }} />
          </div>
        );
      })}
    </div>
  );
}

// month heatmap cells (filled = colored glow)
function MonthCells({ set, year, month, cell, gap, today, showNums = false }) {
  const lead = (new Date(year, month, 1).getDay() + 6) % 7;
  const days = new Date(year, month + 1, 0).getDate();
  const out = [];
  for (let i = 0; i < lead; i++) out.push(<div key={"b" + i} style={{ width: cell, height: cell }} />);
  for (let d = 1; d <= days; d++) {
    const on = set.has(d);
    const isToday = d === today;
    out.push(
      <div key={d} style={{
        width: cell, height: cell, borderRadius: cell * 0.28,
        display: "flex", alignItems: "center", justifyContent: "center",
        fontFamily: DISP, fontSize: cell * 0.36, fontWeight: on ? 600 : 500, letterSpacing: "-0.02em",
        color: on ? set.color.ink : S.dimmer,
        background: on ? `linear-gradient(155deg, ${set.color.base}, ${set.color.deep})` : S.cardHi,
        border: isToday ? `2px solid ${BRAND.neon}` : on ? "none" : `1px solid ${S.borderSoft}`,
        boxShadow: on ? `0 2px 10px ${set.color.base}40, inset 0 1px 0 rgba(255,255,255,0.25)` : "none",
      }}>{showNums ? d : ""}</div>
    );
  }
  return out;
}

// ── PHONE FRAME ─────────────────────────────────────────────────────────────
const SCREEN_W = 980, SCREEN_H = 2120, BEZ = 26, RAD = 116;
function StatusBar() {
  return (
    <div style={{
      position: "absolute", top: 0, left: 0, right: 0, height: 116, zIndex: 5,
      display: "flex", alignItems: "center", justifyContent: "space-between",
      padding: "0 64px", paddingTop: 18,
    }}>
      <span style={{ fontFamily: DISP, fontWeight: 600, fontSize: 34, color: S.text, letterSpacing: "0.01em" }}>12:43</span>
      <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
        <svg width="38" height="26" viewBox="0 0 38 26"><g fill={S.text}>
          <rect x="0" y="16" width="6" height="9" rx="1.5" /><rect x="9" y="11" width="6" height="14" rx="1.5" /><rect x="18" y="6" width="6" height="19" rx="1.5" /><rect x="27" y="1" width="6" height="24" rx="1.5" />
        </g></svg>
        <svg width="34" height="26" viewBox="0 0 34 26" fill="none"><path d="M17 6c4.5 0 8.6 1.8 11.6 4.7M17 6C12.5 6 8.4 7.8 5.4 10.7M17 13.5c2.5 0 4.8 1 6.4 2.7M17 13.5c-2.5 0-4.8 1-6.4 2.7" stroke={S.text} strokeWidth="2.4" strokeLinecap="round" /><circle cx="17" cy="21" r="2.4" fill={S.text} /></svg>
        <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
          <div style={{ width: 40, height: 22, borderRadius: 6, border: `2px solid ${S.dim}`, padding: 3, display: "flex" }}>
            <div style={{ flex: 1, background: S.text, borderRadius: 2 }} />
          </div>
          <div style={{ width: 3, height: 9, background: S.dim, borderRadius: 2 }} />
        </div>
      </div>
    </div>
  );
}

function Phone({ children }) {
  return (
    <div style={{
      width: SCREEN_W + BEZ * 2, height: SCREEN_H + BEZ * 2, borderRadius: RAD + BEZ,
      padding: BEZ, background: "linear-gradient(150deg,#3a3d42,#191b1e 40%,#26282c)",
      boxShadow: "0 50px 120px rgba(0,0,0,0.6), inset 0 0 3px rgba(255,255,255,0.3)",
      position: "relative", flexShrink: 0,
    }}>
      <div style={{
        width: SCREEN_W, height: SCREEN_H, borderRadius: RAD, overflow: "hidden",
        background: S.bg, position: "relative",
      }}>
        <StatusBar />
        {/* dynamic island */}
        <div style={{
          position: "absolute", top: 26, left: "50%", transform: "translateX(-50%)",
          width: 248, height: 68, background: "#000", borderRadius: 34, zIndex: 10,
        }} />
        {children}
      </div>
    </div>
  );
}

// ── shared screen shell ─────────────────────────────────────────────────────
function Screen({ children, pad = "150px 56px 0" }) {
  return <div style={{ position: "absolute", inset: 0, padding: pad, fontFamily: DISP, color: S.text, display: "flex", flexDirection: "column" }}>{children}</div>;
}
function TopNav({ title, left = "back", right }) {
  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 8 }}>
      <div style={{ width: 70, height: 70, borderRadius: 18, background: S.cardHi, border: `1px solid ${S.border}`, display: "flex", alignItems: "center", justifyContent: "center" }}>
        {left === "back"
          ? <svg width="18" height="30" viewBox="0 0 18 30" fill="none"><path d="M15 3L4 15l11 12" stroke={S.dim} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" /></svg>
          : <svg width="26" height="26" viewBox="0 0 26 26" fill="none"><path d="M4 4l18 18M22 4L4 22" stroke={S.dim} strokeWidth="2.6" strokeLinecap="round" /></svg>}
      </div>
      <span style={{ fontFamily: DISP, fontSize: 38, fontWeight: 600, letterSpacing: "-0.02em", whiteSpace: "nowrap" }}>{title}</span>
      <div style={{ width: 70 }}>{right}</div>
    </div>
  );
}
function Wordmark({ size = 40 }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: size * 0.3 }}>
      <span style={{ fontFamily: DISP, fontWeight: 600, fontSize: size, letterSpacing: "-0.04em", color: S.text }}>ember</span>
      <span style={{ width: size * 0.34, height: size * 0.34, borderRadius: "50%", marginTop: size * 0.1,
        background: `radial-gradient(circle at 35% 30%, ${BRAND.bright}, ${BRAND.deep})`, boxShadow: `0 0 ${size * 0.5}px ${BRAND.neon}` }} />
    </div>
  );
}
function HomeHeader({ pie }) {
  const btn = (children) => <div style={{ width: 64, height: 64, borderRadius: 16, background: S.cardHi, border: `1px solid ${S.border}`, display: "flex", alignItems: "center", justifyContent: "center" }}>{children}</div>;
  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 36 }}>
      <Wordmark size={40} />
      <div style={{ display: "flex", gap: 14 }}>
        {btn(<svg width="26" height="26" viewBox="0 0 26 26" fill="none"><circle cx="13" cy="13" r="10" stroke={S.dim} strokeWidth="2" /><path d="M13 3v10h10" stroke={BRAND.neon} strokeWidth="2" /></svg>)}
        {btn(<svg width="26" height="26" viewBox="0 0 26 26" fill="none"><rect x="3" y="5" width="20" height="18" rx="3" stroke={S.dim} strokeWidth="2" /><path d="M3 10h20M8 2v5M18 2v5" stroke={S.dim} strokeWidth="2" strokeLinecap="round" /></svg>)}
      </div>
    </div>
  );
}

Object.assign(window, { BRAND, A, S, DISP, MONO, mlabel, Flame, IconTile, Check, WeekRow, MonthCells, Phone, Screen, TopNav, Wordmark, HomeHeader });
