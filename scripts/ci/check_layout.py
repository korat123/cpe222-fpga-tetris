#!/usr/bin/env python3
"""check_layout.py — fail CI if a file is in the wrong place, badly named, generated, or too large.

Usage: python3 scripts/ci/check_layout.py
Rules come from AGENTS.md section 7. To allow a NEW kind of file, change this script in its own
PR and explain why in the PR description (so nobody quietly adds a new category).
"""
import pathlib
import re
import subprocess
import sys

files = subprocess.run(["git", "ls-files"], capture_output=True, text=True, check=True).stdout.split("\n")
files = [f for f in files if f]

AREAS = r"(common|io|video|game|features|top)"
ROOT_OK = {"README.md", "AGENTS.md", "CLAUDE.md", "CONTRIBUTING.md", "THIRD_PARTY_NOTICES.md",
           "Makefile", ".gitignore", ".gitattributes", ".editorconfig"}
DIR_OK = {"rtl", "tb", "constraints", "scripts", "docs", "media", "third_party", ".github", ".gemini", ".claude"}
RULES = [  # (prefix, regex that the rest of the path must fully match)
    ("rtl/include/", r"[a-z0-9_]+\.vh"),
    ("rtl/", AREAS + r"/[a-z0-9_]+\.v|README\.md"),
    ("tb/", r"include/[a-z0-9_]+\.vh|" + AREAS + r"/tb_[a-z0-9_]+\.v|" + AREAS + r"/[a-z0-9_]+\.wcfg"
            r"|vectors/[a-z0-9_]+/[A-Za-z0-9_.-]+\.(mem|hex|txt)|README\.md"),
    ("constraints/", r"nexys_a7_100t\.xdc|README\.md"),
    ("media/", r"(waveforms/[a-z0-9_]+|board|ui)/\d{8}-[a-z0-9-]+\.(png|jpg)|README\.md|VIDEOS\.md"),
    ("scripts/", r"(vivado|sim|ci|github)/[a-z0-9_]+\.(tcl|sh|py)"),
]
BANNED = re.compile(r"\.(xpr|jou|log|bit|bin|dcp|vcd|fst|wdb|vvp|mp4|mov|mkv|zip|str|rpt)$|(^|/)\.Xil/")
BAD_SUFFIX = re.compile(r"(_old|_new|_copy|_backup|_v\d+|_final)\.(v|vh|md)$")
MAX = {"media/": 1_000_000, "docs/": 10_000_000}
DEFAULT_MAX = 5_000_000

errors = []
for f in files:
    top = f.split("/")[0]
    if "/" not in f and f not in ROOT_OK:
        errors.append(f"unexpected file in repo root: {f}  (see AGENTS.md section 7)")
    if "/" in f and top not in DIR_OK:
        errors.append(f"unexpected top-level folder: {f}")
    if BANNED.search(f):
        errors.append(f"generated/binary file must not be committed: {f}")
    if BAD_SUFFIX.search(f):
        errors.append(f"no copies like *_old / *_v2 — git keeps history: {f}")
    for prefix, rx in RULES:
        if f.startswith(prefix):
            if not re.fullmatch(rx, f[len(prefix):]):
                errors.append(f"bad name or location: {f}")
            break
    p = pathlib.Path(f)
    if p.exists():
        size = p.stat().st_size
        limit = next((v for k, v in MAX.items() if f.startswith(k)), DEFAULT_MAX)
        if size > limit:
            errors.append(f"file too large ({size:,} B > {limit:,} B): {f}")

for f in files:  # every RTL module needs a matching testbench
    m = re.fullmatch(r"rtl/" + AREAS + r"/([a-z0-9_]+)\.v", f)
    if m and f"tb/{m[1]}/tb_{m[2]}.v" not in files:
        errors.append(f"missing testbench tb/{m[1]}/tb_{m[2]}.v for {f}")

if errors:
    print("Layout check FAILED:")
    print("\n".join("  - " + e for e in errors))
    sys.exit(1)
print(f"layout OK ({len(files)} files)")
