vlib work

vlog -timescale 1ns/1ns part2.v

vsim combine

log {/*}

add wave {/*}

force {clk} 0 0, 1 10 -r 20
force {resetn} 0 0, 1 20
force {go} 0 0, 1 65, 0 85
force {ld} 0 0, 1 25, 0 45, 1 475
force {data_in} 1000000111 0, 1000000011 40
run 500ns
