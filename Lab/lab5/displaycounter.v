module displaycounter(SW, CLOCK_50, HEX0);
    input CLOCK_50;
    input [9:0] SW;
	 output [6:0] HEX0;
	 
	 wire [3:0] w0;
	 
	 counter c0(
	     .load(SW[5:2]),
		  .par_load(SW[7]),
		  .enable(SW[8]),
		  .clock(CLOCK_50),
		  .reset_n(SW[9]),
		  .frequency(SW[1:0]),
		  .q(w0)
		  );
	     
	 
	 HEXdisplays h0(
	     .SW(w0),
		  .HEX(HEX0[6:0])
		  );
endmodule


module counter(load, par_load, enable, clock, reset_n, frequency, q);
    input [3:0] load;
	 input [1:0] frequency;
	 input par_load, enable, clock, reset_n;
	 output [3:0] q;
	 
	 wire [27:0] w1hz, w05hz, w025hz;
	 reg penable;
	
	 ratedriver r1hz(
	     .load({2'b0, 26'd49999999}),
		  .enable(enable),
		  .reset_n(reset_n),
		  .clock(clock),
		  .q(w1hz)
		  );
		  
	 ratedriver r05hz(
	     .load({1'b0, 27'd99999999}),
		  .enable(enable),
		  .reset_n(reset_n),
		  .clock(clock),
		  .q(w05hz)
		  );
		  
	 ratedriver r025hz(
	     .load({28'd19999999}),
		  .enable(enable),
		  .reset_n(reset_n),
		  .clock(clock),
		  .q(w025hz)
		  );
		  
	 always @(*)
	 
	 begin
	     case(frequency)
			   2'b00: penable = enable;
				2'b01: penable = (w1hz == 0) ? 1 : 0;
				2'b10: penable = (w05hz == 0) ? 1 : 0;
				2'b11: penable = (w025hz == 0) ? 1 : 0;
		  endcase
	 end
		
    poscounter h0(
	     .load(load),
		  .par_load(par_load),
		  .enable(penable),
		  .reset_n(reset_n),
		  .clock(clock),
		  .q(q)
		  );
endmodule


module poscounter(load, par_load, enable, reset_n, clock, q);
    input [3:0] load;
	 input par_load, enable, reset_n, clock;
	 output reg [3:0] q;
	 
	 always @(posedge clock, negedge reset_n)
	 begin
		  if (reset_n == 1'b0)
			   q <= 0;
		  else if (par_load == 1'b1)
			   q <= load;
		  else if (enable == 1'b1)
			   begin
				if (q == 4'b1111)
					 q <= 0;
				else
					 q <= q + 1'b1;
			   end
	 end
endmodule


module ratedriver(load, enable, reset_n, clock, q);
    input [27:0] load;
	 input enable, reset_n, clock;
	 output reg [27:0] q;
	 
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


module HEXdisplays(SW, HEX);
    input [3:0] SW;
    output [6:0]HEX;


    assign HEX[0] = (~SW[3] & ~SW[2] & ~SW[1] & SW[0]) |  
                     (~SW[3] & SW[2] & ~SW[1] & ~SW[0]) |
		               (SW[3] & ~SW[2] & SW[1] & SW[0]) |
                     (SW[3] & SW[2] & ~SW[1] & SW[0]);
		  
    assign HEX[1] = (SW[3] & SW[2] & ~SW[0]) |  
                     (SW[3] & SW[1] & SW[0]) |
		               (SW[2] & SW[1] & ~SW[0]) |
							(~SW[3] & SW[2] & ~SW[1] & SW[0]);
		  
    assign HEX[2] = (~SW[3] & ~SW[2] & SW[1] & ~SW[0]) |  
                     (SW[3] & SW[2] & ~SW[0]) |
		               (SW[3] & SW[2] & SW[1]);
		  
    assign HEX[3] = (~SW[3] & SW[2] & ~SW[1] & ~SW[0]) |  
                     (~SW[2] & ~SW[1] & SW[0]) |
		               (SW[2] & SW[1] & SW[0]) |
                     (SW[3] & ~SW[2] & SW[1] & ~SW[0]);
		  
    assign HEX[4] = (~SW[3] & SW[2] & ~SW[1]) |  
                     (~SW[2] & ~SW[1] & SW[0]) |
		               (~SW[3] & SW[0]);
		  
    assign HEX[5] = (~SW[3] & ~SW[2] & SW[0]) |  
                     (~SW[3] & ~SW[2] & SW[1]) |
		               (~SW[3] &  SW[1] & SW[0]) |
							(SW[3] & SW[2] & ~SW[1] & SW[0]);
		  
    assign HEX[6] = (~SW[3] & ~SW[2] & ~SW[1]) |  
                     (~SW[3] & SW[2] & SW[1] & SW[0]) |
		               (SW[3] & SW[2] & ~SW[1] & ~SW[0]);
		  
endmodule
