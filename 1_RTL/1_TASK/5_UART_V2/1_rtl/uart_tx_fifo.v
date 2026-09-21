`timescale 1ns/1ps

module uart_tx_fifo (
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


localparam CTRL_IDLE = 3'd0;
localparam CTRL_READ = 3'd1;
localparam CTRL_LOAD = 3'd2;
localparam CTRL_SEND = 3'd3;
localparam CTRL_WAIT = 3'd4;


wire    [7:0]   w_fifoRdData;
wire            w_fifoFull;
wire            w_fifoEmpty;
wire    [4:0]   w_fifoCount;

wire            w_txReady;
wire            w_txBusy;
wire            w_txDone;
wire            w_uartTx;


reg             r_fifoRdEn;

reg             r_txValid;
reg     [7:0]   r_txData;

reg     [2:0]   r_ctrlState;


// ---------------------------------------------------------
// TX FIFO
// ---------------------------------------------------------
uart_fifo uut_fifo (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_wrEn         (i_wrEn),
        .i_wrData       (i_wrData),

        .i_rdEn         (r_fifoRdEn),

        .o_rdData       (w_fifoRdData),
        .o_full         (w_fifoFull),
        .o_empty        (w_fifoEmpty),
        .o_count        (w_fifoCount)
);


// ---------------------------------------------------------
// UART TX
// ---------------------------------------------------------
uart_tx uut_tx (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (i_tick16),

        .i_txValid      (r_txValid),
        .i_txData       (r_txData),

        .i_data7        (i_data7),
        .i_parityMode   (i_parityMode),
        .i_stop2        (i_stop2),

        .o_txReady      (w_txReady),
        .o_txBusy       (w_txBusy),
        .o_txDone       (w_txDone),
        .o_uartTx       (w_uartTx)
);


// ---------------------------------------------------------
// FIFO -> UART TX Controller
// ---------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                r_fifoRdEn  <= 1'b0;

                r_txValid   <= 1'b0;
                r_txData    <= 8'd0;

                r_ctrlState <= CTRL_IDLE;

        end else begin

                // Default pulse signals
                r_fifoRdEn <= 1'b0;
                r_txValid  <= 1'b0;


                case (r_ctrlState)

                        // ---------------------------------
                        // Wait for FIFO Data
                        // ---------------------------------
                        CTRL_IDLE: begin

                                if (
                                        !w_fifoEmpty &&
                                        w_txReady
                                ) begin

                                        r_fifoRdEn  <= 1'b1;
                                        r_ctrlState <= CTRL_READ;

                                end
                        end


                        // ---------------------------------
                        // FIFO Read Cycle
                        // ---------------------------------
                        CTRL_READ: begin

                                r_ctrlState <= CTRL_LOAD;

                        end


                        // ---------------------------------
                        // Load FIFO Data
                        // ---------------------------------
                        CTRL_LOAD: begin

                                r_txData    <= w_fifoRdData;
                                r_txValid   <= 1'b1;

                                r_ctrlState <= CTRL_SEND;

                        end


                        // ---------------------------------
                        // TX Accept Cycle
                        // ---------------------------------
                        CTRL_SEND: begin

                                r_ctrlState <= CTRL_WAIT;

                        end


                        // ---------------------------------
                        // Wait Until UART TX Done
                        // ---------------------------------
                        CTRL_WAIT: begin

                                if (w_txDone)
                                        r_ctrlState <= CTRL_IDLE;

                        end


                        default: begin

                                r_ctrlState <= CTRL_IDLE;

                        end

                endcase
        end
end


assign o_fifoFull  = w_fifoFull;
assign o_fifoEmpty = w_fifoEmpty;
assign o_fifoCount = w_fifoCount;

assign o_txReady   = w_txReady;
assign o_txBusy    = w_txBusy;
assign o_txDone    = w_txDone;
assign o_uartTx    = w_uartTx;


endmodule
