`timescale 1ns/1ps

module calculator (
	i_clk	,
	i_rst_n	,
	i_data	,
	i_valid	,
	o_a	,
	o_b	,
	o_sel	,
	o_start
);


input			i_clk	;
input			i_rst_n ;
input 	   [7:0]	i_data	;
input			i_valid	;

output reg [7:0] 	o_a	;
output reg [7:0] 	o_b	;
output reg [1:0] 	o_sel	;
output reg	 	o_start	;

reg [1:0]		r_state	;


parameter WAIT_A  = 2'b00;
parameter WAIT_OP = 2'b01;
parameter WAIT_B  = 2'b10;

parameter OP_ADD  = 2'b00;
parameter OP_SUB  = 2'b01;
parameter OP_AND  = 2'b10;
parameter OP_OR   = 2'b11;


always @(posedge i_clk or negedge i_rst_n) begin

	if(!i_rst_n) begin

		o_a     <= 8'd0;
		o_b     <= 8'd0;
		o_sel   <= 2'b00;
		o_start <= 1'b0;

		r_state <= WAIT_A;

	end

	else begin

		o_start <= 1'b0;

		if(i_valid) begin

			case(r_state)

				WAIT_A: begin

					if((i_data >= 8'h30) &&
					   (i_data <= 8'h39)) begin

					  	o_a <= i_data - 8'h30;

						r_state <= WAIT_OP;

					end
				end


				WAIT_OP: begin

					case(i_data)

						8'h2B: begin
							// '+'
							o_sel <= OP_ADD;
							r_state <= WAIT_B;
						end


						8'h2D: begin
							// '-'
							o_sel <= OP_SUB;
							r_state <= WAIT_B;
						end


						8'h26: begin
							// '&'
							o_sel <= OP_AND;
							r_state <= WAIT_B;
						end

						
						8'h7C: begin
							// '|'
							o_sel <= OP_OR;
							r_state <= WAIT_B;
						end

						
						default: begin
							r_state <= WAIT_OP;
						end
					endcase
				end


				WAIT_B: begin

					if((i_data >= 8'h30) &&
					   (i_data <= 8'h39)) begin

					   o_b <= i_data - 8'h30;

					   o_start <= 1'b1;

					   r_state <= WAIT_A;
					end

				end

				
				default: begin
					r_state <= WAIT_A;
				end

			endcase
		end
	end
end


endmodule
