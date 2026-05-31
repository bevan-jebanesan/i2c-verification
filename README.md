# I²C Multi-Bus Controller — Functional Verification

A layered **SystemVerilog** verification environment for an OpenCores **I²C Multiple-Bus Controller (IICMB)** RTL core, controlled over a **Wishbone** bus. The testbench drives the Wishbone register side, models the I²C slave on the bus side, and uses a **reference-model predictor + self-checking scoreboard** with **coverage-driven closure** of a written test plan.

> Built on a UVM-style class library (object factory, configuration database, transaction/component base classes). DUT is VHDL; testbench is SystemVerilog (mixed-language).

## Results

| Metric | Result |
|--------|--------|
| Functional coverage | **100%** — 11 covergroups, **57/57 bins**, 15 coverpoints/crosses |
| Scoreboard | **200+ self-checked transactions, 0 mismatches** |
| Code coverage | **82% statement · 81% branch · 88% FSM-state** |
| Stimulus | directed + constrained-random tests · **6-seed regression** |
| Test plan | 20+ items, linked to RTL via XML → UCDB |
| Tool | Questa / QuestaSim 2026.1 |

## Architecture

```
            top.sv
  wb_if <—Wishbone—> [ IICMB DUT (VHDL) ] <—I²C scl/sda—> i2c_if
                          |
   ┌─────────────── i2cmb_test / i2cmb_environment ───────────────┐
   │  generator ─ drives Wishbone (control) + I²C slave (bus)      │
   │  wb_agent (driver+monitor) ── monitor ─► predictor           │
   │  i2c_agent (driver+monitor) ─ monitor ─► scoreboard          │
   │  predictor (reference model) ─► scoreboard.predict()         │
   │  scoreboard (compare) ─► coverage (covergroups)              │
   └──────────────────────────────────────────────────────────────┘
```

The **predictor** watches Wishbone register writes (DPR/CMDR) and predicts the expected I²C transaction; the **monitor** independently reconstructs the actual transaction from the bus; the **scoreboard** compares the two. Two independent views = true self-checking.

## DUT register map

| Reg | Addr | Purpose |
|-----|------|---------|
| CSR  | 0x00 | Control/Status (core enable, interrupt enable) |
| DPR  | 0x01 | Data/Parameter (address byte, write data, bus#, wait count) |
| CMDR | 0x02 | Command (START/WRITE/READ_ACK/READ_NAK/STOP/SET_BUS/WAIT) + status |
| FSMR | 0x03 | FSM state (read-only) |

## Coverage-driven closure

- **Functional coverage** (11 covergroups): I²C op/address/data + op×data cross + op transitions, plus register-side groups (CSR fields, DPR access, CMDR command/status/read, command-sequence transitions). Closed to **57/57 bins**.
- **Code coverage**: root-caused gaps from FSM/transition reports and added targeted tests for uncovered states (WAIT command, SET_BUS error, illegal-command-in-idle), lifting FSM-state coverage to 88%.
- Remaining uncovered code is concentrated in arbitration-lost / reset arcs that require a second bus master or mid-transfer disable — documented as unreachable in this single-master bench.

## Regression flow (`regress.sh`)

One command runs all tests across 6 seeds, merges per-seed UCDBs into `merged_tests.ucdb`, converts the test-plan XML to `test_plan.ucdb`, merges both into a single **`regression.ucdb`**, and opens the coverage GUI — reproducible signoff with no manual steps.

```bash
cd project_benches/proj4/sim
./regress.sh
vcover report -summary regression.ucdb
```

## Repository layout

```
ece745_projects/
├─ project_benches/proj4/
│  ├─ testbench/top.sv          # TB top: clocks, interfaces, DUT, config DB
│  ├─ rtl/                      # IICMB VHDL RTL (DUT)
│  └─ sim/                      # regress.sh, test plan, Makefile
└─ verification_ip/
   ├─ ncsu_pkg/                 # UVM-style base-class library
   ├─ interface_packages/       # wb_pkg (Wishbone), i2c_pkg (I²C BFM/agent)
   └─ environment_packages/i2cmb_env_pkg/   # generator, predictor, scoreboard, coverage, env, test
```

## Technologies

SystemVerilog · VHDL (DUT) · Questa/QuestaSim · UVM-style methodology · functional + code coverage · UCDB · Wishbone · I²C
