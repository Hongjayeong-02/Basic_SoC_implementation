`timescale 1ns/1ps

module shift_register_sipo #(
	parameter WIDTH = 32 
)(
	clk		, 
	rst_n		,
	i_serial_in	,
	
	o_parallel_out
);

input clk		;
input rst_n		;
input i_serial_in	;

output reg [WIDTH-1:0]  o_parallel_out;


always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		o_parallel_out <= {WIDTH{1'b0}};
	else
		o_parallel_out <= {o_parallel_out[WIDTH-2:0], i_serial_in};
end

endmodule

