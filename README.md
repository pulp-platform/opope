# OPE engine - High Performance case

```bash
cd golden-model
source setup-py.sh
cd ..
```

```bash
make verilator # Installs verilator
make riscv32-gcc # Installs GCC
```

```bash
make bender
```

```
source scripts/setup-hwpe.sh
make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
make sim target=vsim
```


To run all the performance logs
./logs.sh

# Synthesis

Carefull you may need to adjust some full paths

## Getting started
Clone the repo into an already cloned [redmule](https://github.com/pulp-platform/redmule) one and move into it. Launch:
```
icdesign gf12 -update all -nogui
```

Then move into the `synopsys` folder and launch:
```
make clean run
```

Step-by-step reports are under `reports`. Final reports are under `out`.

See you!


# Power

You need to change the rtl line 

in redmule_tb.sv
  assign finished_redmule = debug_cntrl_scheduler.finished;
  assign finished_redmule = i_redmule_wrap.debug_cntrl_scheduler_o_finished_;


fix the path in the vcd generation

```
cd redmule-gf12/synopsys
make hw-script-power
make run-power-analysis
```