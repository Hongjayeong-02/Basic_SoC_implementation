`timescale 1ns/1ps

module up_down_counter (
	i_clk		,
	i_rst_n		,
	i_up_down	,
	o_count
);

input	i_clk		;
input 	i_rst_n		;
input 	i_up_down	;

output reg [31:0] o_count;


always @(posedge i_clk or negedge i_rst_n) begin

	if(~i_rst_n) 
		o_count <= 32'd0;

	else if(i_up_down)
		o_count <= o_count + 32'd1;
	
	else
		o_count <= o_count - 32'd1;

end

endmodule
	


