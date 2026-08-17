`timescale 1ns/1ps

module calculator (
	i_clk	,
	i_rst_n	,
	i_data	,
	i_valid	,

	o_a	,
	o_b	,
	o_sel	,
	o_dtype ,
	o_start
);


input			i_clk	;
input			i_rst_n ;
input 	   [7:0]	i_data	;
input			i_valid	;

output reg [7:0] 	o_a	;
output reg [7:0] 	o_b	;
output reg [2:0] 	o_sel	;
output reg		o_dtype	;
output reg	 	o_start	;

// state
reg	[3:0]	r_state;

parameter WAIT_I    = 4'd0;
parameter WAIT_TYPE = 4'd1;
parameter WAIT_A1   = 4'd2;
parameter WAIT_A2   = 4'd3;
parameter WAIT_OP   = 4'd4;
parameter WAIT_B1   = 4'd5;
parameter WAIT_B2   = 4'd6;
parameter WAIT_END  = 4'd7;

// operator
parameter OP_ADD  = 3'b000;
parameter OP_SUB  = 3'b001;
parameter OP_MUL  = 3'b010;
parameter OP_DIVU = 3'b011;
parameter OP_DIVS = 3'b100;


// ASCII HEX -> 4 bit
function [3:0] ascii_to_hex;
	input [7:0] ascii;

	begin
		if ((ascii >= 8'h30) &&
		    (ascii <= 8'h39)) begin

			ascii_to_hex = ascii - 8'h30;
	
		end

		else if ((ascii >= 8'h41) &&
		 	 (ascii <= 8'h46)) begin

			ascii_to_hex = ascii - 8'h41 + 4'd10;
	
		end
	
		else if ((ascii >= 8'h61) &&
			 (ascii <= 8'h66)) begin
	
			ascii_to_hex = ascii - 8'h61 + 4'd10;
	
		end

		else begin
	
			ascii_to_hex = 4'h0;
	
		end

	end

endfunction


// ASCII HEX distinction

function is_hex;
	input [7:0] ascii;

	begin

		if (((ascii >= 8'h30) &&
		    (ascii <= 8'h39)) ||

		   ((ascii >= 8'h41) &&
	     	    (ascii <= 8'h46)) ||

		   ((ascii >= 8'h61) &&
		    (ascii <= 8'h66))) begin

			is_hex = 1'b1;

		end

		else begin

			is_hex = 1'b0;

		end

	end

endfunction


// FSM

always @(posedge i_clk or negedge i_rst_n) begin

	if (!i_rst_n) begin

		o_a	<= 8'd0;
		o_b	<= 8'd0;
		o_sel	<= OP_ADD;
		o_dtype <= 1'b0;
		o_start	<= 1'b0;

		r_state	<= WAIT_I;

	end

	else begin

		o_start <= 1'b0;

		if (i_valid) begin

			case (r_state)

				// I

				WAIT_I: begin

					if (i_data == 8'h49) begin
						// ASCII 'I'
						r_state <= WAIT_TYPE;
					end
				end

				// S / U

				WAIT_TYPE: begin

					if (i_data == 8'h53) begin
						// 'S'
						o_dtype <= 1'b1;
						r_state <= WAIT_A1;
					end

					else if (i_data == 8'h55) begin
						// 'U'
						o_dtype <= 1'b0;
						r_state <= WAIT_A1;
					end

					else begin
						r_state <= WAIT_I;
					end

				end

				
				//  A high nibble -> A[7:4]

				WAIT_A1: begin

					if ((i_data >= 8'h30 &&
					     i_data <= 8'h39) ||
					    (i_data >= 8'h41 &&
					     i_data <= 8'h46) ||
					    (i_data >= 8'h61 &&
					     i_data <= 8'h66)) begin

						o_a[7:4] <= ascii_to_hex(i_data);
					 	r_state  <= WAIT_A2;

					end

				end

				
				// A low nibble -> A[3:0]
				
				WAIT_A2: begin

					if ((i_data >= 8'h30 &&
					     i_data <= 8'h39) ||
					    (i_data >= 8'h41 &&
					     i_data <= 8'h46) ||
					    (i_data >= 8'h61 &&
					     i_data <= 8'h66)) begin

						o_a[3:0] <= ascii_to_hex(i_data);
						r_state <= WAIT_OP;

					end
				
				end


				// operator
				
				WAIT_OP: begin

					case (i_data)

						8'h2B: begin
							// +
							o_sel	<= OP_ADD;
							r_state	<= WAIT_B1;
						end

						8'h2D: begin
							// -
							o_sel	<= OP_SUB;
							r_state	<= WAIT_B1;
						end
						
						8'h2A: begin
							// *
							o_sel	<= OP_MUL;
							r_state	<= WAIT_B1;
						end

						8'h2F: begin
							// /
							if (o_dtype)
								o_sel <= OP_DIVS;
							else
								o_sel <= OP_DIVU;

							r_state <= WAIT_B1;

						end

						default: begin
							r_state <= WAIT_I;
						end

					endcase

				end


				// B high nibble -> B[7:4]
				
				WAIT_B1: begin

					if ((i_data >= 8'h30 &&
					     i_data <= 8'h39) ||
					    (i_data >= 8'h41 &&
					     i_data <= 8'h46) ||
					    (i_data >= 8'h61 &&
					     i_data <= 8'h66)) begin

						o_b[7:4] <= ascii_to_hex(i_data);
						r_state  <= WAIT_B2;

					end

				end


				// B low nibble -> B[3:0]
				
				WAIT_B2: begin

					if ((i_data >= 8'h30 &&
					     i_data <= 8'h39) ||
					    (i_data >= 8'h41 &&
					     i_data <= 8'h46) ||
					    (i_data >= 8'h61 &&
			    	     	     i_data <= 8'h66)) begin

						o_b[3:0] <= ascii_to_hex(i_data);
						r_state  <= WAIT_END;

					end
				
				end


				// =

				WAIT_END: begin
		
					if (i_data == 8'h3D) begin
						// ASCII '='

						o_start <= 1'b1;
						r_state <= WAIT_I;

					end

				end

				default: begin

					r_state <= WAIT_I;

				end

			endcase

		end

	end

end


endmodule
							
