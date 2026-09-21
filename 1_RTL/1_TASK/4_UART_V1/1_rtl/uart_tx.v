`timescale 1ns/1ps

module uart_tx (
	input	wire		clk,
	input	wire		rst_n,
	input 	wire		i_baudTick,
	input	wire		i_txValid,
	input	wire	[7:0]	i_txData,
	output	reg		o_txReady,
	output	reg		o_uartTx,
	output	reg		o_txBusy
);

localparam IDLE 	= 3'd0;
localparam WAIT_START	= 3'd1;
localparam START	= 3'd2;
localparam DATA		= 3'd3;
localparam STOP		= 3'd4;

reg [2:0] r_state;
reg [2:0] r_bitCnt;
reg [7:0] r_txShift;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		r_state 	<= IDLE;
		r_bitCnt	<= 3'd0;
		r_txShift	<= 8'd0;
		o_txReady	<= 1'b1;
		o_uartTx	<= 1'b1;
		o_txBusy	<= 1'b0;
	end else begin
		case (r_state)
			IDLE: begin
				o_uartTx 	<= 1'b1;
				o_txReady	<= 1'b1;
				o_txBusy	<= 1'b0;
		
				if (i_txValid) begin
					r_txShift	<= i_txData;
					o_txReady	<= 1'b0;
					o_txBusy	<= 1'b1;
					r_state		<= WAIT_START;
				end
			end

			WAIT_START: begin
				o_uartTx <= 1'b1;

				if (i_baudTick) begin
					o_uartTx <= 1'b0;
					r_state  <= START;
				end
			end

			START: begin
				o_uartTx <= 1'b0;

				if (i_baudTick) begin
					r_bitCnt	<= 3'd0;
					o_uartTx	<= r_txShift[0];
					r_state		<= DATA;
				end
			end

			DATA: begin
				if (i_baudTick) begin
					r_txShift <= {1'b0, r_txShift[7:1]};

					if (r_bitCnt == 3'd7) begin
						o_uartTx <= 1'b1;
						r_state  <= STOP;
					end else begin
						o_uartTx <= r_txShift[1];
						r_bitCnt <= r_bitCnt + 1'b1;
					end
				end
			end

			STOP: begin
				o_uartTx <= 1'b1;

				if (i_baudTick)
					r_state <= IDLE;
				end

			default: begin
				r_state <= IDLE;
			end
		endcase
	end
end

endmodule
 

