// Part 3 skeleton

module part3
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
	input   [2:0]   SW;
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
	
	wire ld_colour, enable;

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
	     .ld_colour(ld_colour),
        .colour_in(SW[2:0]),
	     .x_vga(x),
	     .y_vga(y),
        .colour_vga(colour)
    );

    // Instansiate FSM control
    control c0(
        .clk(CLOCK_50),
        .resetn(resetn),
	     .ld(~KEY[3]),
	     .writeEn(writeEn),
	     .enable(enable),
	     .ld_colour(ld_colour)
    );
    
endmodule


module combine(
    input [2:0] colour_in,
	 input resetn, ld, clk,
	 
	 output [7:0] x,
	 output [6:0] y,
	 output [2:0] colour,
	 output writeEn
	 );
	 
	 wire ld_colour, enable;

	 datapath d1(
        .clk(clk),
        .resetn(resetn),
	     .enable(enable),
	     .ld_colour(ld_colour),
        .colour_in(colour_in),
	     .x_vga(x),
	     .y_vga(y),
        .colour_vga(colour)
    );

    control c1(
        .clk(clk),
        .resetn(resetn),
	     .ld(ld),
	     .writeEn(writeEn),
	     .enable(enable),
	     .ld_colour(ld_colour)
        );
endmodule


module control(
    input clk,
    input resetn,
	 input ld,

	 output reg writeEn, enable, ld_colour
    );

    reg [1:0] current_state, next_state; 
    
    localparam  S_LOAD_COLOUR         = 4'd0,
                S_LOAD_COLOUR_WAIT    = 4'd1,
                S_DRAW                = 4'd2;
    
    // Next state logic aka state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_COLOUR: next_state = ld ? S_LOAD_COLOUR_WAIT : S_LOAD_COLOUR; // Keep loading Colour until press KEY3
                S_LOAD_COLOUR_WAIT: next_state = ld ? S_LOAD_COLOUR_WAIT : S_DRAW; // Keep wait until release KEY3, then start move
                S_DRAW: next_state = S_DRAW; // Start move
            default:     next_state = S_LOAD_COLOUR;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_colour   = 1'b0;
        writeEn     = 1'b0;
        enable      = 1'b0;
        case (current_state)
            S_LOAD_COLOUR: begin
                ld_colour = 1'b1;
                end
            S_DRAW: begin
                ld_colour = 1'b1;
					 enable = 1'b1;
					 writeEn = 1;
                end
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_COLOUR;
        else
            current_state <= next_state;
    end // state_FFS
endmodule


module draw(
    input clk, resetn, enable, ld_colour,
    input [7:0] x_in,
	 input [6:0] y_in,
	 input [2:0] colour_in,
	 
	 output [7:0] x_out,
	 output [6:0] y_out,
    output [2:0] colour_out
    );
    
    // input registers
    reg [7:0] x;
	 reg [6:0] y;
	 reg [2:0] colour;
	 reg [1:0] draw_x, draw_y;
	 reg [7:0] location_x;
	 reg [6:0] location_y;
	 reg direction_x, direction_y;
	 
    // Registers x, y, colour with respective input logic
	 always @ (posedge clk) begin
        if (!resetn) begin
            x <= 8'b00000000; 
            y <= 7'b0000000;
			   colour <= 3'b000;
        end
        else begin
            x <= x_in;
            y <= y_in;
				if(ld_colour == 1'b1)
				    colour <= colour_in;
        end
    end
 
    // Counter to draw x
	 always @(posedge clk) begin
		  if (!resetn)
			   draw_x <= 2'b00;
		  else if (enable) begin
			   if (draw_x == 2'b11)
				    draw_x <= 2'b00;
			   else begin
				    draw_x <= draw_x + 1'b1;
			   end
		  end
    end
	 
	 assign enabley = (draw_x == 2'b11) ? 1: 0;
	 
	 // Counter to draw y
	 always @(posedge clk) begin
	     if (!resetn)
		      draw_y <= 2'b00;
		  else if (enabley) begin
		      if (draw_y == 2'b11)
		          draw_y <= 2'b00;
				else begin
				    draw_y <= draw_y + 1'b1;
				end
		  end
	 end
	 
	 assign colour_out = colour;
	 assign x_out = x + draw_x;
	 assign y_out = y + draw_y;
endmodule
	 
	 
module datapath(
	 input enable, clk, resetn, ld_colour,
	 input [2:0] colour_in,
	 output [7:0] x_vga,
	 output [6:0] y_vga,
	 output [2:0] colour_vga
	 );
	
	 wire [19:0] c0;
	 wire [3:0] c1;
	 wire [2:0] colour_draw;
	 wire update_1, update_2;
	 reg [7:0] location_x;
	 reg [6:0] location_y;
	 reg direction_x, direction_y;
	 
	 // count down to get around 60HZ
	 rate_driver m1(
	     .clk(clk),
		  .resetn(resetn),
		  .enable(enable),
		  .rate(c0)
		  );
		 
	 assign update_1 = (c0 ==  20'd0) ? 1 : 0;
	
	 // count to move at four pixels per second
	 frame_counter m2(
	     .clk(clk),
	 	  .resetn(resetn),
	 	  .enable(update_1),
		  .frame(c1)
		  );
	
	 assign update_2 = (c1 == 4'b1111) ? 1 : 0;
	 
	 // Counter to re-locate x
	 always @(negedge update_2, negedge resetn) 
	     begin
		      if (!resetn)
			       location_x <= 8'b00000000;
	         else begin
			       if (direction_x == 1'b1)
				        location_x <= location_x + 1'b1;
			       else
				        location_x <= location_x - 1'b1;
			   end
		  end
	 
	 // Counter to re-locate y
	 always @(negedge update_2, negedge resetn) 
	     begin
		      if (!resetn)
			       location_y <= 7'b0111100;
		      else begin
			       if (direction_y == 1'b1)
				        location_y <= location_y + 1'b1;
			       else
				        location_y <= location_y - 1'b1;
			   end
		  end
	 
	 // Register to direct x
	 always @(posedge clk) begin
		  if (!resetn)
			   direction_x <= 1'b1; // default go right
		  else begin
		      if (direction_x == 1'b1) begin // right in progress
				    if (location_x == 8'b10011011) begin // hit the boundary
  					     direction_x <= 1'b0; // start go left
					 end
			       else begin // does not hit the boundary
					     direction_x <= 1'b1; // keep go right
					 end
			   end
				else begin // left in progress
				    if (location_x == 8'b00000000) begin // hit the boundary
				        direction_x <= 1'b1; // statr go right
					 end
					 else begin // does not hit the boundary
					     direction_x <= 1'b0; // keep go left
					 end
			   end
		  end
    end
	 
	 // Register to direct y
	 always @(posedge clk) begin
		  if (!resetn)
			   direction_y <= 1'b0; // deafult go up
		  else begin
			   if (direction_y == 1'b1) begin// down in progress
				    if (location_y == 7'b1110011) begin // hit the boundary
				        direction_y <= 1'b0; // start go up
					 end
				    else begin// does not hit the boundary
					     direction_y <= 1'b1; // keep go down
					 end
				end
			   else begin // up in progress
				    if (location_y == 7'b0000001) begin // hit the boundary
				        direction_y <= 1'b1; // satrt go down
					 end
					 else begin // does not hit the boundary
					     direction_y <= 1'b0; // keep go up
					 end
			   end
		  end
    end
	 
	 
	assign colour_draw = (c1 == 4'b1111) ? 3'b000 : colour_in;
	
	draw dr0(
		 .enable(enable),
		 .clk(clk),
		 .resetn(resetn),
		 .ld_colour(ld_colour),
	    .x_in(location_x),
		 .y_in(location_y),
		 .colour_in(colour_draw),
		 .x_out(x_vga),
		 .y_out(y_vga),
		 .colour_out(colour_vga)
		 );
endmodule


module rate_driver(
		input clk,
		input resetn,
		input enable,
		output reg [19:0] rate
		);
		
		always @(posedge clk)
		begin
			if (resetn == 1'b0)
				rate <= 20'd840000;
			else if(enable ==1'b1)
			begin
			   if (rate == 20'd0)
					rate <= 20'd840000;
				else
					rate <= rate - 1'b1;
			end
		end
		
		
endmodule


module frame_counter(
	input clk,
	input resetn,
	input enable,
	output reg [3:0] frame
	);
	
	always @(posedge clk)
	begin
		if (resetn == 1'b0)
			frame <= 4'b0000;
		else if(enable == 1'b1)
		begin
		  if (frame == 4'b1111)
			  frame <= 4'b0000;
		  else
			  frame <= frame + 1'b1;
		end
   end
endmodule
