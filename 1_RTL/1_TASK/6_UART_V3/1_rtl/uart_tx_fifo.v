`timescale 1ns/1ps

module uart_tx_fifo #(
        // Default depth 8 per spec sec.8.3 / sec.16. Must match
        // uart_rx_fifo's FIFO_DEPTH (driven from uart_core) unless an
        // asymmetric TX/RX FIFO size is intentional.
        parameter FIFO_DEPTH = 8
)(
        input   wire            clk,
        input   wire            rst_n,

        input   wire            i_tick16,

        input   wire            i_wrEn,
        input   wire    [7:0]   i_wrData,

        input   wire            i_data7,
        input   wire    [1:0]   i_parityMode,
        input   wire            i_stop2,

        output  wire            o_fifoFull,
        output  wire            o_fifoEmpty,
        output  wire    [4:0]   o_fifoCount,

        output  wire            o_txReady,
        output  wire            o_txBusy,
        output  wire            o_txDone,

        output  wire            o_uartTx
);


localparam IDLE = 3'd0;
localparam READ = 3'd1;
localparam LOAD = 3'd2;
localparam SEND = 3'd3;
localparam WAIT = 3'd4;


reg     [2:0]   r_state;

reg             r_fifoRdEn;

reg             r_txValid;
reg     [7:0]   r_txData;


wire    [7:0]   w_fifoRdData;


// TX FIFO
uart_fifo #(
        .FIFO_DEPTH     (FIFO_DEPTH)
) uut_fifo (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_wrEn         (i_wrEn),
        .i_wrData       (i_wrData),

        .i_rdEn         (r_fifoRdEn),

        .o_rdData       (w_fifoRdData),

        .o_full         (o_fifoFull),
        .o_empty        (o_fifoEmpty),
        .o_count        (o_fifoCount)
);


// UART TX
uart_tx uut_tx (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (i_tick16),

        .i_txValid      (r_txValid),
        .i_txData       (r_txData),

        .i_data7        (i_data7),
        .i_parityMode   (i_parityMode),
        .i_stop2        (i_stop2),

        .o_txReady      (o_txReady),
        .o_txBusy       (o_txBusy),
        .o_txDone       (o_txDone),

        .o_uartTx       (o_uartTx)
);


// FIFO -> TX Controller
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                r_state    <= IDLE;
                r_fifoRdEn <= 1'b0;
                r_txValid  <= 1'b0;
                r_txData   <= 8'd0;

        end else begin

                r_fifoRdEn <= 1'b0;
                r_txValid  <= 1'b0;


                case (r_state)

                        IDLE: begin

                                if (!o_fifoEmpty && o_txReady) begin
                                        r_fifoRdEn <= 1'b1;
                                        r_state    <= READ;
                                end

                        end


                        READ: begin
                                r_state <= LOAD;
                        end


                        LOAD: begin
                                r_txData  <= w_fifoRdData;
                                r_txValid <= 1'b1;
                                r_state   <= SEND;
                        end


                        SEND: begin
                                r_state <= WAIT;
                        end


                        WAIT: begin

                                if (o_txDone)
                                        r_state <= IDLE;

                        end


                        default: begin
                                r_state <= IDLE;
                        end

                endcase
        end
end


endmodule
