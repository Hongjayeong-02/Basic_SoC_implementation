`timescale 1ns/1ps

module uart_tx (
	input	wire		clk,
	input	wire		rst_n,

	input	wire		i_tick16,

	input	wire		i_txValid,
	input	wire	[7:0]	i_txData,

	input 	wire		i_data7,
	input	wire	[1:0]	i_parityMode,
	input	wire		i_stop2,

	output	reg		o_txReady,
	output	reg		o_txBusy,
	output	reg		o_txDone,
	output	reg		o_uartTx
);

localparam PARITY_NONE 	= 2'b00;
localparam PARITY_EVEN 	= 2'b01;
localparam PARITY_ODD  	= 2'b10;

localparam IDLE		= 3'd0;
localparam WAIT_START	= 3'd1;
localparam START	= 3'd2;
localparam DATA		= 3'd3;
localparam PARITY	= 3'd4;
localparam STOP		= 3'd5;
localparam DONE		= 3'd6;

reg 	[2:0] 	r_state		;
reg 	[3:0] 	r_tickCnt	;
reg 	[2:0] 	r_bitCnt	;
reg	  	r_stopCnt	;

reg 	[7:0] 	r_txData	;
reg		r_data7		;
reg	[1:0]	r_parityMode	;
reg		r_stop2		;
reg		r_parityBit	;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		r_state		<= IDLE;
		r_tickCnt	<= 4'd0;
		r_bitCnt	<= 3'd0;
		r_stopCnt	<= 1'b0;
		
		r_txData	<= 8'd0;
		r_data7		<= 1'b0;
		r_parityMode	<= PARITY_NONE;
		r_stop2		<= 1'b0;
		r_parityBit	<= 1'b0;

		o_txReady	<= 1'b1;
		o_txBusy	<= 1'b0;
		o_txDone	<= 1'b0;
		o_uartTx	<= 1'b1;
	end else begin
		o_txDone	<= 1'b0;

		case (r_state)
			IDLE: begin
				r_tickCnt 	<= 4'd0;
				r_bitCnt	<= 3'd0;
				r_stopCnt	<= 1'b0;

				o_txReady	<= 1'b1;
				o_txBusy	<= 1'b0;
				o_uartTx	<= 1'b1;

				if (i_txValid) begin
					r_txData	<= i_txData;
					r_data7		<= i_data7;
					r_parityMode	<= i_parityMode;
					r_stop2		<= i_stop2;

					case (i_parityMode)
						PARITY_EVEN: begin
							if (i_data7)
								r_parityBit <= ^i_txData[6:0];
							else
								r_parityBit <= ^i_txData[7:0];
						end

						PARITY_ODD: begin
							if (i_data7)
								r_parityBit <= ~^i_txData[6:0];
							else
								r_parityBit <= ~^i_txData[7:0];
						end

						default: begin
								r_parityBit <= 1'b0;
						end

					endcase

					o_txReady <= 1'b0;
					o_txBusy  <= 1'b1;

					r_state   <= WAIT_START;

				end

			end


			WAIT_START: begin
				o_txReady <= 1'b0;
				o_txBusy  <= 1'b1;
				o_uartTx  <= 1'b1;

				if (i_tick16) begin
					r_tickCnt <= 4'd0;
					o_uartTx  <= 1'b0;
					r_state   <= START;
				end

			end

			
			START: begin	
				o_uartTx <= 1'b0;

				if (i_tick16) begin
					if (r_tickCnt == 4'd15) begin
						r_tickCnt <= 4'd0;
						r_bitCnt  <= 3'd0;

						o_uartTx  <= r_txData[0];
						r_state   <= DATA;
					end else begin
						r_tickCnt <= r_tickCnt + 1'b1;
					end
				end
			end

			
			DATA: begin
				if (i_tick16) begin
					if (r_tickCnt == 4'd15) begin
						r_tickCnt <= 4'd0;
	
					if (
						(r_data7 && r_bitCnt == 3'd6) ||
						(!r_data7 && r_bitCnt == 3'd7)
					) begin
						if (r_parityMode == PARITY_NONE ) begin
							r_stopCnt <= 1'b0;
							o_uartTx  <= 1'b1;
							r_state   <= STOP;
						
							end else begin
								o_uartTx  <= r_parityBit;
								r_state   <= PARITY;	
							end 
						
						end else begin
							r_bitCnt <= r_bitCnt + 1'b1;
							o_uartTx <= r_txData[r_bitCnt + 1'b1];
						end

					end else begin
						r_tickCnt <= r_tickCnt + 1'b1;
					end
				end
			end


			PARITY: begin
				o_uartTx <= r_parityBit;

				if (i_tick16) begin
					if (r_tickCnt == 4'd15) begin
						r_tickCnt <= 4'd0;
						r_stopCnt <= 1'b0;

						o_uartTx  <= 1'b1;
						r_state   <= STOP;
					
					end else begin	
						r_tickCnt <= r_tickCnt + 1'b1;
					end
				end
			end
				
			
			STOP: begin
				o_uartTx <= 1'b1;
			
				if (i_tick16) begin
					if (r_tickCnt == 4'd15) begin
						r_tickCnt <= 4'd0;

						if (
							r_stop2 && !r_stopCnt
						) begin
							r_stopCnt <= 1'b1;
					
						end else begin
							r_state <= DONE;
						end

					end else begin
						r_tickCnt <= r_tickCnt + 1'b1;
					end

				end
			end


			DONE: begin
				o_uartTx  <= 1'b1;
				o_txReady <= 1'b1;
				o_txBusy  <= 1'b0;
				o_txDone  <= 1'b1;

				r_state   <= IDLE;
			end


			default: begin
				r_state <= IDLE;
			end

		endcase 
	end
end


endmodule
