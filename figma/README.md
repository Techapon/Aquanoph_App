# figma/ — design reference, one folder per screen

Naming: plain page slug (`home/`, `add_pond_success/`, …). Node ids live in docs/DESIGN_TOKENS.md screen map.

File convention per folder (paste whichever you can export; CSS > PNG > SVG — in that order of usefulness):
- `<frame>.css` (was `css.txt`; files renamed 2026-11-13) — Dev Mode → select **whole frame** → "Copy as code" (CSS) → paste as-is (keeps raw comments; layer names carry the real mock copy)
- `1x.png` / `<frame>.png` — right-click frame → Export PNG @1 (for visual diff + element visibility)
- `css_<state>.txt` / `<state>.png` — variants of the same screen (e.g. severity states)

## Status
| Folder | Node | Screen | Needed for | State |
|---|---|---|---|---|
| `add_pond_success/` | 109:1176 | pond wizard success popup | Phase 2 | ✅ done (css.txt + check.svg) |
| `pond_page/` | (Ponds 1 screen) | pond home — severity card, badges, recs, daily tasks | **Phase 3** | superseded by `pond1/` (detail-frame CSS kept in `css_detail.txt`) |
| `pond1/` | (Ponds 1 screen) | pond home — authoritative export (PNG + CSS + SVG, 2026-11-13) | **Phase 3** | ✅ implemented — PNG is visual truth (CSS stale in places: Today's Task y, section bullets, header icons) |
| `pond_page/Ponds.css` (swapped 2026-11-13) | (Ponds screen) | ponds LIST — per-pond block, DO/Warning cards, View details, FAB 75 | **Phase 3** | ✅ implemented pixel-exact from this CSS |
| `pond_page/` variants | — | **ElevatedRisk** + **Critical** badge colors (never seen [U]) | **Phase 3** | ⏳ css_elevated.txt / css_critical.txt + pngs, or any frame showing those states |
| `add_pond_device/` | 158:196 | wizard step 3 (device id + timezone + Create) | fidelity re-check | ✅ done (css.txt + 1x.png via MCP 2026-11-13, implemented) |
| `setting_page/` | (user export 2026-11-13) | pond settings (PNG + CSS + svg) | Phase 2 | ✅ implemented — PNG is layout truth (CSS is a stale variant: green-check save, Weight/kg/Amount fields not in PNG) |
| `action_sheet/` | 381:242 | activity action sheet | Phase 4 | ⬜ later |
| `param_detail/` + `graph/` | 319:145 / 191:290 | analysis detail + chart | Phase 6 | ⬜ later |
