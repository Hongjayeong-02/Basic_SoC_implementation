`timescale 1ns/1ps

module tb_sequence_detector;

reg	i_clk	;
reg	i_rst_n	;
reg	i_din	;

wire	o_detect;

sequence_detector u_sequence_detector (
	.i_clk	 (i_clk	  ),
	.i_rst_n (i_rst_n ),
	.i_din	 (i_din	  ),
	.o_detect(o_detect)
);

initial begin
	i_clk = 1'b0;
	forever #5 i_clk = ~i_clk;
end

initial begin
	i_rst_n = 1'b0;
	i_din	= 1'b0;

	#10 i_rst_n = 1'b1;

	// 1011
	#10 i_din = 1'b1;
	#10 i_din = 1'b0;
	#10 i_din = 1'b1;
	#10 i_din = 1'b1;

	// 000
	#10 i_din = 1'b0;
	#10 i_din = 1'b0;
	#10 i_din = 1'b0;

	// 1011
	#10 i_din = 1'b1;
	#10 i_din = 1'b0;
	#10 i_din = 1'b1;
	#10 i_din = 1'b1;

	#10 $finish;

end

initial begin
	$dumpfile("./sequence_detector.vcd");
	$dumpvars(0, tb_sequence_detector  );
end

initial begin
	$monitor(
		"TIME = %0t | DIN = %b | DETECT = %b",
		$time, i_din, o_detect
	);
end

endmodule
