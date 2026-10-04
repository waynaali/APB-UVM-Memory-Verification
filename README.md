# APB UVM Memory Verification

A SystemVerilog/UVM-based verification environment developed to verify an APB-connected memory design.

## Overview

This project implements a UVM verification environment for a 64-bit APB memory interface. The environment verifies APB read/write transactions, memory access behavior, byte strobes, address boundaries, error conditions, and randomized traffic.

## DUT

The design consists of:

* APB interface and control FSM
* 64-bit memory interface
* 1024 × 32-bit memory blocks
* Byte-enable based write support
* Address and alignment error generation

## Verification Environment

The testbench is developed using **SystemVerilog and UVM**.

```text
                    +------------------+
                    |    Sequences     |
                    +--------+---------+
                             |
                             v
                    +------------------+
                    |    Sequencer     |
                    +--------+---------+
                             |
                             v
                    +------------------+
                    |     Driver       |
                    +--------+---------+
                             |
                             v
                        +---------+
                        |   DUT   |
                        +----+----+
                             |
                             v
                    +------------------+
                    |     Monitor      |
                    +--------+---------+
                             |
                    +--------+---------+
                    |                  |
                    v                  v
             +-------------+    +-------------+
             | Scoreboard  |    |  Coverage   |
             +-------------+    +-------------+
```

## UVM Components

* **Sequence Item** — represents APB transactions
* **Sequence** — generates directed and randomized stimulus
* **Sequencer** — controls transaction flow
* **Driver** — drives APB signals to the DUT
* **Monitor** — observes APB transactions
* **Scoreboard** — compares DUT responses against the reference model
* **Coverage** — collects functional coverage
* **Agent** — encapsulates driver, monitor, and sequencer
* **Environment** — connects the verification components
* **Tests** — execute different verification scenarios

## Test Scenarios

The verification environment includes tests for:

* Basic read/write operations
* Boundary addresses
* Back-to-back APB transfers
* Byte strobe / partial writes
* Misaligned addresses
* Out-of-range addresses
* Randomized transactions
* Stress testing
* APB error responses

## Functional Coverage

Functional coverage is collected for:

* Read and write operations
* Address ranges
* Valid and invalid addresses
* Byte strobe patterns
* APB error responses
* APB ready response
* Read/write and error combinations

## Project Structure

```text
APB-UVM-Memory-Verification/
│
├── rtl/
│   ├── apb_fsm.sv
│   ├── apb_wrapper.sv
│   ├── err_gen.sv
│   ├── generic_mem.sv
│   └── mem_1024x32.sv
│
├── tb/
│   ├── apb_agent.sv
│   ├── apb_base_test.sv
│   ├── apb_driver.sv
│   ├── apb_env.sv
│   ├── apb_interface.sv
│   ├── apb_monitor.sv
│   ├── apb_scoreboard.sv
│   ├── apb_seq_item.sv
│   ├── apb_sequence.sv
│   ├── apb_sequencer.sv
│   ├── apb_tb_uvm_pkg.sv
│   └── testbench.sv
│
└── README.md
```

## Tools and Technologies

* SystemVerilog
* UVM 1.2
* Synopsys VCS
* DVE
* Functional and code coverage
* ## Simulation Results

The complete APB UVM test suite was executed successfully using Synopsys VCS.

* **Scoreboard Checks:** 157
* **Passed:** 157
* **Failed:** 0
* **UVM Errors:** 0
* **UVM Fatal Errors:** 0
* **UVM Warnings:** 0
* **Overall Test Status:** **PASS**

### Final Simulation Result

## Simulation Results

The complete APB UVM test suite was executed successfully using Synopsys VCS.

* **Scoreboard Checks:** 157
* **Passed:** 157
* **Failed:** 0
* **UVM Errors:** 0
* **UVM Fatal Errors:** 0
* **UVM Warnings:** 0
* **Overall Test Status:** **PASS**

The final `apb_all_test` execution completed successfully with all scoreboard checks passing and no UVM errors or fatal reports.

## Author

**Wayna Ali**

GitHub: [waynaali](https://github.com/waynaali)
