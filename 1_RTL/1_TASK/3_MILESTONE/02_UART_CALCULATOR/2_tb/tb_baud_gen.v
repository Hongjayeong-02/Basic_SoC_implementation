`timescale 1ns/1ps

module tb_baud_gen;

reg	i_clk	;
reg	i_rst_n	;

wire	o_tick	;


baud_gen u_baud_gen (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.o_tick	(o_tick	)	
);

always #5 i_clk = ~i_clk;


initial begin

	i_clk   = 1'b0;
	i_rst_n = 1'b0;
	
 	#20;
	i_rst_n = 1'b1;

	#1_100_000;

	$finish;

end


initial begin
	
	$dumpfile("./baud_gen.vcd");
	$dumpvars(0, tb_baud_gen  );

end

endmodule	

	
	
