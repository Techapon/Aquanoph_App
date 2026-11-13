# Application Spec v0.5 (Prototype)

ปรับจาก v0.4 ให้ตรงกับ Backend ปัจจุบัน ครอบคลุมเฉพาะ Part 1 (Application) รวมคำตอบ Q1–Q10, N1–N4 และ Special Part

**อ้างอิงฝั่ง Backend:** `part2_minimal_logic_flow_v0.3.md` (rule/flow ของ Diagnostic, Prediction, Recommendation) / กติกา apply aeration แบบ "Recommendation ทับ pending" ที่ตกลงเพิ่มหลัง v0.3 (หัวข้อ 3.5.5) / `SEVERITY_TEXT_SYSTEM.md` (ข้อความ severity เป็นอังกฤษแล้ว) / `special_part_retroactive_edits_v0.2.md`

**หมายเหตุ:** ไม่ได้รับ `APP_SPEC_ALIGNMENT.md` ที่ SEVERITY_TEXT_SYSTEM อ้างถึง จึงปรับตามเอกสารข้างต้น ถ้า code จริงต่างออกไปให้ยึด code แล้วแก้ spec

**สัญลักษณ์:** ⚑ = ค่าเริ่มต้นที่ตั้งเองหรือยังรอยืนยัน (รวมไว้ที่หัวข้อ 12) / `[v0.3 §x]` = ที่มาในเอกสาร Backend

---

## 0. สิ่งที่เปลี่ยนใน v0.5 (ปรับให้ตรง Backend)

| หัวข้อ | v0.4 | v0.5 (ตาม Backend) |
|---|---|---|
| Apply: urgent | user เลือกเวลาในช่วงที่ต้องทำ | **เวลาตายตัว** ที่ระบบเสนอ (คำนวณตอนกด Apply) ปุ่ม Apply / Decline `valid_until` = **deadline ที่ยัง Apply ได้** [v0.3 §5.1, 5.3] |
| Apply: non_urgent | เลือกวันในช่วงที่ยังใช้ได้ | **เลือกเวลา** ในช่วง `valid_from → valid_until` ปุ่ม Apply / Remind me later / Dismiss |
| ชน (conflict) | aeration ซ้อนกัน บล็อกทุกกรณี | ฟอร์มของ user: ยังบล็อก / Apply **urgent aeration**: Recommendation ทับ aeration `pending` ของ user ส่วนที่เกินคงไว้ (3.5.5) / ชนิดอื่นที่ชนในช่วง rec: ถาม |
| Recommendation | ฟิลด์พื้นฐาน | เพิ่ม `based_on`, `guidance` (เป็นข้อๆ), `apply_mode`, `entry_id`, `source`, เหตุผลหมดอายุแบบมีรหัส และ **catalog 3 entry** (AERATE, WATER_CHANGE, ADD_ALKALINITY) |
| ความเร่งด่วนเปลี่ยน | ไม่ได้กำหนด | non_urgent อัปเกรดเป็น urgent ได้ (ยกเลิก snooze + push) |
| Diagnostic | "ถ้ามี" | กฎชัด: 1 รายงานต่อ episode, สูงสุด 2 เหตุ, มี fallback และป้าย "Updated after activity change" (3.3.1) |
| Predictive page | placeholder (กราฟ + "Not enough data") | **Prediction card** 3 แบบ ไม่มีค่าพยากรณ์ตัวเลขและไม่มีกราฟอนาคต (3.6) |
| ข้อความ severity | (ภาษาตามที่ 09 เขียน) | อังกฤษแล้ว มี 4 ช่อง `description` / `detail` / `appendDes` / `guidance` (3.3) |
| น้ำหนัก/จำนวนปลา | รอ Part 2 ตัดสิน | **เป็น trigger** ของ Prediction/Recommendation ตอนนี้ (`avg_weight`, `count`) |
| ข้อมูลเซนเซอร์ขาด | รอ Part 2 | ไม่มี reading ใหม่ > 3×Δ: ไม่สร้างผลวิเคราะห์ใหม่ และไม่ expire Recommendation เดิมเพราะข้อมูลหาย (ยังไม่มีป้าย stale) |
| Push | 2 กรณี | 3 กรณี (เพิ่ม non_urgent → urgent) |
| Activity | รายละเอียดตามชนิด | feeding ต้องมี kg (Analysis ใช้คำนวณ % ของ biomass) / ระบบแก้ aeration `pending` ของ user ได้เฉพาะตอน Apply urgent aeration |
| เวลาในข้อความ | — | ข้อความจาก Backend ฝังเวลาเป็น **เวลาท้องถิ่นของบ่อ** ⚑ (3.8) |

### 0.1 ก่อนหน้านี้ (v0.1 → v0.4)

| หัวข้อ | v0.1 | v0.2 |
|---|---|---|
| หน้ารายการบ่อ | ไม่มี | **มี Card list** (ต้นแบบมี 1 การ์ด) |
| การติ๊ก checklist | dialog ยืนยันทุกครั้ง | ติ๊กได้หลายรายการก่อน (ยังไม่บันทึก) แล้วกด **Save** และมี **dialog ยืนยัน** ก่อนบันทึกลง database |
| Timezone | ค่าคงที่ Asia/Bangkok | เก็บเวลาเป็น UTC, บ่อมี timezone ของตัวเองไว้ให้ Analysis ใช้, App แสดงเวลาตาม timezone ปัจจุบันของ user |
| แก้ข้อมูลบ่อ | ทุกฟิลด์ | เฉพาะ **ชื่อบ่อ, น้ำหนักปลา, จำนวนปลา** (Device ID และ timezone แก้ไม่ได้) |
| Device ID | optional | **บังคับกรอก** ตอนสร้างบ่อ |
| ชนิด activity | 5 ชนิด (alkalinity รวม lime, probiotic ไป other) | **7 ชนิด** แยก alkalinity / lime / probiotic |
| ภาษา | UI ไทย + severity อังกฤษ | **อังกฤษล้วน** |
| พิกัดบ่อ (lat/long) | เสนอให้เพิ่ม | **ไม่เก็บ** เก็บ timezone แทน |
| จำนวนปลา | ข้อจำกัด: ไม่ลดตามการตาย | user แก้จำนวนเองได้ (แค่ไม่มีระบบ mortality) |
| จุดเริ่มข้อมูลที่ Analysis ใช้ | `stocking_date` | `max(stocking_date, เวลาสร้างบ่อ)` เพราะไม่มีรอบเลี้ยงและ `stocking_date` แก้ไม่ได้ (Device ID บังคับกรอกตอนสร้าง จึงไม่ต้องมี `device_linked_at` แยก) |
| สถานะ Recommendation | 6 สถานะ | 5 สถานะ (ตัด `superseded` ใช้ `expired` + `reason`) |
| แก้ข้อมูลย้อนหลัง | ยังไม่กำหนด | แก้/ลบ activity ย้อนหลังได้ **4 วัน** ย้อนสถานะหลัง Save ไม่ได้ |

---

## 1. ขอบเขตต้นแบบ

- Flutter, Supabase, ออนไลน์เท่านั้น
- ภาษาอังกฤษล้วนทั้งโปรเจกต์ (UI, ชื่อระดับ severity, ข้อความอธิบาย/guidance/recommendation, disclaimer) หน่วย SI
- 1 account สร้างได้ 1 บ่อ (schema รองรับหลายบ่อ แต่ UI จำกัด)
- ยังไม่มีทุ่นจริง ข้อมูลเซนเซอร์มาจาก simulator/free dataset ฝั่ง dev ไม่มีหน้ากรอกค่าด้วยมือ
- ปลานิลเท่านั้น, 6 parameter: DO, NH₃, NO₂, Temperature, pH, Salinity
- ยังไม่มีระบบรอบการเลี้ยง

---

## 2. แผนผังหน้าจอ

| # | หน้าจอ | หน้าที่ |
|---|---|---|
| 1 | Sign up / Login | สมัครด้วย email + username, ล็อกอินด้วย email + password |
| 2 | **Pond list (Card list)** | การ์ดของแต่ละบ่อ: ชื่อบ่อ, parameter ตัวแทน + ระดับ, เวลาอัปเดตล่าสุด / ปุ่มเพิ่มบ่อซ่อนเมื่อมีครบ 1 บ่อ |
| 3 | Create Pond / Edit Pond | กรอกข้อมูลบ่อ / แก้ได้เฉพาะ 3 ค่า |
| 4 | Pond status | แสดง parameter ที่สำคัญที่สุด 1 ตัวแบบละเอียด |
| 4.1 | All parameters | แถวสรุปทุกตัว (ค่า, ระดับ) |
| 4.2 | Parameter detail | รายละเอียดของแต่ละ parameter |
| 5 | Checklist (รายวัน) | เลือกวัน ติ๊ก/ข้าม แล้ว Save, แก้/เพิ่ม activity |
| 5.1 | Add / Edit activity | ฟอร์มตามชนิด activity |
| 6 | Recommendations | แท็บ Today / Upcoming / History, รายละเอียด, apply |
| 7 | Analysis | Retrospective (กราฟ + diagnostic) และ Predictive (Prediction card) |

---

## 3. โมดูลและกฎ

### 3.1 Account
- สมัครด้วย email + username (ห้ามซ้ำ ไม่แยกตัวพิมพ์เล็ก/ใหญ่)
- ยืนยันอีเมลก่อนใช้งาน และมี reset password (ฟีเจอร์ของ Supabase Auth)

### 3.2 Pond
- **ตอนสร้าง user กรอก:** ชื่อบ่อ, พื้นที่ (m²), ความลึกเฉลี่ย (m), สปีชีส์ (dropdown), จำนวนปลา, น้ำหนักเฉลี่ย, วันที่ปล่อย, Device ID (**บังคับ**), timezone ของบ่อ (ค่าเริ่มต้น = timezone ของเครื่อง แก้ได้ตอนสร้างเท่านั้น)
- **ระบบคำนวณ:** ปริมาตร, biomass, density (kg/m³)
- **แก้ภายหลังได้:** ชื่อบ่อ, น้ำหนักเฉลี่ย (user สุ่มชั่งแล้วกรอก), จำนวนปลา (ใช้ปรับเมื่อมีปลาตาย) ค่าที่แก้ถูกใช้เป็น "ค่าปัจจุบัน" ตั้งแต่เวลาที่แก้เป็นต้นไป
- **แก้ไม่ได้:** พื้นที่, ความลึก, สปีชีส์, วันที่ปล่อย, Device ID, timezone (ถ้ากรอกผิดให้ dev แก้ใน DB ในช่วงต้นแบบ)
- Device ID ต้องไม่ซ้ำกับบ่ออื่น และต้องมีอยู่จริงในตารางอุปกรณ์
- ไม่มีหน้าลบ/เก็บถาวรบ่อ และไม่มีแนวคิดรอบเลี้ยง (เริ่มรอบใหม่ = สร้างบ่อใหม่ในต้นแบบ)

### 3.3 Status (Assess Severity)
- 4 ระดับ: Optimal / Stress / ElevatedRisk / Critical และมีป้าย "Recovering" (Recovery Hold) พร้อมเวลาที่เหลือ
- **Pond status** แสดง parameter ตัวแทน 1 ตัวแบบละเอียด
  - ทุกตัว Optimal → แสดง DO
  - มีตัวที่ไม่ใช่ Optimal → ตัวที่ severity สูงสุด ถ้าเท่ากันใช้ลำดับ parameter (ค่าเริ่มต้น DO > NH₃ > NO₂ > Temperature > pH > Salinity เป็น config)
- กดดูเพิ่ม → แถวสรุปทุกตัว (ค่า, ระดับ) → กดแต่ละตัวเพื่อดูรายละเอียด
- **การ์ด parameter** แสดง (ข้อความทั้งหมดเป็นอังกฤษ มาจาก severity report):
  - ค่า + หน่วย + เวลาที่วัด (`value` อยู่ใน report)
  - ระดับ และป้าย Recovering (ถ้าอยู่ใน Recovery Hold)
  - `description` (หัวข้อสถานการณ์) และ `detail` (อาการ/ผลต่อปลา)
  - `appendDes` เหตุผลเชิงเวลาที่ engine เติมตอนรัน เช่น อยู่ในโซนนี้มานานเท่าไร/จะอันตรายขึ้นเมื่อครบกี่ชั่วโมง หรือเวลา Recovery Hold ที่เหลือ (ซ่อนถ้าไม่มี)
  - `guidance` (best practice)
  - **Diagnostic** "Why this may have happened" (ซ่อนถ้าไม่มี) ดู 3.3.1
- `guidance` เป็นข้อความคงที่ ไม่มีปุ่ม สิ่งที่ลง checklist ได้มาจาก Recommendation เท่านั้น
- **Pond status (home) = parameter ตัวแทน (ตัดสินแล้ว 2026-07-13, ดู docs/DESIGN_TOKENS.md ข้อ 3):** แสดง `value` + ป้าย severity เดียว (Recovery Hold → ป้าย gradient "Recovery") + บรรทัด `description` ของ parameter นั้น; `detail`/`appendDes`/`guidance` แสดงใน parameter detail เท่านั้น (design mock มีช่อง Description ช่องเดียว — ยึด 4 ช่อง)
- แสดงเวลา "Last updated" อย่างเดียว ไม่มีสถานะ Fresh/Stale/Offline, อัปเดตแบบ realtime (ถึง Backend จะข้ามการวิเคราะห์ใหม่เมื่อไม่มี reading เกิน 3×Δ ก็ไม่แสดงป้าย stale)
- ข้อความ severity ทุกชิ้นต้องถูกเก็บไปกับ report (Backend ส่งออกเฉพาะ zone/severity/value ใน ChangeSet จึงต้องมี adapter เก็บข้อความ 4 ช่องใน Part 3) ⚑

#### 3.3.1 Diagnostic (สาเหตุของระดับที่ไม่ Optimal) [v0.3 §3, §9]
- Backend สร้าง 1 รายงานต่อ **episode** = ช่วงที่ parameter อยู่นอกโซน Optimal ต่อเนื่อง (Recovery Hold ไม่เปิด episode ใหม่) เมื่อ episode ยาว ≥ 2 reading หรือถึง HighRisk/Critical จึงมีกรณีที่ parameter ไม่ Optimal แต่ยังไม่มี Diagnostic (ซ่อนส่วนนี้)
- ประเมินสาเหตุ **ที่เวลาเริ่ม episode เท่านั้น** แสดงสูงสุด **2 เหตุ** เรียงตามความสำคัญ แต่ละเหตุมีหัวข้อสั้น + คำอธิบาย + หลักฐานจาก log ของ user (เช่น "You fed 6.0 kg at 18:30")
- เหตุที่ตรวจได้ใน v1 (8 ข้อ): DO ต่ำ (มื้ออาหารล่าสุด / อุณหภูมิสูง / กลางคืน), NH₃ สูง (มื้ออาหารล่าสุด), NO₂ สูง (NH₃ ผิดปกติก่อนหน้า), Temperature (ช่วงเวลาของวัน), pH (ช่วงเวลาของวัน), Salinity (เพิ่งถ่ายน้ำ)
- ไม่เข้ากฎเลย → "We could not find a clear cause from the data available. Check your aeration and feeding records and look at the pond."
- ท้ายส่วนนี้มี disclaimer "Based on your logged activities and sensor data. If something is missing from your log, this explanation may be incomplete."
- **ไม่ทราบ ≠ ไม่ได้ทำ:** ใช้คำว่า "not logged" เสมอ ไม่เขียนว่า "you did not aerate"
- ถ้า user แก้ activity ย้อนหลังแล้วผลถูกคำนวณใหม่ แสดงป้ายเล็ก "Updated after activity change" (มี `revised_at`) และถ้า activity ที่เป็นหลักฐานถูกลบ ผลเดิมยังอ่านได้เพราะเก็บหลักฐานไว้ใน report

ตัวอย่าง (DO episode เริ่ม 20:00, ให้อาหาร 6.0 kg เวลา 18:30, ไม่มี aeration ใน log):
```text
Why this may have happened
1. Feeding raised oxygen demand.
   You fed 6.0 kg at 18:30 (about 1.5% of the fish weight). Fish and bacteria
   use more oxygen while digesting and breaking down feed.
2. It is night.
   Plants and algae stop making oxygen after sunset. No aeration was logged tonight.
```

### 3.4 Checklist และ Activity

**หลักการ:** 1 activity = 1 รายการที่เป็นทั้งแผนและบันทึก เพิ่มผ่านฟอร์ม Add activity ที่ user เลือกเวลาเอง เมื่อติ๊กจะใช้เวลาและรายละเอียดที่บันทึกในรายการ (ถ้าทำจริงต่างจากแผน user แก้รายการก่อนหรือหลังติ๊กได้)

| ชนิด | เวลา | รายละเอียด |
|---|---|---|
| feeding | จุดเวลา | ปริมาณ (kg) **จำเป็น (> 0)** ⚑ |
| aeration | ช่วงเวลา (เริ่ม–สิ้นสุด) | ไม่มี |
| alkalinity | จุดเวลา | ปริมาณ (kg) |
| lime | จุดเวลา | ปริมาณ (kg) |
| probiotic | จุดเวลา | ปริมาณ (kg) |
| water_change | จุดเวลา | ตัวเลือก 1/4, 1/2, 3/4 ของบ่อ หรือกรอก % โดยประมาณ |
| other | จุดเวลา | ชื่อเอง (ไม่ถูกใช้ใน Analysis) |

- alkalinity / lime / probiotic ใช้โครงฟอร์มเดียวกัน (ปริมาณ + เวลา) ต่างกันแค่ชนิด/ชื่อ จึงไม่เพิ่มงานมาก (หน่วย kg ตามที่ระบุ แต่ probiotic จริงๆ มักเป็น g หรือ L เปลี่ยนได้ภายหลัง)
- feeding และ aeration คือสองชนิดที่ต้องติดตามทุกวัน
- Repeat: สวิตช์ "ทำซ้ำทุกวันตั้งแต่วันนี้" ระบบสร้างรายการล่วงหน้า 7 วัน และเก็บรหัสชุด (`series_id`) เพื่อแก้ "ตั้งแต่วันนี้เป็นต้นไป" ได้
- **การติ๊ก (batch):** user ติ๊ก 1 หรือหลายรายการ (และกด skip) ในหน้าก่อน ยังไม่บันทึกอะไร แล้วกด **Save** จะมี **dialog ให้ยืนยัน** (สรุปจำนวนรายการ) ก่อน เมื่อยืนยันระบบจึงเขียนลง database ในครั้งเดียว (all-or-nothing) ออกจากหน้าโดยยังไม่ Save → เตือนว่าจะทิ้งการเปลี่ยนแปลง ติ๊กวันอนาคตไม่ได้ วันนี้ติ๊กได้ทุกรายการ เวลาของ `done` คือเวลาที่บันทึกในรายการ ไม่ใช่เวลาที่กด Save
- **สถานะ:** `pending` / `done` / `skipped` ส่วน `missed` คำนวณจาก pending ที่เลยเวลาแล้ว (ไม่เก็บ)
- วันที่ไม่มีรายการ = **ไม่ทราบ (unknown)** ไม่ใช่ "ไม่ได้ทำ"
- **Conflict (ฟอร์มที่ user เพิ่ม/แก้เอง):** มีเฉพาะ **aeration ที่ช่วงเวลาซ้อนกับ aeration อื่นที่ยังไม่ `skipped` ซึ่งบล็อก** (user ต้องแก้เวลาหรือ skip ของเดิมก่อน) ส่วน conflict ตอน Apply Recommendation ดู 3.5.4–3.5.5 เกณฑ์เตือนเชิงตัวเลข (ระยะห่างมื้อ, เพดานปริมาณ ฯลฯ) เลื่อนไปภายหลัง
- ไม่มี validation ปริมาณ
- รายการที่มาจาก Recommendation **ลบไม่ได้** (ถ้าไม่ทำให้กด skipped) และระบบไม่แก้หรือลบ activity ของ user เอง **ยกเว้นเคสเดียว**: ตอน user กด Apply urgent aeration (3.5.5) ซึ่งแสดงข้อความแจ้งก่อนและหลัง
- รายการจาก Recommendation ไม่เร่งด่วนที่ missed: ย้ายมาวันนี้ด้วยการแก้เวลาตามปกติ
- แก้/ลบ activity ย้อนหลังได้ภายใน 4 วัน (ลบรายการ done ได้ แต่รายการจาก Recommendation ลบไม่ได้) ย้อนสถานะ done/skipped กลับเป็น pending ไม่ได้ แต่แก้เวลา/รายละเอียดได้ ผลต่อการวิเคราะห์ดู `special_part_retroactive_edits_v0.2.md`
- **รายการ `pending` คือ "แผน" ที่ Backend ใช้พยากรณ์:** เช่น วางแผนให้อาหารเย็นมากและไม่มี aeration → Prediction/Recommendation อาจขึ้นก่อนถึงเวลา และเมื่อ user แก้/ลบแผน ผลจะถูกคำนวณใหม่ทันที (ตามกติกาใน Special Part; Recommendation ที่ `applied` แล้วไม่ถูกแตะ)
- **สิ่งที่ Analysis ใช้จาก activity:** feeding (เวลา, kg เทียบ biomass), aeration (ช่วงเวลา), water_change (เวลา) / ส่วน alkalinity, lime, probiotic, other ยังไม่ถูกใช้เป็นเหตุหรือเงื่อนไขใน v1
- **water_change** เก็บเป็นสัดส่วนของบ่อ (1/4, 1/2, 3/4 หรือ % โดยประมาณ) **aeration** ต้องมีทั้งเวลาเริ่มและสิ้นสุด (เริ่ม < สิ้นสุด)

### 3.5 Recommendation [v0.3 §5]

#### 3.5.1 ประเภท

| | non_urgent | urgent |
|---|---|---|
| ตัวอย่าง | ADD_ALKALINITY, WATER_CHANGE (NH₃ ไต่ / ElevatedRisk) | AERATE, WATER_CHANGE (Critical) |
| เวลาที่ทำ | user **เลือกเวลา** ในช่วง `valid_from → valid_until` | **เวลาตายตัว** ที่ระบบเสนอ คำนวณตอนกด Apply (user เลือกเวลาไม่ได้) |
| `valid_until` คือ | ปลายช่วงที่เลือกเวลาได้ | **deadline ที่ยัง Apply ได้** เลยแล้วเป็น `expired` |
| `valid_from` | เวลาที่สร้าง | เวลาที่สร้าง |
| ปุ่ม | Apply (choose time) / Remind me later / Dismiss | Apply / Decline |
| เลื่อน (snooze) | ได้ ภายใน `valid_until` | ไม่ได้ |
| ปฏิเสธ | Dismiss ได้ | Decline ต้องยืนยัน (แสดงเหตุผลและความเสี่ยงซ้ำ) และบันทึกการปฏิเสธ ⚑ |
| หมดอายุ | เลย `valid_until` | เลย deadline |

- **อัปเกรด:** non_urgent เปลี่ยนเป็น urgent ได้เมื่อสถานการณ์แย่ลง (เช่น NH₃ ElevatedRisk → Critical) Backend อัปเดต **รายการเดิม** เป็น urgent, ยกเลิก snooze, และส่ง push [v0.3 §5.2, T8]
- ถ้า Recommendation เดียวถูกเสนอจากหลายแหล่ง urgency สูงสุดชนะ (urgent → เวลาตายตัว)

#### 3.5.2 Catalog v1 (3 entry) [v0.3 §5.1]

| entry | เกิดจาก | urgency | activity ที่เสนอ | เวลา | deadline / ช่วงเลือก | `dedupe_key` |
|---|---|---|---|---|---|---|
| `AERATE` | (a) Prediction DO ตกคืนนี้ (`PRED_DO_NIGHT` / `PRED_DO_REPEAT`) ที่ active (b) DO episode ที่ยังเปิดและ severity ล่าสุด ≥ ElevatedRisk | urgent เสมอ | aeration 1 รายการ | (a) เริ่ม `max(เวลา Apply, risk_start − 1 ชม.)` จบ `risk_end` (06:00) (b) เริ่มเวลา Apply ยาว 4 ชม. / มีทั้งสองทาง: เริ่มแบบ (b) จบที่ช้ากว่า | (a) `risk_start + 1 ชม.` (b) `created + 1 ชม.` / มีทั้งสอง: ใช้ที่เร็วกว่า | `AERATE:{night_date}` |
| `WATER_CHANGE` | (a) NH₃ หรือ NO₂ episode ที่ยังเปิดและ severity ล่าสุด ≥ ElevatedRisk (b) Prediction `PRED_NH3_RISE` | (a) Critical → urgent / ElevatedRisk → non_urgent (b) non_urgent | water_change 1 รายการ | urgent: เวลา Apply สัดส่วน **1/2** ตายตัว / non_urgent: user เลือกเวลา สัดส่วนเริ่มต้น **1/4** | urgent: `created + 3 ชม.` / non_urgent: `now → สิ้นวันถัดไป` | `WATER_CHANGE:{local_date}` |
| `ADD_ALKALINITY` | detector pH แกว่ง (max−min ≥ 1.0 ในอย่างน้อย 2 จาก 3 วันล่าสุด) | non_urgent | alkalinity 1 รายการ **ไม่เสนอปริมาณ** | user เลือกเวลา และกรอกปริมาณ (kg) เอง ⚑ | `now → now + 3 วัน` | `ADD_ALKALINITY` |

ตัวเลขทั้งหมดในตารางเป็นค่าเริ่มต้นชั่วคราว (⚙ ใน v0.3) รอผู้เชี่ยวชาญด้านประมงตรวจ [v0.3 §10]

#### 3.5.3 ข้อมูลของ Recommendation
`title`, `reason` (จะเกิดอะไร + อ้างอิงข้อมูลอะไร), `based_on` (สรุปหลักฐานบรรทัดเดียว), `guidance` (รายการข้อ), `proposed_activities` (0 ถึง n), `apply_mode` (`fixed` | `pick_window`), ประเภท (urgent / non_urgent), `valid_from`–`valid_until`, parameter ที่เกี่ยวข้อง, `entry_id`, `dedupe_key`, สถานะ, `expire_reason` (`no_longer_applies` | `time_window_over`), แหล่งที่มา (`source_type` = episode / prediction / detector + `source_id`), `created_at`, `updated_at`
- Recommendation ที่ไม่มี activity ใช้ปุ่ม "Acknowledge" แทน Apply (catalog v1 ยังไม่มีเคสนี้)
- ไม่สร้างซ้ำถ้ามี Recommendation ที่ `dedupe_key` เดียวกันค้างอยู่ หรือถูกบล็อกตาม 3.5.6

#### 3.5.4 Apply
1. ตรวจว่ายังไม่เลย deadline/`valid_until` ถ้าเลยแล้วเป็น `expired` และไม่ให้ Apply (non_urgent: เลือกเวลานอกช่วงไม่ได้)
2. เวลา: non_urgent = user เลือกในช่วง / urgent = คำนวณตายตัว ณ ตอนกด (การ์ดแสดงแผน เช่น "Aeration 19:00 → 06:00 (if you apply after 19:00, it starts when you apply)")
3. ตรวจชน:

| กรณี | non_urgent | urgent |
|---|---|---|
| ชนิดเดียวกันอยู่ในช่วง rec แล้ว (ไม่ใช่ aeration) | ถาม "Adjust time / Apply anyway / Don't apply" | ถาม "Apply anyway / Don't apply" |
| aeration ชนกับ aeration เดิม | (catalog v1 ไม่มี non_urgent aeration) | ใช้กฎ 3.5.5 |

4. สร้าง activity `pending` (source = recommendation) แล้ว Recommendation เป็น `applied` ทำใน transaction เดียว (รวมการแก้ activity เดิมในกฎ 3.5.5)
5. หลัง Apply แก้เวลา/รายละเอียดได้ตามกติกาปกติ (ภายใน 4 วัน) ลบไม่ได้ (ให้ skip)

#### 3.5.5 Urgent aeration: Recommendation ทับ aeration `pending` ของ user
ให้ R = ช่วงเวลา aeration ที่ Recommendation จะสร้าง **R ชนะเสมอ** ส่วนของ aeration เดิมที่อยู่นอก R คงไว้

| aeration เดิมที่ทับ R | ทำอย่างไร |
|---|---|
| `pending` ที่ user สร้างเอง | ตัดส่วนที่ทับ R ออก เก็บส่วนนอก R |
| `done` | **ไม่แตะ** (เป็นเหตุการณ์ที่เกิดแล้ว) Recommendation สร้างเฉพาะช่วงที่เหลือรอบๆ ⚑ |
| `pending` ที่มาจาก Recommendation อื่น | **ไม่แตะ** Recommendation สร้างเฉพาะช่วงที่เหลือ ⚑ |
| `skipped` | ไม่นับ |

ตัวอย่าง R = 22:00–03:00

| aeration `pending` เดิม | ผลลัพธ์ |
|---|---|
| 21:00–23:00 | เดิมเหลือ **21:00–22:00** + rec 22:00–03:00 |
| 01:00–05:00 | เดิมเหลือ **03:00–05:00** + rec 22:00–03:00 |
| 20:00–05:00 (คลุมทั้งช่วง) | แยกเป็น 2 ชิ้น **20:00–22:00** และ **03:00–05:00** + rec 22:00–03:00 |
| 23:00–02:00 (อยู่ในช่วง) | **ลบทิ้ง** (ถูก rec แทนที่) + rec 22:00–03:00 |
| `done` 23:00–01:00 | เดิมไม่แตะ rec สร้าง 2 ชิ้น 22:00–23:00 และ 01:00–03:00 |

กรณีขอบ (⚑ ค่าเริ่มต้น): ส่วนที่เหลือสั้นกว่า 15 นาทีให้ตัดทิ้ง / `done` ครอบ R ทั้งหมด → ไม่สร้างอะไร Recommendation เป็น `applied` พร้อมข้อความ "Your logged aeration already covers this period." / ชิ้นแรกที่ถูกแยกคง id เดิม ชิ้นหลังสร้างใหม่โดยคัดลอกรายละเอียด / ทุกชิ้นที่สร้างจาก rec เป็น source = recommendation (ลบไม่ได้ แก้/skip ได้)

ข้อความแจ้ง user:
- **ก่อนกด Apply** (บนการ์ด ไม่เพิ่มปุ่ม): `This will shorten your planned aeration 21:00–23:00 to 21:00–22:00.`
- **หลังกด:** `Aeration 22:00–03:00 added. Your planned aeration 21:00–23:00 was shortened to 21:00–22:00.`

#### 3.5.6 Decline / Dismiss / Snooze / Expire และการไม่สร้างซ้ำ [v0.3 §5.2]
- `dismissed` (non_urgent) หรือ Decline (urgent, ยืนยันก่อน): ไม่สร้าง `dedupe_key` เดิมซ้ำจนถึง `valid_until` ข้อยกเว้น urgent: สร้างใหม่ได้ถ้า severity ขึ้นถึง Critical หลังถูกปฏิเสธ
- `applied` และ activity ที่สร้างจากมันยัง `pending`/`done`: ไม่สร้างซ้ำ แต่ถ้า user **skip หรือลบ** activity นั้นแล้วเงื่อนไขยังจริง → สร้าง Recommendation ใหม่ได้
- user แก้ aeration ที่ Apply แล้วให้สั้นลง: **ไม่มี** Recommendation ใหม่ แต่ Prediction card ยังแสดงความเสี่ยง (ข้อจำกัดที่รับไว้ ข้อ 10 ใน 7)
- `expired` ไม่บล็อกการสร้างใหม่
- snooze (non_urgent): กลับเป็น `pending` เมื่อถึงเวลา ห้ามเกิน `valid_until`

#### 3.5.7 เมื่อ Recommendation เปลี่ยนเพราะการวิเคราะห์ใหม่ (รวมการแก้ activity)
- ยังเข้าเงื่อนไข: **อัปเดตในที่เดิม** (คงสถานะ snooze ถ้า urgency ไม่เปลี่ยน)
- แหล่งที่มาปิดจริง (episode จบ / prediction จบ) → `expired` (`no_longer_applies`) ไม่ลบทิ้ง / ถ้ามีหลายแหล่ง ต้องปิดครบทุกแหล่ง
- urgent ไม่หายเพราะการแก้ activity เว้นแต่ source ปิดจริง / non_urgent จาก detector (ADD_ALKALINITY) อยู่ถึง `valid_until`
- `applied` / `dismissed` / `expired` เดิม ไม่ถูกแตะ
- ทุกครั้งที่ปรับหรือหมดอายุเพราะการแก้ activity ต้องแจ้ง user และบันทึก reason ใน History เช่น
  - `Updated after you changed Feeding at 19:00.`
  - `No longer needed: the planned meal was reduced.`
  - `Resolved: aeration is now planned for tonight.` (Prediction จบเพราะ user วาง aeration)

#### 3.5.8 UI
- แท็บ Today / Upcoming / History เร่งด่วนอยู่บนสุดเสมอ แสดงเร่งด่วนทั้งหมด + ไม่เร่งด่วนสูงสุด 3 อัน ที่เหลือใน "See more" (History แสดง reason ของ `dismissed`/`expired`)
- ป้ายประเภทใช้ **Urgent / Non-urgent** (ไม่ใช้คำว่า "Critical" เพราะซ้ำกับระดับ severity) ⚑
- โครงการ์ด: Title / ป้าย / Reason / Based on / Plan / Guidance (เป็นข้อๆ) / Footer / ปุ่มตาม 3.5.1
- **urgent card:** deadline (`valid_until`) เป็นตัวหลักพร้อมนับถอยหลัง + บรรทัด metadata เล็ก "Detected HH:MM (pond time)" จาก `created_at` (ตัดสินแล้ว 2026-07-13, ดู §12 #9 — ไม่โชว์ `valid_from` เป็นช่วง)
- Footer ทุกการ์ด: "Automated estimate based on your logs and sensor data. Not a guarantee." (ตัดสินแล้ว 2026-07-13: ใส่ทุกการ์ด รวม non_urgent)

ตัวอย่าง urgent:
```text
Title:    Run aeration tonight: DO may drop too low
Reason:   You planned 8.0 kg of feed at 19:00 (about 2.0% of the fish weight)
          and no aeration is planned overnight. Oxygen use rises after feeding,
          and plants stop making oxygen after sunset. DO may fall into the
          High Risk range between 20:00 and 06:00.
Based on: Planned feeding 19:00 · no aeration planned 20:00–06:00 · water temperature 31 °C
Plan:     Aeration 19:00 → 06:00 (if you apply after 19:00, it starts when you apply)
Guidance: 1. Keep aeration running until about 06:00.
          2. Consider a smaller meal tonight to reduce oxygen demand.
          3. Check the DO reading in the app around midnight.
Buttons:  [Apply]  [Decline]
```

### 3.6 Analysis (Full Analysis Result)
- ช่วงเวลา: 24 ชม. / 7 วัน / 30 วัน / กำหนดเอง
- **Retrospective:** กราฟต่อ parameter พร้อมแถบสีโซน, min/max/avg (คำนวณตอนเปิดหน้า), marker ของ activity บนแกนเวลาเดียวกัน, **Diagnostic** ที่ backend เก็บไว้ (1 รายการต่อ episode ตาม 3.3.1 พร้อมป้าย "Updated after activity change" เมื่อมี `revised_at`) เกิน 4 วันอ่านอย่างเดียว
- **Predictive [v0.3 §4]:** แสดง **Prediction card** ของบ่อ ไม่มีกราฟอนาคตและไม่มีค่าพยากรณ์เชิงตัวเลข (kNN อยู่ใน backlog)
  - Prediction 3 แบบ: DO จะตกคืนนี้จากมื้อหนักช่วงเย็น + เติมอากาศไม่พอ / DO ตกซ้ำจากคืนก่อนๆ (2 จาก 3 คืน) / NH₃ กำลังไต่
  - ข้อมูลต่อการ์ด: parameter, โซนที่คาด (v1 = High Risk), ช่วงเวลาเสี่ยง (เวลาท้องถิ่นของบ่อ), เงื่อนไขที่เข้า (เช่น "3/3") และหลักฐาน, สถานะ `active` / `ended` พร้อมเหตุผล (`mitigated` = user จัดการแล้ว, `conditions_gone` = เงื่อนไขไม่จริงแล้ว, `window_over` = พ้นช่วงเสี่ยง)
  - ตัวอย่าง: `DO may fall into the High Risk range tonight (20:00–06:00).` / `Ammonia may reach the High Risk range in the next 12 hours.`
  - แสดง active ก่อน แล้วตามด้วยที่เพิ่งจบ Prediction ที่ทำให้เกิด Recommendation ให้ลิงก์ไปยัง Recommendation นั้น ⚑
  - Empty state: "No risks predicted right now." / บ่อใหม่ข้อมูลไม่พอ: ไม่มีการ์ด / ไม่มี reading ใหม่เกิน 3×Δ: **ไม่ขึ้นข้อความ "paused"** — แสดง Prediction card/ผลล่าสุดที่มีอยู่ พร้อมเวลา "Last updated" (เวลาบ่อ) กำกับว่าข้อมูลอาจล้าหลัง (ตัดสินแล้ว 2026-07-13 แทน ⚑ #7 เดิม)

### 3.7 Notifications
- Push เฉพาะ 3 กรณี: severity เป็น Critical / มี Recommendation เร่งด่วนใหม่ / Recommendation เดิมถูกอัปเกรดเป็น urgent (un-snooze) ทำเป็น phase ท้ายของต้นแบบ
- การเปลี่ยนของ Recommendation เพราะการแก้ activity (3.5.7) แจ้งในแอปเป็นข้อความสั้น ไม่ใช่ push

### 3.8 เวลาและ timezone
- ทุก timestamp เก็บเป็น **UTC**
- **Analysis Backend** ใช้ timezone ของบ่อ ในทุก logic ที่ช่วงเวลาของวันมีผล (เช่น 02:00–05:00 DO ต่ำเป็นพิเศษ, กลางวัน/กลางคืน)
- **App** แสดงเวลา (Last updated, แกนเวลากราฟ, ประวัติ) ตาม timezone ปัจจุบันของ user
- วัน (day) ของ checklist และเวลาที่ตั้งในฟอร์มใช้ **timezone ของบ่อ** และแสดงแบนเนอร์ "Pond time (UTC+x)" เมื่อต่างจากเครื่อง user
- ไม่เก็บพิกัดบ่อ เก็บเฉพาะ timezone แบบ IANA id (เช่น `Asia/Bangkok`) ซึ่งรองรับ daylight saving ต่างจากการเก็บ UTC offset ตรงๆ
- **ข้อความที่ Backend สร้าง** (reason, plan, based_on, ข้อความ Diagnostic/Prediction, `appendDes` ของ severity) ฝังเวลาเป็น **เวลาท้องถิ่นของบ่อ** และ App ไม่แปลงซ้ำ ⚑ ส่วนเวลาในการ์ด Recommendation/Prediction (`valid_until`, ช่วงเสี่ยง) แสดงเป็นเวลาบ่อเหมือน checklist พร้อมแบนเนอร์ "Pond time (UTC+x)" เมื่อต่างจากเครื่อง user
- ต้องให้ Backend ยืนยัน: `appendDes` ของ Recovery Hold ฝังวันเวลาจาก `event.dateTime` (ตอนนี้ naive/UTC ตามธรรมเนียม) ต้องแปลงเป็นเวลาบ่อก่อนใส่ในข้อความ ⚑

### 3.9 ส่วนที่ใช้ร่วมกัน
- Empty state: บ่อใหม่ยังไม่มีข้อมูล / ยังไม่มี activity / วันแรก / ข้อมูลไม่พอพยากรณ์
- Loading ใช้ skeleton (ยังไม่ทำการแสดงข้อมูลแคช)
- RLS: user เห็นเฉพาะบ่อของตน (บ่อมี `user_id`) simulator/Analysis backend เขียนผ่าน service role
- Hard delete ไม่มี soft delete และไม่เก็บประวัติการแก้ไข (กลับมาคุยใน Special Part) แต่ฐานข้อมูลเก็บ `created_at`/`updated_at` อัตโนมัติ
- report เก็บ snapshot ของ threshold และข้อมูลบ่อ (น้ำหนัก, จำนวน, density, timezone) ที่ใช้ตอนวิเคราะห์ Diagnostic และ Prediction ก็เก็บ snapshot ของข้อมูลบ่อและ **หลักฐาน (facts) ไว้ในตัวเอง** จึงอธิบายได้แม้ activity ที่อ้างถึงถูกลบ
- **Analysis ทำงานแบบ eager ทีละบ่อ:** ทุกเหตุการณ์ (reading ใหม่, เพิ่ม/แก้/ลบ/Save activity, แก้น้ำหนักหรือจำนวนปลา, tick ทุก 30 นาที) เข้าคิวของบ่อ ผลอัปเดตเข้า DB (upsert) แล้ว App รับผ่าน realtime จึงอาจมีหน่วงสั้นๆ หลัง user บันทึก UI ไม่ต้องรอผล
- **ข้อมูลเซนเซอร์ขาด/ช้า:** ไม่มี reading ใหม่เกิน 3×Δ (Δ ค่าเริ่มต้น 30 นาที) → Backend ไม่สร้างผลวิเคราะห์ใหม่ และไม่ expire Recommendation เดิมเพราะข้อมูลหาย (แต่หมดอายุตามเวลาได้ตามปกติ) / reading ที่มาช้าเก็บ raw พร้อม flag `late` ไม่คำนวณ severity ที่ผ่านมาใหม่

---

## 4. State machine

### 4.1 Activity

```
pending ──Save (done)──▶ done
   └─────Save (skip)───▶ skipped
(missed = pending ที่เลยเวลาแล้ว ไม่ใช่สถานะที่เก็บ)
```

ก่อน Save การสลับติ๊ก/ยกเลิกเป็นแค่สถานะบนหน้าจอ **หลัง Save ย้อนสถานะไม่ได้** (done/skipped → pending ไม่อนุญาต) แต่แก้เวลา/รายละเอียดได้ภายใน 4 วัน

### 4.2 Recommendation

```
pending ──apply──────▶ applied
   │──dismiss (non_urgent) / decline (urgent, ต้องยืนยัน)──▶ dismissed
   │──snooze──────────▶ snoozed ──ถึงเวลา──▶ pending   (เฉพาะ non_urgent)
   │                       └──อัปเกรดเป็น urgent──▶ pending (ยกเลิก snooze + push)
   └──source ปิด (no_longer_applies) / เลย valid_until (time_window_over)──▶ expired (มี reason)
```

- สถานะของ Recommendation = การตัดสินใจเรื่อง "คำแนะนำ" / สถานะของ Activity = การทำ "งานจริง" หลัง apply
- `expired` เกิดโดยระบบและมี `reason` เกิดได้เฉพาะจาก `pending` หรือ `snoozed` ส่วน `applied`/`dismissed` แล้วระบบไม่เปลี่ยนอีก

### 4.3 Prediction และ Diagnostic (สถานะที่ Backend เก็บ)

```
Prediction:  active ──▶ ended (mitigated | conditions_gone | window_over)    ended แล้วไม่คำนวณใหม่
Diagnostic:  open (episode ยังอยู่) ──▶ closed (episode จบ)                     คำนวณสาเหตุใหม่ได้ภายใน 4 วันเมื่อมีการแก้ activity
```

---

## 5. พจนานุกรมข้อมูล (ระดับ business)

**Pond:** user_id, name, area_m2, avg_depth_m, species, stocking_count, avg_weight, stocking_date, device_id (บังคับ, unique, แก้ไม่ได้), timezone (IANA id, แก้ไม่ได้), created_at / คำนวณ: volume, biomass, density

**Activity:** pond, type, เวลา (จุดเวลา หรือ เริ่ม–สิ้นสุดสำหรับ aeration), detail (feeding/alkalinity/lime/probiotic = kg, water_change = สัดส่วน), title (เฉพาะ other), status, source (self / recommendation) + อ้างอิง recommendation, series_id (กรณี repeat), created_at, updated_at

**Recommendation:** ตามหัวข้อ 3.5.3

**Severity report ที่ App แสดง:** parameter, `value`, เวลาที่วัด, level (zone + severity), recovering หรือไม่, `description`, `detail`, `appendDes`, `guidance`, diagnostic (ถ้ามี), snapshot

**Diagnostic report (ต่อ episode):** parameter, direction (pH/Temperature), onset_at, end_at, status (open/closed), peak_severity, last_severity, causes (สูงสุด 2: รหัสเหตุ + facts) หรือ no clear cause, revised_at, snapshot ข้อมูลบ่อ [v0.3 §8]

**Prediction:** rule_id, scope (คืนที่เกี่ยวข้อง หรือว่าง), parameter, expected_zone, risk_start, risk_end, met (เงื่อนไขที่เข้า), status (active/ended), end_reason, evidence (facts), revised_at, snapshot ข้อมูลบ่อ

**ตารางที่มีอยู่แล้วใน Database (จาก Q10):** (1) ตาราง devices (device_id + รายละเอียดอุปกรณ์) (2) ตารางค่า parameter ทั้งชุด 1 แถวต่อ 1 การวัด: device_id | DO | pH | … (ต้องมีคอลัมน์เวลาที่วัดเป็น UTC ด้วย) ใช้ตรวจว่า Device ID ที่ user กรอกมีอยู่จริง

**คำศัพท์**

| กลุ่ม | ค่า |
|---|---|
| Severity | Optimal, Stress, ElevatedRisk, Critical (+ป้าย Recovering) |
| Zone (threshold) | Optimal, Stress, HighRisk, Critical (ใช้ภายใน Backend / ข้อความ Prediction ใช้ "High Risk") |
| Parameter (ชื่อที่แสดง → รหัสใน Backend) | DO → `DO` / NH₃ → `NH3` / NO₂ → `NO2_N` / Temperature → `tem` / pH → `pH` / Salinity → `salinity` |
| Activity type | feeding, aeration, alkalinity, lime, probiotic, water_change, other |
| Activity status | pending, done, skipped (missed คำนวณ) |
| Recommendation status | pending, snoozed, applied, dismissed, expired (+ reason: `no_longer_applies`, `time_window_over`) |
| Recommendation type / apply mode | urgent = `fixed` / non_urgent = `pick_window` |
| Recommendation entry (v1) | AERATE, WATER_CHANGE, ADD_ALKALINITY |
| Prediction rule (v1) | PRED_DO_NIGHT, PRED_DO_REPEAT, PRED_NH3_RISE |
| Prediction end reason | mitigated, conditions_gone, window_over |

---

## 6. การคัดกรองส่วนที่บวม (ปรับตามคำตอบล่าสุด)

### 6.1 คงไว้ (แกนของระบบ)
Severity 4 ระดับ + Recovering / parameter ตัวแทน 1 ตัว / activity + checklist / Recommendation แยกเร่งด่วน + apply + เวลาตายตัวและ deadline ของ urgent / Retrospective (กราฟ + zone band + min/max/avg) / Auth (ใช้ Supabase Auth)

### 6.2 คงไว้ แต่ทำให้เล็ก

| ส่วน | วิธีทำให้เล็ก |
|---|---|
| Card list ของบ่อ | การ์ดเดียวในต้นแบบ ไม่มีปุ่มเพิ่มเมื่อครบ 1 บ่อ (schema รองรับหลายบ่อเพราะไม่เพิ่มต้นทุน) |
| 7 ชนิด activity | alkalinity/lime/probiotic ใช้ฟอร์มเดียวกัน ต่างแค่ชนิด จึงสื่อสารกับ user ชัดโดยไม่เพิ่มงานฟอร์ม |
| Batch tick + Save + dialog ยืนยัน | dialog ครั้งเดียวต่อการ Save (ไม่ใช่ต่อรายการ) แต่ต้องเก็บ state ที่ยังไม่ Save บนหน้าจอและบันทึกแบบ transaction เดียว |
| Repeat | สวิตช์เดียว (ทุกวัน) + `series_id` ไม่มี template |
| Conflict | ฟอร์มของ user: บล็อกเฉพาะ aeration ซ้อนกัน / Apply urgent aeration: rec ทับ `pending` ของ user (3.5.5) / ไม่มี combine เกณฑ์เตือนเชิงตัวเลขเลื่อนไปภายหลัง |
| Timezone | เก็บ IANA id ต่อบ่อ ค่าเริ่มต้นจากเครื่อง ไม่มีพิกัด |
| Tie-break parameter | เหลือ 2 ชั้น (severity → ลำดับ parameter) |
| Retrospective | เลื่อน timeline เหตุการณ์, จำนวนครั้ง HighRisk/Critical, เวลาในแต่ละโซน |
| Push | 3 กรณี และเป็น phase ท้าย |
| `superseded` | **ตัดออกแล้ว** ใช้ `expired` + `reason` แทน |

### 6.3 ตัดแล้ว
เกณฑ์เตือน conflict เชิงตัวเลข (prompt วิจัยพักไว้) / Crop cycle / mortality / ประมาณน้ำหนักอัตโนมัติ / validation ปริมาณ / สถานะ Fresh-Stale-Offline / หน้าลบหรือ archive บ่อ / ประวัติการแก้ pond และ soft delete / combine ใน conflict / พิกัดบ่อ / การแก้ไขฟิลด์โครงสร้างของบ่อ (พื้นที่, ความลึก, สปีชีส์, วันที่ปล่อย) / ลบบัญชี, เตือน checklist, ให้คะแนน Recommendation, ส่งออกรายงาน

### 6.4 ตัดสินแล้วใน Part 2 (minimal)

| เรื่อง | ข้อสรุป |
|---|---|
| ข้อมูลเซนเซอร์มาช้า (L6) | เก็บ raw พร้อม flag `late` ไม่คำนวณ severity ที่ผ่านมาใหม่ |
| data gap (L9) | กฎง่าย: ไม่มี reading ใหม่เกิน 3×Δ → ไม่สร้างผลวิเคราะห์ใหม่ และไม่ expire Recommendation เดิมเพราะข้อมูลหาย / นโยบายเต็ม (เรียนรู้ Δ, การนับ gap กับ Recovery) อยู่ใน backlog |
| น้ำหนัก/จำนวนปลาเป็น trigger หรือไม่ | **เป็น** (`avg_weight`, `count` ตั้งค่าได้) เพราะ `meal_pct` และ rule ใช้ biomass: prediction + reconcile ถูกคำนวณใหม่ตั้งแต่เวลาที่แก้ ไม่แตะ Diagnostic เก่า |
| เวลาดวงอาทิตย์ขึ้น-ตก | ใช้ช่วงคงที่ในเวลาบ่อ: กลางคืน 18:00–06:00 (ตั้งค่าได้) |
| ข้อความ severity เป็นอังกฤษ | ทำแล้ว (ไม่มี Thai ใน engine) |


---

## 7. ข้อจำกัดที่รับไว้ในต้นแบบ

1. น้ำหนักปลาเท่ากับค่าที่ user กรอกล่าสุด ถ้าไม่อัปเดต threshold ของ DO จะใช้น้ำหนักเก่า
2. จำนวนปลาไม่ลดอัตโนมัติ user ต้องแก้เอง
3. ถ้าทุ่นหยุดส่งข้อมูล App แสดงค่าล่าสุดพร้อมเวลาเท่านั้น
4. ไม่มีประวัติการแก้ pond ดูได้เฉพาะ snapshot ใน report จึงต้องบันทึก snapshot ตั้งแต่ต้น
5. ไม่มีรอบเลี้ยง เริ่มรอบใหม่ = สร้างบ่อใหม่ และฟิลด์ที่แก้ไม่ได้ (รวม Device ID, timezone) ถ้ากรอกผิดต้องให้ dev แก้ใน DB
6. ไม่มีพิกัด เวลาดวงอาทิตย์ขึ้น-ตกต้องประมาณจาก timezone (เหมาะกับเขตร้อน ไม่แม่นที่ละติจูดสูง) ไปตัดสินใจใน Part 2
7. ค่าเซนเซอร์ผูกกับ device ไม่ใช่กับบ่อ จึงใช้เวลาสร้างบ่อเป็นตัวกั้นข้อมูลก่อนหน้า และเพราะ Device ID แก้ไม่ได้ จึงย้ายอุปกรณ์ข้ามบ่อไม่ได้ในต้นแบบ
8. **Diagnostic ประเมินสาเหตุที่เวลาเริ่ม episode เท่านั้น** เหตุที่เกิดหลังจากนั้นและทำให้แย่ลงไม่ถูกอธิบาย (แต่ `peak_severity` บอกว่ามีการยกระดับ)
9. **ไม่มีพยากรณ์ตัวเลขและไม่มี kNN** `PRED_DO_REPEAT` คือกฎ "ซ้ำจากคืนก่อนๆ" ไม่ใช่การจับคู่วันที่คล้ายกัน
10. **แก้ aeration ที่ Apply แล้วให้สั้นลง:** ไม่มี Recommendation ใหม่ แต่ Prediction card ยังแสดงความเสี่ยง
11. **ตัวเลขทุกตัวใน rule/catalog เป็นค่าชั่วคราว** รอผู้เชี่ยวชาญด้านประมงตรวจ ข้อความวิเคราะห์เป็นประมาณการจาก log และเซนเซอร์ ไม่ใช่การรับประกัน
12. **คำอธิบายขึ้นกับ log ของ user:** วันที่ไม่บันทึก = ไม่ทราบ จึงอาจอธิบายไม่ครบ (มี disclaimer ในข้อความ)

---

## 8. คำตอบที่ปิดแล้ว (N1–N4)

| ข้อ | ข้อสรุป |
|---|---|
| N1 | Device ID บังคับกรอก จึง **Device ID และ timezone แก้ไม่ได้** ฟิลด์ที่แก้ได้มีแค่ ชื่อ, น้ำหนัก, จำนวนปลา |
| N2 | Analysis ใช้ข้อมูลตั้งแต่ `max(stocking_date, เวลาสร้างบ่อ)` |
| N3 | checklist (แบ่งวัน, ตั้งเวลา) ใช้ timezone ของบ่อ ส่วน timestamp อื่นแสดงตามเครื่อง user |
| N4 | ติ๊กได้ไม่จำกัดโดยยังไม่บันทึก จากนั้นกด Save และมี dialog ยืนยันก่อนบันทึก |

---

## 9. Special Part (ปิดแล้ว)

สรุปการตัดสินใจอยู่ใน `special_part_retroactive_edits_v0.2.md` ประเด็นหลัก: ช่วงย้อนหลัง 4 วัน, ย้อนสถานะหลัง Save ไม่ได้, ลบรายการ done ได้ภายใน window, ตัด `superseded`, ผลที่คำนวณใหม่เขียนทับพร้อม `revised_at`

**ผลต่อ Backend (ตัดสินแล้ว):** ตารางกรณีแก้ย้อนหลังอยู่ใน `part2_minimal_logic_flow_v0.3.md` §6.1 ข้อยกเว้นจาก "ระบบไม่แก้ activity ของ user เอง" มีเคสเดียวคือ Apply urgent aeration (3.5.5) ซึ่งต้องแก้ `special_part_retroactive_edits_v0.2.md` ข้อ 3.5 ให้ตรงกัน

---

## 10. โน้ตส่งต่อ

**Part 2 (Backend for Analysis) — สถานะ**
- ออกแบบ minimal เสร็จ (v0.3) กำลังเขียน code เฉพาะ logic ก่อน (ยังไม่เชื่อมฐานข้อมูล) สิ่งที่ยังต้องทำ: ให้ผู้เชี่ยวชาญตรวจตัวเลข/ข้อความ (v0.3 §10), ปรับ v0.3 §5.3 และ T14/T18 ให้เป็นกฎ "rec ทับ pending", ยืนยันข้อ ⚑ ในหัวข้อ 12

**Part 3 (Database) — สิ่งที่ต้องมี**
- ตารางค่าเซนเซอร์ผูกกับ `device_id` ต้องมีเวลาที่วัด (UTC) และ flag `late` (L6)
- Pond → Device ผ่าน `device_id` (unique ระหว่างบ่อ) ตรวจกับตาราง devices
- Activity: เวลาเริ่ม/สิ้นสุด (aeration), kg, สัดส่วน (water_change), `source`, อ้างอิง recommendation, `series_id`
- ตาราง **diagnostic_report**, **prediction**, **recommendation** ตามฟิลด์ใน 5 (upsert ได้ ผลที่คำนวณใหม่เขียนทับพร้อม `revised_at`) และ severity report ที่มี `value` + ข้อความ 4 ช่อง (`description`, `detail`, `appendDes`, `guidance`)
- คิวงานต่อบ่อ (ทำทีละงาน, รวม event ซ้อนด้วย `t_from` ต่ำสุด) + tick ทุก 30 นาที (ให้เวลาเดินและ expire ตามเวลาแม้ไม่มี reading)
- Trigger จากการแก้บ่อ: `avg_weight`, `count`
- Batch Save = 1 transaction / การ Apply urgent aeration (สร้าง + แก้ activity ของ user) = 1 transaction
- Repeat 7 วันต้องมีกลไกต่ออายุรายการ (เช่น scheduled job รายวัน หรือสร้างเพิ่มเมื่อเปิดแอป)
- report/prediction เก็บ snapshot ตาม 3.9
- RLS: Analysis backend เขียนผ่าน service role, App เปิด realtime ให้ recommendation / prediction / diagnostic

---

## 11. ขั้นตอนถัดไป

1. เขียน/ทดสอบ logic ของ Backend ให้ครบ (Diagnostic, Prediction, Recommendation, ข้อความ, orchestrator) ตามเฟสที่วางไว้
2. ปรับเอกสารที่ยังเก่า: v0.3 §5.3 / T14 / T18 และ Special Part ข้อ 3.5
3. ให้ผู้เชี่ยวชาญด้านประมงตรวจตัวเลขและข้อความ
4. ออกแบบ Part 3 (Database) ตามโน้ตในหัวข้อ 10
5. ทำ UI ตาม spec นี้

---

## 12. ประเด็นที่เคยรอยืนยัน (⚑) — ตัดสินแล้ว 2026-07-13

| # | ประเด็น | ข้อสรุป |
|---|---|---|
| 1 | Decline ของ urgent: ต้องให้ user พิมพ์เหตุผลหรือไม่ | ยืนยันก่อน + บันทึกว่าปฏิเสธเท่านั้น **ไม่มีช่องให้กรอกเหตุผล** |
| 2 | กฎย่อยของ "rec ทับ pending": `done` ไม่แตะ / rec-origin pending ไม่แตะ / เศษสั้นกว่า 15 นาทีตัดทิ้ง / `done` ครอบทั้งหมด → `applied` | ใช้ค่าเริ่มต้น ตาม 3.5.5 |
| 3 | Prediction card แสดงที่ไหน | **แสดงผล prediction ในหน้า Analysis โดยตรง** (ส่วน Predictive ตาม design ใน Figma "NamDee") **ไม่มี link จาก Recommendation ไปหน้า prediction** (ตัดสินแล้ว 2026-07-13) |
| 4 | เวลาในข้อความที่ Backend สร้าง | ใช้ค่าเริ่มต้น: เวลาท้องถิ่นของบ่อ (รวม `appendDes` ของ severity ต้องแปลงจาก UTC) |
| 5 | feeding ต้องมี kg > 0 / alkalinity จาก ADD_ALKALINITY user กรอก kg เองตอน Apply | ใช้ค่าเริ่มต้น: จำเป็นทั้งสองอย่าง |
| 6 | Footer disclaimer บนทุก Recommendation (ไม่เฉพาะ urgent) | **ยืนยันแล้ว:** ใส่ทุกการ์ด รวม non_urgent (ตัดสินแล้ว 2026-07-13) |
| 7 | ข้อความเมื่อ Prediction หยุดเพราะไม่มีข้อมูลใหม่ | **เปลี่ยน:** ไม่ขึ้น "Predictions are paused..." แต่แสดง Prediction card/ผลล่าสุดที่มีอยู่ พร้อมเวลาอัปเดตล่าสุดของข้อมูลเซนเซอร์ (Last updated เวลาบ่อ) |
| 8 | ป้ายประเภท Recommendation | ใช้ค่าเริ่มต้น: "Urgent" / "Non-urgent" (ไม่ใช้ "Critical") |
| 9 | v0.3 T2 ระบุ urgent window "18:00–21:00" แต่ §5.1 ระบุ `valid_from` = เวลาที่สร้าง | **ตัดสินแล้ว 2026-07-13:** App แสดง **deadline (`valid_until`) เป็นตัวหลัก** + นับถอยหลัง / แสดง `created_at` เป็นบรรทัดรอง "Detected HH:MM (pond time)" เพื่อบอกว่าระบบเพิ่งสร้างเมื่อไร / **ไม่แสดง `valid_from` เป็นช่วงเวลา** (T2 "18:00–21:00" ตกร่างไปแล้ว) |
| 10 | การเก็บข้อความ severity 4 ช่องไปกับ report (ChangeSet ปัจจุบันไม่ส่งข้อความ) | ใช้ค่าเริ่มต้น: ให้ Part 3 adapter เก็บ (ดูคำอธิบาย) |
