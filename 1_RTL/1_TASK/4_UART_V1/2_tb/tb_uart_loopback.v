`timescale 1ns/1ps

module tb_uart_loopback;

localparam CLK_FREQ  = 48_000_000;
localparam BAUD_RATE = 9_600;

reg		clk;
reg		rst_n;
reg		r_txValid;
reg	[7:0]	r_txData;

wire		w_uartLine;
wire		w_txReady;
wire		w_txBusy;
wire	[7:0]	w_rxData;
wire		w_rxValid;
wire		w_frameErr;

integer r_errorCnt;

uart_core #(
	.CLK_FREQ (CLK_FREQ),
	.BAUD_RATE(BAUD_RATE)
) uut (
	.clk		(clk),
	.rst_n		(rst_n),
	.i_txValid	(r_txValid),
	.i_txData	(r_txData),
	.i_uartRx	(w_uartLine),
	.o_uartTx	(w_uartLine),
	.o_txReady	(w_txReady),
	.o_txBusy	(w_txBusy),
	.o_rxData	(w_rxData),
	.o_rxValid	(w_rxValid),
	.o_frameErr	(w_frameErr)
);

// Approximately 48 MHz
always #10.416667 clk = ~clk;

task send_and_check;
	input [7:0] data;
	begin
		wait (w_txReady);

		@(posedge clk);
		r_txData  <= data;
		r_txValid <= 1'b1;

		@(posedge clk);
		r_txValid <= 1'b0;

		wait (w_rxValid);

		if (w_rxData !== data) begin
			$display (
				"FAIL: TX=%02h RX=%02h",
				data,
				w_rxData
			);
			r_errorCnt = r_errorCnt + 1;
		end else begin
			$display (
				"PASS: TX=%02h RX=%02h",
				data,
				w_rxData
			);
		end

		wait (!w_txBusy);
		@(posedge clk);
	end
endtask

initial begin
	$dumpfile("uart_loopback.vcd.vcd");
	$dumpvars(0, tb_uart_loopback);

	$monitor (
		"time=%0t rst_n=%b tx=%b busy=%b rxValid=%b rxData=%02h",
		$time,
		rst_n,
		w_uartLine,
		w_txBusy,
		w_rxValid,
		w_rxData
	);

	clk		= 1'b0;
	rst_n		= 1'b0;
	r_txValid	= 1'b0;
	r_txData	= 8'd0;
	r_errorCnt	= 0;

	repeat (5) @(posedge clk);
	rst_n = 1'b1;

	send_and_check(8'h00);
	send_and_check(8'hFF);
	send_and_check(8'h55);
	send_and_check(8'hAA);

	if (r_errorCnt == 0)
		$display("UART V1 LOOPBACK: ALL PASS");
	else
		$display (
			"UART V1 LOOPBACK: %0d ERROR(S)",
			r_errorCnt
		);
	#100;
	$finish;
end

always @(uut.u_uart_rx.r_state) begin
	$display (
		"RX STATE: time=%0t state=%0d sync=%b bitCnt=%0d",
		$time,
		uut.u_uart_rx.r_state,
		uut.u_uart_rx.r_rxSync,
		uut.u_uart_rx.r_bitCnt
	);
end

always @(uut.u_uart_rx.r_bitCnt) begin
	$display (
		"RX DATA: time=%0t state=%0d bitCnt=%0d shift=%02h",
		$time,
		uut.u_uart_rx.r_state,
		uut.u_uart_rx.r_bitCnt,
		uut.u_uart_rx.r_rxShift
	);
end

always @(w_rxValid or w_frameErr) begin
	$display (
		"RX RESULT: time=%0t valid=%b frameErr=%b data=%02h",
		$time,
		w_rxValid,
		w_frameErr,
		w_rxData
	);
end

// 6 ms timeout
initial begin
	#6_000_000;
	$display("TIMEOUT: simulation did not finish");
	$finish;
end

endmodule
