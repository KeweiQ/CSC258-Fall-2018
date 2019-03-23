module ALUplus(SW, KEY, LEDR, HEX0, HEX4, HEX5);
	 input [9:0] SW;
    input [0:0] KEY;
	 output [7:0] LEDR;
	 output [6:0] HEX0, HEX4, HEX5;
	 
	 reg [7:0] ALUout;
	 
	 wire [4:0] c0;
	 wire [4:0] c1;
	 wire [7:0] regout;
	 
	 register rg(
	     .d(ALUout[7:0]),
		  .clk(KEY[0]),
		  .reset_n(SW[9]),
		  .q(regout[7:0])
		  );
	 
	 ripplecarryadder r0(
	     .SW({5'b00001, SW[3:0]}),
		  .LEDR(c0)
		  );
	 
	 ripplecarryadder r1(
	     .SW({1'b0, regout[3:0], SW[3:0]}),
		  .LEDR(c1)
		  );
		  
	 function0 f0(
	     .SW({regout[3:0], SW[3:0]}), 
		  .r(c2)
		  );
	 
	 always @(*)
	 
    begin
        case (SW[7:5])
		      3'b000: ALUout = {3'b000, c0[4], c0[3:0]};
				3'b001: ALUout = {3'b000, c1[4], c1[3:0]};
				3'b010: ALUout = SW[3:0] + regout[3:0];
				3'b011: ALUout = {SW[3:0] | regout[3:0], SW[3:0] ^ regout[3:0]};
				3'b100: ALUout = {7'b0000000, c2};
				3'b101: ALUout = {4'b0000, regout[3:0] << SW[3:0]};
				3'b110: ALUout = {4'b0000, regout[3:0] >> SW[3:0]};
				3'b111: ALUout = SW[3:0] * regout[3:0];
				default: ALUout = 8'b00000000;
		  endcase
	 end
	 
	 assign LEDR[7:0] = regout[7:0];
	 
	 HEXdisplays h0(
	    .SW(SW[3:0]), 
		 .HEX(HEX0[6:0])
		 );
		 
	 HEXdisplays h4(
	    .SW(regout[3:0]), 
		 .HEX(HEX4[6:0])
		 );
		 
	 HEXdisplays h5(
	    .SW(regout[7:4]), 
		 .HEX(HEX5[6:0])
		 );
endmodule


module register (d, clk, reset_n, q);
    input [7:0] d;
	 input clk, reset_n;
	 output reg [7:0] q;
    
	 always @(posedge clk)
	 
	 begin
	    if (reset_n == 1'b0)
		     q <= 8'b00000000;
	    else
		     q <= d;
    end
endmodule


module function0 (SW, r);
    input [7:0] SW;
	 output r;
	 
	 assign r = {SW[7] | SW[6] | SW[5] | SW[4] | SW[3] | SW[2] | SW[1] | SW[0]};
endmodule


module ripplecarryadder(SW, LEDR);
	 input [8:0] SW;
	 output [4:0] LEDR;
	 
	 wire c1;
	 wire c2;
	 wire c3;
	 
	 full_adder f0(
	     .A(SW[0]),
		  .B(SW[4]),
		  .cin(SW[8]),
		  .S(LEDR[0]),
		  .cout(c1)
		  );
	 
	 full_adder f1(
	     .A(SW[1]),
		  .B(SW[5]),
		  .cin(c1),
		  .S(LEDR[1]),
		  .cout(c2)
		  );
	 
	 full_adder f2(
	     .A(SW[2]),
		  .B(SW[6]),
		  .cin(c2),
		  .S(LEDR[2]),
		  .cout(c3)
		  );
		  
	 full_adder f3(
	     .A(SW[3]),
		  .B(SW[7]),
		  .cin(c3),
		  .S(LEDR[3]),
		  .cout(LEDR[4])
		  );
endmodule

module full_adder(A, B, cin, S, cout);
	 input A, B, cin;
	 output S, cout;
	 
	 assign S = A ^ B ^ cin;
	 assign cout = (A & B) | (cin & (A ^ B));
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
