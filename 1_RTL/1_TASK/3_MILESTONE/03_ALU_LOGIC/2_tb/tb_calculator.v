`timescale 1ns/1ps

module tb_calculator;


reg		i_clk	;
reg		i_rst_n	;
reg	[7:0]	i_data	;
reg		i_valid	;

wire	[7:0]	o_a	;
wire	[7:0]	o_b	;
wire	[1:0] 	o_sel	;
wire		o_start	;


calculator u_calculator (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.i_data	(i_data	),
	.i_valid(i_valid),
	.o_a	(o_a	),
	.o_b	(o_b	),
	.o_sel	(o_sel	),
	.o_start(o_start)
);


always #5 i_clk = ~i_clk;


initial begin

	i_clk   = 1'b0;
	i_rst_n = 1'b0;
	i_data	= 8'd0;
	i_valid	= 1'b0;

	#20;
	i_rst_n = 1'b1;

	// '5'
	#10;
	i_data  = 8'h35;
	i_valid = 1'b1;

	#10;
	i_valid = 1'b0;

	// '+'
	#10;
	i_data  = 8'h33;
	i_valid = 1'b1;

	#10;
	i_valid = 1'b0;

	// '3' 
	#10;
	i_data  = 8'h33;
	i_valid = 1'b1; 

	#10;
	i_valid = 1'b1;

	#20;

	$finish;

end


initial begin
	$dumpfile("./calculator.vcd"	);
	$dumpvars(0, tb_calculator	);
end


initial begin
	$monitor(
		"TIME = %0t | DATA = %h | VALID = %b | A = %d | B = %d | SEL = %b | START = %b",
		$time, i_data, i_valid, o_a, o_b, o_sel, o_start
	);
end


endmodule
