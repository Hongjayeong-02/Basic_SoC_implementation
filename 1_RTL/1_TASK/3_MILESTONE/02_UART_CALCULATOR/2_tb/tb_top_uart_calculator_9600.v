`timescale 1ns/1ps

module tb_top_uart_calculator_9600;

reg	i_clk	;
reg	i_rst_n	;
reg	i_rx	;

wire	o_tx	;


top_uart_calculator u_uart_calculator (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.i_rx	(i_rx	),
	.o_tx	(o_tx	)
);

always #5 i_clk = ~i_clk;


// UART bit transmission task
task send_bit;

	input bit_data;

	begin

		i_rx = bit_data;

		#104167;

	end

endtask


// Send one byte
task send_byte;

	input [7:0] data;

	begin

		// START
		send_bit(1'b0);

		// DATA : LSB first
		send_bit(data[0]);
		send_bit(data[1]);
		send_bit(data[2]);
		send_bit(data[3]);
		send_bit(data[4]);
		send_bit(data[5]);
		send_bit(data[6]);
		send_bit(data[7]);

		// STOP
		send_bit(1'b1);
	end

endtask



initial begin
	i_clk 	= 1'b0;
	i_rst_n = 1'b0;
	i_rx	= 1'b1;

	#20;
	i_rst_n = 1'b1;


	// 3 + 5
	
	send_byte(8'h33);	// '3'
	send_byte(8'h2B);	// '+'
	send_byte(8'h35);	// '5'

	#200000;

	$finish;

end


initial begin
	$dumpfile("./top_uart_calculator_9600.vcd"	);
	$dumpvars(0, tb_top_uart_calculator_9600	);
end


initial begin
	$monitor(
		"TIME = %0t | RX = %b | TX = %b | A = %d | B = %d | SEL = %b | START = %b | RESULT = %d",
		$time, 
		i_rx, 
		o_tx,
		u_uart_calculator.w_a, 
		u_uart_calculator.w_b,
		u_uart_calculator.w_sel,
		u_uart_calculator.w_start,
		u_uart_calculator.w_result
	);
end


endmodule	 		
