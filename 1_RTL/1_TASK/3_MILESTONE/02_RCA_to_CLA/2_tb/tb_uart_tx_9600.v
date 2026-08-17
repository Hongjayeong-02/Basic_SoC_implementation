`timescale 1ns/1ps

module tb_uart_tx_9600	;

reg		i_clk	;
reg		i_rst_n	;
reg	[7:0] 	i_data	;
reg		i_valid	;
reg 		i_tick	;

wire		o_tx	;
wire		o_busy	;


uart_tx_9600 u_uart_tx_9600 (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.i_data	(i_data	),
	.i_valid(i_valid),
	.i_tick	(i_tick	),
	.o_tx	(o_tx	),
	.o_busy	(o_busy	)
);


always #5 i_clk = ~i_clk;


initial begin

	i_clk   = 1'b0;
	i_rst_n = 1'b0;

	i_data  = 8'h00;
	i_valid = 1'b0;
	i_tick  = 1'b0;

	#20;
	i_rst_n = 1'b1;

	// ASCII '5'
	#20;
	i_data	= 8'h35;
	i_valid	= 1'b1;

	#10;
	i_valid = 1'b0;

	// START
	#20;
	i_tick 	= 1'b1;

	#10;
	i_tick 	= 1'b0;

	// DATA 8 bits
	repeat (8) begin

		#20;
		i_tick = 1'b1;

		#10;
		i_tick = 1'b0;

	end

	// STOP
	#20;
	i_tick 	= 1'b1;

	#10;
	i_tick	= 1'b0;

	#20;

	$finish;	

end


initial begin

	$dumpfile("./uart_tx_9600.vcd"	);
	$dumpvars(0, tb_uart_tx_9600	);

end


initial begin

	$monitor(
		"TIME = %0t | DATA = %h | VALID = %b | TICK = %b | TX = %b | BUSY = %b",
		$time, i_data, i_valid, i_tick, o_tx, o_busy
	);

end


endmodule

