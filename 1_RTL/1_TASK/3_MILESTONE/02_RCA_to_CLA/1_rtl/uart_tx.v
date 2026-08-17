`timescale 1ns/1ps

module uart_tx(
	i_clk	,
	i_rst_n	,
	i_data	,
	i_valid	,
	o_tx	,
	o_busy
);


input		 i_clk		;
input		 i_rst_n	;
input	   [7:0] i_data		;
input 		 i_valid	;

output reg	 o_tx		;
output reg	 o_busy		;
reg 	   [7:0] r_data		;
reg        [7:0] r_bit_cnt 	;
reg        [1:0] r_state	;


parameter IDLE  = 2'b00;
parameter START = 2'b01;
parameter DATA  = 2'b10;
parameter STOP  = 2'b11;


always @(posedge i_clk or negedge i_rst_n) begin

	if(!i_rst_n) begin

		o_tx  	  <= 1'b1;
		o_busy	  <= 1'b0;

		r_data	  <= 8'd0;
		r_bit_cnt <= 4'd0;
		r_state	  <= IDLE;

	end

	else begin

		case (r_state)

			IDLE: begin

				o_tx	<= 1'b1;
				o_busy 	<= 1'b0;

				if (i_valid) begin
		
					r_data	  <= i_data;
					r_bit_cnt <= 4'd0;

					o_busy    <= 1'b1;
					r_state	  <= START;

				end

			end

			
			START: begin

				o_tx	<= 1'b0;
				r_state <= DATA;

			end


			DATA: begin

				o_tx	<= r_data[r_bit_cnt];

				if (r_bit_cnt == 4'd7) begin

					r_bit_cnt <= 4'd0;
					r_state	  <= STOP;

				end

				else begin
		
					r_bit_cnt <= r_bit_cnt + 1'b1;

				end

		
			end

	
			STOP: begin

				o_tx	<= 1'b1;
				o_busy 	<= 1'b0;
				r_state	<= IDLE;

			end

			
			default: begin

				o_tx	<= 1'b1;
				o_busy	<= 1'b0;
				r_state	<= IDLE;

			end

		endcase
	end

end


endmodule
