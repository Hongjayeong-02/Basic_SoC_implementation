`timescale 1ns/1ps

module tb_counter;

reg	i_clk	;
reg	i_rst_n	;

wire [31:0] o_count;


counter u_counter (
	.i_clk	(i_clk),
	.i_rst_n(i_rst_n),
	.o_count(o_count)
);

initial begin
	i_clk 	= 1'b0;
	i_rst_n = 1'b0;

	#10;
	i_rst_n = 1'b1;
	
	#50;
	i_rst_n = 1'b0;

	#10;
	i_rst_n = 1'b1;

	#50;
	$finish;

end

always #5 i_clk = ~i_clk;

initial begin
	$dumpfile("./counter.vcd");
	$dumpvars(0, tb_counter	 );
end

initial begin
	$monitor(
		"TIME = %0t | CLK = %b | RST_N = %b | COUNT = %h",
		$time, i_clk, i_rst_n, o_count
	);
end

endmodule
