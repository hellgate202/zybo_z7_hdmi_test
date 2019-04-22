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
generate_target all [get_files  ./zybo_z7_hdmi_test.srcs/sources_1/bd/zybo_z7_hdmi_test/zybo_z7_hdmi_test.bd]
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

# Pin placement
place_ports hdmi_clk_p_o_0 H16
place_ports hdmi_tx0_p_o_0 D19
place_ports hdmi_tx1_p_o_0 C20
place_ports hdmi_tx2_p_o_0 B19

# Creating directory for constraints
file mkdir ./zybo_z7_hdmi_test.srcs/constrs_1/new

# Creating constraints file
close [ open ./zybo_z7_hdmi_test.srcs/constrs_1/new/zybo_z7_hdmi_test.xdc w ]

# Setting this file as target constraint
set_property target_constrs_file ./zybo_z7_hdmi_test.srcs/constrs_1/new/zybo_z7_hdmi_test.xdc [current_fileset -constrset]

# Timing constraints
set_property ASYNC_REG TRUE [get_cells zybo_z7_hdmi_test_i/hdmi_tx_0/inst/hdmi_tx/rst_d1_reg]
set_property ASYNC_REG TRUE [get_cells zybo_z7_hdmi_test_i/hdmi_tx_0/inst/hdmi_tx/rst_d2_reg]

# Saving previous constraints to file
save_constraints -force

# Run Synthesis
launch_runs synth_1 -jobs 8
wait_on_run synth_1

# Generate bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

# Export Hardware
file mkdir ./zybo_z7_hdmi_test.sdk
file copy -force ./zybo_z7_hdmi_test.runs/impl_1/zybo_z7_hdmi_test_wrapper.sysdef ./zybo_z7_hdmi_test.sdk/zybo_z7_hdmi_test_wrapper.hdf

exit
