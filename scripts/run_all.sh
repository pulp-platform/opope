
CURRENT_DIR=$(pwd)
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAKE_PATH=$SCRIPT_PATH/..
cd $MAKE_PATH

FIFO_0__H_04__ACC_16_active=0
FIFO_0__H_08__ACC_16_active=0
FIFO_0__H_16__ACC_16_active=1
FIFO_4__H_04__ACC_16_active=0 # Problems here!
FIFO_4__H_08__ACC_16_active=0
FIFO_4__H_16__ACC_16_active=0
FIFO_0__H_04__ACC_32_active=0
FIFO_0__H_08__ACC_32_active=0
FIFO_0__H_16__ACC_32_active=0
FIFO_4__H_04__ACC_32_active=0 # Problems here!
FIFO_4__H_08__ACC_32_active=0
FIFO_4__H_16__ACC_32_active=0
sed -i '70s/.*/  -do "run 2 ms; quit -f;"/' "$MAKE_PATH/target/sim/vsim/vsim.mk"
sed -i '527s/.*/    int ENABLE_ENGINE_OUTPUT  = 0;/' "$MAKE_PATH/target/sim/src/redmule_tb.sv"
sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
### FIFO DEPTH = 0  
### ARRAY_HEIGHT = 4
### ACCUMULATOR = 16 bits
if [ "$FIFO_0__H_04__ACC_16_active" -eq 1 ]; then
  echo 'start' &> $MAKE_PATH/logs/performance_0_4_16.log
  date '+%Y-%m-%d %H:%M:%S' &>> $MAKE_PATH/logs/performance_0_4_16.log
  sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 4;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP16;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b001100;|" "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 0/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_16.log
fi
### FIFO DEPTH = 0
### ARRAY_HEIGHT = 8
### ACCUMULATOR = 16 bits
if [ "$FIFO_0__H_08__ACC_16_active" -eq 1 ]; then
  echo 'start' &> $MAKE_PATH/logs/performance_0_8_16.log
  date '+%Y-%m-%d %H:%M:%S' &>> $MAKE_PATH/logs/performance_0_8_16.log
  sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 8;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP16;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b001100;|" "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 0/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_16.log
fi
### FIFO DEPTH = 0
### ARRAY_HEIGHT = 16
### ACCUMULATOR = 16 bits
if [ "$FIFO_0__H_16__ACC_16_active" -eq 1 ]; then
  echo 'start' &> $MAKE_PATH/logs/performance_0_16_16.log
  date '+%Y-%m-%d %H:%M:%S' &>> $MAKE_PATH/logs/performance_0_16_16.log
  sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 16;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP16;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b001100;|" "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 0/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_16.log
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_16.log
fi
### FIFO DEPTH = 4
### ARRAY_HEIGHT = 4
### ACCUMULATOR = 16 bits
if [ "$FIFO_4__H_04__ACC_16_active" -eq 1 ]; then
  echo 'start' &> $MAKE_PATH/logs/performance_4_4_16.log
  date '+%Y-%m-%d %H:%M:%S' &>> $MAKE_PATH/logs/performance_4_4_16.log
  sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 4;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP16;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b001100;|" "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 0/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_16.log
fi
### FIFO DEPTH = 4
### ARRAY_HEIGHT = 8
### ACCUMULATOR = 16 bits
if [ "$FIFO_4__H_08__ACC_16_active" -eq 1 ]; then
  echo 'start' &> $MAKE_PATH/logs/performance_4_8_16.log
  date '+%Y-%m-%d %H:%M:%S' &>> $MAKE_PATH/logs/performance_4_8_16.log
  sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 8;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP16;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b001100;|" "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 0/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_16.log
fi
### FIFO DEPTH = 4
### ARRAY_HEIGHT = 16
### ACCUMULATOR = 16 bits
if [ "$FIFO_4__H_16__ACC_16_active" -eq 1 ]; then
  echo 'start' &> $MAKE_PATH/logs/performance_4_16_16.log
  date '+%Y-%m-%d %H:%M:%S' &>> $MAKE_PATH/logs/performance_4_16_16.log
  sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 16;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP16;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b001100;|" "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 0/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_16.log
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP8FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_16.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_16.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_16.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_16.log
fi
### FIFO DEPTH = 0  
### ARRAY_HEIGHT = 4
### ACCUMULATOR = 32 bits
if [ "$FIFO_0__H_04__ACC_32_active" -eq 1 ]; then
  echo 'start' &> $MAKE_PATH/logs/performance_0_4_32.log
  date '+%Y-%m-%d %H:%M:%S' &>> $MAKE_PATH/logs/performance_0_4_32.log
  sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 4;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP32;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b101000;|" "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 0/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_4_32.log
fi
### FIFO DEPTH = 0
### ARRAY_HEIGHT = 8
### ACCUMULATOR = 32 bits
if [ "$FIFO_0__H_08__ACC_32_active" -eq 1 ]; then
  echo 'start' &> $MAKE_PATH/logs/performance_0_8_32.log
  date '+%Y-%m-%d %H:%M:%S' &>> $MAKE_PATH/logs/performance_0_8_32.log
  sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 8;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP32;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b101000;|" "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 0/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_8_32.log
fi
### FIFO DEPTH = 0
### ARRAY_HEIGHT = 16
### ACCUMULATOR = 32 bits
if [ "$FIFO_0__H_16__ACC_32_active" -eq 1 ]; then
  echo 'start' &> $MAKE_PATH/logs/performance_0_16_32.log
  date '+%Y-%m-%d %H:%M:%S' &>> $MAKE_PATH/logs/performance_0_16_32.log
  sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 16;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP32;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b101000;|" "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 0/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_32.log
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_0_16_32.log
fi
### FIFO DEPTH = 4
### ARRAY_HEIGHT = 4
### ACCUMULATOR = 32 bits
if [ "$FIFO_4__H_04__ACC_32_active" -eq 1 ]; then
  echo 'start' &> $MAKE_PATH/logs/performance_4_4_32.log
  date '+%Y-%m-%d %H:%M:%S' &>> $MAKE_PATH/logs/performance_4_4_32.log
  sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 4;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP32;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b101000;|" "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 0/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_4_32.log
fi
### FIFO DEPTH = 4
### ARRAY_HEIGHT = 8
### ACCUMULATOR = 32 bits
if [ "$FIFO_4__H_08__ACC_32_active" -eq 1 ]; then
  echo 'start' &> $MAKE_PATH/logs/performance_4_8_32.log
  date '+%Y-%m-%d %H:%M:%S' &>> $MAKE_PATH/logs/performance_4_8_32.log
  sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 8;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP32;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b101000;|" "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 0/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=16 N=16 K=16 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_8_32.log
fi
### FIFO DEPTH = 4
### ARRAY_HEIGHT = 16
### ACCUMULATOR = 32 bits
if [ "$FIFO_4__H_16__ACC_32_active" -eq 1 ]; then
  echo 'start' &> $MAKE_PATH/logs/performance_4_16_32.log
  date '+%Y-%m-%d %H:%M:%S' &>> $MAKE_PATH/logs/performance_4_16_32.log
  sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 16;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP32;/' "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b101000;|" "$MAKE_PATH/rtl/ope_pkg.sv"
  sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 4;/' "$MAKE_PATH/rtl/ope_buffers.sv"
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 0/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_32.log
  sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP16FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_32.log
  make golden OP=gemm M=32 N=32 K=32 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_32.log
  make golden OP=gemm M=64 N=64 K=64 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_32.log
  make golden OP=gemm M=96 N=96 K=96 fp_fmt=FP32
  make sim target=vsim gui=0 &>> $MAKE_PATH/logs/performance_4_16_32.log
fi
### DEFAULT CONFIGURATION
sed -i '70s|.*|  -do "run -a;"|' "$MAKE_PATH/target/sim/vsim/vsim.mk"
sed -i '527s/.*/    int ENABLE_ENGINE_OUTPUT  = 0;/' "$MAKE_PATH/target/sim/src/redmule_tb.sv"
sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 8;/' "$MAKE_PATH/rtl/ope_pkg.sv"
sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP16;/' "$MAKE_PATH/rtl/ope_pkg.sv"
sed -i "29s|.*|  parameter fpnew_pkg::fmt_logic_t  FpFmtConfig  = 6'b001100;|" "$MAKE_PATH/rtl/ope_pkg.sv"
sed -i '41s/.*/  localparam int unsigned X_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
sed -i '42s/.*/  localparam int unsigned W_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
sed -i '43s/.*/  localparam int unsigned Y_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
sed -i '44s/.*/  localparam int unsigned Z_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/ope_buffers.sv"
sed -i '21s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/ope_engine.sv"
cd $CURRENT_DIR