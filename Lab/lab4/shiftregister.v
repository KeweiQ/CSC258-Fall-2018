module shiftregister(SW, KEY, LEDR);
	input [9:0] SW;
	input [3:0] KEY;
	output [7:0] LEDR;
	
	shifter8bit s0(
		.LoadVal(SW[7:0]),
		.clk(KEY[0]),
		.Load_n(KEY[1]),
		.ShiftRight(KEY[2]),
		.ASR(KEY[3]),
		.reset_n(SW[9]),
		.q(LEDR[7:0])
	   );
endmodule


module shifter8bit(LoadVal, Load_n, ShiftRight, ASR, clk, reset_n, q);
	 input [7:0] LoadVal;
	 input Load_n, ShiftRight, ASR, clk, reset_n;
    output [7:0] q;
	 
	 wire w0;
	 
	 function0 f0(
	     .ASR(ASR),
		  .s(LoadVal[7]),
		  .o(w0)
		  );
	 
	 shifterbit s7(
	  	  .load_val(LoadVal[7]),
        .load_n(Load_n),
		  .shift(ShiftRight),
		  .clk(clk),
		  .reset_n(reset_n),
		  .in(w0),
		  .out(q[7])
	     );
	
	  shifterbit s6(
		  .load_val(LoadVal[6]),
		  .load_n(Load_n),
		  .shift(ShiftRight),
		  .clk(clk),
		  .reset_n(reset_n),
		  .in(q[7]),
		  .out(q[6])
	     );
	
	  shifterbit s5(
		  .load_val(LoadVal[5]),
		  .load_n(Load_n),
		  .shift(ShiftRight),
		  .clk(clk),
		  .reset_n(reset_n),
		  .in(q[6]),
		  .out(q[5])
	     );
	
	  shifterbit s4(
		  .load_val(LoadVal[4]),
		  .load_n(Load_n),
		  .shift(ShiftRight),
		  .clk(clk),
		  .reset_n(reset_n),
		  .in(q[5]),
		  .out(q[4])
	     );
	
	  shifterbit s3(
		  .load_val(LoadVal[3]),
		  .load_n(Load_n),
		  .shift(ShiftRight),
		  .clk(clk),
		  .reset_n(reset_n),
		  .in(q[4]),
		  .out(q[3])
	     );
	
	  shifterbit s2(
		  .load_val(LoadVal[2]),
		  .load_n(Load_n),
		  .shift(ShiftRight),
		  .clk(clk),
		  .reset_n(reset_n),
		  .in(q[3]),
		  .out(q[2])
	     );
	
	  shifterbit s1(
		  .load_val(LoadVal[1]),
		  .load_n(Load_n),
		  .shift(ShiftRight),
		  .clk(clk),
		  .reset_n(reset_n),
		  .in(q[2]),
		  .out(q[1])
	     );
	
	  shifterbit s0(
		  .load_val(LoadVal[0]),
		  .load_n(Load_n),
		  .shift(ShiftRight),
		   .clk(clk),
		  .reset_n(reset_n),
		  .in(q[1]),
		  .out(q[0])
        );
endmodule


module function0(ASR, s, o);
    input s, ASR;
	 output o;
	 
	 reg out;
	 
	 always @(*)
	 
	 begin
	    if (ASR == 1'b0)
		     out = 1'b0;
	    else
		     out = s;
    end
	 
	 assign o = out;
endmodule


module shifterbit(in, shift, clk, load_n, load_val, reset_n, out);
    input in, shift, clk, load_n, load_val, reset_n;
    output out;
	 
	 wire c0, c1, c2;

    mux2to1 u0(
        .x(c2),
        .y(in),
        .s(shift),
        .m(c0)
        );
		  
    mux2to1 u1(
        .x(load_val),
        .y(c0),
        .s(load_n),
        .m(c1)
        );
		  
	 Dflipflop d1(
	     .clk(clk),
		  .d(c1),
		  .reset_n(reset_n),
		  .q(c2)
		  );

	 assign out = c2;
endmodule


module Dflipflop(clk, d, reset_n, q);
    input d, clk, reset_n;
	 output q;
	 
	 reg q;
	 
	 always @(posedge clk)
	 
	 begin
	     if (reset_n == 1'b0)
		      q <= 1'b0;
        else
		      q <= d;
	 end
endmodule


module mux2to1(x, y, s, m);
    input x;
    input y;
    input s;
    output m;
  
    assign m = s & y | ~s & x;
endmodule
