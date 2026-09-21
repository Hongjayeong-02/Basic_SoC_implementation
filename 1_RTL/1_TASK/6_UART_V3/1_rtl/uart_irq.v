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
        input   wire            i_rxOverflow,

        output  reg     [4:0]   o_irqStatus,
        output  wire            o_irq
);


assign o_irq = |(o_irqStatus &
                 i_irqEn);


always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin

                o_irqStatus <= 5'b00000;

        end else begin

                // Level IRQ
                o_irqStatus[0] <= !i_rxFifoEmpty;
                o_irqStatus[1] <= i_txFifoEmpty;


                // Parity Error Sticky
                if (i_irqClear[2])
                        o_irqStatus[2] <= 1'b0;

                if (i_parityErr)
                        o_irqStatus[2] <= 1'b1;


                // Frame Error Sticky
                if (i_irqClear[3])
                        o_irqStatus[3] <= 1'b0;

                if (i_frameErr)
                        o_irqStatus[3] <= 1'b1;


                // RX Overflow Sticky
                if (i_irqClear[4])
                        o_irqStatus[4] <= 1'b0;

                if (i_rxOverflow)
                        o_irqStatus[4] <= 1'b1;

        end
end


endmodule
