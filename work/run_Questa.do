if [file exists ../work/FIRQuesta] { exec rm -r FIRQuesta }
exec mkdir FIRQuesta

vlib FIRQuesta/work

vcom -2008 -l ./logs/FIRpackages.log -work work ../packages/params_package.vhdl
vcom -2008 -l ./logs/FIRpackages.log -work work ../packages/coeff_package.vhdl
vcom -2008 -l ./logs/FIRrtl.log ../rtl/fir_v7.vhdl
vcom -2008 -l ./logs/FIRsim.log ../sim/fir_fixed_tb.vhdl

vsim -gui work.fir_fixed_tb

quietly WaveActivateNextPane {} 0
add wave -divider Inputs:
add wave -color green clk rstn
add wave -color cyan enable inX

add wave -divider Outputs:
add wave -color yellow outY

run 1000ns

#quit -sim
