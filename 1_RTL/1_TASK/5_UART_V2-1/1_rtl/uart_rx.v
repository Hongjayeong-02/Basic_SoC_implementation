`timescale 1ns/1ps

module uart_rx (
        input   wire            clk,
        input   wire            rst_n,

        input   wire            i_tick16,
        input   wire            i_uartRx,

        input   wire            i_data7,
        input   wire    [1:0]   i_parityMode,
        input   wire            i_stop2,

        output  reg     [7:0]   o_rxData,
        output  reg             o_rxValid,
        output  reg             o_rxBusy,

        output  reg             o_parityErr,
        output  reg             o_frameErr,
        output  reg             o_falseStart
);

localparam PARITY_NONE  = 2'b00;
localparam PARITY_EVEN  = 2'b01;
localparam PARITY_ODD   = 2'b10;

localparam IDLE         = 3'd0;
localparam START_CHECK  = 3'd1;
localparam DATA         = 3'd2;
localparam PARITY       = 3'd3;
localparam STOP         = 3'd4;
localparam PUSH         = 3'd5;


reg             r_rxMeta;
reg             r_rxSync;

reg     [2:0]   r_state;
reg     [3:0]   r_tickCnt;
reg     [2:0]   r_bitCnt;

reg     [7:0]   r_rxData;

reg             r_data7;
reg     [1:0]   r_parityMode;
reg             r_stop2;

reg             r_parityErr;
reg             r_frameErr;
reg             r_stopCnt;


// ---------------------------------------------------------
// 2-FF Synchronizer
// ---------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                r_rxMeta <= 1'b1;
                r_rxSync <= 1'b1;
        end else begin
                r_rxMeta <= i_uartRx;
                r_rxSync <= r_rxMeta;
        end
end


// ---------------------------------------------------------
// RX FSM
// ---------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                r_state         <= IDLE;

                r_tickCnt       <= 4'd0;
                r_bitCnt        <= 3'd0;
                r_stopCnt       <= 1'b0;

                r_rxData        <= 8'd0;

                r_data7         <= 1'b0;
                r_parityMode    <= PARITY_NONE;
                r_stop2         <= 1'b0;

                r_parityErr     <= 1'b0;
                r_frameErr      <= 1'b0;

                o_rxData        <= 8'd0;
                o_rxValid       <= 1'b0;
                o_rxBusy        <= 1'b0;

                o_parityErr     <= 1'b0;
                o_frameErr      <= 1'b0;
                o_falseStart    <= 1'b0;

        end else begin

                // Pulse outputs
                o_rxValid       <= 1'b0;
                o_parityErr     <= 1'b0;
                o_frameErr      <= 1'b0;
                o_falseStart    <= 1'b0;


                case (r_state)

                        // ---------------------------------
                        // IDLE
                        // ---------------------------------
                        IDLE: begin
                                o_rxBusy        <= 1'b0;

                                r_tickCnt       <= 4'd0;
                                r_bitCnt        <= 3'd0;
                                r_stopCnt       <= 1'b0;

                                // Falling level detected
                                if (!r_rxSync) begin
                                        r_data7         <= i_data7;
                                        r_parityMode    <= i_parityMode;
                                        r_stop2         <= i_stop2;

                                        r_rxData        <= 8'd0;

                                        r_parityErr     <= 1'b0;
                                        r_frameErr      <= 1'b0;

                                        o_rxBusy        <= 1'b1;

                                        r_state         <= START_CHECK;
                                end
                        end


                        // ---------------------------------
                        // START BIT
                        // Sample center of start bit
                        // ---------------------------------
                        START_CHECK: begin
                                o_rxBusy <= 1'b1;

                                if (i_tick16) begin

                                        if (r_tickCnt == 4'd7) begin
                                                r_tickCnt <= 4'd0;

                                                // Start bit still LOW
                                                if (!r_rxSync) begin
                                                        r_bitCnt <= 3'd0;
                                                        r_state  <= DATA;

                                                end else begin
                                                        // False start
                                                        o_falseStart <= 1'b1;
                                                        o_rxBusy     <= 1'b0;
                                                        r_state      <= IDLE;
                                                end

                                        end else begin
                                                r_tickCnt <= r_tickCnt + 1'b1;
                                        end

                                end
                        end


                        // ---------------------------------
                        // DATA
                        // Sample every 16 ticks
                        // ---------------------------------
                        DATA: begin
                                o_rxBusy <= 1'b1;

                                if (i_tick16) begin

                                        if (r_tickCnt == 4'd15) begin
                                                r_tickCnt <= 4'd0;

                                                // LSB first
                                                r_rxData[r_bitCnt] <= r_rxSync;

                                                // Last data bit
                                                if (
                                                        (r_data7  && (r_bitCnt == 3'd6)) ||
                                                        (!r_data7 && (r_bitCnt == 3'd7))
                                                ) begin

                                                        if (r_parityMode == PARITY_NONE) begin
                                                                r_stopCnt <= 1'b0;
                                                                r_state   <= STOP;
                                                        end else begin
                                                                r_state   <= PARITY;
                                                        end

                                                end else begin
                                                        r_bitCnt <= r_bitCnt + 1'b1;
                                                end

                                        end else begin
                                                r_tickCnt <= r_tickCnt + 1'b1;
                                        end

                                end
                        end


                        // ---------------------------------
                        // PARITY
                        // ---------------------------------
                        PARITY: begin
                                o_rxBusy <= 1'b1;

                                if (i_tick16) begin

                                        if (r_tickCnt == 4'd15) begin
                                                r_tickCnt <= 4'd0;

                                                if (r_data7) begin

                                                        if (r_parityMode == PARITY_EVEN) begin

                                                                if (r_rxSync != (^r_rxData[6:0]))
                                                                        r_parityErr <= 1'b1;

                                                        end else if (r_parityMode == PARITY_ODD) begin

                                                                if (r_rxSync != (~^r_rxData[6:0]))
                                                                        r_parityErr <= 1'b1;

                                                        end

                                                end else begin

                                                        if (r_parityMode == PARITY_EVEN) begin

                                                                if (r_rxSync != (^r_rxData[7:0]))
                                                                        r_parityErr <= 1'b1;

                                                        end else if (r_parityMode == PARITY_ODD) begin

                                                                if (r_rxSync != (~^r_rxData[7:0]))
                                                                        r_parityErr <= 1'b1;

                                                        end

                                                end

                                                r_stopCnt <= 1'b0;
                                                r_state   <= STOP;

                                        end else begin
                                                r_tickCnt <= r_tickCnt + 1'b1;
                                        end

                                end
                        end


                        // ---------------------------------
                        // STOP BIT
                        // ---------------------------------
                        STOP: begin
                                o_rxBusy <= 1'b1;

                                if (i_tick16) begin

                                        if (r_tickCnt == 4'd15) begin
                                                r_tickCnt <= 4'd0;

                                                // Stop bit must be HIGH
                                                if (!r_rxSync)
                                                        r_frameErr <= 1'b1;

                                                // 2-stop-bit mode
                                                if (r_stop2 && !r_stopCnt) begin
                                                        r_stopCnt <= 1'b1;

                                                end else begin
                                                        r_state <= PUSH;
                                                end

                                        end else begin
                                                r_tickCnt <= r_tickCnt + 1'b1;
                                        end

                                end
                        end


                        // ---------------------------------
                        // PUSH RESULT
                        // ---------------------------------
                        PUSH: begin
                                o_rxBusy <= 1'b0;

                                if (r_data7)
                                        o_rxData <= {1'b0, r_rxData[6:0]};
                                else
                                        o_rxData <= r_rxData;

                                o_rxValid   <= 1'b1;
                                o_parityErr <= r_parityErr;
                                o_frameErr  <= r_frameErr;

                                r_state <= IDLE;
                        end


                        default: begin
                                r_state  <= IDLE;
                                o_rxBusy <= 1'b0;
                        end

                endcase
        end
end

endmodule

