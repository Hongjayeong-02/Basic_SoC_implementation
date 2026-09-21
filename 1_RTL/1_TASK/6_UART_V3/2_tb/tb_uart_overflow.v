`timescale 1ns/1ps

module tb_uart_overflow;

localparam ADDR_TXDATA      = 8'h00;
localparam ADDR_RXDATA      = 8'h04;
localparam ADDR_STATUS      = 8'h08;
localparam ADDR_CTRL        = 8'h0C;
localparam ADDR_BAUDDIV     = 8'h10;
localparam ADDR_IRQ_EN      = 8'h14;
localparam ADDR_IRQ_STATUS  = 8'h18;
localparam ADDR_FIFO_LEVEL  = 8'h1C;

localparam CTRL_LOOPBACK    = 32'h0000_0087;
localparam BAUD_DIV         = 16'd8;
localparam WAIT_LIMIT       = 50000;

reg             clk;
reg             rst_n;

reg             r_psel;
reg             r_penable;
reg             r_pwrite;
reg     [7:0]   r_paddr;
reg     [31:0]  r_pwdata;
reg             r_uartRx;

wire    [31:0]  w_prdata;
wire            w_pready;
wire            w_pslverr;
wire            w_uartTx;
wire            w_irq;

reg     [31:0]  r_readData;
reg             r_overflowPulseSeen;
reg             r_testAbort;

integer         r_errorCnt;
integer         r_index;


// DUT
uart_apb uut (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_psel         (r_psel),
        .i_penable      (r_penable),
        .i_pwrite       (r_pwrite),
        .i_paddr        (r_paddr),
        .i_pwdata       (r_pwdata),

        .o_prdata       (w_prdata),
        .o_pready       (w_pready),
        .o_pslverr      (w_pslverr),

        .i_uartRx       (r_uartRx),
        .o_uartTx       (w_uartTx),

        .o_irq          (w_irq)
);


// Clock
initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
end


// Overflow Pulse Save
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                r_overflowPulseSeen <= 1'b0;
        end else begin
                if (uut.w_rxOverflow)
                        r_overflowPulseSeen <= 1'b1;
        end
end


// APB Write
task apb_write;
        input   [7:0]   addr;
        input   [31:0]  data;

        begin
                @(negedge clk);

                r_psel    = 1'b1;
                r_penable = 1'b0;
                r_pwrite  = 1'b1;
                r_paddr   = addr;
                r_pwdata  = data;

                @(negedge clk);

                r_penable = 1'b1;

                @(posedge clk);

                while (!w_pready)
                        @(posedge clk);

                if (w_pslverr) begin
                        $display("FAIL: APB WRITE addr=%02h", addr);
                        r_errorCnt = r_errorCnt + 1;
                end

                @(negedge clk);

                r_psel    = 1'b0;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;
                r_paddr   = 8'd0;
                r_pwdata  = 32'd0;
        end
endtask


// APB Read
task apb_read;
        input   [7:0]   addr;
        output  [31:0]  data;

        begin
                @(negedge clk);

                r_psel    = 1'b1;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;
                r_paddr   = addr;
                r_pwdata  = 32'd0;

                @(negedge clk);

                r_penable = 1'b1;

                @(posedge clk);

                while (!w_pready)
                        @(posedge clk);

                #1;
                data = w_prdata;

                if (w_pslverr) begin
                        $display("FAIL: APB READ addr=%02h", addr);
                        r_errorCnt = r_errorCnt + 1;
                end

                @(negedge clk);

                r_psel    = 1'b0;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;
                r_paddr   = 8'd0;
        end
endtask


// Register Check
task check_register;
        input   [7:0]   addr;
        input   [31:0]  expectedData;
        input   [31:0]  mask;

        begin
                apb_read(addr, r_readData);

                if ((r_readData & mask) !==
                    (expectedData & mask)) begin

                        $display(
                                "FAIL: REGISTER addr=%02h expected=%08h actual=%08h",
                                addr,
                                expectedData & mask,
                                r_readData & mask
                        );

                        r_errorCnt = r_errorCnt + 1;
                        r_testAbort = 1'b1;
                end else begin
                        $display(
                                "PASS: REGISTER addr=%02h data=%08h",
                                addr,
                                r_readData & mask
                        );
                end
        end
endtask


// TX -> RX Loopback
task send_and_wait;
        input   [7:0]   data;
        input   [4:0]   expectedCount;

        integer         waitCnt;

        begin
                waitCnt = 0;

                while (uut.w_txBusy &&
                       waitCnt < WAIT_LIMIT) begin
                        @(posedge clk);
                        waitCnt = waitCnt + 1;
                end

                if (uut.w_txBusy) begin
                        $display("FAIL: PREVIOUS TX BUSY TIMEOUT");
                        r_errorCnt = r_errorCnt + 1;
                        r_testAbort = 1'b1;
                end

                if (!r_testAbort) begin
                        repeat (2)
                                @(posedge clk);

                        apb_write(
                                ADDR_TXDATA,
                                {24'd0, data}
                        );
                end

                if (!r_testAbort) begin
                        waitCnt = 0;

                        while (!uut.w_txBusy &&
                               waitCnt < WAIT_LIMIT) begin
                                @(posedge clk);
                                waitCnt = waitCnt + 1;
                        end

                        if (!uut.w_txBusy) begin
                                $display(
                                        "FAIL: TX START TIMEOUT data=%02h",
                                        data
                                );

                                $display(
                                        "DEBUG: uartEn=%b txEn=%b rxEn=%b loopback=%b txCount=%0d",
                                        uut.r_uartEn,
                                        uut.r_txEn,
                                        uut.r_rxEn,
                                        uut.r_loopbackEn,
                                        uut.w_txFifoCount
                                );

                                r_errorCnt = r_errorCnt + 1;
                                r_testAbort = 1'b1;
                        end
                end

                if (!r_testAbort) begin
                        waitCnt = 0;

                        while ((uut.w_rxFifoCount != expectedCount) &&
                               waitCnt < WAIT_LIMIT) begin
                                @(posedge clk);
                                waitCnt = waitCnt + 1;
                        end

                        if (uut.w_rxFifoCount != expectedCount) begin
                                $display(
                                        "FAIL: RX COUNT TIMEOUT data=%02h expected=%0d actual=%0d",
                                        data,
                                        expectedCount,
                                        uut.w_rxFifoCount
                                );

                                $display(
                                        "DEBUG: txBusy=%b rxBusy=%b rxValid=%b uartTx=%b",
                                        uut.w_txBusy,
                                        uut.w_rxBusy,
                                        uut.w_rxValid,
                                        w_uartTx
                                );

                                r_errorCnt = r_errorCnt + 1;
                                r_testAbort = 1'b1;
                        end
                end

                if (!r_testAbort) begin
                        waitCnt = 0;

                        while (uut.w_txBusy &&
                               waitCnt < WAIT_LIMIT) begin
                                @(posedge clk);
                                waitCnt = waitCnt + 1;
                        end

                        if (uut.w_txBusy) begin
                                $display("FAIL: TX END TIMEOUT data=%02h", data);
                                r_errorCnt = r_errorCnt + 1;
                                r_testAbort = 1'b1;
                        end
                end

                repeat (2)
                        @(posedge clk);
        end
endtask


// Overflow Byte Send
task send_overflow_byte;
        input   [7:0]   data;

        integer         waitCnt;

        begin
                waitCnt = 0;

                while (uut.w_txBusy &&
                       waitCnt < WAIT_LIMIT) begin
                        @(posedge clk);
                        waitCnt = waitCnt + 1;
                end

                apb_write(
                        ADDR_TXDATA,
                        {24'd0, data}
                );

                waitCnt = 0;

                while (!uut.w_txBusy &&
                       waitCnt < WAIT_LIMIT) begin
                        @(posedge clk);
                        waitCnt = waitCnt + 1;
                end

                if (!uut.w_txBusy) begin
                        $display("FAIL: OVERFLOW TX START TIMEOUT");
                        r_errorCnt = r_errorCnt + 1;
                        r_testAbort = 1'b1;
                end

                if (!r_testAbort) begin
                        waitCnt = 0;

                        while (uut.w_txBusy &&
                               waitCnt < WAIT_LIMIT) begin
                                @(posedge clk);
                                waitCnt = waitCnt + 1;
                        end

                        if (uut.w_txBusy) begin
                                $display("FAIL: OVERFLOW TX END TIMEOUT");
                                r_errorCnt = r_errorCnt + 1;
                                r_testAbort = 1'b1;
                        end
                end

                repeat (5)
                        @(posedge clk);
        end
endtask


// RX Data Check
task rx_check;
        input   [7:0]   expectedData;

        begin
                apb_read(
                        ADDR_RXDATA,
                        r_readData
                );

                if (r_readData[7:0] !== expectedData) begin
                        $display(
                                "FAIL: RX expected=%02h actual=%02h",
                                expectedData,
                                r_readData[7:0]
                        );

                        r_errorCnt = r_errorCnt + 1;
                end else begin
                        $display("PASS: RX = %02h", r_readData[7:0]);
                end
        end
endtask


// Test
initial begin
        $dumpfile("uart_overflow.vcd");
        $dumpvars(0, tb_uart_overflow);

        $monitor(
                "TIME=%0t TX_BUSY=%b RX_BUSY=%b RX_COUNT=%0d OVERFLOW=%b IRQ=%b",
                $time,
                uut.w_txBusy,
                uut.w_rxBusy,
                uut.w_rxFifoCount,
                uut.w_rxOverflow,
                w_irq
        );

        rst_n       = 1'b0;

        r_psel      = 1'b0;
        r_penable   = 1'b0;
        r_pwrite    = 1'b0;
        r_paddr     = 8'd0;
        r_pwdata    = 32'd0;
        r_uartRx    = 1'b1;

        r_readData  = 32'd0;
        r_testAbort = 1'b0;
        r_errorCnt  = 0;

        repeat (5)
                @(posedge clk);

        rst_n = 1'b1;

        repeat (3)
                @(posedge clk);

        $display("");
        $display("========================================");
        $display(" UART V3 RX OVERFLOW TEST");
        $display("========================================");

        apb_write(ADDR_BAUDDIV, BAUD_DIV);
        apb_write(ADDR_CTRL, CTRL_LOOPBACK);
        apb_write(ADDR_IRQ_EN, 32'h0000_0010);

        check_register(
                ADDR_BAUDDIV,
                {16'd0, BAUD_DIV},
                32'h0000_FFFF
        );

        check_register(
                ADDR_CTRL,
                CTRL_LOOPBACK,
                32'h0000_00FF
        );

        check_register(
                ADDR_IRQ_EN,
                32'h0000_0010,
                32'h0000_001F
        );


        // TEST 1 : FILL RX FIFO
        if (!r_testAbort) begin
                $display("");
                $display("----------------------------------------");
                $display(" TEST 1 : FILL RX FIFO");
                $display("----------------------------------------");

                for (
                        r_index = 0;
                        (r_index < 8) && !r_testAbort;
                        r_index = r_index + 1
                ) begin
                        send_and_wait(
                                8'h40 + r_index,
                                r_index + 1
                        );
                end

                if (!r_testAbort) begin
                        if (uut.w_rxFifoCount !== 5'd8) begin
                                $display(
                                        "FAIL: RX FIFO COUNT = %0d",
                                        uut.w_rxFifoCount
                                );

                                r_errorCnt = r_errorCnt + 1;
                        end else begin
                                $display("PASS: RX FIFO COUNT = 8");
                        end

                        if (!uut.w_rxFifoFull) begin
                                $display("FAIL: RX FIFO FULL = 0");
                                r_errorCnt = r_errorCnt + 1;
                        end else begin
                                $display("PASS: RX FIFO FULL = 1");
                        end
                end
        end


        // TEST 2 : RX OVERFLOW
        if (!r_testAbort) begin
                $display("");
                $display("----------------------------------------");
                $display(" TEST 2 : RX OVERFLOW");
                $display("----------------------------------------");

                send_overflow_byte(8'hAA);

                if (uut.w_rxFifoCount !== 5'd8) begin
                        $display(
                                "FAIL: OVERFLOW changed FIFO COUNT = %0d",
                                uut.w_rxFifoCount
                        );

                        r_errorCnt = r_errorCnt + 1;
                end else begin
                        $display("PASS: NEW BYTE DROPPED");
                end

                if (r_overflowPulseSeen !== 1'b1) begin
                        $display("FAIL: RX OVERFLOW EVENT PULSE = 0");
                        r_errorCnt = r_errorCnt + 1;
                end else begin
                        $display("PASS: RX OVERFLOW EVENT PULSE = 1");
                end

                if (uut.w_irqStatus[4] !== 1'b1) begin
                        $display("FAIL: OVERFLOW STICKY INTERNAL = 0");
                        r_errorCnt = r_errorCnt + 1;
                end else begin
                        $display("PASS: OVERFLOW STICKY INTERNAL = 1");
                end

                apb_read(ADDR_IRQ_STATUS, r_readData);

                if (r_readData[4] !== 1'b1) begin
                        $display("FAIL: OVERFLOW IRQ STATUS = 0");
                        r_errorCnt = r_errorCnt + 1;
                end else begin
                        $display("PASS: OVERFLOW IRQ STATUS = 1");
                end

                if (w_irq !== 1'b1) begin
                        $display("FAIL: OVERFLOW IRQ = 0");
                        r_errorCnt = r_errorCnt + 1;
                end else begin
                        $display("PASS: OVERFLOW IRQ = 1");
                end

                apb_read(ADDR_STATUS, r_readData);

                if (r_readData[8] !== 1'b1) begin
                        $display("FAIL: STATUS OVERFLOW = 0");
                        r_errorCnt = r_errorCnt + 1;
                end else begin
                        $display("PASS: STATUS OVERFLOW = 1");
                end
        end


        // TEST 3 : OLD DATA PRESERVED
        if (!r_testAbort) begin
                $display("");
                $display("----------------------------------------");
                $display(" TEST 3 : OLD DATA PRESERVED");
                $display("----------------------------------------");

                for (
                        r_index = 0;
                        r_index < 8;
                        r_index = r_index + 1
                ) begin
                        rx_check(8'h40 + r_index);
                end

                if (uut.w_rxFifoCount !== 5'd0) begin
                        $display(
                                "FAIL: RX FIFO COUNT = %0d",
                                uut.w_rxFifoCount
                        );

                        r_errorCnt = r_errorCnt + 1;
                end else begin
                        $display("PASS: ORIGINAL 8 BYTES PRESERVED");
                end

                if (w_irq !== 1'b1) begin
                        $display("FAIL: OVERFLOW IRQ NOT STICKY");
                        r_errorCnt = r_errorCnt + 1;
                end else begin
                        $display("PASS: OVERFLOW IRQ STICKY");
                end
        end


        // TEST 4 : OVERFLOW IRQ CLEAR
        if (!r_testAbort) begin
                $display("");
                $display("----------------------------------------");
                $display(" TEST 4 : OVERFLOW IRQ CLEAR");
                $display("----------------------------------------");

                apb_write(
                        ADDR_IRQ_STATUS,
                        32'h0000_0010
                );

                repeat (3)
                        @(posedge clk);

                apb_read(ADDR_IRQ_STATUS, r_readData);

                if (r_readData[4] !== 1'b0) begin
                        $display("FAIL: OVERFLOW CLEAR");
                        r_errorCnt = r_errorCnt + 1;
                end else begin
                        $display("PASS: OVERFLOW STATUS CLEAR");
                end

                if (w_irq !== 1'b0) begin
                        $display("FAIL: IRQ AFTER CLEAR = 1");
                        r_errorCnt = r_errorCnt + 1;
                end else begin
                        $display("PASS: IRQ AFTER CLEAR = 0");
                end
        end


        // RESULT
        if (r_testAbort) begin
                $display("");
                $display("========================================");
                $display(" UART V3 RX OVERFLOW: TEST ABORT");
                $display("========================================");
                $display("");
        end else if (r_errorCnt == 0) begin
                $display("");
                $display("========================================");
                $display(" UART V3 RX OVERFLOW: ALL PASS");
                $display("========================================");
                $display("");
        end else begin
                $display("");
                $display("========================================");
                $display(
                        " UART V3 RX OVERFLOW: %0d ERROR(S)",
                        r_errorCnt
                );
                $display("========================================");
                $display("");
        end

        #100;
        $finish;
end


// Timeout
initial begin
        #100000000;

        $display("");
        $display("========================================");
        $display(" UART V3 RX OVERFLOW: TIMEOUT");
        $display("========================================");
        $display("");

        $finish;
end

endmodule
