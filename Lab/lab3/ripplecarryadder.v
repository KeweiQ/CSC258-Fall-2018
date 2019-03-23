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
