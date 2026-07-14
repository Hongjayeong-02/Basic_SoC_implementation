`timescale 1ns/1ps

module tb_traffic_light;

reg clk		;
reg rst_n	;

wire o_red	;
wire o_yellow	;
wire o_green	;

// DUT
traffic_light uut (
	.clk		(clk		),	
	.rst_n		(rst_n		),
	.o_red		(o_red		),
	.o_yellow	(o_yellow	),
	.o_green	(o_green	)
);

// Clock Generation
always #5 clk = ~clk;

// Dump file
initial begin
	$dumpfile("./traffic_light.vcd");
	$dumpvars(0, uut);
end

// Test
initial begin
	clk   = 1'b0;
	rst_n = 1'b0;

	// Reset
	#20;
	rst_n = 1'b1;

	repeat(30)
		@(posedge clk);
	#20;
	$finish;
end

endmodule
