vlib work

vlog -timescale 1ns/1ps morsecodeencoder.v

vsim morse

log {/*}

add wave {/*}

force {in[2: 0]} 2#010
force {start} 1 0, 0 20
force {reset_n} 1 0, 0 1, 1 2
force {clock50} 0 0, 1 10 -r 20
run 10000000ns