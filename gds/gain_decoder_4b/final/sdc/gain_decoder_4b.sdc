###############################################################################
# Created by write_sdc
###############################################################################
current_design gain_decoder_4b
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name __VIRTUAL_CLK__ -period 10.0000 
set_clock_uncertainty 0.2500 __VIRTUAL_CLK__
set_input_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {gain_sel[0]}]
set_input_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {gain_sel[1]}]
set_input_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {gain_sel[2]}]
set_input_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {gain_sel[3]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s1[0]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s1[1]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s1[2]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s1[3]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s1[4]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s1_b[0]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s1_b[1]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s1_b[2]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s1_b[3]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s1_b[4]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s2[0]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s2[1]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s2[2]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s2[3]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s2[4]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s2_b[0]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s2_b[1]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s2_b[2]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s2_b[3]}]
set_output_delay 2.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {s2_b[4]}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0060 [get_ports {s1[4]}]
set_load -pin_load 0.0060 [get_ports {s1[3]}]
set_load -pin_load 0.0060 [get_ports {s1[2]}]
set_load -pin_load 0.0060 [get_ports {s1[1]}]
set_load -pin_load 0.0060 [get_ports {s1[0]}]
set_load -pin_load 0.0060 [get_ports {s1_b[4]}]
set_load -pin_load 0.0060 [get_ports {s1_b[3]}]
set_load -pin_load 0.0060 [get_ports {s1_b[2]}]
set_load -pin_load 0.0060 [get_ports {s1_b[1]}]
set_load -pin_load 0.0060 [get_ports {s1_b[0]}]
set_load -pin_load 0.0060 [get_ports {s2[4]}]
set_load -pin_load 0.0060 [get_ports {s2[3]}]
set_load -pin_load 0.0060 [get_ports {s2[2]}]
set_load -pin_load 0.0060 [get_ports {s2[1]}]
set_load -pin_load 0.0060 [get_ports {s2[0]}]
set_load -pin_load 0.0060 [get_ports {s2_b[4]}]
set_load -pin_load 0.0060 [get_ports {s2_b[3]}]
set_load -pin_load 0.0060 [get_ports {s2_b[2]}]
set_load -pin_load 0.0060 [get_ports {s2_b[1]}]
set_load -pin_load 0.0060 [get_ports {s2_b[0]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gain_sel[3]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gain_sel[2]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gain_sel[1]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gain_sel[0]}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_fanout 10.0000 [current_design]
