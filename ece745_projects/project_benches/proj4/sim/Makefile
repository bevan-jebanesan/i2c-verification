export ECE745_PROJECT_HOME ?= $(PWD)/../../..
export ECE745_COMMON_HOME ?= $(ECE745_PROJECT_HOME)/verification_ip
include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile
clean:
	rm -rf work *.wlf transcript qrun.out vsim.ucdb merged.ucdb sim_and_testplan_merged.ucdb i2cmb_test_plan.ucdb
comp_I2C_MB:
	vcom ../rtl/iicmb_int_pkg.vhd
	vcom ../rtl/iicmb_pkg.vhd
	vcom ../rtl/mbyte.vhd
	vcom ../rtl/mbit.vhd
	vcom ../rtl/bus_state.vhd
	vcom ../rtl/filter.vhd
	vcom ../rtl/conditioner.vhd
	vcom ../rtl/conditioner_mux.vhd
	vcom ../rtl/iicmb_m.vhd
	vcom ../rtl/regblock.vhd
	vcom ../rtl/wishbone.vhd
	vcom ../rtl/iicmb_m_wb.vhd
comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg
	vlog ../testbench/top.sv
optimize:
	vopt +acc top -o optimized_debug_top_tb
compile: comp_I2C_MB comp_bench optimize
simulate:
	vsim -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" optimized_debug_top_tb
debug_3step: clean compile simulate
view_coverage:
	vsim -gui -coverage -viewcov merged.ucdb -do "verif open"
merge_coverage:
	xml2ucdb -format Excel i2cmb_test_plan.xls i2cmb_test_plan.ucdb
	vcover merge -stats=none -strip 0 -totals merged.ucdb vsim.ucdb i2cmb_test_plan.ucdb
run_p3: clean
	vcom ../rtl/iicmb_int_pkg.vhd
	vcom ../rtl/iicmb_pkg.vhd
	vcom ../rtl/mbyte.vhd
	vcom ../rtl/mbit.vhd
	vcom ../rtl/bus_state.vhd
	vcom ../rtl/filter.vhd
	vcom ../rtl/conditioner.vhd
	vcom ../rtl/conditioner_mux.vhd
	vcom ../rtl/iicmb_m.vhd
	vcom ../rtl/regblock.vhd
	vcom ../rtl/wishbone.vhd
	vcom ../rtl/iicmb_m_wb.vhd
	$(MAKE) comp_ncsu_pkg
	$(MAKE) comp_wb_pkg
	$(MAKE) comp_i2c_pkg
	$(MAKE) comp_i2cmb_env_pkg
	vlog ../testbench/top.sv
	vopt +acc +cover=bcesf top -o optimized_debug_top_tb
	vsim -c -coverage -classdebug -msgmode both -do run_p3.do optimized_debug_top_tb
	xml2ucdb -format Excel i2cmb_test_plan.xls i2cmb_test_plan.ucdb
	vcover merge -stats=none -strip 0 -totals merged.ucdb vsim.ucdb i2cmb_test_plan.ucdb
	vsim -gui -coverage -viewcov merged.ucdb -do "verif open"
# ---------------------------------------------------------------
# Project 4 targets
# ---------------------------------------------------------------
compile_p4: clean
	vcom ../rtl/iicmb_int_pkg.vhd
	vcom ../rtl/iicmb_pkg.vhd
	vcom ../rtl/mbyte.vhd
	vcom ../rtl/mbit.vhd
	vcom ../rtl/bus_state.vhd
	vcom ../rtl/filter.vhd
	vcom ../rtl/conditioner.vhd
	vcom ../rtl/conditioner_mux.vhd
	vcom ../rtl/iicmb_m.vhd
	vcom ../rtl/regblock.vhd
	vcom ../rtl/wishbone.vhd
	vcom ../rtl/iicmb_m_wb.vhd
	$(MAKE) comp_ncsu_pkg
	$(MAKE) comp_wb_pkg
	$(MAKE) comp_i2c_pkg
	$(MAKE) comp_i2cmb_env_pkg
	vlog ../testbench/top.sv
	vopt +acc +cover=bcesf top -o optimized_debug_top_tb
run_p4: compile_p4
	./regress.sh
	vsim -gui -coverage -viewcov regression.ucdb -do "verif open"
view_p4:
	vsim -gui -coverage -viewcov regression.ucdb -do "verif open"
# Single seed interactive simulation for waveform debugging
# Usage: make wave_p4 SEED=123456
wave_p4: compile_p4
	vsim -gui -coverage -classdebug -msgmode both \
	     -sv_seed $(SEED) \
	     -do "coverage save -onexit wave_debug.ucdb; do wave.do; run -all" \
	     optimized_debug_top_tb
debug:
	qrun -64 -gui -visualizer -onfinish stop -classdebug -uvmcontrol=all -msgmode both -permit_unmatched_virtual_intf -l run.log -f lab1_filelist.f -sv_seed 123456 -msglimit error -msglimitcount 20 -do "set IterationLimit 140000; set NoQuitOnFinish 1; coverage attribute -name TESTNAME -value test_top; coverage save -onexit test_top.ucdb; do wave.do" -debug,livesim -qwavedb=+signal+memory=1024+report+parameter+class+assertion+uvm_schematic+msg+classmemory=1024+statictaskfunc -top top -covermultiuserenv -designfile design.bin
