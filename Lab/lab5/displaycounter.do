vlib work

vlog -timescale 1ns/1ps displaycounter.v

vsim displaycounter

log {/*}

add wave {/*}

force {SW[1: 0]} 2#01
force {SW[5: 2]} 2#0000
force {SW[7]} 0
force {SW[8]} 1
force {SW[9]} 0 0, 1 5
force {CLOCK_50} 0 0ps, 1 1ps -r 2ps
run 1000000ns

