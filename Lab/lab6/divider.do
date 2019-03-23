vlib work

vlog -timescale 1ns/1ns divider.v

vsim divider

log {/*}

add wave {/*}

force {CLOCK_50} 0 0, 1 5 -r 10
force {KEY[0]} 0 0, 1 10
force {KEY[1]} 1 0, 0 20, 1 30
force {SW[7: 0]} 01110011
run 300ns

force {CLOCK_50} 0 0, 1 5 -r 10
force {KEY[0]} 0 0, 1 10
force {KEY[1]} 1 0, 0 20, 1 30
force {SW[7: 0]} 11101011
run 300ns