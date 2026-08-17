`timescale 1ns/1ps

module uart_rx (
	i_clk	,
	i_rst_n	,
	i_rx	,
	o_data	,
	o_valid	
);

input	i_clk		;
input	i_rst_n		;
input	i_rx		;

output reg [7:0] o_data	;
output reg [7:0] o_valid;

reg [7:0] r_bit_cnt	;
reg [7:0] r_data	;
reg [1:0] r_state	;

parameter IDLE 	= 2'b00;
parameter START = 2'b01;
parameter DATA 	= 2'b10;
parameter STOP 	= 2'b11;


always @(posedge i_clk or negedge i_rst_n) begin

	if(!i_rst_n) begin
		o_data 	<= 8'd0;
		o_valid <= 1'b0;

		r_bit_cnt <= 4'd0;
		r_data 	  <= 8'd0;
		r_state	  <= IDLE;
	end

	else begin
		o_valid <= 1'b0;

		case(r_state)

			IDLE: begin
				if(!i_rx) begin
					r_state <= START;
				end
			end

			START: begin
				r_bit_cnt <= 4'd0;
				r_state	  <= DATA;
			end

			DATA: begin
				r_data[r_bit_cnt] <= i_rx;
			
				if(r_bit_cnt == 4'd7) begin
				   r_bit_cnt <= 4'd0;
				   r_state   <= STOP;
				end

				else begin
					r_bit_cnt <= r_bit_cnt + 1'b1;
				end
			end

			STOP: begin
				o_data 	<= r_data;
				o_valid <= 1'b1;
				r_state <= IDLE;
			end

			default: begin
				r_state <= IDLE;
			end

		endcase
	end

end


endmodule

