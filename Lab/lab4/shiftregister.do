vlib work

vlog -timescale 1ns/1ns shiftregister.v

vsim shiftregister

log {/*}

add wave {/*}

force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {KEY[0]} 0 0, 1 5 -r 10
force {SW[7: 0]} 2#10011010
force {SW[9]} 0
run 10ns

force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {KEY[0]} 0 0, 1 5 -r 10
force {SW[7: 0]} 2#10011010
force {SW[9]} 1
run 10ns

force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
force {KEY[0]} 0 0, 1 5 -r 10
force {SW[7: 0]} 2#10011010
force {SW[9]} 1
run 10ns

force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 0
force {KEY[0]} 0 0, 1 5 -r 10
force {SW[7: 0]} 2#10011010
force {SW[9]} 1
run 10ns

force {KEY[1]} 1
force {KEY[2]} 0
force {KEY[3]} 0
force {KEY[0]} 0 0, 1 5 -r 10
force {SW[7: 0]} 2#10011010
force {SW[9]} 1
run 10ns
