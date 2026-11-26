# วิธีทำงานในรีโปนี้ (CONTRIBUTING)

> **จำแค่นี้ก็พอ:** 1 issue = 1 branch = 1 PR · push เข้า `main` ตรง ๆ ไม่ได้ (ระบบบล็อก) ·
> CI เขียวแล้ว merge เองได้ (แบบ *Create a merge commit*) · บอร์ดอยู่ที่ Korat คนเดียว → ดู §2

กติกาเต็ม: [AGENTS.md](AGENTS.md) · มาใหม่อ่าน [docs/GETTING-STARTED.md](docs/GETTING-STARTED.md) · ลงเครื่องมือ: [docs/TOOLS.md](docs/TOOLS.md)
คำสั่ง `git` พิมพ์ได้ทั้ง Git Bash และ PowerShell · สคริปต์ sim (`bash ...`) ใช้ Git Bash · Vivado ใช้ PowerShell

## 0. ตั้งค่าครั้งแรก (ทำครั้งเดียว)

1. ติดตั้ง Git for Windows (ดู [docs/TOOLS.md](docs/TOOLS.md))
2. GitHub.com → Settings → Emails → อีเมลต้องขึ้น **Verified**
3. รันใน terminal (อีเมลต้องตรงกับบัญชี GitHub ไม่งั้น commit ไม่ขึ้นชื่อเรา → TA ไม่เห็นงานเรา):
   ```bash
   git config --global user.name "ชื่อจริง"
   git config --global user.email "อีเมลเดียวกับบัญชี GitHub"
   git clone https://github.com/korat123/cpe222-fpga-tetris.git
   cd cpe222-fpga-tetris
   ```
   ครั้งแรกที่ clone/push จะมีหน้าต่างให้ login GitHub — login ครั้งเดียวจบ

## 1. Workflow ต่อ 1 issue (ตัวอย่าง: issue #12)

**เริ่มงาน**
1. เปิด issue → ช่อง Assignees ต้องมีชื่อเรา · อ่านคอมเมนต์ *Handoff* ล่าสุด (ถ้ามี)
2. ดึงของล่าสุด แล้วแตก branch ชื่อ `<type>/<เลข issue>-<ชื่อสั้น>`
   (type: `feat` งานใหม่ · `fix` แก้บั๊ก · `test` · `docs` · `chore`)
   ```bash
   git switch main
   git pull
   git switch -c feat/12-tetromino
   ```

**ทำงาน**

3. แก้ไฟล์ → ทดสอบจนผ่าน (`bash scripts/sim/run_tb.sh tb_<module>` ต้องขึ้น `TB_PASS`)
4. บันทึกและส่งขึ้น GitHub (ทำซ้ำได้บ่อย ๆ):
   ```bash
   git status                     # แก้ไฟล์ไหนบ้าง
   git diff                       # แก้อะไรไป
   git add rtl/game/tetromino.v tb/game/tb_tetromino.v    # ใส่ชื่อไฟล์ — ห้าม git add .
   git commit -m "feat(tetromino): add SRS shape table" -m "Refs #12"
   git push -u origin feat/12-tetromino                   # ครั้งต่อไปพิมพ์แค่ git push
   ```
   ใช้ AI ช่วย → เพิ่ม `-m "Assisted-by: Claude Code"` ท้าย commit

**ส่งงาน**

5. GitHub → แถบเหลือง **Compare & pull request** → base = `main` → กรอก template:
   ใส่ `Closes #12` (issue ปิดเองตอน merge) · แนบหลักฐาน (รูป waveform / `TB_PASS` / รูปบอร์ด) ·
   ติ๊กเช็คลิสต์ ข้อไหนไม่เกี่ยวเขียน N/A
6. รอ CI 1–3 นาที
   - ❌ แดง → กด **Details** ดูสาเหตุ (§3) → แก้ใน branch เดิม → commit → push (PR อัปเดตเอง ไม่ต้องเปิดใหม่)
   - ✅ เขียว → **Merge pull request** (แบบ *Create a merge commit*) → **Delete branch**

**ปิดงาน**

7. เก็บกวาดในเครื่อง:
   ```bash
   git switch main
   git pull
   git branch -d feat/12-tetromino
   ```
8. ถ้างานยังไม่จบ / ส่งต่อคนอื่น → คอมเมนต์ *Handoff* ใน issue (แม่แบบ AGENTS §11)

**พลาดบ่อย**
- เผลอ commit บน `main` → push ไม่ผ่าน: `git switch -c feat/12-tetromino` แล้ว push branch นี้แทน จากนั้นถามในกลุ่มให้ช่วยเคลียร์ `main` ในเครื่อง
- ลืม pull ก่อนแตก branch → PR ขึ้นว่า conflict: ถามในกลุ่มก่อน อย่ากด resolve มั่ว

## 2. งานที่ต้องเทสบนบอร์ด (บอร์ดอยู่ที่ Korat คนเดียว)

1. ทำจนผ่าน simulation แล้ว push branch และเปิด PR ไว้ (ยังไม่ merge)
2. คอมเมนต์ใน PR แท็ก Korat บอก **ชื่อ branch** และ **ต้องดูอะไรบนบอร์ด** (เช่น "กด BTNL แล้วตัวต่อขยับซ้าย 1 ช่อง")
   — ไม่ต้องส่งไฟล์ `.bit` Korat build เองจาก branch
3. Korat โหลดลงบอร์ด แล้วแนบรูป/วิดีโอผลใน PR → ผ่านแล้วค่อย merge

## 3. CI ตรวจอะไร

| ชื่อ | ตรวจ | ถ้าแดงให้ดู |
|---|---|---|
| `layout` | ไฟล์อยู่ถูกโฟลเดอร์ ไม่มีไฟล์ขยะ ทุกโมดูลมี testbench | ข้อความบอกชื่อไฟล์ที่ผิด → ย้าย/ลบ (`.log`, `.xpr` ห้าม commit) |
| `lint` | Verilog ไม่มีข้อผิดพลาดพื้นฐาน (ความกว้างบิต, latch) | บรรทัดที่ Verilator ชี้ |
| `sim` | testbench ทุกตัวพิมพ์ `TB_PASS` | ดาวน์โหลด artifact `sim-logs` ดู log ของ tb ที่ FAIL |
| `synth` | (ยังไม่บังคับ) Yosys สังเคราะห์ได้ไหม | ดู `synth-log` |

**CI เขียว ≠ เล่นบนบอร์ดได้** — CI ทดสอบเฉพาะ simulation ต้องลองบนบอร์ดจริงด้วย (§2)

## 4. กติกาของกลุ่ม

- **รีวิวตัวเองแล้ว merge เองได้** เมื่อ CI เขียว (มีเพื่อนช่วยดูยิ่งดี แต่ไม่บังคับ)
- **ยกเว้น 2 อย่าง ให้มีอีกคนดู หรือประกาศในกลุ่มก่อน merge:** แก้ `constraints/*.xdc` · แก้ port ที่คนอื่นใช้
- **รับงานแทนเพื่อน:** เปลี่ยน Assignee เป็นตัวเอง + เขียน 1 บรรทัดว่าทำไม · commit ด้วยบัญชีตัวเองเสมอ ·
  ทำร่วมกันให้ใส่ `Co-authored-by: ชื่อ <อีเมล>` ท้าย commit
- ห้ามอัปโหลดไฟล์ผ่านหน้าเว็บ GitHub แทนคนอื่น
- **main แดงหลัง merge:** คน merge ล่าสุดแก้ภายใน ~1 ชม. หรือกด **Revert** ที่ PR นั้น
- ทำไม่ทัน → บอกใน issue **ก่อน** หมด phase ไม่ใช่วันสุดท้าย

## 5. วางไฟล์ตรงไหน (ย่อ)

| ไฟล์ | ที่อยู่ |
|---|---|
| โมดูล Verilog | `rtl/<common|io|video|game|features|top>/<module>.v` |
| Testbench | `tb/<โฟลเดอร์เดียวกัน>/tb_<module>.v` |
| ขาบอร์ด | แก้ `constraints/nexys_a7_100t.xdc` ไฟล์เดียว |
| บันทึกประชุม | `docs/meetings/YYYY-MM-DD-topic.md` |
| รูป waveform / บอร์ด | ลากใส่ใน PR ได้เลย · ถ้าจะใช้ในรายงาน → `media/` (< 1 MB) |
| วิดีโอ | อัป YouTube (unlisted)/Drive → ใส่ลิงก์ใน `media/VIDEOS.md` |
| ไม่แน่ใจ | ถามใน issue ก่อน อย่าสร้างโฟลเดอร์ใหม่เอง |

## 6. Vivado

ห้าม commit โปรเจค Vivado — สร้างใหม่จากสคริปต์ (ทุกอย่างไปอยู่ใน `build/` ซึ่ง git ไม่สนใจ)
รันใน PowerShell ที่โฟลเดอร์รีโป (แก้ path ให้ตรงกับที่ลง Vivado ไว้):
```powershell
& "C:\Xilinx\Vivado\2024.2\bin\vivado.bat" -mode batch -source scripts/vivado/create_project.tcl
& "C:\Xilinx\Vivado\2024.2\bin\vivado.bat" -mode batch -source scripts/vivado/build_bitstream.tcl   # ได้ build/out/tetris_top.bit
```
อยากใช้หน้าต่าง Vivado แบบ lab ก็ได้: เปิด `build/vivado/tetris.xpr` แล้วกด Run Synthesis / Generate Bitstream ตามปกติ
ไฟล์ `.v` ใหม่ให้สร้างใน `rtl/...` ของรีโป แล้วรัน `create_project.tcl` ซ้ำ (อย่าใช้ "Add Sources → Create File" หรือ "copy into project")

## 7. ใช้ AI ช่วย

AI (Claude Code, Copilot, Cursor, Gemini ฯลฯ) จะอ่าน `AGENTS.md` เอง · เราต้องอ่านและเข้าใจทุกบรรทัดก่อน commit ·
ใส่ `Assisted-by: <ชื่อเครื่องมือ>` ท้าย commit และติ๊กช่อง AI ใน PR · ถ้าทำไม่จบ ให้ AI เขียน handoff comment ใน issue
