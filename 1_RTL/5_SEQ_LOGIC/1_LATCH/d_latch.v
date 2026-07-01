`timescale 1ns/1ps

module d_latch(

	i_clk	,
	i_d	,
	o_q

);

input 			i_clk	;
input 		[31:0] 	i_d	;

output reg 	[31:0] 	o_q	;

always @(*) begin
	if(i_clk)
		o_q <= i_d;
end

endmodule
