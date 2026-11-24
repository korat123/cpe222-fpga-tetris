# วิธีทำงานในรีโปนี้ (CONTRIBUTING)

อ่านครั้งเดียวจบ ใช้ได้ตลอดโปรเจค · กติกาเต็มอยู่ใน [AGENTS.md](AGENTS.md)
มาใหม่? อ่าน [docs/GETTING-STARTED.md](docs/GETTING-STARTED.md) ก่อน (แต่ละโมดูลทำอะไร, ศัพท์, งานแรก) · ลงเครื่องมือ/รันเทสต์/ดู waveform: [docs/TOOLS.md](docs/TOOLS.md)

## 0. ตั้งค่าครั้งแรก (ทำครั้งเดียว)

1. ติดตั้ง **[GitHub Desktop](https://desktop.github.com)** แล้ว Sign in ด้วยบัญชี GitHub ของตัวเอง
2. ไปที่ GitHub.com → Settings → Emails → ดูว่าอีเมลที่ใช้ **ขึ้นว่า Verified**
3. ใน GitHub Desktop: File → Options → Git → ใส่ชื่อจริง + อีเมลเดียวกับบัญชี GitHub
   (ถ้าอีเมลไม่ตรง commit จะไม่ขึ้นชื่อเรา → TA ไม่เห็นงานเรา)
4. รับคำเชิญเข้ารีโปจากอีเมล แล้ว File → Clone repository → เลือก `cpe222-fpga-tetris`

## 1. ทำงาน 1 ชิ้น = 5 ขั้น

| ขั้น | ใน GitHub Desktop |
|---|---|
| **1. Pull** ดึงของล่าสุด | Current branch = `main` → กด **Fetch origin** / **Pull origin** |
| **2. Branch** แยกทางของเรา | Current branch → **New branch** → ตั้งชื่อ `feat/12-vga-sync` (เลข issue + ชื่อสั้น) |
| **3. Commit** บันทึกงาน | แก้ไฟล์ใน Vivado/VS Code → กลับมาที่ Desktop → ติ๊กไฟล์ → เขียน `feat(vga_sync): add counters` → **Commit** (ทำบ่อย ๆ ได้) |
| **4. Push** ส่งขึ้น GitHub | กด **Push origin** (ครั้งแรกจะเป็น **Publish branch**) |
| **5. Pull request** | กด **Create Pull Request** → กรอก template → **Create** |

จากนั้น:
- รอ **CI** (วงกลมเหลือง → ✅ เขียว / ❌ แดง) ประมาณ 1–3 นาที
- ✅ เขียวครบ → ทำ **เช็คลิสต์รีวิวตัวเอง** ใน PR → กด **Merge pull request** (แบบ *Create a merge commit*) ได้เลย
- ❌ แดง → กด **Details** ดูว่าพังตรงไหน → แก้ใน branch เดิม → Commit → Push → CI รันใหม่เอง (ไม่ต้องเปิด PR ใหม่)
- merge แล้ว: กลับไป `main` แล้ว Pull อีกครั้ง และบอกในกลุ่มถ้ามีคนรองานนี้อยู่

## 2. CI ตรวจอะไร

| ชื่อ | ตรวจ | ถ้าแดงให้ดู |
|---|---|---|
| `layout` | ไฟล์อยู่ถูกโฟลเดอร์ ไม่มีไฟล์ขยะ ทุกโมดูลมี testbench | ข้อความบอกชื่อไฟล์ที่ผิด → ย้าย/ลบ (`.log`, `.xpr` ห้าม commit) |
| `lint` | Verilog ไม่มีข้อผิดพลาดพื้นฐาน (ความกว้างบิต, latch) | บรรทัดที่ Verilator ชี้ |
| `sim` | testbench ทุกตัวพิมพ์ `TB_PASS` | ดาวน์โหลด artifact `sim-logs` ดู log ของ tb ที่ FAIL |
| `synth` | (ยังไม่บังคับ) Yosys สังเคราะห์ได้ไหม | ดู `synth-log` |

**CI เขียว ≠ เล่นบนบอร์ดได้** — CI ทดสอบเฉพาะ simulation ต้องลองบนบอร์ดจริงด้วยเสมอ

## 3. กติกาแบบยืดหยุ่นของกลุ่มเรา

- **รีวิวตัวเองแล้ว merge เองได้** เมื่อ CI เขียว (มีเพื่อนช่วยดูยิ่งดี แต่ไม่บังคับ)
- **ยกเว้น 2 อย่าง ให้มีอีกคนดู หรือประกาศในกลุ่มก่อน merge:** แก้ `constraints/*.xdc` · แก้ port ที่คนอื่นใช้
- **ช่วยงานเพื่อน/รับงานแทน:** เปลี่ยน Assignee ใน issue เป็นตัวเอง + เขียน 1 บรรทัดว่าทำไม · commit ด้วยบัญชีตัวเองเสมอ · ทำร่วมกันให้ใส่ `Co-authored-by: ชื่อ <อีเมล>` ท้าย commit
- **ห้าม** push เข้า `main` ตรง ๆ (ระบบจะบล็อก) · ห้ามอัปโหลดไฟล์ผ่านหน้าเว็บแทนคนอื่น
- **main แดงหลัง merge:** คน merge ล่าสุดแก้ภายใน ~1 ชม. หรือกด **Revert** ที่ PR นั้น
- ทำงานไม่ทัน → บอกใน issue **ก่อน** หมด phase ไม่ใช่วันสุดท้าย

## 4. วางไฟล์ตรงไหน (ย่อ)

| ไฟล์ | ที่อยู่ |
|---|---|
| โมดูล Verilog | `rtl/<common|io|video|game|features|top>/<module>.v` |
| Testbench | `tb/<โฟลเดอร์เดียวกัน>/tb_<module>.v` |
| ขาบอร์ด | แก้ `constraints/nexys_a7_100t.xdc` ไฟล์เดียว |
| บันทึกประชุม | `docs/meetings/YYYY-MM-DD-topic.md` |
| รูป waveform / บอร์ด | ลากใส่ใน PR ได้เลย · ถ้าจะใช้ในรายงาน → `media/` (< 1 MB) |
| วิดีโอ | อัป YouTube (unlisted)/Drive → ใส่ลิงก์ใน `media/VIDEOS.md` |
| ไม่แน่ใจ | ถามใน issue ก่อน อย่าสร้างโฟลเดอร์ใหม่เอง |

## 5. เปิด Vivado

ห้าม commit โปรเจค Vivado — ให้สร้างใหม่จากสคริปต์:
Vivado → Tcl Console → `cd C:/path/to/cpe222-fpga-tetris` → `source scripts/vivado/create_project.tcl`
→ เปิด `build/vivado/tetris.xpr` · ไฟล์ทั้งหมดที่ Vivado สร้างจะอยู่ใน `build/` ซึ่ง git ไม่สนใจ
ถ้าเพิ่มไฟล์ `.v` ใหม่ ให้สร้างไฟล์ในโฟลเดอร์ `rtl/...` ของรีโป แล้วรันสคริปต์ซ้ำ (อย่าใช้ "Add Sources → copy into project")

## 6. ใช้ AI ช่วย

AI (Claude Code, Copilot, Cursor, Gemini ฯลฯ) จะอ่าน `AGENTS.md` เอง · เราต้องอ่านและเข้าใจทุกบรรทัดก่อน commit ·
ใส่ `Assisted-by: <ชื่อเครื่องมือ>` ท้าย commit และติ๊กช่อง AI ใน PR · ถ้าทำไม่จบ ให้ AI เขียน handoff comment ใน issue
