create_clock -period 7.8125 -name clk  [get_ports clk]
# set_input_jitter clk 0.010

# set_input_delay -clock [get_clocks clk] -min -add_delay 1.000 [get_ports rstn]
# set_input_delay -clock [get_clocks clk] -min -add_delay 2.000 [get_ports rstn]

# set_input_delay -clock [get_clocks clk] -min -add_delay 1.000 [get_ports enable]
# set_input_delay -clock [get_clocks clk] -min -add_delay 2.000 [get_ports enable]

# set_input_delay -clock [get_clocks clk] -min -add_delay 2.000 [get_ports inX]
# set_input_delay -clock [get_clocks clk] -min -add_delay 2.500 [get_ports inX]

# set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports outY]
# set_output_delay -clock [get_clocks clk] -min -add_delay 1.000 [get_ports outY]
