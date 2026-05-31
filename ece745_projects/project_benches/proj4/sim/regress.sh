#!/bin/bash
# ECE 745 Project 4 Regression Script

export PATH=/mnt/apps/public/COE/mg_apps/questa2026.1/questasim/bin:$PATH

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export ECE745_PROJECT_HOME="$SCRIPT_DIR/../../.."
export ECE745_COMMON_HOME="$ECE745_PROJECT_HOME/verification_ip"

echo "=== Compiling ==="
rm -rf work *.ucdb transcript

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

vlog +incdir+${ECE745_COMMON_HOME}/ncsu_pkg ${ECE745_COMMON_HOME}/ncsu_pkg/ncsu_pkg.sv

vlog ${ECE745_PROJECT_HOME}/verification_ip/interface_packages/wb_pkg/src/wb_if.sv

vlog +incdir+${ECE745_PROJECT_HOME}/verification_ip/ncsu_pkg \
     +incdir+${ECE745_PROJECT_HOME}/verification_ip/interface_packages/wb_pkg \
     ${ECE745_PROJECT_HOME}/verification_ip/interface_packages/wb_pkg/wb_pkg.sv

vlog ${ECE745_PROJECT_HOME}/verification_ip/interface_packages/i2c_pkg/src/i2c_if.sv

vlog +incdir+${ECE745_PROJECT_HOME}/verification_ip/ncsu_pkg \
     +incdir+${ECE745_PROJECT_HOME}/verification_ip/interface_packages/i2c_pkg \
     ${ECE745_PROJECT_HOME}/verification_ip/interface_packages/i2c_pkg/i2c_pkg.sv

ENV_PKG=${ECE745_PROJECT_HOME}/verification_ip/environment_packages/i2cmb_env_pkg
vlog +incdir+${ECE745_PROJECT_HOME}/verification_ip/ncsu_pkg \
     +incdir+${ECE745_PROJECT_HOME}/verification_ip/interface_packages/wb_pkg/src \
     +incdir+${ECE745_PROJECT_HOME}/verification_ip/interface_packages/i2c_pkg \
     +incdir+${ENV_PKG} \
     ${ENV_PKG}/i2cmb_env_pkg.sv

vlog ../testbench/top.sv
vopt +acc +cover=bcesf top -o optimized_debug_top_tb

echo "=== Running Tests ==="
UCDB_LIST=""
while read TEST_NAME SEED; do
    [ -z "$TEST_NAME" ] && continue
    UCDB_NAME="${TEST_NAME}_${SEED}.ucdb"
    echo "--- Running $TEST_NAME seed=$SEED"
    vsim -c -coverage -classdebug -msgmode both -sv_seed $SEED \
         -do "coverage save -onexit ${UCDB_NAME}; run -all; quit -f" \
         optimized_debug_top_tb
    UCDB_LIST="$UCDB_LIST $UCDB_NAME"
done < testlist

echo "=== Merging simulation UCDBs ==="
vcover merge -stats=none -strip 0 -totals merged_tests.ucdb $UCDB_LIST

echo "=== Converting test plan ==="
xml2ucdb -format Excel i2cmb_test_plan.xls test_plan.ucdb

echo "=== Creating regression.ucdb ==="
vcover merge -stats=none -strip 0 -totals regression.ucdb merged_tests.ucdb test_plan.ucdb

vsim -gui -coverage -viewcov regression.ucdb
