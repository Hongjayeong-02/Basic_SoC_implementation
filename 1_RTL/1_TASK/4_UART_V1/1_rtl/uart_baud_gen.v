`timescale 1ns/1ps

module uart_baud_gen #(
	parameter CLK_FREQ = 48_000_000,
	parameter BAUD_RATE = 9_600
)(
	input wire clk,
	input wire rst_n,
	output reg o_baudTick
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
localparam CNT_WIDTH 	= $clog2(CLKS_PER_BIT);

reg [CNT_WIDTH-1:0] r_clkCnt;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		r_clkCnt <= {CNT_WIDTH{1'b0}};
		o_baudTick <= 1'b0;
	end else if (r_clkCnt == CLKS_PER_BIT - 1) begin
		r_clkCnt <= {CNT_WIDTH{1'b0}};
		o_baudTick <= 1'b1;
	end else begin
		r_clkCnt <= r_clkCnt + 1'b1;
		o_baudTick <= 1'b0;
	end

end


endmodule
