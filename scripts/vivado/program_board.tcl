# program_board.tcl — program the connected Nexys A7 with build/out/tetris_top.bit
# Usage: vivado -mode batch -source scripts/vivado/program_board.tcl
set root [file normalize [file join [file dirname [info script]] .. ..]]
open_hw_manager
connect_hw_server
open_hw_target
set dev [lindex [get_hw_devices xc7a100t*] 0]
current_hw_device $dev
set_property PROGRAM.FILE [file join $root build out tetris_top.bit] $dev
program_hw_devices $dev
puts "Programmed $dev"
