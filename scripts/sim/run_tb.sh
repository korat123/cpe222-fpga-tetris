#!/usr/bin/env bash
# Usage: bash scripts/sim/run_tb.sh tb_vga_sync [--dump]
# Runs ONE testbench. --dump writes build/sim/<tb>.vcd (open with GTKWave / Vivado).
set -u
cd "$(dirname "$0")/../.."
name="${1:?usage: run_tb.sh tb_<module> [--dump]}"
tb=$(find tb -name "$name.v" | head -n1); [ -n "$tb" ] || { echo "no such testbench: $name"; exit 1; }
mkdir -p build/sim
iverilog -g2012 -Wall -Irtl/include -Itb/include -s "$name" -o "build/sim/$name.vvp" $(find rtl -name '*.v') "$tb" || exit 1
plus=""; [ "${2:-}" = "--dump" ] && plus="+dump"
vvp -n "build/sim/$name.vvp" $plus | tee "build/sim/$name.log"
grep -q "TB_PASS" "build/sim/$name.log" && ! grep -q "TB_FAIL" "build/sim/$name.log"
