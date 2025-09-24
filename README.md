# O-POPE - WIP

To setup the repo:
```bash
cd golden-model
source setup-py.sh
cd ..
make riscv32-gcc # Installs GCC
make bender
source scripts/setup-hwpe.sh
```

To run a simulation with the GUI:
```bash
make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
make sim target=vsim gui=1
```

To run all the performance logs:
```bash
make sim-all
```