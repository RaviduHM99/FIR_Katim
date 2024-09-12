vlib sim_build/xilinx_vip
vlib sim_build/xpm
vlib sim_build/fifo_generator_v13_2_9
vlib sim_build/xpm_cdc_gen_v1_0_3

vmap xilinx_vip sim_build/xilinx_vip
vmap xpm sim_build/xpm
vmap fifo_generator_v13_2_9 sim_build/fifo_generator_v13_2_9
vmap xpm_cdc_gen_v1_0_3 sim_build/xpm_cdc_gen_v1_0_3

vlog -work xilinx_vip  -incr -mfcu  -sv -L axi4stream_vip_v1_1_15 -L xilinx_vip "+incdir+C:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -incr -mfcu  -sv -L axi4stream_vip_v1_1_15 -L xilinx_vip "+incdir+C:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"C:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work work  -incr -mfcu  "+incdir+C:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"C:/Projects/FIR_Katim/work/FIRVivado/firFilter.ip_user_files/bd/design_2/ip/design_2_fir_wrapper_0_0/sim/design_2_fir_wrapper_0_0.v" \

vlog -work fifo_generator_v13_2_9  -incr -mfcu  "+incdir+C:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"C:/Projects/FIR_Katim/work/FIRVivado/firFilter.gen/sources_1/bd/design_2/ipshared/ac72/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_9  -93  \
"C:/Projects/FIR_Katim/work/FIRVivado/firFilter.gen/sources_1/bd/design_2/ipshared/ac72/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_9  -incr -mfcu  "+incdir+C:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"C:/Projects/FIR_Katim/work/FIRVivado/firFilter.gen/sources_1/bd/design_2/ipshared/ac72/hdl/fifo_generator_v13_2_rfs.v" \

vcom -work work -2008 "C:/Projects/FIR_Katim/packages/params_package.vhdl" \
"C:/Projects/FIR_Katim/packages/coeff_package.vhdl" \
"C:/Projects/FIR_Katim/rtl/fir_v7.vhdl" \
"C:/Projects/FIR_Katim/rtl/firFixedAXI.vhdl" \

vlog -work work -incr -mfcu C:/Projects/FIR_Katim/rtl/fir_wrapper.v

vlog -work work -incr -mfcu  "+incdir+C:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"C:/Projects/FIR_Katim/work/FIRVivado/firFilter.ip_user_files/bd/design_2/ip/design_2_fifo_generator_0_0/sim/design_2_fifo_generator_0_0.v" \
"C:/Projects/FIR_Katim/work/FIRVivado/firFilter.ip_user_files/bd/design_2/ip/design_2_fifo_generator_0_1/sim/design_2_fifo_generator_0_1.v" \

vlog -work xpm_cdc_gen_v1_0_3  -incr -mfcu  "+incdir+C:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"C:/Projects/FIR_Katim/work/FIRVivado/firFilter.gen/sources_1/bd/design_2/ipshared/891d/hdl/xpm_cdc_gen_v1_0_vl_rfs.v" \

vlog -work work  -incr -mfcu  "+incdir+C:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"C:/Projects/FIR_Katim/work/FIRVivado/firFilter.ip_user_files/bd/design_2/ip/design_2_xpm_cdc_gen_0_1/sim/design_2_xpm_cdc_gen_0_1.v" \

vlog -work work \
"C:/Projects/FIR_Katim/cocotb/questa_scripts/glbl.v" \

vlog -work work +define+COCOTB_SIM -timescale 1ns/1ps -incr -mfcu "+incdir+C:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"C:/Projects/FIR_Katim/work/FIRVivado/firFilter.ip_user_files/bd/design_2/sim/design_2.v" \