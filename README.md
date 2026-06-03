# O-POPE: High-Frequency Pipelined Outer Product GEMM Accelerator

O-POPE is a highly scalable, high-frequency outer-product engine for General Matrix Multiply (GEMM) acceleration with minimal buffering overhead. Developed as a collaboration between **ETH Zurich** (Integrated Systems Laboratory) and the **University of Bologna**, O-POPE targets the execution time and energy bottlenecks of modern machine learning floating-point workloads.

The key architectural innovation is the runtime repurposing of floating-point unit (FPU) pipeline registers as implicit data reuse and double buffers. By implementing an output-stationary outer-product dataflow on a semi-systolic mesh, the engine hides pipeline latency and decouples accumulation from memory access without relying on bulky, area-intensive input buffer arrays. In a 12 nm FinFET process, O-POPE achieves 1 GHz at 0.72 V, sustaining up to 99.97% FPU utilization with input buffer overhead below 2% for large configurations.

**Authors:** Danilo Cammarata (ETH Zurich IIS)

---

## Table of Contents

- [Repository Structure](#repository-structure)
- [Integration & Dependencies](#integration--dependencies)
- [Getting Started](#getting-started)
- [Software Support](#software-support)
- [Architectural Parameters](#architectural-parameters)
- [License](#license)

---

## Repository Structure

```
opope/
├── rtl/                   # Synthesizable SystemVerilog RTL (Solderpad 0.51)
├── sw/                    # Software HAL, driver, and example application (Apache 2.0)
│   ├── kernel/            # Bare-metal boot and linker scripts
│   └── utils/             # Utility headers
├── golden-model/          # Python golden reference models per precision (Apache 2.0)
│   ├── FP8/, FP16/, FP32/ # Single-precision golden models
│   └── FP8FP16/, FP16FP32/# Mixed-precision golden models
├── target/sim/            # Simulation infrastructure
│   ├── src/               # Testbenches in SystemVerilog (Solderpad 0.51) / C++ (Apache 2.0)
│   ├── vsim/              # QuestaSim/ModelSim makefrags (Apache 2.0)
│   └── verilator/         # Verilator makefrags (Apache 2.0)
├── scripts/               # Environment and utility scripts (Apache 2.0)
├── Bender.yml             # Dependency manifest
└── Makefile               # Top-level build system
```

The primary RTL modules in `rtl/` are:

| Module | Description |
|---|---|
| `opope_top.sv` | Top-level wrapper. Integrates the PE mesh, memory streamer, and control subsystems. Exposes an HCI memory port and an optional HWPE peripheral control port. |
| `opope_engine.sv` | Configurable p×p PE mesh. Handles row-wise broadcasting for Matrix A and column-wise broadcasting for Matrix B. |
| `opope_ctrl.sv` | Central state machine. Orchestrates config phases, execution flags, multi-context scheduling, and pipeline/memory decoupling boundaries. |
| `opope_streamer.sv` | Memory address generation. Manages multi-channel data motion for matrices A, B, and C over the TCDM interface. |
| `opope_buffers.sv` | Input FIFOs and latency tolerance logic for absorbing memory bank conflicts and aligning data streams. |

---

## Integration & Dependencies

### System Integration

O-POPE can be integrated into any system that exposes an [HCI](https://github.com/pulp-platform/hci)-compatible memory interface. Two integration modes are selected at compile time:

**`TARGET_OPOPE_HWPE`** (recommended) — the host core configures the accelerator via a memory-mapped peripheral port (`hwpe_ctrl_intf_periph`). This is the standard path and works with any RISC-V core that can perform MMIO writes, including systems built on the open-source [PULP](https://pulp-platform.org/) platform.

**`TARGET_OPOPE_COMPLEX`** — the accelerator is controlled via the [CV32E40X](https://github.com/pulp-platform/cv32e40x) eXtension Interface (XIF), enabling custom RISC-V instructions.

### IP Dependencies

All hardware dependencies are managed via [Bender](https://github.com/pulp-platform/bender) and declared in `Bender.yml`:

| Dependency | Version | Purpose |
|---|---|---|
| [fpnew / cvfpu](https://github.com/pulp-platform/cvfpu) | `pulp-v0.1.3` | Transprecision FPU (FP8/FP16/FP32). Integer units can be substituted. |
| [hci](https://github.com/pulp-platform/hci) | `v2.1.2` | Memory interconnect interface |
| [hwpe-ctrl](https://github.com/pulp-platform/hwpe-ctrl) | `v2.1.0` | Register file and peripheral control interface |
| [hwpe-stream](https://github.com/pulp-platform/hwpe-stream) | `1.7` | Streaming data interface |
| [common_cells](https://github.com/pulp-platform/common_cells) | `1.21.0` | Shared RTL primitives |
| [tech_cells_generic](https://github.com/pulp-platform/tech_cells_generic) | `0.2.11` | Technology-independent cell wrappers |

### Toolchain Requirements

The following tools are required. `make init` will install the RISC-V toolchain, Bender and Verilator automatically for external users; commercial simulators, instead, must be installed separately.

| Tool | Purpose | Install |
|---|---|---|
| [Bender](https://github.com/pulp-platform/bender) | RTL dependency manager | `make init` (via Cargo) |
| RISC-V GCC (`riscv32-unknown-elf-gcc`) | Compile software stimuli | `make init` (downloads prebuilt binary) |
| QuestaSim / ModelSim **or** Verilator  | RTL simulation | Must be installed separately |
| Python 3 | Golden model generation | System package manager |

---

## Getting Started

### 1. Initialize the Repository

For external users — fetches and installs open-source dependencies (RISC-V GCC, Bender and Verilator):

```
make init
```

### 2. Generate a Golden Reference

Before simulating, generate the software reference output for your target matrix dimensions and precision. For example, a 32×32×32 GEMM in FP16:

```
make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
```

Supported formats: `FP16`, `FP32`, and mixed-precision variants `FP8FP16`, `FP16FP32`.

### 3. Run Simulations

O-POPE supports both QuestaSim/ModelSim and Verilator simulation flows.

Run with QuestaSim (with GUI):

```
make sim target=vsim gui=1
```

Run with Verilator (with waveform tracing):

```
make sim target=verilator gui=1
```

Run the full regression suite and collect logs:

```
make sim-all
```

---

## Software Support

The `sw/` directory provides a complete bare-metal software stack for programming O-POPE from a RISC-V host core:

| File | Description |
|---|---|
| `sw/archi_opope.h` | Register map: base address and offsets for all control registers |
| `sw/hal_opope.h` | HAL: inline C functions for configuring, triggering, and polling the accelerator |
| `sw/utils/opope_utils.h` | Utility functions for result comparison across FP8/FP16/FP32 |
| `sw/opope.c` | Example application: runs a GEMM, sleeps on `wfi`, and checks output against the golden model |

A typical offload sequence using the HAL:

```c
#include "archi_opope.h"
#include "hal_opope.h"

// 1. Clear state and acquire a job slot
hwpe_soft_clear();
while (hwpe_acquire_job() < 0);

// 2. Configure: matrix pointers, dimensions, and arithmetic format
opope_cfg((unsigned int)x, (unsigned int)w, (unsigned int)y,
          M_SIZE, N_SIZE, K_SIZE,
          gemm_ops, comp_fmt, mem_fmt);

// 3. Trigger execution and wait for interrupt
hwpe_trigger_job();
asm volatile("wfi" ::: "memory");
```

---

## Architectural Parameters

O-POPE can be reconfigured at compile time via top-level parameters:

| Parameter | Description | Options / Default |
|---|---|---|
| `FpFormat` | Compute precision of the accumulator of the PE array | `FP16` (default), `FP32` |
| `Height` / `Width` (p) | PE mesh dimensions (rows × columns) | Power of 2 (default: 8) |

---

## License

This repository uses two licenses, applied by directory:

### Solderpad Hardware License v0.51 (`LICENSE_HW`)

Applies to all **synthesizable RTL** and **SystemVerilog testbenches**:

- `rtl/` — all `.sv` files
- `target/sim/src/` — all `.sv` files (`opope_tb.sv`, `opope_tb_wrap.sv`, `opope_complex_tb.sv`, `tb_dummy_memory.sv`)

### Apache License 2.0 (`LICENSE`)

Applies to all **software, scripts, build infrastructure, and golden models**:

- `sw/` — all C, assembly, and header files (except `sw/utils/tinyprintf.h`, see below)
- `golden-model/` — all Python scripts
- `scripts/` — all shell scripts and utilities
- `target/sim/src/opope_tb.cpp` — Verilator C++ testbench driver
- `target/sim/vsim/` — QuestaSim makefrags and TCL scripts
- `target/sim/verilator/` — Verilator makefrags
- `Makefile`, `Bender.yml`, `bender_common.mk`, `bender_sim.mk`, `bender_synth.mk`
- CI configuration (`.github/`, `.gitlab/`)

### Third-Party: BSD License

- `sw/utils/tinyprintf.h` — Copyright (c) 2004, 2012 Kustaa Nyholm / SpareTimeLabs, distributed under a BSD-style license. See the file header for the full terms.
