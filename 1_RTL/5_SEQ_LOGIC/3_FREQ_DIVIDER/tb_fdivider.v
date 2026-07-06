`timescale 1ns/1ps

module tb_fdivider;

reg clk_in	;
reg rst_n	;
wire o_clk_out	;	

fdivider #(
	.DIVISOR(10)
)  uut (
	.clk_in(clk_in)	,
	.rst_n(rst_n)	,
	.o_clk_out(o_clk_out)
);

	always #5 clk_in = ~clk_in;

	initial begin
		clk_in = 0;
		rst_n = 0;
		#20 rst_n = 1;

	repeat(200) @(posedge clk_in);
	$finish;
	
	end

	always @(posedge clk_in) begin
		$display("Time=%0t, clk_in=%b, clk_out=%b", 
		$time,
		clk_in, 
		o_clk_out);
	end

	initial begin
		$dumpfile("./fdivider.vcd");
		$dumpvars(0, uut);
	end

endmodule
