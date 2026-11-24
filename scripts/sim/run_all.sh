#!/usr/bin/env bash
# Usage: bash scripts/sim/run_all.sh
# Compiles every tb/**/tb_*.v with all RTL (Icarus Verilog) and runs it.
# Pass = log contains "TB_PASS" and no "TB_FAIL". Exit code 1 if any testbench fails.
set -u
cd "$(dirname "$0")/../.."
mkdir -p build/sim
fail=0; stubs=0; total=0
RTL=$(find rtl -name '*.v' | sort)
for tb in $(find tb -name 'tb_*.v' | sort); do
  name=$(basename "$tb" .v); total=$((total+1))
  if ! iverilog -g2012 -Wall -Irtl/include -Itb/include -s "$name" -o "build/sim/$name.vvp" $RTL "$tb" \
       > "build/sim/$name.compile.log" 2>&1; then
    echo "COMPILE FAIL $name (see build/sim/$name.compile.log)"; cat "build/sim/$name.compile.log"; fail=1; continue
  fi
  timeout 120 vvp -n "build/sim/$name.vvp" > "build/sim/$name.log" 2>&1
  if grep -q "TB_PASS" "build/sim/$name.log" && ! grep -q "TB_FAIL" "build/sim/$name.log"; then
    if grep -q "STUB" "build/sim/$name.log"; then echo "PASS (stub, no checks yet) $name"; stubs=$((stubs+1));
    else echo "PASS $name"; fi
  else
    echo "FAIL $name (see build/sim/$name.log)"; tail -n 20 "build/sim/$name.log"; fail=1
  fi
done
echo "----"
echo "$total testbenches, $stubs still stubs, result: $([ $fail = 0 ] && echo OK || echo FAILED)"
exit $fail
