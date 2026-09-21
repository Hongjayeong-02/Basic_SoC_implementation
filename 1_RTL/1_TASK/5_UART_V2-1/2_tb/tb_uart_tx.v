`default_nettype none
`timescale 1ns/1ps

module tb_uart_tx;

localparam BAUD_DIV = 16'd312;

localparam PARITY_NONE = 2'b00;
localparam PARITY_EVEN = 2'b01;
localparam PARITY_ODD  = 2'b10;

reg		clk;
reg		rst_n;

reg		r_enable;
reg	[15:0]	r_baudDiv;

reg 		r_txValid;
reg	[7:0]	r_txData;

reg		r_data7;
reg	[1:0]	r_parityMode;
reg		r_stop2;

wire		w_tick16;
wire		w_txReady;
wire		w_txBusy;
wire		w_txDone;
wire		w_uartTx;

integer r_errorCnt;



uart_baud_gen uut_baud_gen (
	.clk		(clk),
	.rst_n		(rst_n),
	.i_enable	(r_enable),
	.i_baudDiv	(r_baudDiv),
	.o_tick16	(w_tick16)
);


uart_tx uut_tx (
	.clk		(clk),
	.rst_n		(rst_n),

	.i_tick16	(w_tick16),

	.i_txValid	(r_txValid),
	.i_txData	(r_txData),

	.i_data7	(r_data7),
	.i_parityMode	(r_parityMode),
	.i_stop2	(r_stop2),

	.o_txReady	(w_txReady),
	.o_txBusy	(w_txBusy),
	.o_txDone	(w_txDone),
	.o_uartTx	(w_uartTx)
);


// 48 MHz clock
always #10.41667 clk = ~clk;


// Task for checking a specific bit value
task check_uart_bit;
	input 		expectedBit;
	input [31:0]  	bitNumber;

	begin
		if (w_uartTx !== expectedBit) begin
			$display(
				"FAIL: bit[%0d] expected=%b actual=%b",
				bitNumber,
				expectedBit,
				w_uartTx
			);

				r_errorCnt = r_errorCnt + 1;
		end
	end
endtask


// UART frame transmission and serial output verification
task send_and_check;
	input 	[7:0]	data;
	input		data7;
	input	[1:0]	parityMode;
	input		stop2;

	integer i;
	integer dataBitCount;
	integer previousErrorCount;

	reg expectedParity;


	begin
		previousErrorCount = r_errorCnt;

		if (data7)
			dataBitCount = 7;

		else
			dataBitCount = 8;

		if (parityMode == PARITY_EVEN) begin
			if (data7) 
				expectedParity = ^data[6:0];

			else
				expectedParity = ^data[7:0];

		end else if (parityMode == PARITY_ODD) begin
			if (data7)
				expectedParity = ~^data[6:0];

			else
				expectedParity = ~^data[7:0];

		end else begin
			expectedParity = 1'b0;
		end


		wait (w_txReady);

		@(negedge clk);
		
		r_txData	= data;
		r_data7		= data7;
		r_parityMode	= parityMode;
		r_stop2		= stop2;
		r_txValid	= 1'b1;

		@(negedge clk);

		r_txValid	= 1'b0;


		// Start bit Detection
		@(negedge w_uartTx);


		// Move to center of the Start bit
		repeat (8) @(posedge w_tick16);
		#1;

		check_uart_bit(1'b0, 0);

		// Sample the center of each data bit
		for (i = 0; i < dataBitCount; i = i + 1) begin
			repeat (16) @(posedge w_tick16);
			#1;

			check_uart_bit(data[i], i);
		end

		// Parity bit Check
		if (parityMode != PARITY_NONE) begin
			repeat (16) @(posedge w_tick16);
			#1;

				check_uart_bit (
						expectedParity,
						dataBitCount
				);
		end

		// First stop bit check
		repeat (16) @(posedge w_tick16);
		#1;

		check_uart_bit(1'b1, dataBitCount + 1);


		// Second stop bit check
		if (stop2) begin
			repeat (16) @(posedge w_tick16);
			#1;

			check_uart_bit(1'b1, dataBitCount + 2);
		end

		wait (w_txDone);
		@(posedge clk);

		if (previousErrorCount == r_errorCnt) begin
			$display (
				"PASS: data=%02h data7=%b parity=%02b stop2=%b",
				data,
				data7,
				parityMode,
				stop2
			);
		end else begin
			$display (
				"FAIL: data=%02h data7=%b parity=%02b stop2=%b",
				data,
				data7,
				parityMode,
				stop2
			);
		end
	end
endtask


initial begin
	$dumpfile("uart_tx.vcd");
	$dumpvars(0, tb_uart_tx);

	clk		= 1'b0;
	rst_n		= 1'b0;

	r_enable	= 1'b0;
	r_baudDiv	= BAUD_DIV;

	r_txValid	= 1'b0;
	r_txData	= 8'd0;

	r_data7		= 1'b0;
	r_parityMode	= PARITY_NONE;
	r_stop2		= 1'b0;

	r_errorCnt  	= 0;

	repeat (5) @(posedge clk);

	rst_n = 1'b1;

	@(negedge clk);
	r_enable = 1'b1;


	// 8-bit, 1 Stop
	send_and_check(8'h55, 1'b0, PARITY_NONE, 1'b0);
	send_and_check(8'h55, 1'b0, PARITY_EVEN, 1'b0);
	send_and_check(8'h55, 1'b0, PARITY_ODD , 1'b0);

	// 8-bit, 2 Stop
	send_and_check(8'hAA, 1'b0, PARITY_NONE, 1'b1);
	send_and_check(8'hAA, 1'b0, PARITY_EVEN, 1'b1);
	send_and_check(8'hAA, 1'b0, PARITY_ODD , 1'b1);

	// 7-bit, 1 Stop
	send_and_check(8'h55, 1'b1, PARITY_NONE, 1'b0);
	send_and_check(8'h55, 1'b1, PARITY_EVEN, 1'b0);
	send_and_check(8'h55, 1'b1, PARITY_ODD , 1'b0);

	// 7-bit, 2 Stop
	send_and_check(8'h2A, 1'b1, PARITY_NONE, 1'b1);
	send_and_check(8'h2A, 1'b1, PARITY_EVEN, 1'b1);
	send_and_check(8'h2A, 1'b1, PARITY_ODD , 1'b1);

	
	if (r_errorCnt == 0) begin
		$display (
			"UART V2 CONFIGURABLE TX: ALL PASS"
		);

	end else begin
		$display (
			"UART V2 CONFIGURABLE TX: %0d ERROR(S)",
			r_errorCnt
		);
	end

	#100;
	$finish;
end


initial begin
	#20_000_000;

	$display (
		"TIMEOUT: configurable TX test did not finish"
	);

	$finish;
end


endmodule

`default_nettype wire
