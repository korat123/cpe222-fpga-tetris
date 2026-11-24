#!/usr/bin/python3
"""bridge.py — CHAOTETRIS host bridge: laptop keyboard / game controller -> FPGA over USB-UART.

Spec: docs/input-controller.md (sections 3, 4, 6, 7). The laptop is only a "controller adapter":
it reads which keys are held and sends ONE byte with all of them. There is NO game logic here —
the FPGA (host_input -> button_control -> game_fsm) decides what every key does.

Byte (115200 baud, 8N1), sent when the state changes AND every 50 ms as a heartbeat:
    bit  7 6   5      4     3          2       1      0
         1 0   FREEZE BOMB  SOFT_DROP  ROTATE  RIGHT  LEFT
    0x80 = nothing held, 0x81 = LEFT, 0x89 = LEFT + SOFT_DROP.

Usage (Windows):  py scripts/host/bridge.py [--port COM5] [--dry-run] [--list-pad]
Needs: py -m pip install pygame pyserial   (Python 3.10+)
"""
from __future__ import annotations

import argparse
import os
import sys
import time

# controller input keeps working while another window (e.g. Vivado) has focus
os.environ.setdefault("SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS", "1")
os.environ.setdefault("PYGAME_HIDE_SUPPORT_PROMPT", "1")

import pygame  # noqa: E402  (must come after the environment variables above)

try:
    import serial
    from serial.tools import list_ports
except ImportError:  # --dry-run and --list-pad still work without pyserial
    serial = None
    list_ports = None

# ---------------------------------------------------------------------------------------------
# Settings — change the keys here (docs/input-controller.md section 3)
# ---------------------------------------------------------------------------------------------
LEFT, RIGHT, ROTATE, SOFT_DROP, BOMB, FREEZE = range(6)   # value = bit number in the byte
ACTION_NAMES = ("LEFT", "RIGHT", "ROTATE", "SOFT_DROP", "BOMB", "FREEZE")

KEYMAP = {                      # keyboard key -> action (main key, backup key)
    pygame.K_LEFT: LEFT,       pygame.K_a: LEFT,
    pygame.K_RIGHT: RIGHT,     pygame.K_d: RIGHT,
    pygame.K_UP: ROTATE,       pygame.K_w: ROTATE,
    pygame.K_DOWN: SOFT_DROP,  pygame.K_s: SOFT_DROP,
    pygame.K_b: BOMB,          pygame.K_q: BOMB,
    pygame.K_f: FREEZE,        pygame.K_e: FREEZE,
}
QUIT_KEY = pygame.K_ESCAPE

PADMAP = {                      # game controller (SDL numbering; check yours with --list-pad)
    "buttons": {0: ROTATE,      # Xbox A / PlayStation Cross
                2: BOMB,        # Xbox X / PlayStation Square
                3: FREEZE},     # Xbox Y / PlayStation Triangle
    "hat": 0,                   # D-pad: left/right = move, up = rotate, down = soft drop
    "stick_x": 0,               # left stick axes: tilt left/right = move, tilt down = soft drop
    "stick_y": 1,
    "deadzone": 0.5,            # tilt more than half way to count
}

BAUD = 115200
HEARTBEAT_S = 0.050             # resend the state every 50 ms (FPGA times out after 250 ms)
RECONNECT_S = 1.0               # try to (re)open the port every second while disconnected
FTDI_VID = 0x0403               # Digilent boards use an FTDI FT2232 USB-UART
RELEASE_ALL = 0x80


# ---------------------------------------------------------------------------------------------
# Pure helpers (no hardware needed — easy to test)
# ---------------------------------------------------------------------------------------------
def encode_state(actions: set[int]) -> int:
    """Held actions -> protocol byte: header 10 in bits 7..6, one bit per action."""
    byte = 0x80
    for a in actions:
        byte |= 1 << a
    return byte


def describe(byte: int) -> str:
    held = [name for bit, name in enumerate(ACTION_NAMES) if byte & (1 << bit)]
    return " + ".join(held) if held else "(nothing)"


class KeyboardState:
    """Tracks held keys from KEYDOWN/KEYUP events (works only while the window has focus)."""

    def __init__(self) -> None:
        self.held_keys: set[int] = set()

    def handle(self, event: pygame.event.Event) -> None:
        if event.type == pygame.KEYDOWN and event.key in KEYMAP:
            self.held_keys.add(event.key)
        elif event.type == pygame.KEYUP:
            self.held_keys.discard(event.key)
        elif event.type == getattr(pygame, "WINDOWFOCUSLOST", -1):
            self.held_keys.clear()      # no KEYUP arrives after focus is lost: never leave keys stuck

    def actions(self) -> set[int]:
        return {KEYMAP[k] for k in self.held_keys}


def pad_actions(pads: list) -> set[int]:
    """Current actions from every connected controller (OR-ed together)."""
    acts: set[int] = set()
    dz = PADMAP["deadzone"]
    for js in pads:
        for button, action in PADMAP["buttons"].items():
            if button < js.get_numbuttons() and js.get_button(button):
                acts.add(action)
        if PADMAP["hat"] < js.get_numhats():
            hx, hy = js.get_hat(PADMAP["hat"])
            if hx < 0: acts.add(LEFT)
            if hx > 0: acts.add(RIGHT)
            if hy > 0: acts.add(ROTATE)
            if hy < 0: acts.add(SOFT_DROP)
        if max(PADMAP["stick_x"], PADMAP["stick_y"]) < js.get_numaxes():
            x, y = js.get_axis(PADMAP["stick_x"]), js.get_axis(PADMAP["stick_y"])
            if x < -dz: acts.add(LEFT)
            if x > dz: acts.add(RIGHT)
            if y > dz: acts.add(SOFT_DROP)
    return acts


def find_board_port() -> tuple[str | None, list[str]]:
    """Return (port, all candidate descriptions). Port is None unless exactly one candidate."""
    if list_ports is None:
        return None, []
    cands = []
    for p in list_ports.comports():
        text = f"{p.description} {p.manufacturer or ''}".lower()
        if p.vid == FTDI_VID or "digilent" in text or "ft2232" in text:
            cands.append(p)
    names = [f"{p.device} ({p.description})" for p in cands]
    return (cands[0].device if len(cands) == 1 else None), names


# ---------------------------------------------------------------------------------------------
# Link to the board (real serial port, or printing for --dry-run)
# ---------------------------------------------------------------------------------------------
class SerialLink:
    def __init__(self, port_arg: str | None) -> None:
        self.port_arg = port_arg
        self.port: str | None = port_arg
        self.ser = None
        self.next_try = 0.0
        self.warned = False
        self.last_msg = ""
        self.status = "Disconnected"

    def tick(self, now: float) -> None:
        """(Re)open the port at most once per RECONNECT_S while disconnected."""
        if self.ser is not None or now < self.next_try:
            return
        self.next_try = now + RECONNECT_S
        if serial is None:
            self.status = "pyserial missing: py -m pip install pyserial"
            return
        if self.port_arg is None:
            self.port, cands = find_board_port()
            if self.port is None:
                self.status = "No board port found - use --port COMx" if not cands else "Several ports - use --port"
                if not self.warned:
                    print(f"[bridge] board USB-UART candidates: {cands or 'none'} -> run with --port COMx")
                    self.warned = True
                return
        try:
            # serial_for_url also accepts "loop://" (used to test this class without a board)
            self.ser = serial.serial_for_url(self.port, BAUD, timeout=0, write_timeout=0.2)
            self.status = "Connected"
            self.last_msg = ""
            print(f"[bridge] connected to {self.port} at {BAUD} baud")
        except (serial.SerialException, OSError) as exc:
            self.status = "Disconnected"
            self.ser = None
            msg = f"[bridge] cannot open {self.port}: {exc} (retrying every {RECONNECT_S:.0f} s)"
            if msg != self.last_msg:            # print once, not every retry
                print(msg)
                self.last_msg = msg

    def send(self, byte: int) -> None:
        if self.ser is None:
            return
        try:
            self.ser.write(bytes([byte]))
        except (serial.SerialException, OSError) as exc:
            print(f"[bridge] link lost: {exc}")
            self.close()

    def close(self) -> None:
        if self.ser is not None:
            try:
                self.ser.close()
            except (serial.SerialException, OSError):
                pass
        self.ser = None
        self.status = "Disconnected"


class DryRunLink:
    """--dry-run: no board. Prints every change; heartbeats are summarised once per second."""

    def __init__(self) -> None:
        self.port = "DRY-RUN"
        self.status = "DRY-RUN (no board)"
        self.t0 = time.monotonic()
        self.last = None
        self.beats = 0
        self.next_report = self.t0 + 1.0

    def tick(self, now: float) -> None:
        if now >= self.next_report:
            print(f"{now - self.t0:7.3f}s  heartbeat: {self.beats} x 0x{self.last:02X} in the last second")
            self.beats = 0
            self.next_report = now + 1.0

    def send(self, byte: int) -> None:
        now = time.monotonic()
        if byte != self.last:
            print(f"{now - self.t0:7.3f}s  send 0x{byte:02X}  {describe(byte)}")
            self.last = byte
        else:
            self.beats += 1

    def close(self) -> None:
        pass


# ---------------------------------------------------------------------------------------------
# Window
# ---------------------------------------------------------------------------------------------
def draw(screen, font, link, held: set[int], pads: list) -> None:
    screen.fill((20, 20, 28))
    ok = link.status.startswith(("Connected", "DRY-RUN"))
    lines = [(f"Port: {link.port or '?'}", (220, 220, 220)),
             (f"Status: {link.status}", (90, 220, 120) if ok else (240, 90, 90)),
             (f"Controllers: {', '.join(js.get_name() for js in pads) or 'none'}", (200, 200, 200))]
    for i, (text, colour) in enumerate(lines):
        screen.blit(font.render(text, True, colour), (12, 10 + 22 * i))
    for bit, name in enumerate(ACTION_NAMES):
        x = 12 + bit * 68
        on = bit in held
        pygame.draw.rect(screen, (240, 200, 60) if on else (60, 60, 72), (x, 92, 62, 44), border_radius=6)
        label = font.render(name.replace("SOFT_DROP", "DROP"), True, (20, 20, 20) if on else (200, 200, 200))
        screen.blit(label, (x + 31 - label.get_width() // 2, 105))
    hint = "Click this window before using the keyboard.  Esc = quit"
    screen.blit(font.render(hint, True, (150, 150, 160)), (12, 160))
    pygame.display.flip()


# ---------------------------------------------------------------------------------------------
# Modes
# ---------------------------------------------------------------------------------------------
def open_pads() -> list:
    return [pygame.joystick.Joystick(i) for i in range(pygame.joystick.get_count())]


def list_pad(exit_after: float | None) -> int:
    """--list-pad: print controller numbers so PADMAP can be adjusted."""
    pygame.init()
    pygame.display.set_mode((420, 120))
    pygame.display.set_caption("CHAOTETRIS bridge - list pad (Esc to quit)")
    pads = open_pads()
    if not pads:
        print("[list-pad] no controller found - plug one in (USB is more reliable than Bluetooth)")
    for js in pads:
        print(f"[list-pad] {js.get_instance_id()}: {js.get_name()}  buttons={js.get_numbuttons()} "
              f"axes={js.get_numaxes()} hats={js.get_numhats()}")
    t_end = None if exit_after is None else time.monotonic() + exit_after
    clock = pygame.time.Clock()
    while t_end is None or time.monotonic() < t_end:
        for ev in pygame.event.get():
            if ev.type == pygame.QUIT or (ev.type == pygame.KEYDOWN and ev.key == QUIT_KEY):
                pygame.quit()
                return 0
            if ev.type == pygame.JOYDEVICEADDED:
                pads = open_pads()
                print(f"[list-pad] connected: {pads[-1].get_name()}" if pads else "[list-pad] connected")
            elif ev.type == pygame.JOYBUTTONDOWN:
                print(f"[list-pad] button {ev.button} pressed")
            elif ev.type == pygame.JOYHATMOTION:
                print(f"[list-pad] hat {ev.hat} = {ev.value}")
            elif ev.type == pygame.JOYAXISMOTION and abs(ev.value) > PADMAP["deadzone"]:
                print(f"[list-pad] axis {ev.axis} = {ev.value:+.2f}")
        clock.tick(100)
    pygame.quit()
    return 0


def run_bridge(args) -> int:
    pygame.init()
    screen = pygame.display.set_mode((420, 190))
    pygame.display.set_caption("CHAOTETRIS bridge")
    font = pygame.font.Font(None, 22)
    link = DryRunLink() if args.dry_run else SerialLink(args.port)
    keyboard = KeyboardState()
    pads = open_pads()
    clock = pygame.time.Clock()
    last_byte, last_sent = None, 0.0
    t_end = None if args.exit_after is None else time.monotonic() + args.exit_after
    print(f"[bridge] {'dry run - nothing is sent to a board' if args.dry_run else 'looking for the board'}; "
          f"controllers: {[js.get_name() for js in pads] or 'none'}")
    try:
        running = True
        while running and (t_end is None or time.monotonic() < t_end):
            for ev in pygame.event.get():
                if ev.type == pygame.QUIT or (ev.type == pygame.KEYDOWN and ev.key == QUIT_KEY):
                    running = False
                elif ev.type in (pygame.JOYDEVICEADDED, pygame.JOYDEVICEREMOVED):
                    pads = open_pads()
                    print(f"[bridge] controllers: {[js.get_name() for js in pads] or 'none'}")
                keyboard.handle(ev)
            now = time.monotonic()
            link.tick(now)
            held = keyboard.actions() | pad_actions(pads)   # keyboard OR controller
            byte = encode_state(held)
            if byte != last_byte:
                link.send(byte)
                last_byte, last_sent = byte, now
            elif now - last_sent >= HEARTBEAT_S:
                link.send(byte)
                # keep a steady 50 ms rhythm even if the loop wakes up late (Windows timer ~15 ms)
                last_sent = max(last_sent + HEARTBEAT_S, now - HEARTBEAT_S)
            draw(screen, font, link, held, pads)
            clock.tick(250)
    except KeyboardInterrupt:
        pass
    finally:
        link.send(RELEASE_ALL)          # always release every key on the FPGA before closing
        print(f"[bridge] exit: sent 0x{RELEASE_ALL:02X} (release all)")
        link.close()
        pygame.quit()
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="CHAOTETRIS keyboard/controller -> FPGA bridge (UART 115200 8N1)")
    ap.add_argument("--port", help="serial port of the board, e.g. COM5 (default: auto-detect)")
    ap.add_argument("--dry-run", action="store_true", help="no board: print the bytes instead of sending")
    ap.add_argument("--list-pad", action="store_true", help="print controller button/axis/hat numbers")
    ap.add_argument("--exit-after", type=float, metavar="SECONDS", help="quit automatically (for tests)")
    args = ap.parse_args(argv)
    if sys.version_info < (3, 10):
        print("Python 3.10+ is required")
        return 1
    if args.list_pad:
        return list_pad(args.exit_after)
    return run_bridge(args)


if __name__ == "__main__":
    sys.exit(main())
