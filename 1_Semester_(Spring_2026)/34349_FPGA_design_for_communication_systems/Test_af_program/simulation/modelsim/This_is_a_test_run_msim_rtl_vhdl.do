transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/hakon/Documents/DTU/Kandidat/Hakon_master_notes/1_Semester_(Spring_2026)/34349_FPGA_design_for_communication_systems/Test_af_program/This_is_a_test.vhd}

