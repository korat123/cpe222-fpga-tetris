# Makefile — shortcuts. On Windows use Git Bash/WSL, or run the scripts directly (see CONTRIBUTING.md).
TB ?= tb_vga_sync
VIVADO ?= vivado

.PHONY: check layout lint sim sim-all project bit program clean
check: layout lint sim-all            ## same as CI
layout: ; python3 scripts/ci/check_layout.py
lint:   ; verilator --lint-only -Wall -Wno-fatal -Wno-DECLFILENAME -Irtl/include $$(find rtl -name '*.v' ! -path 'rtl/features/*') --top-module tetris_top
sim:    ; bash scripts/sim/run_tb.sh $(TB)
sim-all:; bash scripts/sim/run_all.sh
project:; $(VIVADO) -mode batch -source scripts/vivado/create_project.tcl
bit:    ; $(VIVADO) -mode batch -source scripts/vivado/build_bitstream.tcl
program:; $(VIVADO) -mode batch -source scripts/vivado/program_board.tcl
clean:  ; rm -rf build
