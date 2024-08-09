if [file exists ../work/FIRQuesta] { exec rm -r FIRQuesta }
exec mkdir FIRQuesta

vlib FIRQuesta/work

vcom -2008 -l ./logs/FIRpackages.log -work work ../packages/params_package.vhdl
vcom -2008 -l ./logs/FIRpackages.log -work work ../packages/coeff_package.vhdl
vcom -2008 -l ./logs/FIRrtl.log ../rtl/fir_v7.vhdl
vcom -2008 -l ./logs/FIRrtl.log ../rtl/firFixedAXI.vhdl
vcom -2008 -l ./logs/FIRsim.log ../sim/fir_fixed_AXI_tb.vhdl

vsim -voptargs=+acc+firFixedAXI -gui work.fir_fixed_AXI_tb

add wave -divider Clock/Reset:
add wave -color green clk rstn

add wave -divider InputAXIStream:
add wave -color cyan s_axis_tdata s_axis_tready s_axis_tvalid s_axis_tlast

add wave -divider OutputAXIStream:
add wave -color yellow m_axis_tdata m_axis_tready m_axis_tvalid m_axis_tlast

run 1000ns

#quit -sim
