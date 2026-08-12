`timescale 1ns/1ps

module tb_demux		;

reg [31:0] 	i_din	;
reg 		i_sel	;

wire [31:0] 	o_y0	;
wire [31:0] 	o_y1	;

demux u_demux (
	.i_din	(i_din	)	,
	.i_sel	(i_sel	)	,
	.o_y0	(o_y0	)	,
	.o_y1	(o_y1	)
);

initial begin
	i_din = 32'h0000_0000	;
	i_sel = 1'b0		;

	#10			;

	// SEL = 0
	i_din = 32'h1234_5678	;
	i_sel = 1'b0		;

	#10			;
	
	// SEL = 1
	i_sel = 1'b1		;

	#10			;

	// change data
	i_din = 32'hABCD_EF01	;
	i_sel = 1'b0		;

	#10			;

	// SEL = 1
	i_sel = 1'b1		;

	#10			;
	
	// another data
	i_din = 32'hFFFF_0000	;
	i_sel = 1'b0		;

	#10			;
	$finish			;
end

initial begin
	$dumpfile("./demux.vcd"	)	;
	$dumpvars(0, tb_demux	)	;
end

initial begin
	$monitor(
		"TIME=%0t | DIN = %h | SEL = %b | Y0 = %h | Y1 = %h ",
		$time	,
		i_din	,
		i_sel	,
		o_y0	,
		o_y1
	);
end

endmodule	
