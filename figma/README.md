# figma/ — design reference, one folder per screen

Naming: plain page slug (`home/`, `add_pond_success/`, …). Node ids live in docs/DESIGN_TOKENS.md screen map.

File convention per folder (paste whichever you can export; CSS > PNG > SVG — in that order of usefulness):
- `css.txt` — Dev Mode → select **whole frame** → "Copy as code" (CSS) → paste as-is (keeps raw comments; layer names carry the real mock copy)
- `1x.png` — right-click frame → Export PNG @1 (for visual diff + element visibility)
- `css_<state>.txt` / `<state>.png` — variants of the same screen (e.g. severity states)

## Status
| Folder | Node | Screen | Needed for | State |
|---|---|---|---|---|
| `add_pond_success/` | 109:1176 | pond wizard success popup | Phase 2 | ✅ done (css.txt + check.svg) |
| `home/` | 77:605 | Ponds 1 home (severity card, representative param, badges) | **Phase 3** | ⏳ awaiting css.txt + 1x.png |
| `home/` variants | 77:605* | **ElevatedRisk** + **Critical** badge colors (never seen [U]) | **Phase 3** | ⏳ `css_elevated.txt` / `css_critical.txt` + pngs, or any frame showing those states |
| `add_pond_step3/` | 158:196 | wizard step 3 | fidelity re-check | ⬜ later (MCP rate limit) |
| `pond_setting/` | 304:195 | pond settings | Phase 2 done via earlier scan | ⬜ nice-to-have |
| `action_sheet/` | 381:242 | activity action sheet | Phase 4 | ⬜ later |
| `param_detail/` + `graph/` | 319:145 / 191:290 | analysis detail + chart | Phase 6 | ⬜ later |
