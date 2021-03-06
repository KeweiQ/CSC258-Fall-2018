vlib work

vlog -timescale 1ns/1ns part2.v

vsim datapath

log {/*}

add wave {/*}

force {clk} 0 0, 1 10 -r 20
force {resetn} 0 0, 1 20
force {enable} 0 0, 1 100, 0 450
force {ld_x} 1 0, 0 40, 1 450
force {ld_y} 0 0, 1 60, 0 80
force {ld_colour} 0 0, 1 60, 0 80
force {data_in} 1000000111 0, 1000000011 50
run 500ns
