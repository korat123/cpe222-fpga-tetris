# build_bitstream.tcl — synthesize, implement and write the bitstream to build/out/tetris_top.bit
# Usage: vivado -mode batch -source scripts/vivado/build_bitstream.tcl   (after create_project.tcl)
set root [file normalize [file join [file dirname [info script]] .. ..]]
open_project [file join $root build vivado tetris.xpr]
reset_run synth_1
launch_runs synth_1 -jobs 4; wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4; wait_on_run impl_1
open_run impl_1
file mkdir [file join $root build out]
report_timing_summary -file [file join $root build out timing_summary.rpt]
file copy -force [glob [file join $root build vivado tetris.runs impl_1 *.bit]] [file join $root build out tetris_top.bit]
puts "Bitstream: [file join $root build out tetris_top.bit]  (check WNS >= 0 in build/out/timing_summary.rpt)"
