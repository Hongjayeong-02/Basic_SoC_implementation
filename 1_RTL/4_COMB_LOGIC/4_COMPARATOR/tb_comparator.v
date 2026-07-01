`timescale 1ns/1ps

module tb_comparator;

reg[31:0] i_a;
reg[31:0] i_b; 

wire o_gt;
wire o_eq;
wire o_it;

comparator uut(

	.i_a(i_a	)	,
	.i_b(i_b	)	,

	.o_gt(o_gt	)	,
	.o_eq(o_eq	)	,
	.o_it(o_it	)

);

initial begin
	$dumpfile("./comparator.vcd"	);
	$dumpvars(0, uut		);
end

initial begin
	$monitor("Time=%0t A=%d B=%d | GT=%b EQ= %b LT=%b",
	$time, i_a, i_b, o_gt, o_eq, o_it);

	i_a = 32'd10		;	i_b = 32'd20		; 	#10;
	i_a = 32'd20		; 	i_b = 32'd10		;	#10;
	i_a = 32'd100		; 	i_b = 32'd100		;	#10;
	i_a = 32'd0		;	i_b = 32'd0		;	#10;
	i_a = 32'hFFFFFFFF	;	i_b = 32'd1		; 	#10;
	i_a = 32'h12345678	;	i_b = 32'h12345679	;	#10;
	i_a = 32'h87654321	;	i_b = 32'h12345678	;	#10;

	$finish;
end

endmodule

	
