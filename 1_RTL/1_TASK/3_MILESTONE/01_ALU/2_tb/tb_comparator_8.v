`timescale 1ns/1ps

module tb_comparator_8;

reg [7:0] i_a	;
reg [7:0] i_b	;

wire	  o_eq	;
wire	  o_gt	;
wire	  o_lt	;


comparator_8 u_comparator_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_eq	(o_eq	),
	.o_gt	(o_gt	),
	.o_lt	(o_lt	)
);


initial begin

	i_a = 8'd0;
	i_b = 8'd0;

	// A == B 
	#10;
	i_a = 8'd50;
	i_b = 8'd50;

	// A > B
	#10;
	i_a = 8'd100;
	i_b = 8'd50;

	// A < B
	#10;
	i_a = 8'd30;
	i_b = 8'd80;

	// A == B 
	#10;
	i_a = 8'hFF;
	i_b = 8'hFF;

	#10 $finish;

end


initial begin

	$dumpfile("./comparator_8.vcd"	);
	$dumpvars(0, tb_comparator_8	);

end


initial begin

	$monitor(
		"TIME = %0t | A = %h | B = %h | EQ = %b | GT = %b | LT = %b",
		$time, i_a, i_b, o_eq, o_gt, o_lt
	);

end


endmodule

