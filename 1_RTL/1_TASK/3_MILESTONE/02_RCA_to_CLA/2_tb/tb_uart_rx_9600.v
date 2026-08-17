`timescale 1ns/1ps

module tb_uart_rx_9600;


reg	i_clk	;
reg	i_rst_n	;
reg 	i_rx	;
reg 	i_tick	;


wire [7:0] 	o_data	;
wire		o_valid ;



uart_rx_9600 u_uart_rx_9600 (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.i_rx	(i_rx 	),
	.i_tick	(i_tick	),
	.o_data (o_data	),
	.o_valid(o_valid)
);

always #5 i_clk = ~i_clk;


task send_bit;

	input bit_data;
	integer i;	

	begin

		i_rx = bit_data;

		for (i = 0; i < 16; i = i + 1) begin

		#20;
		i_tick = 1'b1;

		#10;
		i_tick = 1'b0;
		
		end

	end

endtask


initial begin

	i_clk   = 1'b0;
	i_rst_n = 1'b0;

	i_rx	= 1'b1;
	i_tick 	= 1'b0;

	#20;
	i_rst_n = 1'b1;

	
	// ASCII '5' = 8'h35
	// LSB first
	
	send_bit(1'b0); // START

	send_bit(1'b1); // bit 0
	send_bit(1'b0); // bit 1
	send_bit(1'b1); // bit 2
	send_bit(1'b0); // bit 3
	send_bit(1'b1); // bit 4
	send_bit(1'b1); // bit 5
	send_bit(1'b0); // bit 6
	send_bit(1'b0); // bit 7

	send_bit(1'b1); // STOP

	#10000;

	$finish;

end


initial begin
	$dumpfile("./uart_rx_9600.vcd"	);
	$dumpvars(0, tb_uart_rx_9600	);
end


initial begin
	$monitor(
		"TIME = %0t | RX = %b | TICK = %b | DATA = %h | VALID = %b",
		$time, i_rx, i_tick, o_data, o_valid
	);

end


endmodule

