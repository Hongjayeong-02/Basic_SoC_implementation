`timescale 1ns/1ps

module tb_alu;

reg	[31:0]	i_a	;
reg	[31:0]	i_b	;
reg	[2:0] 	i_op	;

wire	[31:0]	o_y	;
wire		o_zero	;

alu u_alu (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.i_op	(i_op	),
	.o_y	(o_y	),
	.o_zero	(o_zero )
);

initial begin
	i_a  = 32'd10	;
	i_b  = 32'd3	;
	i_op = 3'b000	;

	#10 i_op = 3'b001;
	#10 i_op = 3'b010;
	#10 i_op = 3'b011;
	#10 i_op = 3'b100;
	#10 i_op = 3'b101;
	#10 i_op = 3'b110;
	#10 i_op = 3'b111;

	#10;
	i_a = 32'd0	;
	i_b = 32'd0	;
	i_op = 3'b000	;

	#10 $finish;
end

endmodule
