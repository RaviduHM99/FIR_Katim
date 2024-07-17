# You can Parameterized and Pass Parameters through here***********************************
set PROJ_NAME firFilter
set PROJ_FOLDER firFilter
set PROJ_DIR ../work/firFilter
set SOURCE_FOLDER ../rtl
set TB_FOLDER ../sim

# Check if the project directory exists and is a directory
if {[file exists $PROJ_DIR] && [file isdirectory $PROJ_DIR]} {
    exec rm -r $PROJ_FOLDER
}

# Create Project 
create_project $PROJ_NAME ./$PROJ_FOLDER -part xczu7ev-ffvc1156-2-e -force
set_property board_part xilinx.com:zcu106:part0:2.6 [current_project]

# Add Design Sources
#read_vhdl -vhdl2008 $SOURCE_FOLDER/register8.vhd
#read_vhdl -vhdl2008 $SOURCE_FOLDER/uartRx_mux.vhd

# Check Lints
#synth_design -top register8 -part xczu7ev-ffvc1156-2-e -lint 
#synth_design -top uartRx_mux -part xczu7ev-ffvc1156-2-e -lint 

# Simulation and Waveform generation



