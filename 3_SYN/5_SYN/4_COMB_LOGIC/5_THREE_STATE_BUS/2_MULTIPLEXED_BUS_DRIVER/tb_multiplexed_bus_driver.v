`timescale 1ns/1ps

module tb_multiplexed_bus_driver;

reg [31:0] i_dataA;
reg [31:0] i_dataB;
reg 	   i_enA;
reg        i_enB;

wire [31:0] o_busData;

multiplexed_bus_driver uut(

	.i_dataA(i_dataA),
	.i_dataB(i_dataB),
	.i_enA(i_enA),
	.i_enB(i_enB),
	.o_busData(o_busData)

);

initial begin
	$dumpfile("./multiplexed_bus_driver.vcd");
	$dumpvars(0, uut);
end

initial begin
	$monitor("T=%0t | enA=%b enB=%b | A=%h B=%h | BUS=%h",
	$time,
	i_enA, i_enB,
	i_dataA, i_dataB,
	o_busData );

	i_dataA = 32'h12345678;
	i_dataB = 32'hABCDEF12;

	// High-Z
	i_enA = 0; i_enB = 0; #10;
	
	// A
	i_enA = 1; i_enB = 0; #10;
	
	// B
	i_enA = 0; i_enB = 1; #10;
 
	// both enable -> A -> B
	i_enA = 1; i_enB = 1; #10;

	// High-Z
	i_enA = 0; i_enB = 0; #10;

	$finish;
end

endmodule

