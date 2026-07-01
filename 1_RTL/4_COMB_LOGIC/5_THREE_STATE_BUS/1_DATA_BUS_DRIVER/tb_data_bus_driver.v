`timescale 1ns/1ps

module tb_data_bus_driver;

reg [7:0] i_dataA	;
reg [7:0] i_dataB	;
reg       i_enA		;
reg       i_enB		;

wire [7:0] o_busData	;

data_bus_driver uut(

	.i_dataA(i_dataA)	,
	.i_dataB(i_dataB)	,
	.i_enA(i_enA)		,
	.i_enB(i_enB)		,
	.o_busData(o_busData)

);

initial begin
	$dumpfile("./data_bus_driver.vcd");
	$dumpvars(0, uut);
end

initial begin
	$monitor("T=%0t | enA=%b enB=%b | A=%h B=%h | BUS=%h",
	$time, i_enA, i_enB,
	i_dataA, i_dataB, o_busData);

	i_dataA = 8'h55;
	i_dataB = 8'hAA;
	i_enA 	= 0;
	i_enB 	= 0;
	#10;

	i_enA = 1;
	#10;

	i_enA = 0;
	i_enB = 1;
	#10;

	i_enA = 1;
	i_enB = 1;
	#10;

	i_enA = 0;
	i_enB = 0;
	#10;
	
	$finish;
end

endmodule 
