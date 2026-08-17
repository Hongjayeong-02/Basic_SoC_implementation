`timescale 1ns/1ps

module baud_gen (
	i_clk	,
	i_rst_n	,
	o_tick
);

input		i_clk	;
input		i_rst_n	;

output reg 	o_tick	;
reg	[13:0]	r_count	;

parameter CLK_FREQ  = 100_000_000;
parameter BAUD_RATE = 9600;
parameter OVERSAMPLE = 16;

parameter BAUD_DIV  = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);


always @(posedge i_clk or negedge i_rst_n) begin

	if(!i_rst_n) begin

		r_count <= 14'd0;
		o_tick	<= 1'b0;

	end

	else begin
		if (r_count == BAUD_DIV - 1) begin

			r_count <= 14'd0;
			o_tick	<= 1'b1;

		end

		else begin

			r_count <= r_count + 1'b1;
			o_tick	<= 1'b0;

		end
	end

end


endmodule
	
