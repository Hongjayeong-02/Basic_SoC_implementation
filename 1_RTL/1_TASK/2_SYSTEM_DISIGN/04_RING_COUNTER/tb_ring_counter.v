`timescale 1ns/1ps

module tb_ring_counter;

reg i_clk	;
reg i_rst_n	;

wire [31:0] o_count;

ring_counter u_ring_counter (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.o_count(o_count)
);

initial begin 
	i_clk 	= 1'b0;
	i_rst_n = 1'b0;

	#10;
	i_rst_n = 1'b1;

	#200;

	$finish;
end

always #5 i_clk = ~i_clk;

initial begin
	$dumpfile("./ring_counter"  );
	$dumpvars(0, tb_ring_counter);
end

initial begin
	$monitor(
		"TIME = %0t | CLK = %b | RST_N = %b | COUNT = %h",
		$time, i_clk, i_rst_n, o_count
	);
end

endmodule
