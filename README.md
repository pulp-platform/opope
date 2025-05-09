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
make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16 transpose=1
make hw-clean sw-clean synth-ips hw-script hw-build sw-build hw-run target=vsim
```

Carefull you may need to adjust some full paths


