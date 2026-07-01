`timescale 1ns/1ps

module tb_bidirectional_bus_driver;

reg [31:0] i_dataToBus		;
reg	   i_send		;

wire [31:0] o_dataFromBus	;

reg [31:0] tb_busData		;

wire [31:0] io_busData		;

bidirectional_bus_driver uut (

	.i_dataToBus(i_dataToBus)	,
	.i_send(i_send)			,
	.o_dataFromBus(o_dataFromBus)	,
	.io_busData(io_busData)	
	
);

assign io_busData = (!i_send) ? tb_busData : 32'bz;

initial begin
	$dumpfile("./bidirectional_bus_driver.vcd");
	$dumpvars(0, uut);
end

initial begin
	$monitor("T=%0t | send=%b | ToBus=%h | Bus=%h | FromBus=%h",
	$time, i_send, i_dataToBus, io_busData, o_dataFromBus);

	i_dataToBus = 32'h12345678;
	tb_busData = 32'h00000000;
	i_send = 1;

	i_send = 0;
	tb_busData = 32'hABCDEF12;
	#10;

	i_dataToBus = 32'h12345678;
	i_send = 1;
	#10;

	i_send = 0;
	tb_busData = 32'hFFFFFFFF;
	#10;

	$finish;
end

endmodule

