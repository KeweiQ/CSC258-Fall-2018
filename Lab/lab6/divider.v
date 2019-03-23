//SW[7:0] data_in

//KEY[0] synchronous reset when pressed
//KEY[1] go signal

//LEDR displays result
//HEX0 & HEX1 also displays result

module divider(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire resetn;
    wire go;

    wire [7:0] data_result;
    assign go = ~KEY[1];
    assign resetn = KEY[0];

    part2 u0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .go(go),
        .data_in(SW[7:0]),
        .data_result(data_result)
    );
      
    assign LEDR[9:0] = {2'b00, data_result};

    hex_decoder H0(
        .hex_digit(SW[3:0]), 
        .segments(HEX0)
        );
        
    hex_decoder H1(
        .hex_digit(4'h0), 
        .segments(HEX1)
        );
		  
	 hex_decoder H2(
        .hex_digit(SW[7:4]), 
        .segments(HEX2)
        );
		  
	 hex_decoder H3(
        .hex_digit(4'h0), 
        .segments(HEX3)
        );
		  
	 hex_decoder H4(
        .hex_digit(data_result[3:0]), 
        .segments(HEX4)
        );
		  
	 hex_decoder H5(
        .hex_digit(data_result[7:4]), 
        .segments(HEX5)
        );

endmodule

module part2(
    input clk,
    input resetn,
    input go,
    input [7:0] data_in,
    output [7:0] data_result
    );

    // lots of wires to connect our datapath and control
    wire ld_divisor, ld_dividend, ld_remainder, shift_dividend, shift_remainder;
    wire alu_op;
	 wire ld_result;

    control C0(
        .clk(clk),
        .resetn(resetn),
        .go(go),
        
		  .ld_divisor(ld_divisor),
        .ld_dividend(ld_dividend),
		  .ld_remainder(ld_remainder),
        .shift_dividend(shift_dividend),
        .shift_remainder(shift_remainder),
        .alu_op(alu_op),
        .ld_result(ld_result)
    );

    datapath D0(
        .clk(clk),
        .resetn(resetn),
        .divisor_in(data_in[3:0]), 
		  .dividend_in(data_in[7:4]),
		  
		  .ld_divisor(ld_divisor),
        .ld_dividend(ld_dividend),
		  .ld_remainder(ld_remainder),
        .shift_dividend(shift_dividend),
        .shift_remainder(shift_remainder),
        .alu_op(alu_op), 
        .ld_result(ld_result),
		  
		  .remainder_result(data_result[7:4]),
		  .quotient_result(data_result[3:0])
    );
                
 endmodule        
                

module control(
    input clk,
    input resetn,
    input go,

    output reg ld_divisor, ld_dividend, ld_remainder,
	 output reg shift_dividend, shift_remainder, ld_result,
	 output reg alu_op
    );

    reg [2:0] current_state, next_state;
	 reg [2:0] count;
    
    localparam  S_LOAD               = 4'd0,
                S_LOAD_WAIT          = 4'd1,
                S_SHIFT_REMAINDER    = 4'd2,
                S_SUBTRACT           = 4'd3,
                S_SHIFT_DIVIDEND     = 4'd4,
                S_ADD                = 4'd5,
					 S_DONE               = 4'd6;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD: begin
					     next_state = go ? S_LOAD_WAIT : S_LOAD; // Loop in current state until value is input
                    count = 3'b000;
					 end
					 S_LOAD_WAIT: next_state = go ? S_LOAD_WAIT : S_SHIFT_REMAINDER; // Loop in current state until go signal goes low
                S_SHIFT_REMAINDER: next_state = S_SUBTRACT;
					 S_SUBTRACT: begin
					     next_state = S_SHIFT_DIVIDEND;
						  count = count + 3'b001;
					 end
					 S_SHIFT_DIVIDEND: next_state = S_ADD;
					 S_ADD: next_state = (count == 3'b100) ? S_DONE : S_SHIFT_REMAINDER;
					 S_DONE: next_state = S_LOAD;
				default:     next_state = S_LOAD;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_divisor = 1'b0;
        ld_dividend = 1'b0;
		  ld_remainder = 1'b0;
		  shift_dividend = 1'b0;
        shift_remainder = 1'b0;
        alu_op = 1'b0;
		  ld_result = 1'b0;

        case (current_state)
            S_LOAD: begin
                ld_divisor = 1'b1;
					 ld_dividend = 1'b1;
            end
				S_LOAD_WAIT: begin
                ld_divisor = 1'b0;
					 ld_dividend = 1'b0;
            end
            S_SHIFT_REMAINDER: begin // Shift dividend to remainder 
                shift_remainder = 1'b1; // Shift MSB of dividend into LSB of remainder
            end
            S_SUBTRACT: begin // Subtract divisor from remainder
                alu_op = 1'b0; // Do subtraction
					 ld_remainder = 1'b1;
			   end
				S_SHIFT_DIVIDEND: begin
                shift_dividend = 1'b1; // Left shift dividend 1 bit
				end
				S_ADD: begin // Add divisor to remainder if cout == 1
                ld_remainder = 1'b1;
   			    alu_op = 1'b1; // Do addition
				end
				S_DONE: begin // Finish the calculation
                ld_result = 1'b1;
				end
            default: begin
                ld_divisor = 1'b0;
					 ld_dividend = 1'b0;
				end
        endcase
    end // enable_signals
   
    // current_state registers
    always @(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(
    input clk,
    input resetn,
    input [3:0]divisor_in, dividend_in,
    input ld_divisor, ld_dividend, ld_remainder,
	 input shift_dividend, shift_remainder, ld_result,
	 input alu_op,
    output reg [3:0]remainder_result, quotient_result
    );
    
    // input registers
    reg [4:0] divisor;
	 reg [3:0] dividend;
	 reg [4:0] remainder;

    // output of the alu
    reg [4:0] alu_out;
    
    // Register about divisor
    always @ (posedge clk) begin
        if (!resetn) begin
            divisor <= 5'd0;
        end
        else begin
            if (ld_divisor)
                divisor <= {1'b0, divisor_in}; // load from divisor_in if ld_divisor signal is high
        end
    end
	 
	 // Register about dividend/quotient
    always @ (posedge clk) begin
        if (!resetn) begin
            dividend <= 4'd0;
        end
        else begin
            if (ld_dividend)
                dividend <= dividend_in; // Load from dividend_in if ld_dividend signal is high
            if (shift_dividend)
					 dividend <= {dividend[2:0], ~remainder[4]};
		  end
    end
	 
	 // Register about remainder
    always @ (posedge clk) begin
        if (!resetn) begin
            remainder <= 5'd0;
        end
        else begin
            if (ld_remainder) begin
                remainder <= alu_out; // Load from alu_out if ld_remiander signal is high
				end
				if (shift_remainder)
					 remainder <= {remainder[3:0], dividend[3]}; //Shift MSB of dividend into LSB of remainder if shift_left is high
		  end
    end
	 
	 // Output result register
    always @ (posedge clk) begin
        if (!resetn) begin
            remainder_result <= 4'b0000;
				quotient_result <= 4'b0000;
        end
        else begin
            if (ld_result) begin
				    remainder_result <= remainder[3:0];
				    quotient_result <= dividend;
				end
		  end
    end

    // The ALU 
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            1'b0: begin
                   alu_out = remainder - divisor; //performs subtraction
               end
            1'b1: begin
				       if (remainder[4])
                       alu_out = remainder + divisor; //performs addition
                   else
						     alu_out = remainder + 5'b00000; //don't perform addition
					end
        endcase
    end
endmodule


module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
