/// The showcase stylesheet. Classes in the "Example classes" section are
/// the ones the examples apply with `.class(_:)`.
let showcaseCSS = """
:root {
  --ink: #1b1f27; --muted: #5b6474; --line: #e2e5eb; --bg: #f6f7f9; --panel: #ffffff;
  --accent: #e8590c; --accent-soft: #fff1e8; --link: #1c5fd4;
  --code-bg: #15181e; --code-ink: #e6e8ec;
}
* { box-sizing: border-box; }
html { scroll-padding-top: 72px; }
body { margin: 0; font: 16px/1.55 -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif; color: var(--ink); background: var(--bg); }
a { color: var(--link); }
code, pre { font-family: ui-monospace, "SF Mono", Menlo, Consolas, monospace; }

/* Shell */
.topbar { position: sticky; top: 0; z-index: 10; background: rgba(255,255,255,.92); backdrop-filter: blur(8px); border-bottom: 1px solid var(--line); padding: 10px 24px; }
.brand { text-decoration: none; color: var(--ink); display: inline-flex; gap: 8px; align-items: baseline; }
.brand-name { font-weight: 700; font-size: 1.1rem; }
.brand-tag { color: var(--accent); font-weight: 600; font-size: .85rem; text-transform: uppercase; letter-spacing: .06em; }
.top-links a { text-decoration: none; color: var(--muted); font-weight: 500; }
.top-links a:hover, .top-links a.active { color: var(--ink); }
.shell { display: grid; grid-template-columns: 230px minmax(0, 1fr); max-width: 1320px; margin: 0 auto; }
.sidebar { position: sticky; top: 56px; align-self: start; max-height: calc(100vh - 56px); overflow: auto; padding: 24px 16px 24px 24px; }
.sidebar-title { font-size: .75rem; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); margin: 0 0 8px 10px; }
.sidebar ol { list-style: none; margin: 0; padding: 0; counter-reset: topic; }
.sidebar li { counter-increment: topic; }
.sidebar a { display: block; padding: 6px 10px; border-radius: 8px; color: var(--ink); text-decoration: none; font-size: .95rem; }
.sidebar a::before { content: counter(topic) "  "; color: var(--muted); font-variant-numeric: tabular-nums; font-size: .8rem; }
.sidebar-extra { list-style: none; margin: 0; padding: 0; }
.sidebar-extra a::before { content: "" !important; }
.sidebar .sidebar-title + ul { margin-top: 0; }
.sidebar ol + .sidebar-title { margin-top: 20px; }
.sidebar a:hover { background: #eceef2; }
.sidebar a.active { background: var(--accent-soft); color: var(--accent); font-weight: 600; }
.content { padding: 32px 32px 64px; min-width: 0; }
@media (max-width: 860px) {
  .shell { grid-template-columns: 1fr; }
  .sidebar { position: static; max-height: none; padding: 16px; border-bottom: 1px solid var(--line); }
  .sidebar ol { display: flex; flex-wrap: wrap; gap: 4px; }
  .content { padding: 20px 16px 48px; }
  .topbar .spacer-hide { display: none; }
}

/* Page header */
.page-header h1 { font-size: 2.2rem; line-height: 1.15; margin: 0 0 12px; }
.eyebrow { margin: 0 0 6px; color: var(--accent); font-weight: 600; font-size: .8rem; text-transform: uppercase; letter-spacing: .08em; }
.lead { font-size: 1.08rem; color: #3a4252; max-width: 72ch; }
.toc { background: var(--panel); border: 1px solid var(--line); border-radius: 12px; padding: 12px 16px; margin: 20px 0 8px; font-size: .92rem; }
.toc ul { margin: 6px 0 0; padding-left: 18px; columns: 2; column-gap: 32px; }
@media (max-width: 640px) { .toc ul { columns: 1; } }

/* Examples */
.example { margin-top: 40px; }
.example > h2 { font-size: 1.35rem; margin: 0 0 4px; }
.anchor { color: inherit; text-decoration: none; }
.anchor:hover::after { content: " #"; color: var(--muted); }
.summary { color: var(--muted); margin: 0 0 14px; max-width: 80ch; }
.example-grid { display: grid; grid-template-columns: minmax(0, 1.15fr) minmax(0, 1fr); gap: 16px; align-items: stretch; }
@media (max-width: 1080px) { .example-grid { grid-template-columns: 1fr; } }
.panel { border-radius: 12px; border: 1px solid var(--line); overflow: hidden; display: flex; flex-direction: column; min-width: 0; }
.panel-label { padding: 6px 12px; font-size: .75rem; text-transform: uppercase; letter-spacing: .08em; font-weight: 600; }
.code-panel { background: var(--code-bg); border-color: var(--code-bg); }
.code-panel .panel-label { color: #9aa3b2; border-bottom: 1px solid #262b34; }
.result-panel { background: var(--panel); }
.result-panel .panel-label { color: var(--muted); border-bottom: 1px solid var(--line); background: #fafbfc; }
.copy-button { background: transparent; color: #9aa3b2; border: 1px solid #3a404c; border-radius: 6px; font: inherit; font-size: .7rem; padding: 2px 8px; cursor: pointer; text-transform: uppercase; letter-spacing: .06em; }
.copy-button:hover { color: #fff; border-color: #6b7383; }
pre.code { margin: 0; padding: 14px 16px; overflow: auto; font-size: .84rem; line-height: 1.6; color: var(--code-ink); background: var(--code-bg); flex: 1; tab-size: 4; }
.source-path { display: block; padding: 6px 16px 8px; color: #7d8696; font-family: ui-monospace, Menlo, monospace; font-size: .72rem; border-top: 1px solid #262b34; }
.tok-keyword { color: #ff7ab2; } .tok-string { color: #ff8170; } .tok-comment { color: #7f8c98; font-style: italic; }
.tok-type { color: #6bdfff; } .tok-number { color: #d9c97c; } .tok-attribute { color: #fd8f3f; }
.tok-member { color: #67b7a4; } .tok-call { color: #a2e57b; }
.preview { padding: 20px; flex: 1; overflow: auto; }
.preview > :first-child { margin-top: 0; } .preview > :last-child { margin-bottom: 0; }
.preview-frame { width: 100%; flex: 1; min-height: 280px; border: 0; background: #fff; }
.html-output { margin-top: 10px; }
.html-output summary { cursor: pointer; color: var(--muted); font-size: .9rem; }
.html-code { border-radius: 10px; margin-top: 8px; font-size: .78rem; max-height: 360px; }

.capstone-frame { height: 760px; flex: none; }

/* Home */
.topic-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(230px, 1fr)); gap: 12px; margin: 16px 0 32px; }
.topic-card { display: flex; flex-direction: column; gap: 2px; background: var(--panel); border: 1px solid var(--line); border-radius: 12px; padding: 14px 16px; text-decoration: none; color: var(--ink); transition: border-color .15s, transform .15s; }
.topic-card:hover { border-color: var(--accent); transform: translateY(-1px); }
.topic-card small { color: var(--accent); font-weight: 700; }
.topic-card span { color: var(--muted); font-size: .9rem; }

/* Pager */
.pager { display: flex; gap: 16px; margin-top: 56px; padding-top: 20px; border-top: 1px solid var(--line); }
.pager-link { display: flex; flex-direction: column; text-decoration: none; padding: 10px 14px; border: 1px solid var(--line); border-radius: 10px; background: var(--panel); min-width: 180px; }
.pager-link small { color: var(--muted); }
.pager-next { text-align: right; }

/* Example classes: used by the examples through .class(_:) */
.notice { background: #e9f6ec; border: 1px solid #b9dfc2; border-radius: 8px; padding: 10px 14px; }
.warning { background: #fff6e0; border: 1px solid #f0d58c; border-radius: 8px; padding: 10px 14px; }
.muted { color: var(--muted); }
.card { background: #fff; border: 1px solid var(--line); border-radius: 12px; padding: 14px 16px; }
.card h3, .card h4 { margin: 0 0 6px; }
.badge { display: inline-block; font-size: .78rem; font-weight: 600; padding: 2px 10px; border-radius: 999px; background: #eef0f4; color: #3a4252; }
.badge-green { background: #e3f4e7; color: #1f6b35; } .badge-orange { background: var(--accent-soft); color: #b2440a; } .badge-gray { background: #eef0f4; }
.box { background: #eef2ff; border: 1px dashed #9aa9e8; border-radius: 8px; padding: 8px 12px; }
.button { display: inline-block; background: var(--accent); color: #fff; border: 0; border-radius: 8px; padding: 8px 16px; font: inherit; font-weight: 600; text-decoration: none; cursor: pointer; }
.button-secondary { display: inline-block; background: #fff; color: var(--ink); border: 1px solid var(--line); border-radius: 8px; padding: 8px 16px; font: inherit; text-decoration: none; cursor: pointer; }
.button:disabled { opacity: .45; cursor: not-allowed; }
.pill-nav a { text-decoration: none; padding: 4px 12px; border-radius: 999px; color: var(--muted); }
.pill-nav a.active { background: var(--ink); color: #fff; }
.breadcrumbs ol { list-style: none; display: flex; gap: 6px; padding: 0; margin: 0; flex-wrap: wrap; }
.breadcrumbs li + li::before { content: "/"; color: var(--muted); margin-right: 6px; }
.data-table { border-collapse: collapse; width: 100%; font-size: .93rem; }
.data-table th, .data-table td { text-align: left; padding: 8px 10px; border-bottom: 1px solid var(--line); }
.data-table thead th { font-size: .78rem; text-transform: uppercase; letter-spacing: .05em; color: var(--muted); }
.data-table tfoot td { font-weight: 700; border-bottom: 0; }
.data-table .number { text-align: right; font-variant-numeric: tabular-nums; }
.data-table tr.highlight td { background: var(--accent-soft); }
.stack-form { display: grid; gap: 12px; max-width: 420px; }
.stack-form label { font-weight: 600; font-size: .9rem; display: block; margin-bottom: 4px; }
.stack-form input:not([type=checkbox]):not([type=radio]), .stack-form select, .stack-form textarea { width: 100%; padding: 8px 10px; border: 1px solid #cdd2db; border-radius: 8px; font: inherit; }
.stack-form fieldset { border: 1px solid var(--line); border-radius: 8px; padding: 8px 12px 12px; }
.stack-form .choice { font-weight: 400; display: flex; gap: 8px; align-items: center; margin: 4px 0; }
.swatch { width: 56px; height: 56px; border-radius: 10px; }
.status-dot { display: inline-block; width: 10px; height: 10px; border-radius: 50%; margin-right: 6px; }
.sample-site header, .sample-site footer { background: #f1f3f6; padding: 8px 12px; border-radius: 6px; }
.sample-site main { padding: 12px; }
"""
