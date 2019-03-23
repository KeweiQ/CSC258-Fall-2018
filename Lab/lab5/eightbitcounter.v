module eightbitcounter(SW, KEY, HEX0, HEX1);
	 input [1:0] SW;
	 input [0:0] KEY;
	 output [6:0] HEX0, HEX1;
	
    wire [3:0] h0, h1;
	 
	 tffcounter t0(
	     .t(SW[1]),
		  .clock(KEY[0]),
		  .clear_b(SW[0]),
		  .q({h1, h0})
		  );
		  
	 HEXdisplays hex0(
	     .SW(h0),
		  .HEX(HEX0[6:0])
		  );
		  
	 HEXdisplays hex1(
	     .SW(h1),
		  .HEX(HEX1[6:0])
		  );
endmodule


module tffcounter(t, clock, clear_b, q);
    input t, clock, clear_b;
	 output [7:0] q;
	 
	 wire c0, c1, c2 ,c3 ,c4 ,c5 ,c6;
	 
	 assign c0 = q[0] & t;
	 assign c1 = q[1] & c0;
	 assign c2 = q[2] & c1;
	 assign c3 = q[3] & c2;
	 assign c4 = q[4] & c3;
	 assign c5 = q[5] & c4;
	 assign c6 = q[6] & c5;
	 
	 tflipflop t0(
	     .t(t),
		  .clock(clock),
		  .clear_b(clear_b),
		  .q(q[0])
		  );
	 
	 tflipflop t1(
	     .t(c0),
		  .clock(clock),
		  .clear_b(clear_b),
		  .q(q[1])
		  );
		  
    tflipflop t2(
	     .t(c1),
		  .clock(clock),
		  .clear_b(clear_b),
		  .q(q[2])
		  );
		  
	 tflipflop t3(
	     .t(c2),
		  .clock(clock),
		  .clear_b(clear_b),
		  .q(q[3])
		  );
		  
	 tflipflop t4(
	     .t(c3),
		  .clock(clock),
		  .clear_b(clear_b),
		  .q(q[4])
		  );
		  
	 tflipflop t5(
	     .t(c4),
		  .clock(clock),
		  .clear_b(clear_b),
		  .q(q[5])
		  );
		  
	 tflipflop t6(
	     .t(c5),
		  .clock(clock),
		  .clear_b(clear_b),
		  .q(q[6])
		  );
		  
	 tflipflop t7(
	     .t(c6),
		  .clock(clock),
		  .clear_b(clear_b),
		  .q(q[7])
		  );
endmodule


module tflipflop(t, clock, clear_b, q);
    input t, clock, clear_b;
	 output reg q;
    
	 always @(posedge clock, negedge clear_b)
	 
	 begin
	    if (clear_b == 1'b0)
		     q <= 1'b0;
	    else if (t == 1'b1)
		     q <= ~q;
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
