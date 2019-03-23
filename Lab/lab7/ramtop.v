module ramtop(SW, KEY, HEX5, HEX4, HEX2, HEX0);
	input [9:0] SW;
	input [0:0] KEY;
	output [6:0] HEX5, HEX4, HEX2, HEX0;
	
	wire [3:0] out;
	
	ram32x4 r(SW[8:4], KEY[0], SW[3:0], SW[9], out[3:0]);
	
	HEXdisplays h5({3'b000, SW[8]}, HEX5);
	HEXdisplays h4(SW[7:4], HEX4);
	HEXdisplays h2(SW[3:0], HEX2);
	HEXdisplays h0(out, HEX0);
endmodule


module HEXdisplays(SW, HEX);
    input [3:0] SW;
    output [6:0] HEX;

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
