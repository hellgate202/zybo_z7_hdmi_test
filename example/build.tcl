start_gui
# Project creation
create_project zybo_z7_hdmi_test . -part xc7z020clg400-1

# Creating new block design
create_bd_design "zybo_z7_hdmi_test"

# Adding ZYNQ-7000 Processing System
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 zynq_ps

# Congiguring PS
source ./zynq_config.tcl

# Make PS signals external
make_bd_intf_pins_external [list       \
  [get_bd_intf_pins zynq_ps/DDR]       \
  [get_bd_intf_pins zynq_ps/FIXED_IO]]

# Add local repository with CSI2 IP-core
set_property ip_repo_paths [list \
  ../]                           \
[current_project]
update_ip_catalog 

# Add Clock Wizard to create 74.25 MHz pixel clock
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 px_clk_mmcm
set_property -dict [list                       \
  CONFIG.CLKOUT2_USED               {true}     \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {148.5}    \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {742.5}    \
  CONFIG.USE_LOCKED                 {false}    \
  CONFIG.USE_RESET                  {false}]   \
[get_bd_cells px_clk_mmcm]

# Add Processing System Reset instances to synchronize resets
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 px_clk_rst

# Add HDMI TX IP-core
create_bd_cell -type ip -vlnv hellgate202:user:hdmi_tx:1.0 hdmi_tx_0

# Add Pattern Generator
create_bd_cell -type ip -vlnv hellgate202:user:axi4_video_pattern_gen:1.0 pattern_gen

# Connceting modules together
connect_bd_net [get_bd_pins zynq_ps/FCLK_CLK0] [get_bd_pins px_clk_mmcm/clk_in1]
connect_bd_net [get_bd_pins zynq_ps/FCLK_RESET0_N] [get_bd_pins px_clk_rst/ext_reset_in]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins px_clk_rst/slowest_sync_clk]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins hdmi_tx_0/px_clk_i]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins pattern_gen/clk_i]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out2] [get_bd_pins hdmi_tx_0/tmds_clk_i]
connect_bd_net [get_bd_pins px_clk_rst/peripheral_reset] [get_bd_pins pattern_gen/rst_i]
connect_bd_net [get_bd_pins px_clk_rst/peripheral_reset] [get_bd_pins hdmi_tx_0/rst_i]
connect_bd_intf_net [get_bd_intf_pins pattern_gen/video_o] [get_bd_intf_pins hdmi_tx_0/video_i]

make_bd_pins_external [get_bd_pins hdmi_tx_0/hdmi_tx2_p_o] \
                      [get_bd_pins hdmi_tx_0/hdmi_tx1_p_o] \
                      [get_bd_pins hdmi_tx_0/hdmi_tx2_n_o] \
                      [get_bd_pins hdmi_tx_0/hdmi_tx1_n_o] \
                      [get_bd_pins hdmi_tx_0/hdmi_tx0_n_o] \
                      [get_bd_pins hdmi_tx_0/hdmi_tx0_p_o] \
                      [get_bd_pins hdmi_tx_0/hdmi_clk_p_o] \
                      [get_bd_pins hdmi_tx_0/hdmi_clk_n_o]

# Saving block design
regenerate_bd_layout
save_bd_design

# Create HDL Wraper
make_wrapper -files [get_files ./zybo_z7_hdmi_test.srcs/sources_1/bd/zybo_z7_hdmi_test/zybo_z7_hdmi_test.bd] -top
add_files -norecurse ./zybo_z7_hdmi_test.srcs/sources_1/bd/zybo_z7_hdmi_test/hdl/zybo_z7_hdmi_test_wrapper.v
update_compile_order -fileset sources_1

# Generate Output Products
generate_target all [get_files  ./zybo_z7_hdmi_example.srcs/sources_1/bd/zybo_z7_hdmi_test/zybo_z7_hdmi_test.bd]
catch { config_ip_cache -export [get_ips -all zybo_z7_hdmi_test_zynq_ps_0] }
catch { config_ip_cache -export [get_ips -all zybo_z7_hdmi_test_px_clk_mmcm_0] }
catch { config_ip_cache -export [get_ips -all zybo_z7_hdmi_test_px_clk_rst_0] }
catch { config_ip_cache -export [get_ips -all zybo_z7_hdmi_test_hdmi_tx_0_0] }
catch { config_ip_cache -export [get_ips -all zybo_z7_hdmi_test_pattern_gen_0] }
export_ip_user_files -of_objects [get_files ./zybo_z7_hdmi_test.srcs/sources_1/bd/zybo_z7_hdmi_test/zybo_z7_hdmi_test.bd] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ./zybo_z7_hdmi_test.srcs/sources_1/bd/zybo_z7_hdmi_test/zybo_z7_hdmi_test.bd]

launch_runs -jobs 8 { zybo_z7_hdmi_test_zynq_ps_0_synth_1       \
                      zybo_z7_hdmi_test_px_clk_mmcm_0_synth_1   \
                      zybo_z7_hdmi_test_px_clk_rst_0_synth_1    \
                      zybo_z7_hdmi_test_hdmi_tx_0_0_synth_1     \
                      zybo_z7_hdmi_test_pattern_gen_0_synth_1 }

wait_on_run zybo_z7_hdmi_test_zynq_ps_0_synth_1
wait_on_run zybo_z7_hdmi_test_px_clk_mmcm_0_synth_1
wait_on_run zybo_z7_hdmi_test_px_clk_rst_0_synth_1
wait_on_run zybo_z7_hdmi_test_hdmi_tx_0_0_synth_1
wait_on_run zybo_z7_hdmi_test_pattern_gen_0_synth_1

# RTL Elaboration
create_ip_run [get_files -of_objects [get_fileset sources_1] ./zybo_z7_hdmi_test.srcs/sources_1/bd/zybo_z7_hdmi_test/zybo_z7_hdmi_test.bd]
synth_design -rtl -name rtl_1

## Pin placement
#place_ports {dphy_data_p_i_0[0]} M19
#place_ports {dphy_data_p_i_0[1]} L16
#place_ports dphy_clk_p_i_0       J18
#set_property IOSTANDARD LVDS_25 [get_ports [list \
#  {dphy_data_p_i_0[1]}                           \
#  {dphy_data_p_i_0[0]}                           \
#  dphy_clk_p_i_0]]
#place_ports {video_0_tdata[15]} V8
#place_ports {video_0_tdata[14]} W8
#place_ports {video_0_tdata[13]} U7
#place_ports {video_0_tdata[12]} V7
#place_ports {video_0_tdata[11]} Y7
#place_ports {video_0_tdata[10]} Y6
#place_ports {video_0_tdata[9]}  V6
#place_ports {video_0_tdata[8]}  W6
#place_ports {video_0_tdata[7]}  V15
#place_ports {video_0_tdata[6]}  W15
#place_ports {video_0_tdata[5]}  T11
#place_ports {video_0_tdata[4]}  T10
#place_ports {video_0_tdata[3]}  W14
#place_ports {video_0_tdata[3]}  Y14
#place_ports {video_0_tdata[2]}  T12
#place_ports {video_0_tdata[1]}  U12
#place_ports {video_0_tdata[0]}  T14
#place_ports video_0_tlast       V18
#place_ports video_0_tready      G15
#place_ports video_0_tuser       W16
#place_ports video_0_tvalid      J15
#place_ports sccb_sda_io_0       F19
#place_ports sccb_scl_io_0       F20
#place_ports cam_pwup_o_0        G20
#set_property IOSTANDARD LVCMOS33 [get_ports [list \
#  {video_0_tdata[15]}                           \
#  {video_0_tdata[14]}                           \
#  {video_0_tdata[13]}                           \
#  {video_0_tdata[12]}                           \
#  {video_0_tdata[11]}                           \
#  {video_0_tdata[10]}                           \
#  {video_0_tdata[9]}                            \
#  {video_0_tdata[8]}                            \
#  {video_0_tdata[7]}                            \
#  {video_0_tdata[6]}                            \
#  {video_0_tdata[5]}                            \
#  {video_0_tdata[4]}                            \
#  {video_0_tdata[3]}                            \
#  {video_0_tdata[2]}                            \
#  {video_0_tdata[1]}                            \
#  {video_0_tdata[0]}                            \
#  video_0_tvalid                                \
#  video_0_tlast                                 \
#  video_0_tready                                \
#  video_0_tuser                                 \
#  sccb_sda_io_0                                 \
#  sccb_scl_io_0                                 \
#  cam_pwup_o_0]]
#place_ports dphy_lp_clk_p_i_0       H20
#place_ports dphy_lp_clk_n_i_0       J19
#place_ports {dphy_lp_data_p_i_0[0]} L19
#place_ports {dphy_lp_data_p_i_0[1]} J20
#place_ports {dphy_lp_data_n_i_0[0]} M18
#place_ports {dphy_lp_data_n_i_0[1]} L20
#set_property IOSTANDARD HSUL_12 [get_ports [list \
#  dphy_lp_clk_p_i_0                              \
#  dphy_lp_clk_n_i_0                              \
#  {dphy_lp_data_p_i_0[0]}                        \
#  {dphy_lp_data_p_i_0[1]}                        \
#  {dphy_lp_data_n_i_0[0]}                        \
#  {dphy_lp_data_n_i_0[1]}]]
#set_property INTERNAL_VREF 0.6 [get_iobanks 35]
#
## Creating directory for constraints
#file mkdir ./csi2_zybo_z7_example.srcs/constrs_1/new
#
## Creating constraints file
#close [ open ./csi2_zybo_z7_example.srcs/constrs_1/new/csi2_zybo_z7_example.xdc w ]
#
## Setting this file as target constraint
#set_property target_constrs_file ./csi2_zybo_z7_example.srcs/constrs_1/new/csi2_zybo_z7_example.xdc [current_fileset -constrset]
#
## Timing constraints
#create_clock -period 2.976 -name dphy_clk -waveform {0.000 1.488} [get_ports dphy_clk_p_i_0]
#
#set_max_delay -datapath_only -from [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/byte_align[*].settle_ignore/FSM_onehot_state_reg[4]] -to \
#                                   [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/hs_data_valid_d1_reg[*]] 5.000
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/hs_data_valid_d1_reg[*]]
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/hs_data_valid_d2_reg[*]]
#
#set_max_delay -datapath_only -from [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_detect/clk_presence_cnt_reg[*]] -to \
#                                   [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_loss_rst*] 5.000
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_loss_rst_d1_reg]
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_loss_rst_d2_reg]
#
#set_max_delay -datapath_only -from [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/wr_ptr_gray_wr_clk_reg[*]] -to \
#                                   [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/wr_ptr_gray_rd_clk_reg[*]] 11.904
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/wr_ptr_gray_rd_clk_reg[*]]
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/wr_ptr_gray_rd_clk_mtstb_reg[*]]
#
#set_max_delay -datapath_only -from [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rd_ptr_gray_rd_clk_reg[*]] -to \
#                                   [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rd_ptr_gray_wr_clk_reg[*]] 11.904
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rd_ptr_gray_wr_clk_reg[*]]
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rd_ptr_gray_wr_clk_mtstb_reg[*]]
#
#set_max_delay -datapath_only -from [get_cells csi2_zybo_z7_example_i/px_clk_rst/U0/PR_OUT_DFF[0].FDRE_PER] -to \
#                                   [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rst_wr_clk_d1_reg] 11.904
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rst_wr_clk_d1_reg] 
#
#set_max_delay -datapath_only -from [get_cells csi2_zybo_z7_example_i/px_clk_rst/U0/PR_OUT_DFF[0].FDRE_PER] -to \
#                                   [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rst_wr_clk_d2_reg] 11.904
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rst_wr_clk_d2_reg] 
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rst_rd_clk_d1_reg] 
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rst_rd_clk_d2_reg]
#
#set_max_delay -datapath_only -from [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_csr/cr_reg[1][0]] -to \
#                                   [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/axi4_conv/enable_d1_reg] 11.904
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/axi4_conv/enable_d1_reg]
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/axi4_conv/enable_d2_reg]
#
#set_max_delay -datapath_only -from [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_detect/toggle_bit_reg] -to \
#                                   [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_detect/toggle_bit_s1_reg] 5.000
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_detect/toggle_bit_s1_reg]
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_detect/toggle_bit_s2_reg]
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_detect/toggle_bit_s3_reg]
#
#set_max_delay -datapath_only -from [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/crc_calc/crc_failed_o_reg] -to \
#                                   [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_stat_acc/crc_err_d1_reg] 11.904
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_stat_acc/crc_err_d1_reg]
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_stat_acc/crc_err_d2_reg]
#
#set_max_delay -datapath_only -from [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/header_corrector/error_corrected_o_reg] -to \
#                                   [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_stat_acc/corr_header_err_d1_reg] 11.904
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_stat_acc/corr_header_err_d1_reg] 
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_stat_acc/corr_header_err_d2_reg] 
#
#set_max_delay -datapath_only -from [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_rx/header_corrector/error_o_reg] -to \
#                                   [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_stat_acc/header_err_d1_reg] 11.904
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_stat_acc/header_err_d1_reg] 
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/csi2_stat_acc/header_err_d2_reg] 
#
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/sccb_master/i2c_master_phy/mstb_scl_reg[*]]
#set_property ASYNC_REG TRUE [get_cells csi2_zybo_z7_example_i/csi2_2_lane_rx/inst/sccb_master/i2c_master_phy/mstb_sda_reg[*]]
#
## Saving previous constraints to file
#save_constraints -force
#
## Run Synthesis
#launch_runs synth_1 -jobs 4
#wait_on_run synth_1
#
## Generate bitstream
#launch_runs impl_1 -to_step write_bitstream -jobs 4
#wait_on_run impl_1
#
## Export Hardware
#file mkdir ./csi2_zybo_z7_example.sdk
#file copy -force ./csi2_zybo_z7_example.runs/impl_1/csi2_zybo_z7_example_wrapper.sysdef ./csi2_zybo_z7_example.sdk/csi2_zybo_z7_example_wrapper.hdf
#
#exit
