`timescale 1ns/1ps

module data_bus_driver(

	i_dataA	,
	i_dataB	,
	i_enA	,
	i_enB	,

	o_busData

);

input [7:0] i_dataA	;
input [7:0] i_dataB	;
input	    i_enA	;
input	    i_enB	;

output [7:0] o_busData	;

assign o_busData = (i_enA) ? i_dataA : 8'bzzzzzzzz;
assign o_busData = (i_enB) ? i_dataB : 8'bzzzzzzzz;

endmodule
