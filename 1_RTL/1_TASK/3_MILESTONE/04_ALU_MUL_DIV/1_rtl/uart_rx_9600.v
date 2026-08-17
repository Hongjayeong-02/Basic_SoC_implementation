`timescale 1ns/1ps

module uart_rx_9600 (
	i_clk	,
	i_rst_n	,
	i_rx	,
	i_tick	,
	o_data	,
	o_valid
);

input		i_clk	;
input		i_rst_n	;
input		i_rx	;
input		i_tick	;

output reg [7:0] o_data	;
output reg	 o_valid;

reg [7:0] r_data  	;
reg [3:0] r_bit_cnt 	;
reg [3:0] r_tick_cnt	;
reg [1:0] r_state	;

parameter IDLE 	= 2'b00;
parameter START = 2'b01;
parameter DATA 	= 2'b10;
parameter STOP 	= 2'b11;


always @(posedge i_clk or negedge i_rst_n) begin
	
	if (!i_rst_n) begin

		o_data	  <= 8'd0;
		o_valid   <= 1'b0;

		r_data	    <= 8'd0;
		r_bit_cnt   <= 4'd0;
		r_tick_cnt  <= 4'd0;
		r_state	    <= IDLE;

	end

	else begin

		o_valid <= 1'b0;

		case (r_state)

			IDLE: begin

				if (!i_rx) begin
					
					r_tick_cnt <= 4'd0;
					r_bit_cnt  <= 4'd0;
					r_state	   <= START;
				
				end
			
			end


			START: begin
	
				if (i_tick) begin

					if (r_tick_cnt == 4'd7) begin

						r_tick_cnt <= 2'd1;
						
						if (!i_rx) begin
						
							r_tick_cnt <= 4'd0;
							r_state <= DATA;
						
						end

						else begin
						
							r_state     <= IDLE;
						
						end
					
					end
					
					else begin
					
						r_tick_cnt <= r_tick_cnt + 1'b1;
					
					end
				end
			end			


			DATA: begin
	
				if (i_tick) begin

					if (r_tick_cnt == 4'd15) begin

						r_tick_cnt <= 4'd0;

						r_data[r_bit_cnt] <= i_rx;

						if (r_bit_cnt == 4'd7) begin
						
						    r_bit_cnt <= 4'd0;
						    r_state   <= STOP;
					
						end
	
						else begin
					
							r_bit_cnt <= r_bit_cnt + 1'b1;
					
						end

					end

					else begin
					
						r_tick_cnt <= r_tick_cnt + 1'b1;
					
					end
				end
			end
	


			STOP: begin
	
				if (i_tick) begin			
	
					if (r_tick_cnt == 4'd15) begin

						r_tick_cnt <= 4'd0;

						o_data  <= r_data;
						o_valid	<= 1'b1;

						r_state	<= IDLE;

					end

					else begin
		
						r_tick_cnt <= r_tick_cnt + 1'b1;
		
					end

				end

			end

			default: begin
		
				r_state <= IDLE;
		
			end

		endcase

	end

end


endmodule 	
