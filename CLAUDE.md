# PROJECT_CONTEXT.md

บริบทถาวรของโปรเจกต์ สำหรับวางเป็น Project knowledge ให้ Claude อ่านก่อนเริ่มทุกแชท
อัปเดตล่าสุด: 2026-07-13 | ป้าย: **[V]** ยืนยันจากไฟล์/ผลรัน, **[A]** สมมติ, **[U]** ยังไม่ทราบ

---
## Architecture
- ทุกงานที่แตะ `lib/` (สร้าง/แก้/ย้ายไฟล์) ต้องทำตาม skill **flutter-clean-arch** — ต้นฉบับ `docs/flutter-clean-arch-skill.md`

## 1. โปรเจกต์ในหนึ่งย่อหน้า

ระบบทุ่นตรวจวัดคุณภาพน้ำอัตโนมัติ + แอปวิเคราะห์/พยากรณ์สำหรับเพาะเลี้ยงสัตว์น้ำ (ต้นแบบแรก) ผู้ใช้เป็นนักวิจัย/นักพัฒนาไทย ทำ software ทั้งหมดคนเดียว เป้าหมาย: วิเคราะห์ข้อมูลจากทุ่น พยากรณ์ และแนะนำเกษตรกร "เหมือนมีผู้เชี่ยวชาญคอยดู" **[V]**

- ปลานิลเท่านั้น, 6 parameter: DO, NH₃, NO₂, Temperature, pH, Salinity
- ทุ่นวัดทุก ~30 นาที (ไม่ตายตัว) **ยังไม่มีทุ่นจริง** ข้อมูลมาจาก simulator
- 3 ส่วน: (1) ทุ่น (2) Backend = Supabase + **Analysis Backend** (Python, pure logic, ไม่มี DB ในช่วงนี้) (3) แอป Flutter
- ลำดับงาน: Part 1 Application (ปิด) → Part 2 Backend for Analysis (เสร็จแล้ว, เทสต์ผ่านแล้ว) → Part 3 Database (เสร็จแล้ว, เทสต์ผ่านแล้ว) — เหลืองานฝั่งแอป **[V: ผู้ใช้ยืนยัน 2026-07-13]**
- repo Backend: `Aquanoph_backend`, Python 3.11 target, stdlib + pytest เท่านั้น

## 2. วิธีทำงานกับผู้ใช้ (ต้องทำตาม)

- คุยภาษาไทย สั้น กระชับ ภาษากันเอง แต่ไม่ทิ้งรายละเอียดสำคัญ
- ถามทีละเรื่อง พร้อม **ข้อเสนอเริ่มต้น** ผู้ใช้มักตอบ "ทำตามข้อเสนอ" หรือแก้บางข้อ
- แย้งตรงๆ ได้ ผู้ใช้ปรับคำเสนอของ Claude บ่อยและถือเป็นเรื่องปกติ
- **ระวังความบวม:** prototype ต้องเล็ก บอกทุกครั้งว่าอะไรเกินจำเป็น
- ผลงานเป็นไฟล์ `.md` / ไฟล์สั่ง agent เขียนเป็น **อังกฤษ** (ประหยัด token) / ตัวแอปและข้อความถึงผู้ใช้ปลายทางเป็นอังกฤษล้วน
- ไม่แต่งข้อมูล: แยกให้ชัดว่า verified / assumed / unknown และอ่านไฟล์จริงก่อนอ้างว่าอ่านแล้ว
- ถ้าผู้ใช้เรียก `/caveman` ให้ตอบแบบประโยคสั้นตรงๆ (เฉพาะส่วนคุย ไฟล์/prompt/code เขียนปกติ) จนกว่าจะสั่งหยุด

## 3. แผนที่เอกสาร (ลำดับความสำคัญเมื่อขัดกัน: บนชนะล่าง)

| ไฟล์ | หน้าที่ | หมายเหตุ |
|---|---|---|
| `09_system_logic_summary.md` | logic Severity (threshold, escalation, Recovery Hold) | ตัวจริงของ severity |
| `part2_minimal_logic_flow_v0_3.md` | กฎ Diagnostic/Prediction/Recommendation (ไทย) | §5.3 / T14 / T18 ยังเขียน gap-fill = **เก่า** (ดู §6.4) |
| `app_spec_v0_5.md` | spec แอป ปรับให้ตรง Backend แล้ว | แทน v0.4; มี ⚑ 10 ข้อรอยืนยัน (หัวข้อ 12) |
| `special_part_retroactive_edits_v0_2.md` | กติกาแก้/ลบ activity ย้อนหลัง | ข้อ 3.5 ต้องเพิ่มข้อยกเว้นของ §6.4 |
| `SEVERITY_TEXT_SYSTEM.md` | โครงข้อความ severity (4 ช่อง) | ตัวเนื้อหาเก่าเป็นไทย แต่ banner บอก refactor เป็นอังกฤษแล้ว |
| `ANALYSIS_BACKEND_SUMMARY.md` | สรุป codebase จริง | **ฉบับเก่า** (ก่อน Phase 0–7) |
| `AGENT_CONTEXT.md`, `PHASE_*.md` | ไฟล์สั่ง coding agent | AGENT_CONTEXT ยังรอ patch glossary (ใน PROJECT_HANDOFF Appendix B) |
| `PROJECT_HANDOFF.md` | handoff ละเอียด ณ 2026-11-04 | ใช้เป็นประวัติ/รายละเอียดเพิ่ม |
| `app_spec_v0_4.md`, `part2_analysis_flow_v0_1.md`, `Backend_for_Analysis.md`, `handoff_context_for_new_chat.md` | ฉบับเก่า/ต้นฉบับแนวคิด | อ้างอิงประวัติเท่านั้น |

`APP_SPEC_ALIGNMENT.md` และ `SEVERITY_TEXT_REFACTOR_SPEC` ถูกอ้างถึงในเอกสารแต่ **ไม่เคยได้รับ [U]**

## 4. หลักการข้ามระบบ (ห้ามเปลี่ยนโดยไม่ถาม)

1. แยก Facts (ค่าเซนเซอร์, activity, ข้อมูลบ่อ) ออกจาก Derived (severity, diagnostic, prediction, recommendation)
2. **Severity คำนวณจากค่าเซนเซอร์เท่านั้น ไม่ใช้ activity**
3. เก็บเวลา UTC; logic ใช้ timezone ของบ่อ (IANA id) ผ่าน `localTime()` เท่านั้น; ข้อความที่ Backend สร้างใช้เวลาบ่อ
4. ไม่มีตารางประวัติแก้ไข, hard delete, ผลที่คำนวณใหม่เขียนทับ + `revised_at`, report เก็บ snapshot ข้อมูลบ่อ + หลักฐาน (facts) ในตัวเอง
5. **วันที่ไม่มี record = "ไม่ทราบ" ไม่ใช่ "ไม่ได้ทำ"** กฎใช้เฉพาะหลักฐานเชิงบวก ข้อความใช้คำว่า "not logged"
6. ย้อนแก้ activity ได้ **4 วัน** (`RETRO_WINDOW_DAYS`), เกินนั้นอ่านอย่างเดียว, ย้อนสถานะ done/skipped → pending ไม่ได้
7. Recommendation 5 สถานะ: pending, snoozed, applied, dismissed, expired (+ reason `no_longer_applies` | `time_window_over`) ไม่มี `superseded`
8. คำนวณแบบ eager ทีละบ่อ รันซ้ำได้ผลเดิม (idempotent)
9. ตัวเลขทุกตัวใน rule/catalog (⚙) เป็นค่าชั่วคราว รอผู้เชี่ยวชาญประมงตรวจ
   (กฎ UX loading/action + audit shared widget ย้ายไป flutter-clean-arch skill ข้อ 7 แล้ว — 2026-11-13)

## 5. สถาปัตยกรรม Analysis Backend

```
run_analysis(snapshot: PondSnapshot, trigger: Trigger, now) -> ChangeSet     # pure, ไม่มี I/O, ไม่เรียก datetime.now()
Severity (engine เดิม) → Diagnostic (episode + detector) → Prediction → Recommendation reconcile
```
- Signal 3 แบบเข้า Recommendation: episode / prediction / detector (Recommendation ไม่จำเป็นต้องผ่าน Prediction)
- ChangeSet = upsert เต็มวัตถุเฉพาะที่ต่างจากเดิม + `activityOps` + `notifications`; id กำหนดแน่นอน (deterministic)
- ตัวเลขทั้งหมดอยู่ใน `AnalysisConfig` ที่เดียว; ข้อความอังกฤษแบบ template (`identity/text`)
- ตอนนี้ **logic + DB adapter/คิว/push เสร็จแล้ว** (ไม่ใช่ "logic เท่านั้น") **[V: ผู้ใช้ยืนยัน 2026-07-13]**

### ชื่อจริงใน code **[V: agent report]**
`PondParameters`: `DO`, `pH`, `tem`, `NH3`, `NO2_N`, `salinity` (ใช้ member ไม่ใช้ string) / zone `ThresholdLevelType`: Optimal, Stress, HighRisk (ค่า string พิมพ์ผิดเป็น `"hight risk"` ห้ามเทียบ/ห้ามแก้), Critical / severity `SeverityLevelType`: Optimal, Stress, ElevatedRisk, Critical / Recovery Hold = zone Optimal + severity Stress / Range threshold = `pH`, `tem` (มี direction Low/High), ที่เหลือ Level (direction None) / history = `PondParametersHistoryModel` / ห้ามแก้ typo ที่มีอยู่ (`HightRiskCountMinute`, `needRocoveryEleveted` ฯลฯ)

## 6. กฎธุรกิจที่ตัดสินแล้ว (Part 2 minimal = v0.3 + ที่ตกลงเพิ่ม)

### 6.1 ขอบเขต v1
Diagnostic: cause rule 8 ข้อ (สูงสุด 2 เหตุ/รายงาน, 1 รายงานต่อ episode, ประเมินที่ onset เท่านั้น) + detector `PH_SWING` / Prediction 3 rule: `PRED_DO_NIGHT`, `PRED_DO_REPEAT` (แทน kNN), `PRED_NH3_RISE` / Recommendation 3 entry: `AERATE`, `WATER_CHANGE`, `ADD_ALKALINITY` / **kNN, REDUCE_FEED, match score ถ่วงน้ำหนัก, data gap เต็มรูป = backlog**

### 6.2 Recommendation
- **urgent:** เวลาตายตัว (คำนวณตอนกด Apply) ปุ่ม Apply/Decline ไม่มี snooze `valid_until` = deadline ที่ยัง Apply ได้
- **non_urgent:** user เลือกเวลาในช่วง `valid_from → valid_until` ปุ่ม Apply/Remind me later/Dismiss
- non_urgent อัปเกรดเป็น urgent ได้ (ยกเลิก snooze + push)
- `valid_from–valid_until` = ช่วงที่ rec ยังใช้ได้; ระยะเวลาของ activity เป็นอีกฟิลด์ (activity จบเลย `valid_until` ได้)
- หลาย source ใน rec เดียว: expire เมื่อ **ทุก source ปิด**; detector ไม่มีสถานะปิด (หมดตาม `valid_until`)
- `dedupe_key`: `AERATE:{night_date}`, `WATER_CHANGE:{local_date}`, `ADD_ALKALINITY`; dismissed ไม่สร้างซ้ำถึง `valid_until` (urgent สร้างใหม่ได้ถ้าขึ้น Critical); applied + activity ยัง pending/done = บล็อก, ถ้า skip/ลบ = สร้างใหม่ได้
- `AERATE` สองแหล่ง: เริ่มตามแบบ (b) (เวลา Apply), จบที่ช้ากว่า, deadline ที่เร็วกว่า
- ป้ายการ์ดใช้ "Urgent / Non-urgent" ไม่ใช้ "Critical"

### 6.3 กฎกลางคืน/เวลา
กลางคืน = 18:00 ≤ local < 06:00 (ตั้งค่าได้) / `nightWindowFor(t)`: ถ้า local hour < 6 คืนนั้นเริ่มเมื่อวาน / เวลา naive = UTC / ข้อมูลเก่ากว่า `3×Δ` (Δ=30 นาที) = stale: ไม่สร้างผลใหม่ ไม่ expire เพราะข้อมูลหาย แต่ expire ตามเวลาได้

### 6.4 Apply urgent aeration: **rec ทับ aeration `pending` ของ user** (แทน gap-fill/บล็อกเดิม)
ให้ R = ช่วงของ rec: R ชนะเสมอ ส่วนของ pending เดิมนอก R คงไว้ (เช่น pending 21:00–23:00 + R 22:00–03:00 → เดิมเหลือ 21:00–22:00) / คลุมทั้ง R → แยก 2 ชิ้น / อยู่ใน R → ลบ
**[A] กฎย่อยที่ Claude เดา ผู้ใช้ไม่ได้ยืนยัน:** `done` ไม่แตะ (rec สร้างเฉพาะช่วงที่เหลือ), rec-origin pending ไม่แตะ, `skipped` ไม่นับ, เศษ < 15 นาทีตัดทิ้ง, `done` ครอบทั้ง R → rec เป็น `applied` ข้อความ "Your logged aeration already covers this period."
ฟอร์มที่ user เพิ่มเอง และ non_urgent ที่ชนยังใช้กฎเดิม (บล็อก/ถาม) / ทำเป็น transaction เดียว / แจ้ง user ก่อนและหลัง Apply

### 6.5 Activity (ฟิลด์ที่ Analysis ใช้)
7 ชนิด: feeding (จุดเวลา + kg **จำเป็น**), aeration (เริ่ม–สิ้นสุด), alkalinity/lime/probiotic (จุดเวลา + kg), water_change (สัดส่วน 1/4, 1/2, 3/4), other / สถานะ pending|done|skipped / source user|recommendation / ลบ activity จาก rec ไม่ได้ (ให้ skip) / Analysis ใช้เฉพาะ feeding, aeration, water_change ใน v1

## 7. สถานะ ณ 2026-07-13

**เสร็จ [V]:** Part 1 spec (`app_spec_v0_5.md` ปรับตาม Backend แล้ว) / Special Part / severity engine + ข้อความ severity เป็นอังกฤษ (ตาม banner ใน SEVERITY_TEXT_SYSTEM) / ไฟล์สั่ง agent Phase 0–1 + context / **Part 2 Analysis Backend ทุก Phase + Phase 8 (DB adapter) เสร็จและเทสต์ผ่านแล้ว** / **Part 3 Database เสร็จและเทสต์ผ่านแล้ว** (ยืนยันด้วยปากผู้ใช้ 2026-07-13; ผลรัน pytest จริงไม่ได้อยู่ในไฟล์ที่อ่านได้ที่นี่ **[A]**) / **เหลืองานฝั่งแอปเท่านั้น**

**ไม่ต้องห่วงแล้ว:** ความคืบหน้า/เทสต์ของ backend — ผู้ใช้ยืนยันว่าเสร็จและเทสต์แล้ว (ให้ยึดของใหม่แทน §7 เดิมตาม §9)

**ยังไม่เริ่ม:** การตรวจโดยผู้เชี่ยวชาญประมง (ตัวเลข ⚙ ยังเป็นค่าชั่วคราว)

## 8. งานค้าง / ประเด็นเปิด

1. ปรับ `part2_minimal_logic_flow_v0_3.md` (§5.3, T14, T18) และ `special_part` ข้อ 3.5 ให้ตรงกฎ §6.4 (ยังไม่ได้ทำ)
2. ~~ยืนยัน ⚑ 10 ข้อใน `app_spec_v0_5.md` หัวข้อ 12~~ — **ตัดสินแล้ว 2026-07-13** (อัปเดตใน `app_spec_v0_5.md` §12 แล้ว; หมายเหตุ: #1 ไม่มีช่องกรอกเหตุผล, #3 แสดง prediction ในหน้า Analysis ตรงๆ ไม่มี link จาก rec (design อยู่ใน Figma "NamDee"), #6 disclaimer ทุกการ์ด, #7 แสดงผลล่าสุด+เวลาแทน "paused")
3. `appendDes` ของ Recovery Hold ฝังวันเวลาจาก `event.dateTime` (UTC) ต้องแปลงเป็นเวลาบ่อ
4. ChangeSet ไม่ส่งข้อความ severity → Part 3 ต้องเก็บ 4 ช่อง (`description`, `detail`, `appendDes`, `guidance`) ไปกับ report
5. ~~v0.3 T2 ("urgent ช่วง 18:00–21:00") ไม่ตรงกับ §5.1 (`valid_from` = เวลาที่สร้าง)~~ — **ตัดสินแล้ว 2026-07-13:** แอปแสดง deadline เป็นตัวหลัก + "Detected HH:MM (pond time)" จาก `created_at`, ไม่โชว์ `valid_from` เป็นช่วง (เขียนลง `app_spec_v0_5.md` §12 #9 แล้ว)
6. Data gap เต็มรูป (L9), ข้อมูลมาช้า (L6) ใน Part 3 (เก็บ raw + flag `late`)
7. patch `AGENT_CONTEXT.md` glossary (ชื่อ enum จริง, ห้ามเทียบ string, กฎ "ห้ามอ้างว่าเทสต์ผ่านถ้าไม่ได้รัน")

## 9. กติกาสำหรับ Claude ในโปรเจกต์นี้

- เริ่มแชทใหม่: อ่านไฟล์นี้ + ไฟล์ที่ผู้ใช้แนบ แล้วสรุปสั้นๆ ว่าเข้าใจอย่างไร ก่อนเสนอขั้นถัดไป
- ถ้าสถานะใน §7 ขัดกับสิ่งที่ผู้ใช้บอกหรือไฟล์ใหม่ ให้ยึดของใหม่ แล้วแจ้งว่าไฟล์นี้ล้าสมัย
- งานเขียน code ให้ agent: แบ่งเป็น Phase เล็กๆ, test ก่อน, ห้ามแต่งตัวเลขนอก spec, ห้ามเชื่อรายงาน "เทสต์ผ่าน" ที่ไม่มี output จริง, ส่งไฟล์ทีละ 2–3 ชุดแล้วให้ผู้ใช้ลองก่อนต่อ
- เมื่อพบช่องว่างใน spec: เสนอค่าเริ่มต้น + ถามข้อเดียว ไม่ท่วมคำถาม
- ไม่ใส่ Password/API key/secret ในเอกสาร (ใช้ `[REDACTED]`)
- เวลามี list งานที่ต้องทำ จงlistรายการงานทั้งหมดในตอนนั้นและใช้ ✅ หน้าข้อรายการที่สำเร็จแล้ว ส่วนรายการอื่นๆก็ใช้emoji/เครื่องหมายตามเหมาะสม