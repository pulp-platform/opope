onerror {resume}
quietly virtual signal -install {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/x_input_i  } x0
quietly virtual signal -install {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/w_input_i  } w0
quietly virtual function -install /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer -env /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer { &{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[15], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[14], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[13], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[12], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[11], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[10], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[9], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[8], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[7], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[6], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[5], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[4], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[3], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[2], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[1], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data[0] }} data_00
quietly virtual function -install /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers -env /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer { &{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[15], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[14], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[13], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[12], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[11], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[10], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[9], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[8], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[7], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[6], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[5], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[4], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[3], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[2], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[1], /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o[0] }} y_data_o_00
quietly WaveActivateNextPane {} 0
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/clk_i
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/rst_ni
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/current
add wave -noupdate -label finished /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/cntrl_scheduler.finished
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/start_cfg_i
add wave -noupdate {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/in_valid_i}
add wave -noupdate {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/fma_out_valid}
add wave -noupdate -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/req
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/clk_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/periph_add_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/periph_be_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/periph_data_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/periph_id_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/periph_req_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/periph_wen_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/rst_ni
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm_gnt_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm_r_data_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm_r_ecc_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm_r_opc_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm_r_user_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm_r_valid_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/test_mode_i
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/busy_o
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/evt_o
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/periph_gnt_o
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/periph_r_data_o
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/periph_r_id_o
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/periph_r_valid_o
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm_add_o
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm_be_o
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm_data_o
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm_ecc_o
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm_req_o
add wave -noupdate -group Wrap /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm_wen_o
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/clk_i
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/rst_ni
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/test_mode_i
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/ID_WIDTH
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/N_CORES
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/DW
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/UW
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/X_EXT
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/SysInstWidth
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/SysDataWidth
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/NumContext
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/FpFormat
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/Height
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/Width
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/NumPipeRegs
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/PipeConfig
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/BITW
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/HCI_SIZE_tcdm
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/DATAW_ALIGN
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/clear
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/start_cfg
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/cfg_complete
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/cntrl_streamer
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/flgs_streamer
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/cntrl_engine
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/flgs_scheduler
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/mask_y
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/mask_z
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_ready
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/z_valid
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/in_ready
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/busy_o
add wave -noupdate -group Top /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/evt_o
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/clk
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/AW
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/BW
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/DW
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/EHW
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/EW
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/IW
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/UW
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/WAIVE_RQ3_ASSERT
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/WAIVE_RQ4_ASSERT
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/WAIVE_RSP3_ASSERT
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/WAIVE_RSP5_ASSERT
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/be
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/clk_assert
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/ecc
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/egnt
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/ereq
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/id
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/r_ecc
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/r_eready
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/r_evalid
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/r_id
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/r_opc
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/r_ready
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/r_user
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/r_valid
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/user
add wave -noupdate -group TCDM -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/req
add wave -noupdate -group TCDM /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/gnt
add wave -noupdate -group TCDM -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/wen
add wave -noupdate -group TCDM -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/add
add wave -noupdate -group TCDM -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/r_data
add wave -noupdate -group TCDM -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/data
add wave -noupdate -group Streamer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/clear_i
add wave -noupdate -group Streamer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/clk_i
add wave -noupdate -group Streamer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/ctrl_i
add wave -noupdate -group Streamer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/enable_i
add wave -noupdate -group Streamer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/rst_ni
add wave -noupdate -group Streamer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/test_mode_i
add wave -noupdate -group Streamer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/flags_o
add wave -noupdate -group Streamer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/flags_o.w_granted
add wave -noupdate -group Streamer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/flags_o.x_granted
add wave -noupdate -group Streamer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/flags_o.y_granted
add wave -noupdate -group Z_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/z_buffer/clk
add wave -noupdate -group Z_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/z_buffer/valid
add wave -noupdate -group Z_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/z_buffer/ready
add wave -noupdate -group Z_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/z_buffer/data
add wave -noupdate -group Z_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/z_buffer/strb
add wave -noupdate -group {OPE Engine IN-Out} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/clk_i
add wave -noupdate -group {OPE Engine IN-Out} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/cntrl_engine_i
add wave -noupdate -group {OPE Engine IN-Out} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/rst_ni
add wave -noupdate -group {OPE Engine IN-Out} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/w_input_i
add wave -noupdate -group {OPE Engine IN-Out} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/x_input_i
add wave -noupdate -group {OPE Engine IN-Out} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/y_bias_i
add wave -noupdate -group {OPE Engine IN-Out} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o
add wave -noupdate -group {Engine Y} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/y_bias_i[0]}
add wave -noupdate -divider {Engine Data}
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/streamer_current
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/acc_state_current
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/current
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_clock_gating/en_i
add wave -noupdate -color Gold /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/priority_counter_q
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/engine_to_reg_output
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/ldst_tcdm_pre_r_id/add
add wave -noupdate -color {Light Steel Blue} -label x_gnt {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[0]/gnt}
add wave -noupdate -color {Light Steel Blue} -label w_gnt {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[1]/gnt}
add wave -noupdate -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/req
add wave -noupdate -color Cyan -label yz_gnt {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/gnt}
add wave -noupdate -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/wen
add wave -noupdate -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/add
add wave -noupdate -color Gold {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[0]}
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/source_ctrl
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/y_counter_q
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/extra_q
add wave -noupdate -color Gold /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/priority_counter_d
add wave -noupdate -group {OPE-Engine Internal} -color {Cornflower Blue} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/acc_in_data
add wave -noupdate -group {OPE-Engine Internal} -color {Cornflower Blue} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/acc_in_valid
add wave -noupdate -group {OPE-Engine Internal} -color {Cornflower Blue} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/acc_write_index
add wave -noupdate -group {OPE-Engine Internal} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/BITW
add wave -noupdate -group {OPE-Engine Internal} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_clk
add wave -noupdate -group {OPE-Engine Internal} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_operands
add wave -noupdate -group {OPE-Engine Internal} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/engine_to_reg_output
add wave -noupdate -group {OPE-Engine Internal} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/FpFormat
add wave -noupdate -group {OPE-Engine Internal} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/Height
add wave -noupdate -group {OPE-Engine Internal} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/NumPipeRegs
add wave -noupdate -group {OPE-Engine Internal} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/PipeConfig
add wave -noupdate -group {OPE-Engine Internal} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/reg_out_data
add wave -noupdate -group {OPE-Engine Internal} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/Stallable
add wave -noupdate -group {Acc REG} -expand -group Row0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[7]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -expand -group Row0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[6]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -expand -group Row0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[5]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -expand -group Row0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[4]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -expand -group Row0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[3]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -expand -group Row0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[2]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -expand -group Row0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[1]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -expand -group Row0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[1]/accumulation_reg_col[7]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[1]/accumulation_reg_col[6]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[1]/accumulation_reg_col[5]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[1]/accumulation_reg_col[4]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[1]/accumulation_reg_col[3]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[1]/accumulation_reg_col[2]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[1]/accumulation_reg_col[1]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[1]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[2]/accumulation_reg_col[7]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[2]/accumulation_reg_col[6]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[2]/accumulation_reg_col[5]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[2]/accumulation_reg_col[4]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[2]/accumulation_reg_col[3]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[2]/accumulation_reg_col[2]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[2]/accumulation_reg_col[1]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[2]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row3 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[3]/accumulation_reg_col[7]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row3 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[3]/accumulation_reg_col[6]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row3 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[3]/accumulation_reg_col[5]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row3 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[3]/accumulation_reg_col[4]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row3 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[3]/accumulation_reg_col[3]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row3 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[3]/accumulation_reg_col[2]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row3 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[3]/accumulation_reg_col[1]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row3 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[3]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row4 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[4]/accumulation_reg_col[7]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row4 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[4]/accumulation_reg_col[6]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row4 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[4]/accumulation_reg_col[5]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row4 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[4]/accumulation_reg_col[4]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row4 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[4]/accumulation_reg_col[3]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row4 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[4]/accumulation_reg_col[2]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row4 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[4]/accumulation_reg_col[1]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row4 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[5]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row5 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[5]/accumulation_reg_col[7]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row5 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[5]/accumulation_reg_col[6]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row5 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[5]/accumulation_reg_col[5]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row5 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[5]/accumulation_reg_col[4]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row5 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[5]/accumulation_reg_col[3]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row5 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[5]/accumulation_reg_col[2]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row5 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[5]/accumulation_reg_col[1]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row5 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[5]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row6 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[6]/accumulation_reg_col[7]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row6 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[6]/accumulation_reg_col[6]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row6 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[6]/accumulation_reg_col[5]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row6 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[6]/accumulation_reg_col[4]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row6 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[6]/accumulation_reg_col[3]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row6 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[6]/accumulation_reg_col[2]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row6 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[6]/accumulation_reg_col[1]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row7 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[7]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row7 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[6]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row7 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[5]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row7 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[4]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row7 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[3]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row7 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[2]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row7 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[1]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Acc REG} -group Row7 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/clk_i
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/acc_state_current
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/cntrl_engine_i.y_in_valid
add wave -noupdate -color {Cornflower Blue} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/acc_write_index
add wave -noupdate -color {Cornflower Blue} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/acc_read_index
add wave -noupdate -color {Cornflower Blue} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/cntrl_engine_i.y_write_reg_index
add wave -noupdate -color {Cornflower Blue} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/cntrl_engine_i.z_read_reg_index
add wave -noupdate -color {Cornflower Blue} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/cntrl_engine_i.shift_acc
add wave -noupdate -label reg_out_data_00 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/reg_out_data[0][0]}
add wave -noupdate -color Magenta {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[7]/ce_col[7]/i_ce/in_valid_i}
add wave -noupdate -color Magenta -radix hexadecimal -childformat {{{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[15]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[14]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[13]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[12]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[11]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[10]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[9]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[8]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[7]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[6]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[5]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[4]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[3]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[2]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[1]} -radix hexadecimal} {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[0]} -radix hexadecimal}} -subitemconfig {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[15]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[14]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[13]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[12]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[11]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[10]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[9]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[8]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[7]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[6]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[5]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[4]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[3]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[2]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[1]} {-color Magenta -height 16 -radix hexadecimal} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i[0]} {-color Magenta -height 16 -radix hexadecimal}} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/y_bias_i}
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/out_valid_o
add wave -noupdate /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/out_ready_i
add wave -noupdate -subitemconfig {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q[3]} {-color {Orange Red} -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q[2]} {-color Violet -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q[1]} {-color {Green Yellow} -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q[0]} {-color Gold -height 16}} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[1]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[2]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[3]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[4]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[5]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate -subitemconfig {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[6]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q[3]} {-color {Orange Red} -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[6]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q[2]} {-color Violet -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[6]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q[1]} {-color {Green Yellow} -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[6]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q[0]} {-color Gold -height 16}} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[6]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate -subitemconfig {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q[3]} {-color {Orange Red} -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q[2]} {-color Violet -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q[1]} {-color {Green Yellow} -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q[0]} {-color Gold -height 16}} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[7]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {Other TCDM signals} -group Wen -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/ldst_tcdm/wen
add wave -noupdate -group {Other TCDM signals} -group Wen -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/ldst_tcdm_pre_r_id/wen
add wave -noupdate -group {Other TCDM signals} -group Wen /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/ldst_tcdm_pre_r_valid/wen
add wave -noupdate -group {Other TCDM signals} -group Wen /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm_pre_r_id/wen
add wave -noupdate -group {Other TCDM signals} -group Wen /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_yz_mux/in_wen
add wave -noupdate -group {Other TCDM signals} -group Wen /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_ldst_mux/in_wen
add wave -noupdate -group {Other TCDM signals} -group Wen /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_tcdm_r_valid_filter/wen_q
add wave -noupdate -group {Other TCDM signals} -group Wen /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/zstream2cast/wen
add wave -noupdate -group {Other TCDM signals} -group Wen /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/z_fifo_d/wen
add wave -noupdate -group {Other TCDM signals} -group Wen /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/z_fifo_q/wen
add wave -noupdate -group {Other TCDM signals} -group Wen {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/wen}
add wave -noupdate -group {Other TCDM signals} -group Wen {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/wen}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/clk}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/WAIVE_RQ3_ASSERT}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/WAIVE_RQ4_ASSERT}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/WAIVE_RSP3_ASSERT}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/WAIVE_RSP5_ASSERT}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/DW}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/AW}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/BW}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/UW}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/IW}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/EW}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/EHW}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/req}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/gnt}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/r_valid}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/r_ready}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/add}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/wen}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/data}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/be}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/user}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/id}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/r_data}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/r_user}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/r_id}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/r_opc}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/ecc}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/r_ecc}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/ereq}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/egnt}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/r_evalid}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/r_eready}
add wave -noupdate -group {Other TCDM signals} -group yz0 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/clk_assert}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/clk}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/WAIVE_RQ3_ASSERT}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/WAIVE_RQ4_ASSERT}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/WAIVE_RSP3_ASSERT}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/WAIVE_RSP5_ASSERT}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/DW}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/AW}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/BW}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/UW}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/IW}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/EW}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/EHW}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/req}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/gnt}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/r_valid}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/r_ready}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/add}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/wen}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/data}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/be}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/user}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/id}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/r_data}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/r_user}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/r_id}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/r_opc}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/ecc}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/r_ecc}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/ereq}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/egnt}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/r_evalid}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/r_eready}
add wave -noupdate -group {Other TCDM signals} -group yz1 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/clk_assert}
add wave -noupdate -group {Other TCDM signals} -group z_stream /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/z_stream_i/clk
add wave -noupdate -group {Other TCDM signals} -group z_stream /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/z_stream_i/valid
add wave -noupdate -group {Other TCDM signals} -group z_stream /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/z_stream_i/ready
add wave -noupdate -group {Other TCDM signals} -group z_stream /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/z_stream_i/data
add wave -noupdate -group {Other TCDM signals} -group z_stream /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/z_stream_i/strb
add wave -noupdate -group {Other TCDM signals} -group Y_stream /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/y_stream_o/clk
add wave -noupdate -group {Other TCDM signals} -group Y_stream /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/y_stream_o/valid
add wave -noupdate -group {Other TCDM signals} -group Y_stream /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/y_stream_o/ready
add wave -noupdate -group {Other TCDM signals} -group Y_stream /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/y_stream_o/data
add wave -noupdate -group {Other TCDM signals} -group Y_stream /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/y_stream_o/strb
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/clk}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/WAIVE_RQ3_ASSERT}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/WAIVE_RQ4_ASSERT}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/WAIVE_RSP3_ASSERT}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/WAIVE_RSP5_ASSERT}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/DW}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/AW}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/BW}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/UW}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/IW}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/EW}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/EHW}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/req}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/gnt}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/r_valid}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/r_ready}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/add}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/wen}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/data}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/be}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/user}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/id}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/r_data}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/r_user}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/r_id}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/r_opc}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/ecc}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/r_ecc}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/ereq}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/egnt}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/r_evalid}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/r_eready}
add wave -noupdate -group {Other TCDM signals} -group virt_tcdm_2 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/clk_assert}
add wave -noupdate -group {Other TCDM signals} -label tcdm_cast2_wen {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/tcdm_cast[2]/wen}
add wave -noupdate -group {Other TCDM signals} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_stream_sink/ctrl_i.req_start
add wave -noupdate -group {Other TCDM signals} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_stream_sink/flags_o.ready_start
add wave -noupdate -group {Other TCDM signals} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/x_buffer/data
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/load_fifo_d[0]/wen}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/load_fifo_d[0]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/load_fifo_d[0]/r_data}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/tcdm_cast[0]/wen}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/tcdm_cast[0]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/tcdm_cast[0]/r_data}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/load_fifo_q[0]/wen}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/load_fifo_q[0]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/load_fifo_q[0]/r_data}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[0]/wen}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[0]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[0]/r_data}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/tcdm_cast[1]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/tcdm_cast[2]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[0]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/yz_tcdm[1]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[0]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[1]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/load_fifo_d[0]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/load_fifo_d[1]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/load_fifo_d[2]/add}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[0]/i_load_tcdm_fifo/stream_outgoing_push/ready}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[0]/i_load_tcdm_fifo/stream_outgoing_push/valid}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[0]/i_load_tcdm_fifo/stream_outgoing_pop/ready}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[0]/i_load_tcdm_fifo/stream_outgoing_pop/valid}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/load_fifo_q[0]/req}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/load_fifo_q[1]/req}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/load_fifo_q[2]/req}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/tcdm_cast[0]/req}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/tcdm_cast[1]/req}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/tcdm_cast[2]/req}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[0]/i_stream_source/cs}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/out_stream[0]/valid}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/out_stream[0]/ready}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/out_stream[1]/valid}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/out_stream[1]/ready}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/out_stream[2]/valid}
add wave -noupdate -group {Other TCDM signals} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/out_stream[2]/ready}
add wave -noupdate -group Valid-Ready /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/x_buffer/ready
add wave -noupdate -group Valid-Ready /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/w_buffer/ready
add wave -noupdate -group Valid-Ready /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/ready
add wave -noupdate -group Valid-Ready /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/x_buffer/valid
add wave -noupdate -group Valid-Ready /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/w_buffer/valid
add wave -noupdate -group Valid-Ready /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/valid
add wave -noupdate -group HCI_MUX_OOO {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/tcdm_cast[0]/add}
add wave -noupdate -group HCI_MUX_OOO {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/tcdm_cast[1]/add}
add wave -noupdate -group HCI_MUX_OOO {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/tcdm_cast[2]/add}
add wave -noupdate -group HCI_MUX_OOO {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[0]/add}
add wave -noupdate -group HCI_MUX_OOO {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[1]/add}
add wave -noupdate -group HCI_MUX_OOO {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/virt_tcdm[2]/add}
add wave -noupdate -group HCI_MUX_OOO {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[0]/i_stream_source/address_gen_en}
add wave -noupdate -group HCI_MUX_OOO {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[0]/i_stream_source/cs}
add wave -noupdate -group HCI_MUX_OOO {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[0]/i_stream_source/address_gen_en}
add wave -noupdate -group HCI_MUX_OOO {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[0]/i_stream_source/cs}
add wave -noupdate -group HCI_MUX_OOO {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/address_gen_en}
add wave -noupdate -group HCI_MUX_OOO {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/cs}
add wave -noupdate -group HCI_MUX_OOO -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/req
add wave -noupdate -group HCI_MUX_OOO -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/wen
add wave -noupdate -group HCI_MUX_OOO -color Magenta /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/tcdm/add
add wave -noupdate -group HCI_MUX_OOO /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_ldst_mux/in_req
add wave -noupdate -group HCI_MUX_OOO -color Coral /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_ldst_mux/rr_priority_d
add wave -noupdate -group HCI_MUX_OOO -color Coral /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_ldst_mux/winner_d
add wave -noupdate -group HCI_MUX_OOO /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_ldst_mux/winner_q
add wave -noupdate -group HCI_MUX_OOO -color Coral {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_ldst_mux/in_add[2]}
add wave -noupdate -group HCI_MUX_OOO -color Coral {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_ldst_mux/in_add[1]}
add wave -noupdate -group HCI_MUX_OOO -color Coral {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_ldst_mux/in_add[0]}
add wave -noupdate -group HCI_MUX_OOO -color Coral /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/i_ldst_mux/out/add
add wave -noupdate -group Y_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/clk
add wave -noupdate -group Y_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/valid
add wave -noupdate -group Y_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/ready
add wave -noupdate -group Y_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data
add wave -noupdate -group Y_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/strb
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/clk_i}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/rst_ni}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/flush_i}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/iteration_change_i}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/input_i}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/write_en_i}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/write_index_i}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/read_index_i}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/external_loading}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/DATA_WIDTH}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/DEPTH}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/internal_reg_d}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/internal_reg_q}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/accumulation_reg_row[0]/accumulation_reg_col[0]/i_acc_reg/output_o}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/reg_out_data[0][0]}
add wave -noupdate -group {acc[0][0]} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/acc_operand[0][0]}
add wave -noupdate -group {acc[0][0]} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/acc_operand
add wave -noupdate -group {acc[0][0]} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/reg_out_data
add wave -noupdate -group {Engine Data} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_operands
add wave -noupdate -group {Engine Data} -color Orange {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_operands[0][0][2]}
add wave -noupdate -group {Engine Data} -color Orange {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_operands[0][0][1]}
add wave -noupdate -group {Engine Data} -color Orange {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_operands[0][0][0]}
add wave -noupdate -group {Engine Data} -color Orange {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/engine_to_reg_output[0][0]}
add wave -noupdate -group {Engine Data} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/w_input_i
add wave -noupdate -group {Engine Data} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/x_input_i
add wave -noupdate -group {Engine Data} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/clk_i
add wave -noupdate -group {Engine Data} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/out_valid_o
add wave -noupdate -group {Engine Data} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/out_ready_i
add wave -noupdate -group {Engine Data} -color Gold -subitemconfig {{/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[15]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[14]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[13]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[12]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[11]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[10]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[9]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[8]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[7]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[6]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[5]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[4]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[3]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[2]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[1]} {-color Gold -height 16} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o[0]} {-color Gold -height 16}} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/z_output_o
add wave -noupdate -group {Engine Data} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/y_bias_i
add wave -noupdate -group {Engine Data} -group Z_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/z_buffer/clk
add wave -noupdate -group {Engine Data} -group Z_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/z_buffer/valid
add wave -noupdate -group {Engine Data} -group Z_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/z_buffer/ready
add wave -noupdate -group {Engine Data} -group Z_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/z_buffer/data
add wave -noupdate -group {Engine Data} -group Z_buffer /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/z_buffer/strb
add wave -noupdate -group {Engine Data} /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/z_stream_i/data
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/clk_i}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/rst_ni}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/enable_i}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/clear_i}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/presample_i}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/ctrl_i}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/TRANS_CNT}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/CNT}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/DIM_ENABLE_1H}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d0_stride}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d1_stride}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d2_stride}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d3_stride}
add wave -noupdate -group {Engine Data} -group Y_stream_source -color Orange {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/done}
add wave -noupdate -group {Engine Data} -group Y_stream_source -color Orange {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/gen_addr_int}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/overall_counter_d}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d0_counter_d}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d1_counter_d}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d2_counter_d}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d3_counter_d}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d0_addr_d}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d1_addr_d}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d2_addr_d}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d3_addr_d}
add wave -noupdate -group {Engine Data} -group Y_stream_source -radix unsigned {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/overall_counter_q}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d0_counter_q}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d1_counter_q}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d2_counter_q}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d3_counter_q}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d0_addr_q}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d1_addr_q}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d2_addr_q}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/d3_addr_q}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/addr_valid_d}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/addr_valid_q}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/ns}
add wave -noupdate -group {Engine Data} -group Y_stream_source {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/i_addressgen/flags_o}
add wave -noupdate -group {Engine Data} -radix unsigned {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/stream_cnt_q}
add wave -noupdate -group {Engine Data} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/addr_fifo_flags}
add wave -noupdate -group {Engine Data} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/enable_i}
add wave -noupdate -group {Engine Data} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/stream_cnt_en}
add wave -noupdate -group {Engine Data} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/stream/valid}
add wave -noupdate -group {Engine Data} {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_streamer/gen_tcdm2stream[2]/i_stream_source/stream/ready}
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/clk_i
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/rst_ni
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/busy_o
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/clear_o
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/evt_o
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/start_cfg_i
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/cfg_complete_o
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/cntrl_engine_o
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/mask_y_o
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/mask_z_o
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/flgs_streamer_i
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/cntrl_streamer_o
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/in_valid_i
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/y_in_valid_i
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/out_ready_i
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/y_ready_o
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/out_valid_o
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/in_ready_o
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/ce_clk_en_o
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/current
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/next
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/clear
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/latch_clear
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/tiler_setback
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/tiler_valid
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/slave_start
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/change_state
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/last_iteration_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/last_iteration_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/reg_file_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/reg_file_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/cntrl_slave
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/flgs_slave
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/priority_level
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/streamer_current
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/streamer_next
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/cntrl_scheduler
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/streamer_change_state
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/grant
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/done_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/done_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/start_computing
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/finished
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/x_granted
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/w_granted
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/y_granted
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/y_counter_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/y_counter_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/extra_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/extra_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/priority_counter_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/priority_counter_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/total_len_x_w
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/total_len_y_z
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/acc_state_current
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/acc_state_next
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/prefetched_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/prefetched_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/inner_loop_counter_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/inner_loop_counter_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/y_write_reg_index_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/y_write_reg_index_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/y_write_row_index_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/y_write_row_index_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/z_read_reg_index_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/z_read_reg_index_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/z_read_row_index_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/z_read_row_index_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/reg_write_to_engine_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/reg_write_to_engine_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/acc_change_state
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/y_bias_selector
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/acc_input_selector
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/external_loading
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/acc_done_d
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/acc_done_q
add wave -noupdate -group Controller /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_control/ce_enable
add wave -noupdate -group ce00 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/x_input_i}
add wave -noupdate -group ce00 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/w_input_i}
add wave -noupdate -group ce00 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/x0}
add wave -noupdate -group ce00 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/w0}
add wave -noupdate -group ce00 -radix float32 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/z_output_o}
add wave -noupdate -group ce00 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/status_o}
add wave -noupdate -group ce00 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/fma_clk_en}
add wave -noupdate -group ce00 {/redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_ope_engine/ce_row[0]/ce_col[0]/i_ce/sdotp_clk_en}
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/clk_i
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/rst_ni
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/clear_i
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/in_ready_i
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_ready_i
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/mask_y_i
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/mask_z_i
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/z_valid_i
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/z_data_i
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_ready_d
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_ready_q
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/buffer_current
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/buffer_next
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/x_reg_d
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/x_reg_q
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/w_reg_d
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/w_reg_q
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/ready_cnt_d
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/ready_cnt_q
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/change_x_data
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/change_w_data
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/in_valid_o
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/x_data_o
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/w_data_o
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_valid_o
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o_00
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/y_data_o
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/i_buffers/z_ready_o
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/valid
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/ready
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data_00
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/data
add wave -noupdate -expand -group Buffers /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top/y_buffer/strb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6222000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 154
configure wave -valuecolwidth 231
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {6205536 ps} {6239722 ps}
