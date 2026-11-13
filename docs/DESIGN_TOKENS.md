# DESIGN_TOKENS.md — from Figma "NamDee" (fileKey 1c5rRLOkuxDCetEqyqJY1N)

Scanned 2026-07-13 via get_design_context (screenshots not viewable in agent session; text structure used). **[V: design file]** for what's listed; unlisted frames not yet read **[U]**.

## Screen map (top-level node ids)
| Node | Name | Maps to spec |
|---|---|---|
| 30:496 | Ponds (empty state) | §2.2 pond list, "Let's add a new pond" + gradient "Add new Pond" pill |
| 77:605 | Ponds 1 (home) | pond status + rec previews + Today's Task (feeding/aeration time chips) |
| 319:145 | DO | §4.2 parameter detail card |
| 336:148 | Temperature | parameter detail variant (not read yet) |
| 191:290 | Ponds 1 - graph | §7 Analysis: per-param "trends over past 24 hours" chart + "analysis result" card |
| 61:536 / 154:139 / 158:196 / 109:1176 | Add - Pond steps 1-3 + success | §3 Create Pond wizard (61:536 read 2026-11-12: input/select/Next style) |
| 304:195 | setting pond | §3.2 edit 3 fields (read 2026-11-12: form/label/read-only style) |
| 381:242 | action sheet | activity options: Edit Schedule / Add Activities / Apply schedule to other day / Delete Activities (red) |
| 193–196, 52, 64, 60s, 141/143 "edit", Frame 48/49 | dialogs/sheets/variants | not read yet |

## Tokens
- **Fonts:** `Nunito Bold` = titles/values/badges; `Inria Sans Regular/Bold` = body/reason text
- **Text:** #232323 primary · #707070 / #6A6A6A secondary
- **Severity:** Optimal `#0BE220` · Stress `#FFCC00` · **Recovery (Recovery Hold) = gradient `#0496FF → #7ED348` white text badge** · elevated/critical colors not yet seen [U]
- **Card tints:** urgent `#FFF0F0` border `#F29E9F` · warning/analysis `#FFF7F0` border `#EEA882` · destructive text `#FF383C` (accent/red token)
- **Zone bands on charts:** green `rgba(11,226,32,0.1)`, red `rgba(255,50,50,0.1)`
- **Chrome:** white cards, border #D9D9D9 1.5px (content cards), radius 8 (chips/buttons/menu 44px) · 12 (content cards) · 16 (parameter detail) · 24 (sheets); shadow `0 2 29.5 -2 rgba(0,0,0,0.1)`
- **Type scale:** 24 page title · 18 section · 14 labels/badges/values · 12 body/small · 36 big value (DO 4.2 mg/L)

## Observations vs spec
1. **Turbidity graph in design — NOT done (decided 2026-07-13):** v1 = 6 params only, no column in `sensor_readings`
2. **App strings come from DB text cache, never mock copy (decided):** ignore design placeholder text incl. "there's no wind tonight" (backend has no wind data) and typos ("resault" ×3)
3. **Home "Water Quality Now" = representative parameter (decided 2026-07-13, option a):**
   - shows its `value` + ONE severity badge; Recovery Hold → single gradient "Recovery" badge (design's 2 badges Stress+Recovery → collapsed to one state)
   - summary line = that parameter's `description` (design's pond-wide sentence doesn't exist in backend)
   - `detail` / `appendDes` / `guidance` render only in parameter detail screen — design mock has one "Description" slot; app uses 4 fields per spec §3.3
4. Home screen = severity card + rec previews + checklist preview in one page → features stay as structured (home composes widgets from severity/recommendation/activity)
5. Timestamps in copy = pond local time ("Thailand (UTC+7)") — matches spec §3.8 ⚑#4 decision

## Form & auth style (extracted 2026-11-12 from 304:195 + 61:536)
Figma has **no sign-in/sign-up screens** [V: full workspace scan] → auth UI is derived from the rules below.

- **Field label:** Nunito Bold 14 #707070, placed **above** the input (never floating)
- **Editable input:** radius 8, border **1px** #D9D9D9, white bg, padding x16 y12–14, height 43 (SDS component) / 51 (setting-pond field), text 16 #232323, placeholder **16 #B3B3B3**
- **Read-only field:** bg rgba(244,244,244,0.85), radius 8, h51 — bold label + regular value inline (Nunito 18)
- **Buttons:** wizard CTA "Next" = solid #2A2A2A h40 r8, white Nunito 16 + arrow icon; primary app CTA = gradient #0496FF→#7ED348, pill ~44–46 tall (home Group5)
- **Layout:** screen side margin ~20–22 (content 355–358 wide in 402 screen); label→input gap 8; field gap 16; title→fields gap 32–40; divider stroke 1.5px
- **Titles:** page title Nunito Bold 24 #232323 — centered (Settings) or left + subtitle Nunito Regular 16 #707070 (Add-Pond)
- Mock mixes **Inter** (SDS component tokens) with Nunito → app standardizes on Nunito for all form text; Inria Sans reserved for longer body copy [A: decided 2026-11-12]
- **Fonts bundled:** assets/fonts Nunito + InriaSans (400/700), declared in pubspec `fonts:` (Google Fonts static TTFs, 2026-11-12) — replaces earlier system-font fallback

## Phase 2 pond screens (read 2026-11-13; Figma MCP hit Starter-plan rate limit mid-task)
- 30:496 empty state [V]: title "Ponds" Nunito Bold 24 #232323 top-center (x≈166 not truly centered — mock artifact); "Let's add a new pond" Bold 24 **#707070**; CTA = **white pill + shadow + gradient-clipped text 14 Bold** (not filled gradient)
- 154:139 wizard step 2 [V]: same header/subtitle pattern; "Aquatic species" Select (mock shows 🦐 — v1 app = Nile tilapia only); "Aquatic animals count" Input; "Average Weight" Input + kg Select box (84px); dark #2A2A2A Next 88x40 r8 white 16 + arrow
- 109:1176 success popup [V via user-exported `figma/design_svg/check.svg` 2026-11-13]: white card 358x383 **r16**, tick circle 75px fill `#EEFFF6` stroke `#11CD24`, title #232323 (~20) + subtitle #707070, dark button `#2C2C2C` 100x40 r8 bottom-right → implemented as `shared/widgets/success_dialog.dart` (copy is app-authored: mock text is outlined/unreadable)
- Stocking date not in mock steps [A added in wizard step 2, required by DB]; fixed 2026-11-13: default = today, still via date picker (RPC needs `p_stocking_date`; DB maps it to `analysis_start_at`)
- Select pattern implemented as `AppSelectField` (shared): field chrome r8/1px/h49 + chevron, bottom sheet r24 picker — used for species (1 option) + timezone per user feedback 2026-11-13
- Time zone picker shows **country names** (Thailand, …ASEAN+neighbors+UTC) and converts via `core/utils/country_timezones.dart` (`timezoneFor`/`countryFor`); DB/RPC always store IANA ids (user decision 2026-11-13)
- Pond list card [A]: no card mock exists → r12 border 1.5 #D9D9D9 + name 18 bold + species/volume/count 14 gray
- `create_pond(...)` RPC signature [V verified 2026-11-13]: `(p_name, p_area_m2, p_avg_depth_m, p_stocking_count, p_avg_weight_g, p_stocking_date, p_device_id, p_timezone)` — owner comes from `auth.uid()`, **species not a param** (DB default nile_tilapia)



## Form & auth style (extracted 2026-11-12 from 304:195 + 61:536)
Figma has **no sign-in/sign-up screens** [V: full workspace scan] → auth UI is derived from the rules below.

- **Field label:** Nunito Bold 14 #707070, placed **above** the input (never floating)
- **Editable input:** radius 8, border **1px** #D9D9D9, white bg, padding x16 y12–14, height 43 (SDS component) / 51 (setting-pond field), text 16 #232323, placeholder **16 #B3B3B3**
- **Read-only field:** bg rgba(244,244,244,0.85), radius 8, h51 — bold label + regular value inline (Nunito 18)
- **Buttons:** wizard CTA "Next" = solid #2A2A2A h40 r8, white Nunito 16 + arrow icon; primary app CTA = gradient #0496FF→#7ED348, pill ~44–46 tall (home Group5)
- **Layout:** screen side margin ~20–22 (content 355–358 wide in 402 screen); label→input gap 8; field gap 16; title→fields gap 32–40; divider stroke 1.5px
- **Titles:** page title Nunito Bold 24 #232323 — centered (Settings) or left + subtitle Nunito Regular 16 #707070 (Add-Pond)
- Mock mixes **Inter** (SDS component tokens) with Nunito → app standardizes on Nunito for all form text; Inria Sans reserved for longer body copy [A: decided 2026-11-12]
- **Fonts bundled:** assets/fonts Nunito + InriaSans (400/700), declared in pubspec `fonts:` (Google Fonts static TTFs, 2026-11-12) — replaces earlier system-font fallback

