`timescale 1ns/1ps

module counter (
	i_clk	,
	i_rst_n	,
	o_count	
);

input	i_clk	;
input	i_rst_n	;

output reg [31:0] o_count;

always @(posedge i_clk or negedge i_rst_n) begin

	if(~i_rst_n) 
		o_count <= 32'd0;

	else
		o_count <= o_count + 32'd1;
	
end

endmodule

