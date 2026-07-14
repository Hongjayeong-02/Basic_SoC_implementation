`timescale 1ns/1ps

module bidirectional_bus_driver(

	i_dataToBus	,
	i_send		,

	o_dataFromBus	,
	
	io_busData

);

input 	[31:0] i_dataToBus	;
input          i_send		;

output 	[31:0] o_dataFromBus	;

inout 	[31:0] io_busData	;

assign io_busData = (i_send) ? i_dataToBus : 32'bz;

assign o_dataFromBus = io_busData;

endmodule
