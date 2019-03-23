vlib work

vlog -timescale 1ns/1ns ALUplus.v

vsim ALUplus

log {/*}

add wave {/*}

force {KEY[0]} 0 0, 1 5 -r 10
force {SW[9]} 0 0, 1 10 -r 180
force {SW[3: 0]} 2#0011 0, 2#0001 90 -r 180
force {SW[7: 5]} 2#000 00, 2#001 20, 2#010 40, 2#011 60, 2#100 80, 2#101 100, 2#110 120, 2#111 140 -r 180
run 180ns
