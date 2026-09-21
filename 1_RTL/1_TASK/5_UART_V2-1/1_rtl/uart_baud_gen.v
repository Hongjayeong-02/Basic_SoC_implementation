`timescale 1ns/1ps

module uart_baud_gen (
	input 	wire 		clk,
	input 	wire 		rst_n,
	input 	wire		i_enable,
	input	wire	[15:0]	i_baudDiv,

	output 	reg		o_tick16
);

reg [15:0] r_clkCnt;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		r_clkCnt <= 16'd0;
		o_tick16 <= 1'b0;
	end else begin
		o_tick16 <= 1'b0;

		if (!i_enable) begin
			r_clkCnt <= 16'd0;
		
		end else if (i_baudDiv < 16'd1) begin	
			r_clkCnt <= 16'd0;
		
		end else if (r_clkCnt == i_baudDiv) begin
			r_clkCnt <= 16'd0;
			o_tick16 <= 1'b1;
		
		end else begin
			r_clkCnt <= r_clkCnt + 1'b1;
		
		end
	end
end

endmodule

