`timescale 1ns/1ps

module tb_sum_8_rca;

reg	[7:0]	i_a	;
reg	[7:0] 	i_b	;
reg		i_cin	;

wire	[7:0]	o_sum	;
wire		o_cout	;


sum_8_rca u_sum_8_rca (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.i_cin	(i_cin	),
	.o_sum	(o_sum	),
	.o_cout	(o_cout	)
);


initial begin
	i_a   = 8'd0;
	i_b   = 8'd0;
	i_cin = 1'b0;

	#10;
	i_a   = 8'd100;
	i_b   = 8'd50;

	#10;
	i_a   = 8'hFF;
	i_b   = 8'h01;

	#10;
	i_a   = 8'd10;
	i_b   = 8'd20;
	i_cin = 1'b1;

	#10 $finish;

end


initial begin
	$dumpfile("./sum_8_rca.vcd");
	$dumpvars(0, tb_sum_8_rca  );
end


initial begin
	$monitor(
		"TIME = %0t | A = %d | B = %d | CIN = %b | SUM = %d | COUT = %b",
		$time, i_a, i_b, i_cin, o_sum, o_cout
	);
end


endmodule
