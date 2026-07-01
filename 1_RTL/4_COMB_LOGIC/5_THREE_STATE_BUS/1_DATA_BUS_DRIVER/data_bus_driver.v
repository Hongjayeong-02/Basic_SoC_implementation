`timescale 1ns/1ps

module data_bus_driver(

	i_dataA	,
	i_dataB	,
	i_enA	,
	i_enB	,

	o_busData

);

input [31:0] i_dataA	;
input [31:0] i_dataB	;
input	    i_enA	;
input	    i_enB	;

output [31:0] o_busData	;

assign o_busData = (i_enA) ? i_dataA : 32'bz;
assign o_busData = (i_enB) ? i_dataB : 32'bz;

endmodule
