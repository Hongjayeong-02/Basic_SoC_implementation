`timescale 1ns/1ps

module tb_FSM1();

reg clk		;
reg rst_n	;
reg go		;
reg ws		;

wire rd		;
wire ds		;

FSM1 DUT (
	.clk 	(clk	),
	.rst_n	(rst_n	),
	.go	(go	),
	.ws	(ws	),
	.rd	(rd	),
	.ds	(ds	)
);

always #5 clk = ~clk;

initial begin
	clk = 1'b0; rst_n = 1'b0;
	go = 1'b0; ws = 1'b0;

	#100 rst_n = 1'b1;

	#100 go = 1'b1; ws = 1'b1;
	#100 ws = 1'b0;
	#100 rst_n = 1'b0;
	#100; $finish; 
end

endmodule


