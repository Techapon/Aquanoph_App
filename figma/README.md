# figma/ — design reference, one folder per screen

Naming: `<node-underscored>_<page-slug>/` (node id from docs/DESIGN_TOKENS.md screen map).

File convention per folder (paste whichever you can export; CSS > PNG > SVG — in that order of usefulness):
- `css.txt` — Dev Mode → select **whole frame** → "Copy as code" (CSS) → paste as-is (keeps raw comments; layer names carry the real mock copy)
- `1x.png` — right-click frame → Export PNG @1 (for visual diff + element visibility)
- `css_<state>.txt` / `<state>.png` — variants of the same screen (e.g. severity states)

## Status
| Folder | Screen | Needed for | State |
|---|---|---|---|
| `109_1176_addpond_success/` | pond wizard success popup | Phase 2 | ✅ done (css.txt + check.svg) |
| `77_605_home/` | Ponds 1 home (severity card, representative param, badges) | **Phase 3** | ⏳ awaiting css.txt + 1x.png |
| — | home variants: **ElevatedRisk** + **Critical** badge colors (never seen [U]) | **Phase 3** | ⏳ `css_elevated.txt` / `css_critical.txt` + pngs, or any frame showing those states |
| `158_196_addpond_step3/` | wizard step 3 | fidelity re-check | ⬜ later (MCP rate limit) |
| `304_195_pond_setting/` | pond settings | Phase 2 done via earlier scan | ⬜ nice-to-have |
| `381_242_action_sheet/` | activity action sheet | Phase 4 | ⬜ later |
| `319_145_param_detail/` + `191_290_home_graph/` | analysis detail + chart | Phase 6 | ⬜ later |
