`timescale 1ns/1ps

module tb_uart_irq;


reg             clk;
reg             rst_n;

reg     [4:0]   r_irqEn;
reg     [4:0]   r_irqClear;

reg             r_rxFifoEmpty;
reg             r_txFifoEmpty;

reg             r_parityErr;
reg             r_frameErr;
reg             r_falseStart;


wire    [4:0]   w_irqStatus;
wire            w_irq;


integer         r_errorCnt;


// ---------------------------------------------------------
// DUT
// ---------------------------------------------------------
uart_irq uut (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_irqEn        (r_irqEn),
        .i_irqClear     (r_irqClear),

        .i_rxFifoEmpty  (r_rxFifoEmpty),
        .i_txFifoEmpty  (r_txFifoEmpty),

        .i_parityErr    (r_parityErr),
        .i_frameErr     (r_frameErr),
        .i_falseStart   (r_falseStart),

        .o_irqStatus    (w_irqStatus),
        .o_irq          (w_irq)
);


// ---------------------------------------------------------
// Clock
// ---------------------------------------------------------
initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
end


// ---------------------------------------------------------
// Status Check
// ---------------------------------------------------------
task check_irq;

        input   [4:0]   expectedStatus;
        input           expectedIrq;

        begin

                #1;

                if (w_irqStatus !== expectedStatus) begin

                        $display(
                                "FAIL: IRQ STATUS expected=%05b actual=%05b",
                                expectedStatus,
                                w_irqStatus
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: IRQ STATUS = %05b",
                                w_irqStatus
                        );

                end


                if (w_irq !== expectedIrq) begin

                        $display(
                                "FAIL: IRQ expected=%b actual=%b",
                                expectedIrq,
                                w_irq
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: IRQ = %b",
                                w_irq
                        );

                end

        end

endtask


// ---------------------------------------------------------
// Error Pulse
// ---------------------------------------------------------
task pulse_error;

        input parityErr;
        input frameErr;
        input falseStart;

        begin

                @(negedge clk);

                r_parityErr  = parityErr;
                r_frameErr   = frameErr;
                r_falseStart = falseStart;


                @(negedge clk);

                r_parityErr  = 1'b0;
                r_frameErr   = 1'b0;
                r_falseStart = 1'b0;

        end

endtask


// ---------------------------------------------------------
// IRQ Clear
// ---------------------------------------------------------
task clear_irq;

        input [4:0] clearMask;

        begin

                @(negedge clk);

                r_irqClear = clearMask;


                @(negedge clk);

                r_irqClear = 5'b00000;

        end

endtask


// ---------------------------------------------------------
// Main Test
// ---------------------------------------------------------
initial begin

        $dumpfile("uart_irq.vcd");
        $dumpvars(0, tb_uart_irq);


        rst_n           = 1'b0;

        r_irqEn         = 5'b00000;
        r_irqClear      = 5'b00000;

        r_rxFifoEmpty   = 1'b1;
        r_txFifoEmpty   = 1'b1;

        r_parityErr     = 1'b0;
        r_frameErr      = 1'b0;
        r_falseStart    = 1'b0;

        r_errorCnt      = 0;


        // -------------------------------------------------
        // Reset
        // -------------------------------------------------
        repeat (5)
                @(posedge clk);

        rst_n = 1'b1;

        repeat (2)
                @(posedge clk);


        // =================================================
        // TEST 0 : RESET STATE
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 0 : IRQ RESET STATE");
        $display("----------------------------------------");


        // TX FIFO is empty after reset.
        // Therefore IRQ_STATUS[1] = 1.
        // IRQ itself remains LOW because IRQ_EN = 0.
        check_irq(
                5'b00010,
                1'b0
        );


        // =================================================
        // TEST 1 : TX FIFO EMPTY IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 1 : TX FIFO EMPTY IRQ");
        $display("----------------------------------------");


        r_irqEn = 5'b00010;

        check_irq(
                5'b00010,
                1'b1
        );


        // TX FIFO now contains data
        r_txFifoEmpty = 1'b0;

        #1;

        check_irq(
                5'b00000,
                1'b0
        );


        // =================================================
        // TEST 2 : RX FIFO NOT EMPTY IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : RX FIFO NOT EMPTY IRQ");
        $display("----------------------------------------");


        r_irqEn = 5'b00001;

        // RX data arrives
        r_rxFifoEmpty = 1'b0;

        #1;

        check_irq(
                5'b00001,
                1'b1
        );


        // CPU reads all RX data
        r_rxFifoEmpty = 1'b1;

        #1;

        check_irq(
                5'b00000,
                1'b0
        );


        // =================================================
        // TEST 3 : PARITY ERROR IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 3 : PARITY ERROR IRQ");
        $display("----------------------------------------");


        r_irqEn = 5'b00100;


        pulse_error(
                1'b1,
                1'b0,
                1'b0
        );


        check_irq(
                5'b00100,
                1'b1
        );


        // Error input already returned LOW,
        // but sticky pending must remain HIGH.
        repeat (3)
                @(posedge clk);


        check_irq(
                5'b00100,
                1'b1
        );


        // Software clear
        clear_irq(
                5'b00100
        );


        check_irq(
                5'b00000,
                1'b0
        );


        // =================================================
        // TEST 4 : FRAME + FALSE START IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 4 : FRAME + FALSE START IRQ");
        $display("----------------------------------------");


        r_irqEn = 5'b11000;


        pulse_error(
                1'b0,
                1'b1,
                1'b1
        );


        check_irq(
                5'b11000,
                1'b1
        );


        // Clear Frame Error only
        clear_irq(
                5'b01000
        );


        check_irq(
                5'b10000,
                1'b1
        );


        // Clear False Start
        clear_irq(
                5'b10000
        );


        check_irq(
                5'b00000,
                1'b0
        );


        // =================================================
        // TEST 5 : MULTIPLE LEVEL IRQ SOURCES
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 5 : MULTIPLE IRQ SOURCES");
        $display("----------------------------------------");


        r_irqEn       = 5'b00011;

        r_rxFifoEmpty = 1'b0;
        r_txFifoEmpty = 1'b1;


        #1;


        check_irq(
                5'b00011,
                1'b1
        );


        // Disable all interrupt sources.
        //
        // Status remains active,
        // but global IRQ must go LOW.
        r_irqEn = 5'b00000;


        #1;


        check_irq(
                5'b00011,
                1'b0
        );


        // Remove FIFO conditions
        r_rxFifoEmpty = 1'b1;
        r_txFifoEmpty = 1'b0;


        #1;


        check_irq(
                5'b00000,
                1'b0
        );


        // =================================================
        // Final Result
        // =================================================
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART IRQ: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART IRQ: %0d ERROR(S)",
                        r_errorCnt
                );
                $display("========================================");
                $display("");

        end


        #100;

        $finish;

end


// ---------------------------------------------------------
// Timeout
// ---------------------------------------------------------
initial begin

        #1000000;

        $display("");
        $display("========================================");
        $display(" FAIL: UART IRQ SIMULATION TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end


endmodule
