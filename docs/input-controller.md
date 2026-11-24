# Input design — laptop keyboard & game controller (CHAOTETRIS)

> สถานะ: **ACCEPTED** (ตรงกับ proposal ฉบับแก้ 24 พ.ย.) · **implement แล้ว:** RTL `uart_rx`, `host_input`, `button_control` = sim-pass (PR #65) · `scripts/host/bridge.py` (PR #66) · ยังไม่ได้ทดสอบบนบอร์ด (รอ XDC #2 และ tetris_top)
> หลักการ: **โน้ตบุ๊กเป็นแค่ "ตัวแปลงจอย"** — ไม่มี logic ของเกมอยู่บนโน้ตบุ๊กเลย เกมทั้งหมดอยู่บน FPGA

## 1. ภาพรวม

```
Laptop keyboard ─┐
Game controller ─┴─► scripts/host/bridge.py ──UART 115200 (micro-USB เส้นเดิม)──► uart_rx ─► host_input ─┐
                                                                                                         ├─► button_control ─► game_fsm / powerup_controller
Board buttons BTNL/R/U/D/C (สำรองเสมอ) ──────────────────────────────────────────────────────────────────┘
Board switches: SW0 reset · SW1 select (board-button mode) · SW2 demo timer · SW15 pause
```

- สาย micro-USB เส้นเดียวใช้ได้ทั้งโปรแกรมบอร์ด (JTAG) และส่งข้อมูล (UART) พร้อมกัน
- **ปุ่มบนบอร์ดใช้ได้เสมอ** (OR กับ input จากโน้ตบุ๊ก) → ถ้าโน้ตบุ๊ก/จอยมีปัญหาวันเดโม เล่นต่อได้ทันที

## 2. การกระทำในเกม (actions)

| Action | พฤติกรรม | แหล่ง |
|---|---|---|
| `LEFT` / `RIGHT` | เลื่อน 1 ช่องทันทีที่กด · **กดค้าง**: รอ 200 ms แล้วเลื่อนซ้ำทุก 80 ms (auto-repeat) · กดทั้งสองพร้อมกัน = ไม่เลื่อน | keyboard / controller / BTNL, BTNR |
| `ROTATE` | หมุนตามเข็ม 1 ครั้งต่อการกด (ไม่ repeat) · ชนแล้วยกเลิกการหมุน | ↑ / A / BTNU |
| `SOFT_DROP` | **กดค้าง** = ตกเร็ว (ใช้อัตรา soft drop ของ `timers`) · ปล่อย = กลับความเร็วปกติ | ↓ / D-pad ↓ / BTND |
| `BOMB` | ใช้ bomb 1 ครั้งต่อการกด ถ้ามี charge ≥ 1 | B / X(□) |
| `FREEZE` | ใช้ freeze 1 ครั้งต่อการกด ถ้ามี charge ≥ 1 และ freeze ยังไม่ทำงานอยู่ | F / Y(△) |
| `POWERUP` (บอร์ดเท่านั้น) | BTNC ใช้ power-up ที่เลือกด้วย SW1 (0 = bomb, 1 = freeze) — ตาม proposal | BTNC + SW1 |

**ทำไม keyboard/controller มีปุ่ม bomb และ freeze แยกกัน:** ผู้เล่นจะได้ไม่ต้องเอื้อมไปสับ SW1 บนบอร์ดระหว่างเล่น (ตรงกับเหตุผลที่ไม่อยากจับบอร์ด) · ปุ่มบนบอร์ดยังทำงานตาม proposal เดิม (BTNC + SW1)
→ `powerup_controller` รับคำขอ 2 แบบ: "use bomb", "use freeze" (BTNC+SW1 ถูกแปลงเป็นหนึ่งในสองแบบนี้ใน `button_control`) · ตกลงแล้ว (ปุ่ม bomb/freeze แยก)

**ไม่มีใน input:** pause (ใช้ SW15), reset (SW0), demo timer (SW2) — นาน ๆ ใช้ครั้ง ไม่ต้องจับบอร์ดระหว่างเล่น
**chaos "สลับซ้ายขวา"** ทำใน `game_fsm` หลังชั้น input — `bridge.py` และ `button_control` ไม่ต้องรู้สถานะเกมเลย

## 3. ปุ่มที่ใช้

| Action | Keyboard (หลัก) | Keyboard (สำรอง) | Controller (Xbox / PlayStation) |
|---|---|---|---|
| LEFT | ← | A | D-pad ← หรือ stick ซ้ายเอียงซ้าย |
| RIGHT | → | D | D-pad → หรือ stick ซ้ายเอียงขวา |
| ROTATE | ↑ | W | A (✕) หรือ D-pad ↑ |
| SOFT_DROP | ↓ | S | D-pad ↓ หรือ stick ซ้ายเอียงลง |
| BOMB | B | Q | X (□) |
| FREEZE | F | E | Y (△) |
| ออกจากโปรแกรม bridge | Esc | — | — |

- Stick ซ้ายใช้ deadzone 0.5 (เอียงเกินครึ่งจึงนับ)
- ปุ่มทั้งหมดตั้งค่าใหม่ได้ที่ตาราง `KEYMAP` / `PADMAP` ด้านบนของ `bridge.py`
- ทดสอบจอยของเพื่อนตั้งแต่ต้น (ต่อสายดีกว่า Bluetooth) — เลขปุ่มของจอยแต่ละยี่ห้ออาจไม่ตรงกัน ใช้ `bridge.py --list-pad` ดูเลขปุ่มจริง

## 4. โปรโตคอล (laptop → FPGA)

- UART **115200 baud, 8 data bits, no parity, 1 stop bit (8N1)**, ทางเดียว laptop → FPGA
- ส่ง **1 byte = สถานะปุ่มทั้งหมด** เมื่อมีการเปลี่ยนแปลง **และ** ส่งซ้ำทุก 50 ms (heartbeat)

| bit | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|
| ความหมาย | 1 | 0 | FREEZE | BOMB | SOFT_DROP | ROTATE | RIGHT | LEFT |

- bit 7..6 ต้องเป็น `10` — ไม่ใช่ = ทิ้ง byte นั้น (กันข้อมูลขยะ)
- ตัวอย่าง: ไม่กดอะไร = `0x80` · กด ← ค้าง = `0x81` · กด ← + ↓ = `0x89`
- **Timeout:** FPGA ไม่ได้รับ byte ที่ถูกต้องเกิน **250 ms** → ถือว่าปล่อยทุกปุ่ม และ `link_ok = 0`
  (กันกรณีโปรแกรมค้าง/ดึงสายขณะกดปุ่มค้าง แล้วตัวต่อวิ่งไม่หยุด)

## 5. ฝั่ง FPGA (Verilog)

| โมดูล | ไฟล์ | หน้าที่ | เจ้าของ |
|---|---|---|---|
| `uart_rx` | `rtl/io/uart_rx.v` | รับ 8N1: synchronizer 2 FF → ตรวจ start bit → สุ่มกลางบิตทุก 868 clocks (100 MHz / 115200) → `rx_data[7:0]` + `rx_valid` (pulse) + `rx_error` (stop bit ผิด) | Korat |
| `host_input` | `rtl/io/host_input.v` | ตรวจ header `10` → เก็บ `host_keys[5:0]` (level) → timeout 250 ms (25,000,000 clocks) → `link_ok` | Korat |
| `button_control` (แก้) | `rtl/io/button_control.v` | debounce ปุ่มบอร์ด → **OR** กับ `host_keys` → edge pulse + auto-repeat ของ L/R → แปลง BTNC+SW1 เป็น bomb/freeze request | Korat |

พอร์ต (ฉบับจริงอยู่ใน `docs/INTERFACES.md` — `button_control` มี `sw_pause`, `sw_demo`, `pause_level`, `select_level`, `demo_level` และพารามิเตอร์ `DEBOUNCE_CLKS` เพิ่มจากด้านล่าง):

```verilog
module uart_rx #(parameter CLKS_PER_BIT = 868) (
  input  wire clk, rst, rx,                 // rx = UART line from the USB-UART bridge
  output wire [7:0] rx_data, output wire rx_valid, output wire rx_error);

module host_input #(parameter TIMEOUT_CLKS = 25_000_000) (
  input  wire clk, rst, input wire [7:0] rx_data, input wire rx_valid,
  output wire [5:0] host_keys,              // {FREEZE,BOMB,SOFT_DROP,ROTATE,RIGHT,LEFT}, level
  output wire link_ok);

module button_control #(parameter REPEAT_DELAY_CLKS = 20_000_000, REPEAT_RATE_CLKS = 8_000_000) (
  input  wire clk, rst,
  input  wire [4:0] btn_raw,                // board buttons {C,D,U,R,L}
  input  wire sw_select,                    // SW1: 0 = bomb, 1 = freeze (board BTNC only)
  input  wire [5:0] host_keys, input wire link_ok,
  output wire move_left, move_right, rotate,  // 1-cycle pulses (L/R auto-repeat)
  output wire soft_drop,                      // level
  output wire use_bomb, use_freeze);          // 1-cycle pulses
```

- พารามิเตอร์ทุกตัวลดค่าได้ใน testbench (เช่น `CLKS_PER_BIT = 4`, `TIMEOUT_CLKS = 100`) ให้ simulation เร็ว
- ขา `UART_TXD_IN` (FT2232 → FPGA) ต้องเอาจาก Digilent master XDC เท่านั้น — ห้ามพิมพ์เลขขาเอง
- LED (เสนอ): **LED15 = link_ok** (ติด = โน้ตบุ๊กเชื่อมต่ออยู่) · ระหว่าง P2 ใช้ LED0–5 แสดง `host_keys` ตรง ๆ เพื่อดีบัก

## 6. ฝั่งโน้ตบุ๊ก — `scripts/host/bridge.py`

- Python 3.10+ · ไลบรารี: `pip install pygame pyserial` (pygame อ่านทั้งคีย์บอร์ดและจอย)
- **หาพอร์ตบอร์ดเอง** (อุปกรณ์ USB-UART ของ Digilent/FTDI) — ถ้าเจอหลายพอร์ต/ไม่เจอ ใช้ `--port COM5`
- เปิดหน้าต่างเล็กแสดง: พอร์ต, สถานะ Connected/Disconnected, ปุ่มที่กดอยู่ (6 ช่อง), จอยที่เจอ
- **คีย์บอร์ดต้องเลือกหน้าต่างนี้ไว้** (คลิกที่หน้าต่างก่อนเล่น) · จอยอ่านได้แม้ไม่ได้เลือกหน้าต่าง (ตั้ง `SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS=1`)
- ส่ง byte เมื่อสถานะเปลี่ยน + ทุก 50 ms · สายหลุด → ขึ้น Disconnected แล้วพยายามเชื่อมต่อใหม่ทุก 1 วินาที
- รวมคีย์บอร์ดกับจอยด้วย OR (ใช้พร้อมกันได้ เช่น คนหนึ่งถือจอย อีกคนใช้คีย์บอร์ด)
- โหมดทดสอบ: `--dry-run` (ไม่ต่อบอร์ด พิมพ์ byte ออกจอ) · `--list-pad` (แสดงเลขปุ่ม/แกนของจอย)
- Esc หรือปิดหน้าต่าง = ส่ง `0x80` (ปล่อยทุกปุ่ม) ก่อนปิดเสมอ
- เจ้าของ: **Korat** · วิธีติดตั้งและใช้งาน: [`scripts/host/README.md`](../scripts/host/README.md)

## 7. กรณีพิเศษ (edge cases)

| กรณี | พฤติกรรมที่ต้องเป็น |
|---|---|
| ดึงสาย / ปิดโปรแกรม ขณะกด ← ค้าง | ≤ 250 ms ตัวต่อหยุดเลื่อน (timeout) · LED15 ดับ |
| ← และ → พร้อมกัน | ไม่เลื่อน |
| กด ↑ ค้าง | หมุนครั้งเดียว (ไม่ repeat) |
| กดปุ่มบอร์ดและจอยพร้อมกัน | OR — นับเป็นการกดครั้งเดียว ไม่ซ้อน 2 ครั้ง |
| byte header ผิด / stop bit ผิด | ทิ้ง ไม่เปลี่ยนสถานะ (timeout ยังนับต่อ) |
| Pause (SW15 ON) | `game_fsm` ไม่รับ action ทั้งหมด (ไม่เก็บไว้ทำต่อ) — ชั้น input ส่งตามปกติ |
| Chaos สลับซ้ายขวา | `game_fsm` สลับ `move_left`/`move_right` — input ไม่เกี่ยว |
| BOMB/FREEZE แต่ไม่มี charge | ไม่มีอะไรเกิดขึ้น (UI อาจกะพริบ "NO CHARGE") |
| หลัง reset | `host_keys = 0`, `link_ok = 0` จนได้ byte แรก |

## 8. การทดสอบ

**Testbench (CI)**
- `tb_uart_rx`: ส่ง `0x80`, `0x81`, `0xBF`, ส่งติดกันหลาย byte, stop bit ผิด → `rx_error`, สัญญาณรบกวนสั้น ๆ ไม่นับเป็น start bit
- `tb_host_input`: header ผิดถูกทิ้ง · timeout → ปล่อยทุกปุ่ม + `link_ok=0` · heartbeat ต่อเนื่องไม่ timeout
- `tb_button_control`: OR ปุ่มบอร์ดกับ host · auto-repeat ของ L/R ตามเวลา · ROTATE ไม่ repeat · L+R = ไม่เลื่อน · BTNC+SW1 → use_bomb/use_freeze

**บนบอร์ด (P2 gate เพิ่ม)**
- `bridge.py` ต่อแล้ว LED15 ติด · กดแต่ละปุ่มบนคีย์บอร์ด/จอย → LED0–5 ตรงกับตาราง §4
- ปิด `bridge.py` ขณะกดค้าง → LED ดับภายใน ¼ วินาที

## 9. ลำดับงาน (phase)

| Phase | งาน |
|---|---|
| P0 | ทีมยืนยันสเปกนี้ · ทดสอบจอยของเพื่อนกับ `--list-pad` · แก้ proposal (§10) |
| P1 | ✅ `uart_rx`, `host_input`, แก้ `button_control` + testbench · `bridge.py` · เปิด `scripts/host/` ใน layout check (PR #65, #66) |
| P2 | Gate: ปุ่มบนคีย์บอร์ด/จอย → LED บนบอร์ด, LED15 = link |
| P3 | ใช้เล่นเกมจริง (move/rotate/drop) |
| P4 | BOMB/FREEZE ผ่าน keyboard/controller |
| P6 | ซ้อมเดโมบนเครื่องที่จะใช้จริง (ติดตั้ง Python/pygame/pyserial ล่วงหน้า) + ซ้อมกรณีถอดสาย |

## 10. ข้อความแก้ proposal

- ตาราง I/O เพิ่ม: **USB-UART (micro-USB) — Input — รับสถานะปุ่มจากคีย์บอร์ดโน้ตบุ๊ก/จอยผ่านโปรแกรม bridge (115200 baud, 1 byte ต่อสถานะ)**
- BTNL/BTNR/BTNU/BTND/BTNC: เพิ่มคำว่า "(backup input)" · เพิ่มแถว **SW15 — Input — Pause**
- ส่วน Hardware: แก้ "No extra sensors or controllers" เป็น "A laptop keyboard and a game controller are used through a small host bridge program; all game logic remains in the FPGA." และเพิ่มจอยในรายการอุปกรณ์ (Existing)
- ผังโมดูล: เพิ่ม `UART RX → Host input` ก่อน `Debounce/Button control`
