#************************ CoCoTB Makefile **************************
TOPLEVEL_LANG ?= vhdl
PWD:=$(shell pwd)

# For Debug Purposes
#export COCOTB_LOG_LEVEL=DEBUG 

export PYTHONPATH := $(PWD)/../model:$(PYTHONPATH)
SOURCES_FOR_QUESTASIM = C:/Projects/FIR_Katim

ifeq ($(TOPLEVEL_LANG),verilog)
	VERILOG_SOURCES = $(SOURCES_FOR_QUESTASIM)/fir_v7.sv
else ifeq ($(TOPLEVEL_LANG),vhdl)
	VHDL_SOURCES = $(SOURCES_FOR_QUESTASIM)/packages/params_package.vhdl $(SOURCES_FOR_QUESTASIM)/packages/coeff_package.vhdl $(SOURCES_FOR_QUESTASIM)/rtl/fir_v7.vhdl
	ifneq ($(filter $(SIM),questa ius xcelium),)
		COMPILE_ARGS += -2008
	endif
else
	$(error A valid value (verilog or vhdl) was not provided for TOPLEVEL_LANG=$(TOPLEVEL_LANG))
endif

TOPLEVEL := firfilterv7 
MODULE   := fixed_tests_basic

include $(shell cocotb-config --makefiles)/Makefile.sim
#************************************************************************

#********************* Post Simulation - Plot Graphs ********************
post_sim::
	python post_simulation.py

#********************* For Clean the Previous Run ***********************
# Specify the directory
DIR := C:/Projects/FIR_Katim/cocotb

# List of specific files and directories to remove
TARGETS := transcript results.xml modelsim.ini __pycache__ sim_build

clean::
	@for target in $(TARGETS); do \
		if [ -e $(DIR)/$$target ]; then \
			echo "Removing $(DIR)/$$target"; \
			rm -rf $(DIR)/$$target; \
		else \
			echo "$(DIR)/$$target does not exist"; \
		fi \
	done
#************************************************************************