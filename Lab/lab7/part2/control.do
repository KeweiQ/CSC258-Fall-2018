vlib work

vlog -timescale 1ns/1ns part2.v

vsim control

log {/*}

add wave {/*}

force {clk} 0 0, 1 10 -r 20
force {resetn} 0 0, 1 20
force {go} 0 0, 1 65, 0 85
force {ld} 0 0, 1 25, 0 45, 1 105, 0 125
run 150ns
