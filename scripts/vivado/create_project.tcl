# create_project.tcl — recreate the Vivado project from repo sources (never commit build/).
# Usage (terminal):       vivado -mode batch -source scripts/vivado/create_project.tcl
# Usage (Vivado Tcl Console on Windows): cd <repo folder>; source scripts/vivado/create_project.tcl
# Then open build/vivado/tetris.xpr in the Vivado GUI.
set root [file normalize [file join [file dirname [info script]] .. ..]]
create_project tetris [file join $root build vivado] -part xc7a100tcsg324-1 -force
set_property target_language Verilog [current_project]
add_files -norecurse [glob [file join $root rtl * *.v]]
add_files -norecurse [glob -nocomplain [file join $root rtl include *.vh]]
set_property include_dirs [file join $root rtl include] [get_filesets sources_1]
add_files -fileset constrs_1 [file join $root constraints nexys_a7_100t.xdc]
add_files -fileset sim_1 -norecurse [glob [file join $root tb * tb_*.v]]
add_files -fileset sim_1 -norecurse [glob -nocomplain [file join $root tb include *.vh]]
set_property include_dirs [list [file join $root rtl include] [file join $root tb include]] [get_filesets sim_1]
set_property top tetris_top [get_filesets sources_1]
update_compile_order -fileset sources_1
puts "Project ready: [file join $root build vivado tetris.xpr]"
