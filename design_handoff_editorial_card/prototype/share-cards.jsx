// share-cards.jsx — ember workout share cards (dark + neon green, 9:16 story)
// Exports: EmberCardGrid, EmberCardEditorial, EmberCardGlow to window.

const EMBER = {
  bg: "#060B08",
  cell: "#141B16",
  cellBorder: "rgba(120,180,140,0.07)",
  neon: "#57F08C",
  neonBright: "#86FFB1",
  neonDeep: "#2FCB6E",
  ink: "#062012",
  text: "#EAF4EE",
  dim: "#557A63",
  dimmer: "#3C5247",
};

// January 2026: Jan 1 = Thursday. Monday-start grid → 3 leading blanks.
const LOGGED = new Set([2, 3, 8, 9, 10, 12, 13]);
const STREAK = new Set([8, 9, 10]);
const LEAD = 3;
const DAYS = 31;
const WEEKDAYS = ["M", "T", "W", "T", "F", "S", "S"];

// ---- Wordmark -------------------------------------------------------------
function Wordmark({ size = 40, light = false }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: size * 0.34 }}>
      <span
        style={{
          fontFamily: "'Space Grotesk', sans-serif",
          fontWeight: 600,
          fontSize: size,
          letterSpacing: "-0.04em",
          color: light ? EMBER.text : EMBER.text,
        }}
      >
        ember
      </span>
      <span
        style={{
          width: size * 0.4,
          height: size * 0.4,
          borderRadius: "50%",
          background: `radial-gradient(circle at 35% 30%, ${EMBER.neonBright}, ${EMBER.neonDeep})`,
          boxShadow: `0 0 ${size * 0.5}px ${EMBER.neon}, 0 0 ${size * 0.16}px ${EMBER.neonBright}`,
          marginTop: size * 0.12,
        }}
      />
    </div>
  );
}

// ---- Calendar -------------------------------------------------------------
function Calendar({ cell = 116, gap = 14, showWeekdays = true, glow = "soft" }) {
  const cells = [];
  for (let i = 0; i < LEAD; i++) cells.push(<div key={"b" + i} style={{ width: cell, height: cell }} />);
  for (let d = 1; d <= DAYS; d++) {
    const on = LOGGED.has(d);
    const streak = STREAK.has(d);
    cells.push(
      <div
        key={d}
        style={{
          width: cell,
          height: cell,
          borderRadius: cell * 0.26,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontFamily: "'Space Grotesk', sans-serif",
          fontWeight: on ? 600 : 500,
          fontSize: cell * 0.34,
          letterSpacing: "-0.02em",
          color: on ? EMBER.ink : EMBER.dimmer,
          background: on
            ? `linear-gradient(155deg, ${EMBER.neonBright} 0%, ${EMBER.neon} 45%, ${EMBER.neonDeep} 100%)`
            : EMBER.cell,
          border: on ? "none" : `1px solid ${EMBER.cellBorder}`,
          boxShadow: on
            ? glow === "strong"
              ? `0 0 ${cell * 0.42}px rgba(87,240,140,${streak ? 0.7 : 0.5}), inset 0 1px 0 rgba(255,255,255,0.4)`
              : `0 4px ${cell * 0.16}px rgba(87,240,140,0.22), inset 0 1px 0 rgba(255,255,255,0.35)`
            : "inset 0 1px 0 rgba(255,255,255,0.015)",
        }}
      >
        {d}
      </div>
    );
  }
  return (
    <div style={{ display: "inline-flex", flexDirection: "column", gap }}>
      {showWeekdays && (
        <div style={{ display: "grid", gridTemplateColumns: `repeat(7, ${cell}px)`, gap }}>
          {WEEKDAYS.map((w, i) => (
            <div
              key={i}
              style={{
                textAlign: "center",
                fontFamily: "'JetBrains Mono', monospace",
                fontSize: cell * 0.2,
                fontWeight: 500,
                letterSpacing: "0.1em",
                color: EMBER.dim,
              }}
            >
              {w}
            </div>
          ))}
        </div>
      )}
      <div style={{ display: "grid", gridTemplateColumns: `repeat(7, ${cell}px)`, gap }}>{cells}</div>
    </div>
  );
}

// Shared frame
function Frame({ children, bg }) {
  return (
    <div
      style={{
        width: 1080,
        height: 1920,
        background: bg || EMBER.bg,
        color: EMBER.text,
        position: "relative",
        overflow: "hidden",
        fontFamily: "'Space Grotesk', sans-serif",
      }}
    >
      {children}
    </div>
  );
}

const monoLabel = {
  fontFamily: "'JetBrains Mono', monospace",
  fontSize: 26,
  fontWeight: 500,
  letterSpacing: "0.18em",
  textTransform: "uppercase",
  color: EMBER.dim,
};

// ===========================================================================
// DIRECTION 1 — GRID HERO
// ===========================================================================
function EmberCardGrid() {
  return (
    <Frame
      bg={`radial-gradient(120% 80% at 50% 18%, #0C1A12 0%, ${EMBER.bg} 55%)`}
    >
      <div
        style={{
          position: "absolute",
          inset: 0,
          padding: "96px 80px 88px",
          display: "flex",
          flexDirection: "column",
        }}
      >
        {/* header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <Wordmark size={42} />
          <span style={monoLabel}>Jan 2026</span>
        </div>

        {/* hero line */}
        <div style={{ marginTop: 96 }}>
          <div style={{ ...monoLabel, color: EMBER.neon, marginBottom: 22 }}>My month in motion</div>
          <h1
            style={{
              margin: 0,
              fontSize: 92,
              lineHeight: 0.98,
              fontWeight: 600,
              letterSpacing: "-0.045em",
            }}
          >
            7 days I<br />showed up.
          </h1>
        </div>

        {/* calendar — the hero */}
        <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
          <Calendar cell={116} gap={16} />
        </div>

        {/* stat row — minimal, no boxes */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-end" }}>
          {[
            ["Days logged", "7"],
            ["Longest streak", "3"],
            ["Best day", "Mon"],
          ].map(([k, v], i) => (
            <div key={i} style={{ textAlign: i === 0 ? "left" : i === 2 ? "right" : "center" }}>
              <div style={{ ...monoLabel, fontSize: 22, marginBottom: 10 }}>{k}</div>
              <div style={{ fontSize: 64, fontWeight: 600, letterSpacing: "-0.03em", color: EMBER.neon }}>{v}</div>
            </div>
          ))}
        </div>
      </div>
    </Frame>
  );
}

// ===========================================================================
// DIRECTION 2 — EDITORIAL STACKED
// ===========================================================================
function EmberCardEditorial() {
  return (
    <Frame>
      <div
        style={{
          position: "absolute",
          inset: 0,
          padding: "100px 84px 92px",
          display: "flex",
          flexDirection: "column",
        }}
      >
        <Wordmark size={44} />

        {/* big editorial headline */}
        <h1
          style={{
            margin: "120px 0 0",
            fontSize: 118,
            lineHeight: 0.92,
            fontWeight: 600,
            letterSpacing: "-0.05em",
          }}
        >
          <span style={{ color: EMBER.dim }}>I trained</span>
          <br />
          <span style={{ color: EMBER.neon }}>7 times</span>
          <br />
          <span>in January.</span>
        </h1>

        {/* calendar */}
        <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
          <Calendar cell={106} gap={14} />
        </div>

        {/* stat pills */}
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 18 }}>
          {[
            ["Streak", "3 days"],
            ["Best day", "Monday"],
            ["Logged", "7 / 31"],
          ].map(([k, v], i) => (
            <div
              key={i}
              style={{
                background: "rgba(87,240,140,0.06)",
                border: "1px solid rgba(87,240,140,0.14)",
                borderRadius: 24,
                padding: "26px 28px",
              }}
            >
              <div style={{ ...monoLabel, fontSize: 20, marginBottom: 12 }}>{k}</div>
              <div style={{ fontSize: 40, fontWeight: 600, letterSpacing: "-0.03em", color: EMBER.text }}>{v}</div>
            </div>
          ))}
        </div>
      </div>
    </Frame>
  );
}

// ===========================================================================
// DIRECTION 3 — GLOW / SPOTLIGHT
// ===========================================================================
function EmberCardGlow() {
  return (
    <Frame bg={EMBER.bg}>
      {/* spotlight bloom */}
      <div
        style={{
          position: "absolute",
          top: "42%",
          left: "50%",
          transform: "translate(-50%,-50%)",
          width: 1200,
          height: 1200,
          background: "radial-gradient(circle, rgba(87,240,140,0.16) 0%, rgba(87,240,140,0) 60%)",
          pointerEvents: "none",
        }}
      />
      {/* vignette */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          background: "radial-gradient(130% 100% at 50% 45%, rgba(0,0,0,0) 50%, rgba(0,0,0,0.7) 100%)",
          pointerEvents: "none",
        }}
      />

      <div
        style={{
          position: "absolute",
          inset: 0,
          padding: "100px 84px 96px",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
        }}
      >
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", width: "100%" }}>
          <Wordmark size={42} />
          <span style={monoLabel}>Jan 2026</span>
        </div>

        {/* giant hero number */}
        <div style={{ marginTop: 70, textAlign: "center" }}>
          <div
            style={{
              fontSize: 360,
              fontWeight: 600,
              lineHeight: 0.8,
              letterSpacing: "-0.06em",
              color: EMBER.neonBright,
              textShadow: `0 0 80px rgba(87,240,140,0.55), 0 0 30px rgba(134,255,177,0.5)`,
            }}
          >
            7
          </div>
          <div style={{ ...monoLabel, fontSize: 28, marginTop: 6, color: EMBER.neon }}>active days</div>
        </div>

        {/* calendar with strong glow */}
        <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
          <Calendar cell={104} gap={14} showWeekdays={false} glow="strong" />
        </div>

        {/* footer stats */}
        <div style={{ display: "flex", gap: 64, alignItems: "center" }}>
          {[
            ["3-day", "streak"],
            ["Monday", "best day"],
          ].map(([v, k], i) => (
            <div key={i} style={{ textAlign: "center" }}>
              <div style={{ fontSize: 48, fontWeight: 600, letterSpacing: "-0.03em", color: EMBER.text }}>{v}</div>
              <div style={{ ...monoLabel, fontSize: 22, marginTop: 8 }}>{k}</div>
            </div>
          ))}
        </div>
      </div>
    </Frame>
  );
}

Object.assign(window, { EmberCardGrid, EmberCardEditorial, EmberCardGlow });
