`timescale 1ns/1ps

module uart_rx #(
	parameter CLK_FREQ  = 48_000_000,
	parameter BAUD_RATE = 9_600
)(
	input	wire		clk,
	input	wire		rst_n,
	input	wire		i_uartRx,
	output	reg	[7:0]	o_rxData,
	output	reg 		o_rxValid,
	output	reg		o_frameErr
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
localparam HALF_BIT	= CLKS_PER_BIT / 2;
localparam CNT_WIDTH	= $clog2(CLKS_PER_BIT);

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam DATA  = 2'd2;
localparam STOP  = 2'd3;

reg r_rxMeta;
reg r_rxSync;

reg [1:0] r_state;
reg [CNT_WIDTH-1:0] r_sampleCnt;
reg [2:0] r_bitCnt;
reg [7:0] r_rxShift;


// 2-FF synchronizer
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		r_rxMeta <= 1'b1;
		r_rxSync <= 1'b1;
	end else begin
		r_rxMeta <= i_uartRx;
		r_rxSync <= r_rxMeta;
	end
end

// RX FSM
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		r_state		<= IDLE;
		r_sampleCnt	<= {CNT_WIDTH{1'b0}};
		r_bitCnt	<= 3'd0;
		r_rxShift	<= 8'd0;
		o_rxData	<= 8'd0;
		o_rxValid	<= 1'b0;
		o_frameErr	<= 1'b0;
	end else begin
		o_rxValid	<= 1'b0;
		o_frameErr	<= 1'b0;

		case (r_state) 
			IDLE: begin
				r_sampleCnt <= {CNT_WIDTH{1'b0}};
	
				if (!r_rxSync)
					r_state <= START;
			end

			START: begin
				if (r_sampleCnt == HALF_BIT - 1) begin
					r_sampleCnt <= {CNT_WIDTH{1'b0}};

					if (!r_rxSync) begin
						r_bitCnt <= 3'd0;
						r_state  <= DATA;
					end else begin
						r_state  <= IDLE;
					end
				end else begin
					r_sampleCnt <= r_sampleCnt + 1'b1;
				end
			end

			DATA: begin
				if (r_sampleCnt == CLKS_PER_BIT - 1) begin
					r_sampleCnt		<= {CNT_WIDTH{1'b0}};
					r_rxShift[r_bitCnt]	<= r_rxSync;

					if (r_bitCnt == 3'd7)
						r_state <= STOP;
					else
						r_bitCnt <= r_bitCnt + 1'b1;
				end else begin
					r_sampleCnt <= r_sampleCnt + 1'b1;
				end

			end

			STOP: begin
				if (r_sampleCnt == CLKS_PER_BIT - 1) begin
					r_sampleCnt <= {CNT_WIDTH{1'b0}};

					if (r_rxSync) begin
						o_rxData  <= r_rxShift;
						o_rxValid <= 1'b1;
					end else begin
						o_frameErr <= 1'b1;
					end

					r_state <= IDLE;
				end else begin
					r_sampleCnt <= r_sampleCnt + 1'b1;
				end
			end

			default: begin
				r_state <= IDLE;
			end
		endcase
	end
end

endmodule 

