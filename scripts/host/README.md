# scripts/host — โปรแกรม bridge (คีย์บอร์ด/จอย → บอร์ด)

`bridge.py` ทำให้โน้ตบุ๊กเป็น "ตัวแปลงจอย" อ่านปุ่มที่กดบนคีย์บอร์ดหรือจอย แล้วส่ง 1 byte ผ่านสาย micro-USB เส้นเดิม (UART 115200) ไปให้ FPGA
**ไม่มี logic ของเกมอยู่ในโปรแกรมนี้** ทุกอย่างตัดสินบน FPGA สเปกเต็มอยู่ที่ [docs/input-controller.md](../../docs/input-controller.md)
เจ้าของ: Korat

## ติดตั้ง (ทำครั้งเดียว, Windows)
1. ติดตั้ง Python 3.10 ขึ้นไปจาก python.org (ติ๊ก "Add python.exe to PATH")
2. เปิด PowerShell หรือ Terminal ที่โฟลเดอร์ repo แล้วพิมพ์:
   ```
   py -m pip install pygame pyserial
   ```

## วิธีรัน
```
py scripts/host/bridge.py              # หาพอร์ตของบอร์ดเอง
py scripts/host/bridge.py --port COM5  # ระบุพอร์ตเอง (ดูเลขใน Device Manager → Ports)
py scripts/host/bridge.py --dry-run    # ไม่ต่อบอร์ด: พิมพ์ byte ที่จะส่งออกมาให้ดู
py scripts/host/bridge.py --list-pad   # ดูเลขปุ่ม/แกนของจอย ไว้แก้ PADMAP
```
- จะมีหน้าต่างเล็กขึ้นมา บอกพอร์ต สถานะ (Connected / Disconnected / DRY-RUN) ช่อง 6 ช่องที่ติดเมื่อกด และชื่อจอยที่เจอ
- **ถ้าใช้คีย์บอร์ด ต้องคลิกหน้าต่างนี้ก่อน** เพราะคีย์บอร์ดจะทำงานเฉพาะตอนหน้าต่างนี้ถูกเลือกอยู่ ส่วนจอยใช้ได้แม้ไปคลิกหน้าต่างอื่น
- ถ้าเปลี่ยนไปคลิกหน้าต่างอื่น โปรแกรมจะปล่อยทุกปุ่มของคีย์บอร์ดเอง ตัวต่อจะได้ไม่วิ่งค้าง
- ออก: กด **Esc** หรือปิดหน้าต่าง โปรแกรมจะส่ง `0x80` (ปล่อยทุกปุ่ม) ก่อนปิดเสมอ
- ถ้าสายหลุด หน้าต่างจะขึ้น Disconnected และลองต่อใหม่ทุก 1 วินาทีเอง ไม่ต้องปิดโปรแกรม

## ปุ่ม
| Action | คีย์บอร์ด (หลัก) | คีย์บอร์ด (สำรอง) | จอย (Xbox / PlayStation) |
|---|---|---|---|
| เลื่อนซ้าย | ← | A | D-pad ← หรือ stick ซ้ายเอียงซ้าย |
| เลื่อนขวา | → | D | D-pad → หรือ stick ซ้ายเอียงขวา |
| หมุน | ↑ | W | A (✕) หรือ D-pad ↑ |
| ตกเร็ว (soft drop) | ↓ | S | D-pad ↓ หรือ stick ซ้ายเอียงลง |
| BOMB | B | Q | X (□) |
| FREEZE | F | E | Y (△) |
| ออก | Esc | — | — |

- คีย์บอร์ดกับจอยใช้พร้อมกันได้ (โปรแกรม OR ให้)
- ต้องเอียง stick เกินครึ่งจึงนับ (deadzone 0.5)
- อยากเปลี่ยนปุ่ม ให้แก้ตาราง `KEYMAP` / `PADMAP` ด้านบนของ `bridge.py`
- จอยแต่ละยี่ห้อเลขปุ่มไม่เหมือนกัน ให้รัน `--list-pad` กดปุ่มดูเลข แล้วแก้ `PADMAP["buttons"]`

## เช็กว่าใช้ได้
1. `--dry-run`: กด ← ต้องเห็น `send 0x81  LEFT` และกด ← + ↓ ต้องเห็น `0x89`
2. ต่อบอร์ดที่โหลด bitstream แล้ว: หน้าต่างขึ้น Connected และ **LED15 บนบอร์ดติด**
3. ปิดโปรแกรมขณะกดค้าง: LED15 ดับภายใน ¼ วินาที และตัวต่อหยุดเอง (FPGA timeout 250 ms)

## ปัญหาที่พบบ่อย
| อาการ | วิธีแก้ |
|---|---|
| `No board port found - use --port COMx` | เปิด Device Manager → Ports (COM & LPT) ดูเลข COM ของ "USB Serial Port" แล้วใช้ `--port COMx` |
| `Several ports - use --port` | บอร์ดมีหลายพอร์ต ให้ลองทีละพอร์ตด้วย `--port` แล้วดูว่าพอร์ตไหนทำให้ LED15 ติด |
| `cannot open COMx` (Access denied) | มีโปรแกรมอื่นเปิดพอร์ตอยู่ เช่น serial monitor ให้ปิดก่อน (Vivado Hardware Manager ใช้ JTAG จึงไม่ชนกัน) |
| กดคีย์บอร์ดแล้วไม่มีอะไรขึ้น | คลิกหน้าต่าง bridge ก่อน |
| `ModuleNotFoundError: pygame` | `py -m pip install pygame pyserial` |

## วันเดโม
- ติดตั้ง Python, pygame, pyserial บนเครื่องที่จะใช้จริงไว้ล่วงหน้า แล้วซ้อมถอดสายดูสักครั้ง
- ถ้า bridge หรือจอยมีปัญหา ให้เล่นด้วยปุ่มบนบอร์ดต่อได้ทันที (BTNL/R/U/D/C) เพราะปุ่มบอร์ดใช้ได้เสมอ
