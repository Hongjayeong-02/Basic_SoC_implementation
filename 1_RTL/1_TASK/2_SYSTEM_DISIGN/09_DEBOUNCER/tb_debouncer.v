`timescale 1ns/1ps

module tb_debouncer;

reg	i_clk	;
reg 	i_rst_n	;
reg 	i_btn	;

wire	o_btn	;

debouncer u_debouncer (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.i_btn	(i_btn	),
	.o_btn	(o_btn	)
);


initial begin
	i_clk = 1'b0;
	forever #5 i_clk = ~i_clk;
end


initial begin

	i_rst_n = 1'b0;
	i_btn	= 1'b0;

	#10 i_rst_n = 1'b1;

	// ON
	#10 i_btn = 1'b1;

	// OFF
	#30 i_btn = 1'b0;

	// ON
	#20 i_btn = 1'b1;

	#30 $finish;

end


initial begin
	$dumpfile("./debouncer.vcd");
	$dumpvars(0, tb_debouncer  );
end


initial begin
	$monitor (
		"TIME = %0t | BTN = %b | OUT = %b",
		$time, i_btn, o_btn
	);
end

endmodule
