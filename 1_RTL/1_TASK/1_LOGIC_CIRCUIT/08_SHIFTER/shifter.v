`timescale 1ns/1ps

module shifter (
	i_din	,
	i_shamt	,
	i_dir	,
	o_dout
);

input	[31:0] 	i_din	;
input	[4:0] 	i_shamt ;
input		i_dir	;

output	[31:0] 	o_dout	;

assign o_dout = i_dir ? (i_din >> i_shamt):
			(i_din << i_shamt);

endmodule
