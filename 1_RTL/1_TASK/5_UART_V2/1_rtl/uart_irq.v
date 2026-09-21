`timescale 1ns/1ps

module uart_irq (
        input   wire            clk,
        input   wire            rst_n,

        input   wire    [4:0]   i_irqEn,
        input   wire    [4:0]   i_irqClear,

        input   wire            i_rxFifoEmpty,
        input   wire            i_txFifoEmpty,

        input   wire            i_parityErr,
        input   wire            i_frameErr,
        input   wire            i_falseStart,

        output  wire    [4:0]   o_irqStatus,
        output  wire            o_irq
);


reg             r_parityPending;
reg             r_framePending;
reg             r_falseStartPending;


// ---------------------------------------------------------
// Sticky Error Interrupt
//
// bit[2] : Parity Error
// bit[3] : Frame Error
// bit[4] : False Start
//
// Hardware error set has priority over software clear.
// ---------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                r_parityPending     <= 1'b0;
                r_framePending      <= 1'b0;
                r_falseStartPending <= 1'b0;

        end else begin

                // Parity Error
                if (i_irqClear[2])
                        r_parityPending <= 1'b0;

                if (i_parityErr)
                        r_parityPending <= 1'b1;


                // Frame Error
                if (i_irqClear[3])
                        r_framePending <= 1'b0;

                if (i_frameErr)
                        r_framePending <= 1'b1;


                // False Start
                if (i_irqClear[4])
                        r_falseStartPending <= 1'b0;

                if (i_falseStart)
                        r_falseStartPending <= 1'b1;

        end
end


// ---------------------------------------------------------
// IRQ Status
//
// bit[0] : RX FIFO Not Empty
// bit[1] : TX FIFO Empty
// bit[2] : Parity Error Pending
// bit[3] : Frame Error Pending
// bit[4] : False Start Pending
//
// FIFO IRQ sources are level-sensitive.
// Therefore irqClear[1:0] does not clear them.
// The FIFO condition itself must disappear.
// ---------------------------------------------------------
assign o_irqStatus[0] = !i_rxFifoEmpty;
assign o_irqStatus[1] =  i_txFifoEmpty;
assign o_irqStatus[2] =  r_parityPending;
assign o_irqStatus[3] =  r_framePending;
assign o_irqStatus[4] =  r_falseStartPending;


// ---------------------------------------------------------
// Global IRQ
// ---------------------------------------------------------
assign o_irq = |(o_irqStatus & i_irqEn);


endmodule
