`timescale 1ns/1ps

module uart_rx_fifo #(
        // Default depth 8 per spec sec.8.3 / sec.16. Must match
        // uart_tx_fifo's FIFO_DEPTH (driven from uart_core) unless an
        // asymmetric TX/RX FIFO size is intentional.
        parameter FIFO_DEPTH = 8
)(
        input   wire            clk,
        input   wire            rst_n,

        input   wire            i_tick16,
        input   wire            i_uartRx,

        input   wire            i_data7,
        input   wire    [1:0]   i_parityMode,
        input   wire            i_stop2,

        input   wire            i_rdEn,

        output  reg     [7:0]   o_rdData,
        output  reg             o_rdParityErr,
        output  reg             o_rdFrameErr,

        output  wire            o_fifoFull,
        output  wire            o_fifoEmpty,
        output  wire    [4:0]   o_fifoCount,

        output  wire            o_rxValid,
        output  wire            o_rxBusy,

        output  wire            o_parityErr,
        output  wire            o_frameErr,
        output  wire            o_falseStart,

        output  reg             o_rxOverflow
);


localparam PTR_WIDTH = $clog2(FIFO_DEPTH);


reg     [9:0]   r_mem [0:FIFO_DEPTH-1];

reg     [PTR_WIDTH-1:0] r_wrPtr;
reg     [PTR_WIDTH-1:0] r_rdPtr;

reg     [4:0]   r_count;


reg             r_paritySave;
reg             r_frameSave;


wire    [7:0]   w_rxData;

wire            w_fifoWrEn;
wire            w_fifoRdEn;

wire            w_parityData;
wire            w_frameData;


assign o_fifoFull  = (r_count == FIFO_DEPTH);
assign o_fifoEmpty = (r_count == 0);
assign o_fifoCount = r_count;


assign w_fifoWrEn = o_rxValid &&
                    !o_fifoFull;

assign w_fifoRdEn = i_rdEn &&
                    !o_fifoEmpty;


assign w_parityData = r_paritySave |
                      o_parityErr;

assign w_frameData = r_frameSave |
                     o_frameErr;


// UART RX
uart_rx uut_rx (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (i_tick16),
        .i_uartRx       (i_uartRx),

        .i_data7        (i_data7),
        .i_parityMode   (i_parityMode),
        .i_stop2        (i_stop2),

        .o_rxData       (w_rxData),
        .o_rxValid      (o_rxValid),
        .o_rxBusy       (o_rxBusy),

        .o_parityErr    (o_parityErr),
        .o_frameErr     (o_frameErr),
        .o_falseStart   (o_falseStart)
);


// Error Save
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin

                r_paritySave <= 1'b0;
                r_frameSave  <= 1'b0;

        end else begin

                if (o_parityErr)
                        r_paritySave <= 1'b1;

                if (o_frameErr)
                        r_frameSave <= 1'b1;


                if (o_rxValid) begin

                        r_paritySave <= 1'b0;
                        r_frameSave  <= 1'b0;

                end

        end
end


// Overflow Pulse
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin

                o_rxOverflow <= 1'b0;

        end else begin

                o_rxOverflow <= 1'b0;


                if (o_rxValid &&
                    o_fifoFull) begin

                        o_rxOverflow <= 1'b1;

                end

        end
end


// RX FIFO
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin

                r_wrPtr         <= 0;
                r_rdPtr         <= 0;
                r_count         <= 0;

                o_rdData        <= 8'd0;
                o_rdParityErr   <= 1'b0;
                o_rdFrameErr    <= 1'b0;

        end else begin

                case ({
                        w_fifoWrEn,
                        w_fifoRdEn
                })

                        // Write
                        2'b10: begin

                                r_mem[r_wrPtr] <= {
                                        w_frameData,
                                        w_parityData,
                                        w_rxData
                                };


                                if (r_wrPtr == FIFO_DEPTH - 1)
                                        r_wrPtr <= 0;
                                else
                                        r_wrPtr <= r_wrPtr + 1'b1;


                                r_count <= r_count + 1'b1;

                        end


                        // Read
                        2'b01: begin

                                o_rdFrameErr  <= r_mem[r_rdPtr][9];
                                o_rdParityErr <= r_mem[r_rdPtr][8];
                                o_rdData      <= r_mem[r_rdPtr][7:0];


                                if (r_rdPtr == FIFO_DEPTH - 1)
                                        r_rdPtr <= 0;
                                else
                                        r_rdPtr <= r_rdPtr + 1'b1;


                                r_count <= r_count - 1'b1;

                        end


                        // Read + Write
                        2'b11: begin

                                r_mem[r_wrPtr] <= {
                                        w_frameData,
                                        w_parityData,
                                        w_rxData
                                };


                                o_rdFrameErr  <= r_mem[r_rdPtr][9];
                                o_rdParityErr <= r_mem[r_rdPtr][8];
                                o_rdData      <= r_mem[r_rdPtr][7:0];


                                if (r_wrPtr == FIFO_DEPTH - 1)
                                        r_wrPtr <= 0;
                                else
                                        r_wrPtr <= r_wrPtr + 1'b1;


                                if (r_rdPtr == FIFO_DEPTH - 1)
                                        r_rdPtr <= 0;
                                else
                                        r_rdPtr <= r_rdPtr + 1'b1;


                                r_count <= r_count;

                        end


                        default: begin

                                r_count <= r_count;

                        end

                endcase

        end
end


endmodule
