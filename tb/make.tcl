vlib work
vlog -sv -f files
vopt +acc top_tb -L unisim -o top_tb_opt
vsim top_tb_opt
do wave.do
run -all
