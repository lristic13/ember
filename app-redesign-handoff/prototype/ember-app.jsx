// ember-app.jsx — redesigned ember app screens (Home, Details, Insights)
// Carries the share-card system: neon-green brand accent, Space Grotesk +
// JetBrains Mono, dark surfaces. Each habit owns a color ONLY on its tile + data.
// Exports: EmberHome, EmberDetails, EmberInsights to window.

const E = {
  bg: "#070D09",
  card: "#101712",
  cardHi: "#16201A",
  border: "rgba(120,180,140,0.10)",
  borderSoft: "rgba(120,180,140,0.05)",
  neon: "#57F08C",
  neonBright: "#86FFB1",
  neonDeep: "#2FCB6E",
  ink: "#06170D",
  text: "#EAF4EE",
  dim: "#8AA396",
  dimmer: "#55695D",
};

const DISP = "'Space Grotesk', sans-serif";
const MONO = "'JetBrains Mono', monospace";

// Swappable BRAND accent. Default = neon green (matches the share cards).
const GREEN = { neon: "#57F08C", bright: "#86FFB1", deep: "#2FCB6E", ink: "#06170D", rgb: "87,240,140" };
const ORANGE = { neon: "#FF6B1A", bright: "#FF8A45", deep: "#E85600", ink: "#1E0A00", rgb: "255,107,26" };

const mlabel = (size = 12, color = E.dim, weight = 500) => ({
  fontFamily: MONO,
  fontSize: size,
  fontWeight: weight,
  letterSpacing: "0.14em",
  textTransform: "uppercase",
  color,
});

// Curated habit identity colors — distinct from the brand neon green.
const COLORS = {
  coral: { base: "#FF6B8A", deep: "#E84C6F", ink: "#2A0710" },
  amber: { base: "#FFB23E", deep: "#F0951B", ink: "#291800" },
  sky: { base: "#4FC1FF", deep: "#1E9FE6", ink: "#04202E" },
  violet: { base: "#B98BFF", deep: "#9A63F0", ink: "#1A0A2E" },
};

// ── shared atoms ────────────────────────────────────────────────────────────
function IconTile({ emoji, color, size = 46 }) {
  return (
    <div
      style={{
        width: size,
        height: size,
        borderRadius: size * 0.3,
        background: `linear-gradient(155deg, ${color.base}, ${color.deep})`,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontSize: size * 0.5,
        flexShrink: 0,
        boxShadow: `0 6px 16px ${color.base}33`,
      }}
    >
      {emoji}
    </div>
  );
}

function CheckCircle({ done, size = 34, color }) {
  return (
    <div
      style={{
        width: size,
        height: size,
        borderRadius: "50%",
        flexShrink: 0,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: done ? `linear-gradient(155deg, ${color.base}, ${color.deep})` : "transparent",
        border: done ? "none" : `2px solid ${E.dimmer}`,
        boxShadow: done ? `0 0 16px ${color.base}73` : "none",
      }}
    >
      {done && (
        <svg width={size * 0.5} height={size * 0.5} viewBox="0 0 16 16" fill="none">
          <path d="M3 8.5l3.2 3.2L13 4.5" stroke={color.ink} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      )}
    </div>
  );
}

function IconBtn({ children }) {
  return (
    <div
      style={{
        width: 40,
        height: 40,
        borderRadius: 12,
        background: E.cardHi,
        border: `1px solid ${E.border}`,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      {children}
    </div>
  );
}

function Wordmark({ size = 22, ac = GREEN }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: size * 0.32 }}>
      <span style={{ fontFamily: DISP, fontWeight: 600, fontSize: size, letterSpacing: "-0.04em", color: E.text }}>
        ember
      </span>
      <span
        style={{
          width: size * 0.36,
          height: size * 0.36,
          borderRadius: "50%",
          background: `radial-gradient(circle at 35% 30%, ${ac.bright}, ${ac.deep})`,
          boxShadow: `0 0 ${size * 0.5}px ${ac.neon}`,
          marginTop: size * 0.1,
        }}
      />
    </div>
  );
}

// week dates for the demo — today = Thu the 5th (index 3)
const WK_LETTERS = ["M", "T", "W", "T", "F", "S", "S"];
const WK_DATES = [2, 3, 4, 5, 6, 7, 8];
const TODAY_IDX = 3;

function WeekStrip({ done, color, ac = GREEN }) {
  // done: array length 7 of 1/0 for indices <= TODAY_IDX; later = future
  const cell = 38;
  return (
    <div style={{ display: "grid", gridTemplateColumns: "repeat(7, 1fr)", gap: 6, marginTop: 16 }}>
      {WK_LETTERS.map((l, i) => {
        const future = i > TODAY_IDX;
        const today = i === TODAY_IDX;
        const isDone = !future && done[i] === 1;
        return (
          <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 7 }}>
            <span style={mlabel(10, today ? ac.neon : E.dimmer, 500)}>{l}</span>
            <div
              style={{
                width: "100%",
                aspectRatio: "1",
                borderRadius: 11,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontFamily: MONO,
                fontSize: 13,
                fontWeight: 500,
                color: isDone ? color.ink : future ? E.dimmer : E.dim,
                background: isDone ? `linear-gradient(155deg, ${color.base}, ${color.deep})` : E.cardHi,
                border: today ? `2px solid ${ac.neon}` : isDone ? "none" : `1px solid ${E.borderSoft}`,
                opacity: future ? 0.4 : 1,
                boxShadow: isDone ? `0 3px 10px ${color.base}33` : "none",
              }}
            >
              {WK_DATES[i]}
            </div>
          </div>
        );
      })}
    </div>
  );
}

const HOME_ACTS = [
  { name: "Morning Run", emoji: "🏃", color: COLORS.coral, done: [1, 1, 1, 1, 0, 0, 0], streak: 12, doneToday: true },
  { name: "Read 20 min", emoji: "📖", color: COLORS.amber, done: [1, 0, 1, 1, 0, 0, 0], streak: 5, doneToday: true },
  { name: "Meditate", emoji: "🧘", color: COLORS.sky, done: [1, 1, 0, 0, 0, 0, 0], streak: 3, doneToday: false },
  { name: "No sugar", emoji: "🍃", color: COLORS.violet, done: [1, 1, 1, 1, 0, 0, 0], streak: 8, doneToday: true },
];

function ActivityCard({ a, ac = GREEN }) {
  return (
    <div
      style={{
        background: E.card,
        border: `1px solid ${E.border}`,
        borderRadius: 22,
        padding: "18px 18px 20px",
      }}
    >
      <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
        <IconTile emoji={a.emoji} color={a.color} />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: DISP, fontSize: 19, fontWeight: 600, color: E.text, letterSpacing: "-0.02em" }}>
            {a.name}
          </div>
          <div style={{ display: "flex", alignItems: "center", gap: 5, marginTop: 3 }}>
            <span style={{ fontSize: 12 }}>🔥</span>
            <span style={{ fontFamily: MONO, fontSize: 12, fontWeight: 600, color: a.color.base }}>{a.streak}</span>
            <span style={mlabel(11, E.dim)}>day streak</span>
          </div>
        </div>
        <CheckCircle done={a.doneToday} color={a.color} />
      </div>
      <WeekStrip done={a.done} color={a.color} ac={ac} />
    </div>
  );
}

function ScreenShell({ children }) {
  return (
    <div style={{ minHeight: "100%", background: E.bg, color: E.text, fontFamily: DISP }}>{children}</div>
  );
}

// ── HOME ──────────────────────────────────────────────────────────────────
function EmberHome({ ac = GREEN }) {
  const doneCount = HOME_ACTS.filter((a) => a.doneToday).length;
  return (
    <window.IOSDevice dark>
      <ScreenShell>
        <div style={{ display: "flex", flexDirection: "column", minHeight: 874 }}>
          {/* header */}
          <div style={{ padding: "54px 20px 0" }}>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
              <Wordmark size={23} ac={ac} />
              <div style={{ display: "flex", gap: 10 }}>
                <IconBtn>
                  <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
                    <path d="M9 2a7 7 0 107 7H9V2z" stroke={E.dim} strokeWidth="1.6" />
                    <path d="M9 2v7h7" stroke={ac.neon} strokeWidth="1.6" />
                  </svg>
                </IconBtn>
                <IconBtn>
                  <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
                    <rect x="2" y="3.5" width="14" height="12.5" rx="2.5" stroke={E.dim} strokeWidth="1.6" />
                    <path d="M2 7h14M6 2v3M12 2v3" stroke={E.dim} strokeWidth="1.6" strokeLinecap="round" />
                  </svg>
                </IconBtn>
              </div>
            </div>
            {/* today summary */}
            <div style={{ marginTop: 24 }}>
              <div style={mlabel(12, E.dim)}>Thu · Jun 5</div>
              <div style={{ marginTop: 6, display: "flex", alignItems: "center", justifyContent: "space-between" }}>
                <div style={{ fontFamily: DISP, fontSize: 34, fontWeight: 600, letterSpacing: "-0.03em" }}>
                  Today
                </div>
                <div
                  style={{
                    display: "flex",
                    alignItems: "baseline",
                    gap: 6,
                    whiteSpace: "nowrap",
                    background: `rgba(${ac.rgb},0.08)`,
                    border: `1px solid rgba(${ac.rgb},0.18)`,
                    borderRadius: 14,
                    padding: "8px 14px",
                  }}
                >
                  <span style={{ fontFamily: DISP, fontSize: 22, fontWeight: 600, color: ac.neon }}>{doneCount}</span>
                  <span style={mlabel(12, E.dim)}>of {HOME_ACTS.length} done</span>
                </div>
              </div>
            </div>
          </div>

          {/* list */}
          <div style={{ padding: "22px 20px 0", display: "flex", flexDirection: "column", gap: 14, flex: 1 }}>
            {HOME_ACTS.map((a) => (
              <ActivityCard key={a.name} a={a} ac={ac} />
            ))}
          </div>

          {/* sticky add button */}
          <div style={{ position: "sticky", bottom: 0, padding: "16px 20px 34px", background: `linear-gradient(to top, ${E.bg} 60%, transparent)` }}>
            <button
              style={{
                width: "100%",
                border: "none",
                borderRadius: 18,
                padding: "17px",
                background: `linear-gradient(155deg, ${ac.bright}, ${ac.deep})`,
                color: ac.ink,
                fontFamily: DISP,
                fontSize: 17,
                fontWeight: 600,
                letterSpacing: "-0.01em",
                boxShadow: `0 8px 24px rgba(${ac.rgb},0.3)`,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                gap: 8,
              }}
            >
              <span style={{ fontSize: 20, fontWeight: 500 }}>+</span> Add Activity
            </button>
          </div>
        </div>
      </ScreenShell>
    </window.IOSDevice>
  );
}

// ── DETAILS ─────────────────────────────────────────────────────────────────
const JUNE_DONE = new Set([2, 4, 5, 8, 9, 11, 12, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26]);
const JUNE_TODAY = 26;

function MonthCalendar({ color, ac = GREEN }) {
  // June 2026: Mon-start, 0 leading blanks, 30 days
  const cells = [];
  for (let d = 1; d <= 30; d++) cells.push(d);
  return (
    <div>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(7, 1fr)", gap: 7, marginBottom: 8 }}>
        {WK_LETTERS.map((l, i) => (
          <div key={i} style={{ textAlign: "center", ...mlabel(11, E.dimmer) }}>
            {l}
          </div>
        ))}
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(7, 1fr)", gap: 7 }}>
        {cells.map((d) => {
          const done = JUNE_DONE.has(d);
          const today = d === JUNE_TODAY;
          const future = d > JUNE_TODAY;
          return (
            <div
              key={d}
              style={{
                aspectRatio: "1",
                borderRadius: 11,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontFamily: MONO,
                fontSize: 13,
                fontWeight: 500,
                color: done ? color.ink : future ? E.dimmer : E.dim,
                background: done ? `linear-gradient(155deg, ${color.base}, ${color.deep})` : E.cardHi,
                border: today ? `2px solid ${ac.neon}` : done ? "none" : `1px solid ${E.borderSoft}`,
                opacity: future ? 0.4 : 1,
                boxShadow: done ? `0 3px 10px ${color.base}2e` : "none",
              }}
            >
              {d}
            </div>
          );
        })}
      </div>
    </div>
  );
}

function MiniStat({ value, label }) {
  return (
    <div style={{ flex: 1, textAlign: "center" }}>
      <div style={{ fontFamily: DISP, fontSize: 28, fontWeight: 600, color: E.text, letterSpacing: "-0.03em" }}>{value}</div>
      <div style={{ ...mlabel(10, E.dim), marginTop: 5 }}>{label}</div>
    </div>
  );
}

function EmberDetails({ ac = GREEN }) {
  const color = COLORS.coral;
  return (
    <window.IOSDevice dark>
      <ScreenShell>
        <div style={{ padding: "54px 20px 40px" }}>
          {/* nav */}
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <IconBtn>
              <svg width="11" height="18" viewBox="0 0 11 18" fill="none">
                <path d="M9 2L3 9l6 7" stroke={E.dim} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </IconBtn>
            <div style={{ display: "flex", gap: 10 }}>
              <IconBtn>
                <svg width="17" height="17" viewBox="0 0 17 17" fill="none">
                  <path d="M12 5.5a2 2 0 10-1.8-2.9M5 8.5a2 2 0 100 0M12 11.5a2 2 0 10-1.8 2.9M10.2 3.6L6.8 6.9M6.8 10.1l3.4 3.3" stroke={E.dim} strokeWidth="1.5" strokeLinecap="round" />
                </svg>
              </IconBtn>
              <IconBtn>
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path d="M11 2.5l2.5 2.5L6 12.5 3 13l.5-3L11 2.5z" stroke={E.dim} strokeWidth="1.5" strokeLinejoin="round" />
                </svg>
              </IconBtn>
            </div>
          </div>

          {/* hero identity */}
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center", marginTop: 22 }}>
            <IconTile emoji="🏃" color={color} size={64} />
            <div style={{ fontFamily: DISP, fontSize: 27, fontWeight: 600, letterSpacing: "-0.03em", marginTop: 14, whiteSpace: "nowrap" }}>
              Morning Run
            </div>
            <div
              style={{
                ...mlabel(11, E.dim),
                marginTop: 10,
                whiteSpace: "nowrap",
                background: E.cardHi,
                border: `1px solid ${E.border}`,
                borderRadius: 99,
                padding: "5px 12px",
              }}
            >
              Yes / No · Daily
            </div>
          </div>

          {/* current streak hero */}
          <div
            style={{
              marginTop: 26,
              background: E.card,
              border: `1px solid ${E.border}`,
              borderRadius: 24,
              padding: "26px 20px",
              textAlign: "center",
              position: "relative",
              overflow: "hidden",
            }}
          >
            <div
              style={{
                position: "absolute",
                top: -40,
                left: "50%",
                transform: "translateX(-50%)",
                width: 220,
                height: 160,
                background: `radial-gradient(circle, ${color.base}1f, transparent 70%)`,
              }}
            />
            <div style={{ position: "relative" }}>
              <div style={mlabel(12, E.dim)}>🔥 Current streak</div>
              <div
                style={{
                  fontFamily: DISP,
                  fontSize: 78,
                  fontWeight: 600,
                  lineHeight: 1,
                  letterSpacing: "-0.04em",
                  color: color.base,
                  marginTop: 8,
                  textShadow: `0 0 40px ${color.base}55`,
                }}
              >
                11
              </div>
              <div style={{ ...mlabel(12, E.dim), marginTop: 6 }}>days in a row</div>
            </div>
          </div>

          {/* supporting stats */}
          <div
            style={{
              marginTop: 14,
              background: E.card,
              border: `1px solid ${E.border}`,
              borderRadius: 20,
              padding: "20px 8px",
              display: "flex",
            }}
          >
            <MiniStat value="11" label="Longest" />
            <div style={{ width: 1, background: E.border }} />
            <MiniStat value="18" label="Logged" />
            <div style={{ width: 1, background: E.border }} />
            <MiniStat value="69%" label="This month" />
          </div>

          {/* calendar */}
          <div
            style={{
              marginTop: 14,
              background: E.card,
              border: `1px solid ${E.border}`,
              borderRadius: 24,
              padding: "20px 18px",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 16 }}>
              <svg width="8" height="14" viewBox="0 0 8 14" style={{ opacity: 0.5 }}>
                <path d="M7 1L1 7l6 6" stroke={E.dim} strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
              <span style={{ fontFamily: DISP, fontSize: 17, fontWeight: 600 }}>June 2026</span>
              <svg width="8" height="14" viewBox="0 0 8 14" style={{ opacity: 0.5 }}>
                <path d="M1 1l6 6-6 6" stroke={E.dim} strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </div>
            <MonthCalendar color={color} ac={ac} />
          </div>

          {/* view year — secondary button */}
          <button
            style={{
              width: "100%",
              marginTop: 16,
              borderRadius: 16,
              padding: "15px",
              background: E.cardHi,
              border: `1px solid ${E.border}`,
              color: E.text,
              fontFamily: DISP,
              fontSize: 15,
              fontWeight: 600,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 8,
            }}
          >
            View full year
          </button>
        </div>
      </ScreenShell>
    </window.IOSDevice>
  );
}

// ── INSIGHTS ─────────────────────────────────────────────────────────────────
const INSIGHT_ACTS = [
  { name: "Morning Run", emoji: "🏃", color: COLORS.coral, week: [1, 1, 1, 1, 1, 0, 1] },
  { name: "No sugar", emoji: "🍃", color: COLORS.violet, week: [0, 1, 1, 1, 1, 1, 1] },
  { name: "Read 20 min", emoji: "📖", color: COLORS.amber, week: [1, 0, 1, 1, 1, 1, 0] },
  { name: "Meditate", emoji: "🧘", color: COLORS.sky, week: [1, 1, 0, 1, 0, 0, 1] },
];

function DotWeek({ week, color }) {
  return (
    <div style={{ display: "flex", gap: 5, marginTop: 12 }}>
      {week.map((d, i) => (
        <div
          key={i}
          style={{
            flex: 1,
            height: 8,
            borderRadius: 4,
            background: d ? `linear-gradient(90deg, ${color.base}, ${color.deep})` : E.cardHi,
            border: d ? "none" : `1px solid ${E.borderSoft}`,
          }}
        />
      ))}
    </div>
  );
}

function EmberInsights({ ac = GREEN }) {
  const totals = INSIGHT_ACTS.map((a) => a.week.reduce((s, x) => s + x, 0));
  const done = totals.reduce((s, x) => s + x, 0);
  const possible = INSIGHT_ACTS.length * 7;
  const pct = Math.round((done / possible) * 100);
  return (
    <window.IOSDevice dark>
      <ScreenShell>
        <div style={{ padding: "54px 20px 40px" }}>
          {/* nav */}
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <IconBtn>
              <svg width="11" height="18" viewBox="0 0 11 18" fill="none">
                <path d="M9 2L3 9l6 7" stroke={E.dim} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </IconBtn>
            <span style={{ fontFamily: DISP, fontSize: 19, fontWeight: 600 }}>Insights</span>
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 6,
                background: E.cardHi,
                border: `1px solid ${E.border}`,
                borderRadius: 12,
                padding: "9px 12px",
              }}
            >
              <span style={{ ...mlabel(11, E.dim), whiteSpace: "nowrap" }}>7 days</span>
              <svg width="9" height="6" viewBox="0 0 9 6">
                <path d="M1 1l3.5 3.5L8 1" stroke={E.dim} strokeWidth="1.5" fill="none" strokeLinecap="round" />
              </svg>
            </div>
          </div>

          {/* hero completion */}
          <div
            style={{
              marginTop: 26,
              background: E.card,
              border: `1px solid ${E.border}`,
              borderRadius: 24,
              padding: "26px 24px",
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              position: "relative",
              overflow: "hidden",
            }}
          >
            <div style={{ position: "absolute", top: -50, right: -20, width: 200, height: 160, background: `radial-gradient(circle, rgba(${ac.rgb},0.16), transparent 70%)` }} />
            <div style={{ position: "relative" }}>
              <div style={mlabel(12, E.dim)}>This week</div>
              <div style={{ fontFamily: DISP, fontSize: 24, fontWeight: 600, letterSpacing: "-0.02em", marginTop: 8, maxWidth: 150 }}>
                You showed up <span style={{ color: ac.neon }}>{done} of {possible}</span> times.
              </div>
            </div>
            <div style={{ position: "relative", textAlign: "right" }}>
              <div style={{ fontFamily: DISP, fontSize: 60, fontWeight: 600, color: ac.neon, lineHeight: 1, letterSpacing: "-0.04em", textShadow: `0 0 40px rgba(${ac.rgb},0.45)` }}>
                {pct}
                <span style={{ fontSize: 28 }}>%</span>
              </div>
            </div>
          </div>

          {/* ranked list */}
          <div style={{ ...mlabel(12, E.dim), margin: "28px 4px 12px" }}>Ranked this week</div>
          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            {INSIGHT_ACTS.map((a, idx) => {
              const t = totals[idx];
              const p = Math.round((t / 7) * 100);
              return (
                <div
                  key={a.name}
                  style={{ background: E.card, border: `1px solid ${E.border}`, borderRadius: 20, padding: "16px 18px" }}
                >
                  <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                    <IconTile emoji={a.emoji} color={a.color} size={38} />
                    <div style={{ flex: 1 }}>
                      <div style={{ fontFamily: DISP, fontSize: 17, fontWeight: 600 }}>{a.name}</div>
                      <div style={{ ...mlabel(10, E.dim), marginTop: 3 }}>{t} of 7 days</div>
                    </div>
                    <div style={{ fontFamily: DISP, fontSize: 24, fontWeight: 600, color: a.color.base, letterSpacing: "-0.03em" }}>
                      {p}%
                    </div>
                  </div>
                  <DotWeek week={a.week} color={a.color} />
                </div>
              );
            })}
          </div>
        </div>
      </ScreenShell>
    </window.IOSDevice>
  );
}

Object.assign(window, { EmberHome, EmberDetails, EmberInsights, GREEN, ORANGE });
