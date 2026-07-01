`timescale 1ns/1ps

module tb_interrupt_controller	;

reg [7:0]	i_int		;
reg 		i_intAck	;

wire [2:0] 	o_intId		;
wire 		o_intReq	;


interrupt_controller uut (
	.i_int	 	(i_int		)	,
	.i_intAck	(i_intAck	)	,
	.o_intId	(o_intId	)	,
	.o_intReq	(o_intReq	)	
);

	initial begin
		$dumpfile("./interrupt_controller.vcd");
		$dumpvars(0, uut);
	end

	
	initial begin
		i_int		= 8'b0000_0000	;
		i_intAck	= 1'b0		;
		#10;

		i_int 		= 8'b0000_0001	;
		#10;

		i_int 		= 8'b0000_0010	;
		#10;

		i_int 		= 8'b0000_0100	;
		#10;

		i_int		= 8'b0000_1000	;
		#10;

		i_int		= 8'b0001_0000	;
		#10;

		i_int		= 8'b0010_0000	;
		#10;

		i_int	 	= 8'b0100_0000	;
		#10;

		i_int 		= 8'b1000_0000	;
		#10;

		i_intAck 	= 1'b1		;
		#10;

		i_intAck	= 1'b0		;
		i_int		= 8'b0000_0000	;
		#10;

		$finish;

	end
endmodule

		




