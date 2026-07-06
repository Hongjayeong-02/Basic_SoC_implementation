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

	// Reset Release
	#20 rst_n = 1'b1;

	// IDLE -> READ
	#20 go = 1'b1; ws = 1'b1;

	// READ -> DLY -> READ
	#40 go = 1'b0;

	// DLY -> DONE
	#40 ws = 1'b0;

	// DONE -> IDLS
	#20;	

	// Reset
	#20 rst_n = 1'b0;

	#20;
	$finish; 
end

endmodule


