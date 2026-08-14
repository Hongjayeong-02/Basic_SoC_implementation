`timescale 1ns/1ps

module tb_sub_8_rca;

reg	[7:0]	i_a	;
reg	[7:0]	i_b	;
reg		i_bin	;

wire	[7:0] 	o_diff	;
wire		o_bout	;


sub_8_rca u_sub_8_rca (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.i_bin	(i_bin	),
	.o_diff (o_diff ),
	.o_bout (o_bout	)
);


initial begin
	i_a   = 8'd0;
	i_b   = 8'd0;
	i_bin = 1'b0;

	// 100 - 50 = 50
	#10;
	i_a   = 8'd100;
	i_b   = 8'd50;

	// 50 - 100 = -50
	#10;
	i_a   = 8'd50;
	i_b   = 8'd100;

	// 20 - 10 - 1 = 9
	#10;
	i_a   = 8'd20;
	i_b   = 8'd10;
	i_bin = 1'd1;

	// 255 - 1 = 254
	#10;
	i_a   = 8'd255;
	i_b   = 8'd1;
	i_bin = 1'b0;

	#10 $finish;

end


initial begin
	$dumpfile("./sub_8_rca.vcd");
	$dumpvars(0, tb_sub_8_rca  );
end


initial begin
	$monitor(
		"TIME = %0t | A = %d | B = %d | BIN = %b | DIFF = %d | BOUT = %b",
		$time, i_a, i_b, i_bin, o_diff, o_bout
	);
end



endmodule





