module morsecodeencoder(SW, KEY, CLOCK_50, LEDR);
	input [2:0] SW;
	input [1:0] KEY;
	input CLOCK_50;
	output [0:0] LEDR;
	
	morse m0(
	    .in(SW[2:0]),
		 .start(KEY[1]),
		 .reset_n(KEY[0]),
		 .clock50(CLOCK_50),
		 .led(LEDR[0])
		 );
endmodule


module morse(in, start, reset_n, clock50, led);
	 input [2:0] in;
	 input start, reset_n, clock50;
	 output led;
	
	 wire [13:0] lut;
	 wire [24:0] clk;
	 wire shiftenable;
	
    reg rateenable, shiftload;
	 
	 always @(negedge start, negedge reset_n)
	 begin
		  if (reset_n == 0)
		      begin
			   shiftload <= 1;
			   rateenable <= 0;
				end
		  else if (start == 0)
		      begin
			   shiftload <= 0;
			   rateenable <= 1'b1;
				end
    end

	 LUT l0(
	     .in(in),
		  .out(lut)
		  );
		  
	 ratedivider r0(
	     .load(25'd24999999),
		  .enable(rateenable),
		  .reset_n(reset_n),
		  .clock(clock50),
		  .q(clk)
		  );
		  
	 assign shiftenable = (clk == 0) ? 1 : 0;
	 
	 shifter14bit s0(
	     .LoadVal(lut),
		  .Load_n(shiftload),
		  .ShiftRight(shiftenable),
		  .reset_n(reset_n),
		  .clk(clock50),
		  .out(led)
        );
endmodule


module ratedriver(load, enable, reset_n, clock, q);
    input [24:0] load;
	 input enable, reset_n, clock;
	 output reg [24:0] q;
	 
	 always @(posedge clock, negedge reset_n)
	 
	 begin
	     if (reset_n == 1'b0)
		      q <= load;
	     else if (enable == 1'b1)
		      begin
				    if (q == 0)
					     q <= load;
				    else
					     q <= q - 1'b1;
				end
	 end
endmodule


module LUT(in, out);
    input [2:0] in;
	 output reg [13:0] out;

	 always @(*)
	 
	 begin
	     case(in)
		      3'b000: out = 14'b00000000010101;
				3'b001: out = 14'b00000000000111;
				3'b010: out = 14'b00000001110101;
				3'b011: out = 14'b00000111010101;
				3'b100: out = 14'b00000111011101;
				3'b101: out = 14'b00011101010111;
				3'b110: out = 14'b01110111010111;
				3'b111: out = 14'b00010101110111;
		  endcase
	 end
endmodule


module shifter14bit(LoadVal, Load_n, ShiftRight, reset_n, clk, out);
	input Load_n, ShiftRight, reset_n, clk;
	input [13:0] LoadVal;
	output reg out;
	
	reg [13:0] q;
	
	always @(posedge clk, negedge reset_n)
	begin
		if (reset_n == 0)
			begin
			out <= 0;
			q <= 14'b0;
			end
		else if (Load_n == 1)
			begin
			out <= 0;
			q <= LoadVal;
			end
		else if (ShiftRight == 1)
			begin
			out <= q[0];
			q <= q >> 1'b1;
			end
	end
endmodule
