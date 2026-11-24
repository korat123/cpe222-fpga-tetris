#!/usr/bin/env bash
# สร้าง labels, milestones (phase) และ issues ทั้งหมดใน GitHub repo ด้วย gh CLI
# วิธีใช้:
#   1) ติดตั้ง gh แล้ว `gh auth login`
#   2) ใส่ชื่อ repo และ GitHub username ของแต่ละคนด้านล่าง (เว้นว่างได้ = ไม่ assign)
#   3) bash scripts/setup_github.sh
set -euo pipefail

REPO="korat123/cpe222-fpga-tetris"   # <-- แก้เป็นของจริง
KORAT="korat123"                      # GitHub username
NASSASI="miranassasi"
TEERAWIT="Atom7792"
PORNNAPAT="penguinnoiii"
PHOLAWATH="XbunGam"

# ---------- labels ----------
label(){ gh label create "$1" --repo "$REPO" --color "$2" --description "$3" --force >/dev/null; }
label "area:vga"         "1f6feb" "VGA sync / renderer / UI"
label "area:game"        "8250df" "FSM, collision, board, line clear, LFSR"
label "area:display"     "bf8700" "7-seg, LED, score"
label "area:io"          "0e8a16" "buttons, clock, constraints"
label "area:integration" "d1242f" "tetris_top, board testing"
label "type:rtl"         "c5def5" "Verilog module"
label "type:tb"          "d4c5f9" "Testbench"
label "type:docs"        "e4e669" "Docs / report / slides"
label "type:bug"         "b60205" "Bug"
label "optional"         "cccccc" "P5 extra — cut if no time"

# ---------- milestones = phases ----------
ms(){ gh api "repos/$REPO/milestones" -f title="$1" -f description="$2" >/dev/null 2>&1 || true; }
ms "P0 Foundation"     "Gate: INTERFACES.md approved, .xdc complete, everyone can build an empty project"
ms "P1 Modules"        "Gate: every module has a passing testbench and is merged to main"
ms "P2 Skeleton"       "Gate: static 10x20 board on VGA, buttons->LED once per press, 7-seg shows digits"
ms "P3 Playable"       "Gate: fall/move/rotate/lock/clear/score on board; system testbench passes"
ms "P4 Complete"       "Gate: all proposal features, no timing violations, FEATURE FREEZE"
ms "P5 Extras"         "Optional. Only after P4 gate."
ms "P6 Delivery"       "Gate: demo <= 7 min rehearsed, backup video, README, report, slides PDF"

# ---------- issues ----------
issue(){ # title milestone labels assignee body
  local a=(); [ -n "$4" ] && a=(--assignee "$4")
  gh issue create --repo "$REPO" --title "$1" --milestone "$2" --label "$3" "${a[@]}" --body "$5" >/dev/null
  echo "  + $1"; }

echo "P0"
issue "Repo settings, ruleset, project board (docs/setup-github.md)" "P0 Foundation" "area:integration,type:docs" "$KORAT" \
"- [ ] ทำตาม docs/setup-github.md
- [ ] ruleset: ต้องผ่าน PR + CI (ไม่บังคับ approve)
- [ ] Project board: Backlog / Ready / In progress / In review / Done"
issue "Nexys A7 constraints file (.xdc)" "P0 Foundation" "area:io" "$PHOLAWATH" \
"- [ ] clk 100 MHz, btnL/R/U/D/C, SW0-SW15, LED0-15
- [ ] 7-seg an[7:0], seg[6:0]
- [ ] VGA R/G/B[3:0], HS, VS"
issue "Agree conventions + port lists (docs/INTERFACES.md)" "P0 Foundation" "area:game,type:docs" "$PORNNAPAT" \
"- [ ] ประชุมกลุ่มตกลงกติกากลางและ port list
- [ ] ทุกคน approve PR ของไฟล์นี้
- [ ] หลังจากนี้เปลี่ยน interface ต้องแจ้งกลุ่ม"
issue "Check Vivado scripts on a lab/Windows PC" "P0 Foundation" "area:integration" "$PHOLAWATH" \
"- [ ] source scripts/vivado/create_project.tcl ใช้ได้
- [ ] build bitstream เปล่าผ่าน"
issue "Final proposal with chosen special features (due Nov 30)" "P0 Foundation" "type:docs" "$NASSASI" \
"- [ ] ทั้งกลุ่มเลือกฟีเจอร์พิเศษ (ตอบ feedback TA)
- [ ] อัปเดต proposal แล้ววาง PDF ใน docs/proposal/ ผ่าน PR"
issue "Get a display for testing (borrow VGA monitor or capture card)" "P0 Foundation" "area:integration" "$KORAT" \
"- [ ] ดูภาพจากบอร์ดได้ก่อนเริ่ม P2"
issue "Every member: first practice PR (add yourself to README team table)" "P0 Foundation" "type:docs" "" \
"- [ ] ทุกคนตั้งค่า GitHub Desktop + อีเมลถูก
- [ ] ทุกคนเปิด PR แรก แล้ว merge เอง
- [ ] เช็คว่าชื่อขึ้นใน Insights → Contributors"

echo "P1"
issue "vga_sync + tb" "P1 Modules" "area:vga,type:rtl,type:tb" "$KORAT" \
"- [ ] h_count 0-799, v_count 0-524 เดินตาม pix_en
- [ ] HS/VS active-low ตำแหน่งถูก, video_on, x, y
- [ ] tb ตรวจขอบเขต counter และจังหวะ sync"
issue "vga_renderer v1: board frame + cells from board[599:0]" "P1 Modules" "area:vga,type:rtl,type:tb" "$KORAT" \
"- [ ] กรอบสนาม 220<=x<420, 50<=y<450 (ปรับได้)
- [ ] แปลงพิกเซล -> (col,row) แล้วอ่านสีจาก board
- [ ] tb: ป้อน board ทดสอบ ตรวจสีที่พิกเซลตัวอย่าง"
issue "seven_segment (multiplex + decoder) + tb" "P1 Modules" "area:display,type:rtl,type:tb" "$NASSASI" \
"- [ ] สแกน 8 หลัก ~1 kHz, active-low
- [ ] แสดง score_bcd 6 หลัก
- [ ] tb ตรวจ pattern ของเลข 0-9"
issue "score_level (BCD score, lines, level) + tb" "P1 Modules" "area:display,type:rtl,type:tb" "$NASSASI" \
"- [ ] 1/2/3/4 แถว = +100/300/500/800 (BCD)
- [ ] level = 1 + lines/10
- [ ] tb: ครอบคลุมการทดเลข BCD"
issue "tetromino ROM (7 types x 4 rotations) + tb" "P1 Modules" "area:game,type:rtl,type:tb" "$TEERAWIT" \
"- [ ] 28 entries, 4 cells ต่อ entry
- [ ] tb เทียบกับตารางที่คาดไว้ทุก entry"
issue "collision + tb (walls, floor, blocks)" "P1 Modules" "area:game,type:rtl,type:tb" "$TEERAWIT" \
"- [ ] oob: x<0, x>9, y>19
- [ ] occ: ทับช่องที่มีบล็อก
- [ ] tb ครอบคลุมขอบซ้าย/ขวา/ล่าง และการหมุนชิดกำแพง"
issue "lfsr 16-bit + seed load + tb" "P1 Modules" "area:game,type:rtl,type:tb" "$TEERAWIT" \
"- [ ] ให้ค่า 1-7 เท่านั้น (ข้าม 0)
- [ ] seed_load รับ seed จาก free-running counter ตอนกด start"
issue "board_memory + tb" "P1 Modules" "area:game,type:rtl,type:tb" "$KORAT" \
"- [ ] เขียน 1 ช่องต่อ clock (lock)
- [ ] shift แถว (สำหรับ line_clear)
- [ ] reset ล้างทั้งบอร์ด"
issue "game_fsm skeleton (6 states) + tb" "P1 Modules" "area:game,type:rtl,type:tb" "$PORNNAPAT" \
"- [ ] IDLE, SPAWN, FALL, LOCK, CLEAR, GAME_OVER
- [ ] tb ไล่ครบทุก transition"
issue "line_clear + tb" "P1 Modules" "area:game,type:rtl,type:tb" "$PORNNAPAT" \
"- [ ] สแกนล่างขึ้นบน, ตรวจแถวเดิมซ้ำหลัง shift
- [ ] tb: 0, 1, 2, 4 แถว และแถวไม่ติดกัน"
issue "button_control (sync + debounce + one-pulse) + tb" "P1 Modules" "area:io,type:rtl,type:tb" "$PHOLAWATH" \
"- [ ] synchronizer 2 FF
- [ ] debounce ~10 ms
- [ ] tb: สัญญาณเด้ง -> pulse เดียว"
issue "clock_enable (tick_pixel, tick_fall by level, soft drop) + tb" "P1 Modules" "area:io,type:rtl,type:tb" "$KORAT" \
"- [ ] tick_pixel ทุก 4 clock
- [ ] tick_fall จากตาราง FALL_MAX ตาม level
- [ ] soft_drop = เร็วพิเศษ"

echo "P2"
issue "tetris_top v0: static board on VGA" "P2 Skeleton" "area:integration,area:vga" "$KORAT" \
"- [ ] ต่อ clock_enable + vga_sync + vga_renderer + board ค่าคงที่
- [ ] ภาพขึ้นบนจอจริง (แนบรูป)"
issue "tetris_top v0: buttons -> LEDs, 7-seg shows constant" "P2 Skeleton" "area:integration,area:io" "$PHOLAWATH" \
"- [ ] กด 1 ครั้ง = LED counter +1 เสมอ
- [ ] 7-seg แสดง 123456"

echo "P3"
issue "Piece spawns and falls by itself" "P3 Playable" "area:game,area:integration" "$PORNNAPAT" \
"- [ ] FSM + tetromino + collision + fall_tick
- [ ] หยุดที่พื้นแล้วไป LOCK"
issue "Move left/right and rotate with collision check" "P3 Playable" "area:game" "$TEERAWIT" \
"- [ ] ชนแล้วไม่ขยับ / ยกเลิกการหมุน
- [ ] soft drop (BTND)"
issue "Renderer: overlay falling piece" "P3 Playable" "area:vga" "$KORAT" \
"- [ ] วาดตัวต่อที่ตกทับบน board"
issue "Lock + spawn next piece (with lfsr)" "P3 Playable" "area:game" "$PORNNAPAT" \
"- [ ] เขียน 4 ช่องลง board_memory แล้ว spawn ใหม่"
issue "Line clear + score wired to 7-seg" "P3 Playable" "area:display,area:game" "$NASSASI" \
"- [ ] ลบแถวบนบอร์ดจริง, คะแนนขึ้น 7-seg"
issue "System testbench (scripted button sequences)" "P3 Playable" "type:tb,area:integration" "$PORNNAPAT" \
"- [ ] tb ระดับ tetris_top จำลองการเล่น 1 รอบ ตรวจ board และ score"
issue "Board test checklist (manual) passes" "P3 Playable" "area:integration" "$PHOLAWATH" \
"- [ ] ทุกปุ่ม, ตก, หมุนชิดกำแพง, ลบ 1-4 แถว, คะแนน"

echo "P4"
issue "Adaptive speed: level -> fall_tick" "P4 Complete" "area:display,area:io" "$NASSASI" \
"- [ ] ทุก 10 แถว level +1 แล้วตกเร็วขึ้นจริงบนบอร์ด"
issue "Next-piece preview box" "P4 Complete" "area:vga" "$KORAT" \
"- [ ] วาดชิ้นถัดไปในกล่อง NEXT"
issue "UI: SCORE / LEVEL / LINES digits + labels on VGA" "P4 Complete" "area:vga" "$KORAT" \
"- [ ] ตัวเลขแบบ 7-segment วาดด้วยสี่เหลี่ยม (ไม่ต้องใช้ font ROM)
- [ ] ข้อความ PAUSED / GAME OVER"
issue "Game over + restart (BTNC / SW0) + pause" "P4 Complete" "area:game" "$PORNNAPAT" \
"- [ ] spawn ชน -> GAME_OVER
- [ ] SW0 รีเซ็ตได้ทุกสถานะ, BTNC pause"
issue "LED status mapping" "P4 Complete" "area:display" "$NASSASI" \
"- [ ] LED level bar, LED14 pause, LED15 game over"
issue "Timing closure: no violations in Vivado" "P4 Complete" "area:integration" "$PHOLAWATH" \
"- [ ] WNS >= 0, แนบ timing summary
- [ ] ถ้าไม่ผ่าน: เพิ่ม pipeline ใน renderer / แบ่ง line_clear"

echo "P5"
issue "[Extra] Adaptive difficulty engine (reads player skill)" "P5 Extras" "optional,area:game" "$TEERAWIT" \
"- [ ] วัดความสูงกอง / รู / ความเร็ววาง
- [ ] ปรับความเร็ว + น้ำหนักการสุ่ม, แสดงบน LED"
issue "[Extra] PWM sound effects" "P5 Extras" "optional,area:display" "$NASSASI" \
"- [ ] เสียงตอนลบแถว / game over ผ่านช่องเสียบหูฟัง"
issue "[Extra] Tilt control via on-board accelerometer (SPI)" "P5 Extras" "optional,area:io" "$PHOLAWATH" \
"- [ ] SPI master FSM อ่านค่าแกน X
- [ ] เอียงซ้าย/ขวา = เลื่อน"

echo "P6"
issue "Demo script <= 7 min + rehearsal" "P6 Delivery" "type:docs" "$PHOLAWATH" \
"- [ ] ลำดับเดโม + ใครพูดอะไร, ซ้อมจับเวลา 2 รอบ"
issue "Backup demo video" "P6 Delivery" "type:docs" "$PHOLAWATH" \
"- [ ] อัดวิดีโอเล่นจริงบนบอร์ด เผื่อฮาร์ดแวร์มีปัญหา"
issue "Final README (build, run, architecture)" "P6 Delivery" "type:docs" "$PHOLAWATH" \
"- [ ] วิธี build, ผัง I/O, block diagram"
issue "Final report" "P6 Delivery" "type:docs" "$NASSASI" \
"- [ ] ทุกคนเขียนส่วนโมดูลของตัวเอง, Nassasi รวมเล่ม"
issue "Final slides (PDF)" "P6 Delivery" "type:docs" "$KORAT" \
"- [ ] อัปเดตจาก proposal ให้ตรงกับของที่ทำจริง"

echo "Done."
