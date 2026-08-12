`timescale 1ns/1ps

module tb_up_down_counter;

reg i_clk	;
reg i_rst_n	;
reg i_up_down	;

wire [31:0] o_count ;

up_down_counter u_up_down_counter (
	.i_clk		(i_clk		),
	.i_rst_n	(i_rst_n	),
	.i_up_down	(i_up_down	),
	.o_count	(o_count	)
);

initial begin
	i_clk 	  = 1'b0;
	i_rst_n	  = 1'b0;
	i_up_down = 1'b0;
	
	#10;
	i_rst_n	  = 1'b1;
	
	// UP
	#40;
	i_up_down = 1'b0;
	
	// DOWN
	#40;
	i_up_down = 1'b1;

	// UP
	#40;

	$finish;
end

always #5 i_clk = ~i_clk;

initial begin
	$dumpfile("./up_down_counter.vcd");
	$dumpvars(0, tb_up_down_counter	 );
end

initial begin
	$monitor(
		"TIME = %0t | CLK = %b | RST_N = %b | UP_DOWN = %b | COUNT = %b",
		$time, i_clk, i_rst_n, i_up_down, o_count
	);
end

endmodule
