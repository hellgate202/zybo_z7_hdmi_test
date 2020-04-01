onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/pattern_gen/clk_i
add wave -noupdate /top_tb/pattern_gen/rst_i
add wave -noupdate -radix unsigned /top_tb/pattern_gen/px_cnt
add wave -noupdate -radix unsigned /top_tb/pattern_gen/ln_cnt
add wave -noupdate /top_tb/pattern_gen/video_o/aclk
add wave -noupdate /top_tb/pattern_gen/video_o/aresetn
add wave -noupdate /top_tb/pattern_gen/video_o/tvalid
add wave -noupdate /top_tb/pattern_gen/video_o/tready
add wave -noupdate /top_tb/pattern_gen/video_o/tdata
add wave -noupdate /top_tb/pattern_gen/video_o/tstrb
add wave -noupdate /top_tb/pattern_gen/video_o/tkeep
add wave -noupdate /top_tb/pattern_gen/video_o/tlast
add wave -noupdate /top_tb/pattern_gen/video_o/tid
add wave -noupdate /top_tb/pattern_gen/video_o/tdest
add wave -noupdate /top_tb/pattern_gen/video_o/tuser
add wave -noupdate /top_tb/hdmit_tx/timing_gen/clk_i
add wave -noupdate /top_tb/hdmit_tx/timing_gen/rst_i
add wave -noupdate /top_tb/hdmit_tx/timing_gen/data_enable_o
add wave -noupdate /top_tb/hdmit_tx/timing_gen/hsync_o
add wave -noupdate /top_tb/hdmit_tx/timing_gen/vsync_o
add wave -noupdate /top_tb/hdmit_tx/timing_gen/preamble_o
add wave -noupdate /top_tb/hdmit_tx/timing_gen/gb_o
add wave -noupdate /top_tb/hdmit_tx/timing_gen/red_o
add wave -noupdate /top_tb/hdmit_tx/timing_gen/green_o
add wave -noupdate /top_tb/hdmit_tx/timing_gen/blue_o
add wave -noupdate -radix unsigned /top_tb/hdmit_tx/timing_gen/px_cnt
add wave -noupdate -radix unsigned /top_tb/hdmit_tx/timing_gen/hsync_cnt
add wave -noupdate /top_tb/hdmit_tx/timing_gen/state
add wave -noupdate /top_tb/hdmit_tx/timing_gen/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2724015044 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 293
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1672147413 ps}
