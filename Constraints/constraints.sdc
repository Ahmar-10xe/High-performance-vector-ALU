create_clock -name clk -period 0.66 -waveform {0 0.33} [get_ports "clk"]         
set_clock_transition -rise 0.033 [get_clocks "clk"]
set_clock_transition -fall 0.033 [get_clocks "clk"]
set_clock_uncertainty 0.030 [get_ports "clk"]
set_input_delay -max 0.33 [get_ports "a"] -clock [get_clocks "clk"]
set_input_delay -max 0.33 [get_ports "b"] -clock [get_clocks "clk"]
set_input_delay -max 0.33 [get_ports "precision"] -clock [get_clocks "clk"]
set_input_delay -max 0.33 [get_ports "opcode"] -clock [get_clocks "clk"]
set_output_delay -max 0.33 [get_ports "result_final"] -clock [get_clocks "clk"]



