`timescale 1ns/1ps

module tb_mux_8_4to1;

reg [7:0] i_a	;
reg [7:0] i_b	;
reg [7:0] i_c	;
reg [7:0] i_d	;
reg [1:0] i_sel	;

wire [7:0] o_y	;


mux_8_4to1 u_mux_8_4to1 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.i_c	(i_c	),
	.i_d	(i_d	),
	.i_sel	(i_sel	),
	.o_y	(o_y	)
);


initial begin

	i_a 	= 8'hAA;
	i_b 	= 8'h55;
	i_c 	= 8'hF0;
	i_d 	= 8'h0F;
	i_sel 	= 2'b00;

	// SEL = 00 -> A
	#10;
	i_sel = 2'b00;

	// SEL = 01 -> B
	#10;
	i_sel = 2'b01;

	// SEL = 10 -> C
	#10;
	i_sel = 2'b10;

	// SEL = 11 -> D
	#10;
	i_sel = 2'b11;

	#10 $finish;

end


initial begin

	$dumpfile("./mux_8_4to1.vcd"	);
	$dumpvars(0, tb_mux_8_4to1	);

end


initial begin

	$monitor(
		"TIME = %0t | A = %h | B = %h | C = %h | D = %h | SEL = %b | Y = %h",
		$time, i_a, i_b, i_c, i_d, i_sel, o_y
	);

end


endmodule
