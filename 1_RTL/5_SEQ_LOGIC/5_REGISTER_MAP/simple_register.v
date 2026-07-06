`timescale 1ns/1ps

module simple_register(
	clk	,
	rst_n	,
	i_wdata	,
	i_wen	,

	o_rdata
);

input clk		;
input rst_n		;
input i_wen		;
input [31:0] i_wdata	;

output [31:0] o_rdata;

reg [31:0] r_reg32;

always @(posedge clk or negedge rst_n) begin
	if(rst_n)
		r_reg32 <= 32'h00000000;

	else if(i_wen)
		r_reg32 <= i_wdata;
end

assign o_rdata = r_reg32;
	

endmodule
