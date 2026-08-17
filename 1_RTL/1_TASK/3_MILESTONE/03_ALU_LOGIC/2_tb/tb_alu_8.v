`timescale 1ns/1ps

module tb_alu_8;

reg	[7:0] i_a	;
reg	[7:0] i_b	;
reg	[1:0] i_sel	;

wire	[7:0] o_result	;


alu_8 u_alu_8 (
	.i_a	 (i_a	  ),
	.i_b	 (i_b	  ),
	.i_sel	 (i_sel	  ),
	.o_result(o_result)
);


initial begin

	i_a   	= 8'd100;
	i_b   	= 8'd50	;
	i_sel 	= 2'b00	;

	// ADD : 100 + 50 = 150
	#10;
	i_sel 	= 2'b00	;

	// SUB : 100 - 50 = 50
	#10;
	i_sel 	= 2'b01	;

	// AND : 64 & 32 = 0
	#10;
	i_a 	= 8'd64	;
	i_b 	= 8'd32	;
	i_sel 	= 2'b10	;

	// OR : 64 | 32 = 96
	#10;
	i_sel 	= 2'b11	;

	// ADD
	#10;
	i_a 	= 8'd200;
	i_b 	= 8'd55	;
	i_sel 	= 2'd00	;

	#10 $finish;

end


initial begin
	$dumpfile("./alu_8.vcd"	);
	$dumpvars(0, tb_alu_8	);
end


initial begin
	$monitor(
		"TIME = %0t | A = %d | B = %d | SEL = %b | RESULT = %d",
		$time, i_a, i_b, i_sel, o_result
	);
end


endmodule
