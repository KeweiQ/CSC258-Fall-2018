// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	wire ld_x, ld_y, ld_colour, enable;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	 datapath d0(
        .clk(CLOCK_50),
        .resetn(resetn),
	     .enable(enable),
        .data_in(SW[9:0]),
        .ld_x(ld_x),
	     .ld_y(ld_y),
	     .ld_colour(ld_colour),
	     .x_out(x),
	     .y_out(y),
        .colour_out(colour)
    );

    // Instansiate FSM control
    control c0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .go(~KEY[1]),
	     .ld(~KEY[3]),
	     .writeEn(writeEn),
	     .enable(enable),
        .ld_x(ld_x),
	     .ld_y(ld_y),
	     .ld_colour(ld_colour)
    );
    
endmodule


module combine(
    input [9:0] data_in,
	 input resetn, ld, go, clk,
	 
	 output [7:0] x,
	 output [6:0] y,
	 output [2:0] colour,
	 output writeEn
	 );
	 
	 wire ld_x, ld_y, ld_colour, enable;

	 datapath d1(
        .clk(clk),
        .resetn(resetn),
	     .enable(enable),
        .data_in(data_in),
        .ld_x(ld_x),
	     .ld_y(ld_y),
	     .ld_colour(ld_colour),
	     .x_out(x),
	     .y_out(y),
        .colour_out(colour)
    );

    control c1(
        .clk(clk),
        .resetn(resetn),
        .go(go),
	     .ld(ld),
	     .writeEn(writeEn),
	     .enable(enable),
        .ld_x(ld_x),
	     .ld_y(ld_y),
	     .ld_colour(ld_colour)
    );
endmodule


module control(
    input clk,
    input resetn,
    input go,
	 input ld,

	 output reg writeEn, enable,
    output reg ld_x, ld_y, ld_colour
    );

    reg [2:0] current_state, next_state; 
    
    localparam  S_LOAD_X              = 4'd0,
                S_LOAD_X_WAIT         = 4'd1,
                S_LOAD_Y_COLOUR       = 4'd2,
                S_LOAD_Y_COLOUR_WAIT  = 4'd3,
                S_DRAW                = 4'd4;
    
    // Next state logic aka our state table
    always @(*)
    begin: state_table 
            case (current_state)
                S_LOAD_X: next_state = ld ? S_LOAD_X_WAIT : S_LOAD_X; // Keep loading X until press KEY3
                S_LOAD_X_WAIT: next_state = ld ? S_LOAD_X_WAIT : S_LOAD_Y_COLOUR; // Keep wait until release KEY3
                S_LOAD_Y_COLOUR: next_state = go ? S_LOAD_Y_COLOUR_WAIT : S_LOAD_Y_COLOUR; // Keep loading Y and color until press KEY1
                S_LOAD_Y_COLOUR_WAIT: next_state = go ? S_LOAD_Y_COLOUR_WAIT : S_DRAW; // Keep waiting until release KEY1, start to draw
                S_DRAW: next_state = ld ? S_LOAD_X : S_DRAW; 
            default:     next_state = S_LOAD_X;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_x        = 1'b0;
        ld_y        = 1'b0;
        ld_colour   = 1'b0;
        writeEn     = 1'b0;
        enable      = 1'b0;
        case (current_state)
            S_LOAD_X: begin
                ld_x = 1'b1;
                end
            S_LOAD_Y_COLOUR: begin
                ld_y = 1'b1;
					 ld_colour = 1'b1;
                end
            S_DRAW: begin
					 enable = 1'b1;
					 writeEn = 1;
                end
        // default:
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(
    input clk,
    input resetn, enable,
    input [9:0] data_in,
    input ld_x, ld_y, ld_colour,
	 
	 output [7:0] x_out,
	 output [6:0] y_out,
    output [2:0] colour_out
    );
    
    // input registers
    reg [7:0] x;
	 reg [6:0] y;
	 reg [2:0] colour;
	 reg [1:0] count_x, count_y;
    
    // Registers x, y, colour with respective input logic
    always @ (posedge clk) begin
        if (!resetn) begin
            x <= 8'd0; 
            y <= 7'd0; 
            colour <= 3'd0; 
        end
        else begin
            if (ld_x)
                x <= {1'b0, data_in[6:0]}; // load x from data_in if id_x is high
            if (ld_y)
                y <= data_in[6:0]; // load y from data_in if id_y is high
            if (ld_colour)
                colour <= data_in[9:7]; // load colour from data_in if id_color is high
        end
    end
 
    // Counter for x
	 always @(posedge clk) begin
		  if (!resetn)
			   count_x <= 2'b00;
		  else if (enable) begin
			   if (count_x == 2'b11)
				    count_x <= 2'b00;
			   else begin
				    count_x <= count_x + 1'b1;
			   end
		  end
    end
	 
	 assign enabley = (count_x == 2'b11) ? 1: 0;
	 
	 // Counter for y
	 always @(posedge clk) begin
	     if (!resetn)
		      count_y <= 2'b00;
		  else if (enabley) begin
		      if (count_y == 2'b11)
		          count_y <= 2'b00;
				else begin
				    count_y <= count_y + 1'b1;
				end
		  end
	 end
	 
    assign colour_out = colour;
	 assign x_out = x + count_x;
	 assign y_out = y + count_y;
endmodule
