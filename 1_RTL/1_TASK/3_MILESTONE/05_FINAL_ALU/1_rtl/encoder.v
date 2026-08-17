`timescale 1ns/1ps

module  encoder (
	i_clk		,
	i_rst_n		,
	i_result	,
	i_valid		,
	i_tx_busy	,
	o_data		,
	o_valid
);

input		i_clk	  ;
input		i_rst_n	  ;
input	[7:0]	i_result  ;
input		i_valid	  ;
input		i_tx_busy ;

output reg [7:0] o_data	;
output reg	 o_valid;

reg	[7:0]	r_result;
reg 	[2:0] 	r_state ;

parameter IDLE       = 3'b000;
parameter SEND_H     = 3'b001;
parameter WAIT_H_ON  = 3'b010;
parameter WAIT_H_OFF = 3'b011;
parameter SEND_L     = 3'b100;
parameter WAIT_L_ON  = 3'b101;
parameter WAIT_L_OFF = 3'b110;

function [7:0] hex_to_ascii;

	input [3:0] i_hex;

	begin
		if (i_hex < 4'd10)
	
			hex_to_ascii = i_hex + 8'h30;
	
		else
	
			hex_to_ascii = i_hex - 4'd10 + 8'h41;
	end

endfunction


always @(posedge i_clk or negedge i_rst_n) begin

	if (!i_rst_n) begin

		r_result <= 8'd0;
		r_state  <= IDLE;

		o_data   <= 8'd0;
		o_valid  <= 1'b0;

	end

	else begin
		
		o_valid <= 1'b0;

		case (r_state)
	
			IDLE: begin
		
				if (i_valid) begin
			
					r_result <= i_result;
					r_state  <= SEND_H;
				end

			end

			SEND_H: begin
				
				if (!i_tx_busy) begin
			
					o_data  <= hex_to_ascii(r_result[7:4]);
					o_valid <= 1'b1;
				
					r_state <= WAIT_H_ON;

				end

			end

			WAIT_H_ON: begin

				if (i_tx_busy) begin

					r_state <= WAIT_H_OFF;

				end

			end

			WAIT_H_OFF: begin

				if (!i_tx_busy) begin

					r_state <= SEND_L;

				end

			end

			SEND_L: begin
	
				if (!i_tx_busy) begin

					o_data  <= hex_to_ascii(r_result[3:0]);
					o_valid <= 1'b1;

					r_state <= WAIT_L_ON;
				
				end

			end

			WAIT_L_ON: begin

				if (!i_tx_busy) begin

					r_state <= WAIT_L_OFF;
				end

			end

			WAIT_L_OFF: begin

				if (!i_tx_busy) begin

					r_state <= IDLE;

				end

			end
			
			default: begin

				r_state <= IDLE;

			end

		endcase

	end

end


endmodule
