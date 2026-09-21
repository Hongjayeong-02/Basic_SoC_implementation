`timescale 1ns/1ps

module tb_uart_apb_rxmeta;


localparam ADDR_RXDATA      = 8'h04;
localparam ADDR_STATUS      = 8'h08;
localparam ADDR_CTRL        = 8'h0C;
localparam ADDR_BAUDDIV     = 8'h10;
localparam ADDR_FIFO_LEVEL  = 8'h1C;


// UART_EN + RX_EN + EVEN PARITY
localparam CTRL_8E1_RX      = 32'h0000_000D;

localparam BAUD_DIV         = 16'd8;


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

integer         r_errorCnt;


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


// 48 MHz
always #10.41667 clk = ~clk;


// APB Write
task apb_write;

        input [7:0]  addr;
        input [31:0] data;

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

                        $display(
                                "FAIL: APB WRITE addr=%02h",
                                addr
                        );

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

                        $display(
                                "FAIL: APB READ addr=%02h",
                                addr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                @(negedge clk);

                r_psel    = 1'b0;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;

        end

endtask


// UART Frame
task send_frame;

        input   [7:0]   data;
        input           badParity;
        input           badStop;

        integer         bitIndex;

        reg             parityBit;

        begin

                parityBit = ^data;


                if (badParity)
                        parityBit = ~parityBit;


                // Idle
                r_uartRx = 1'b1;

                repeat (3)
                        @(posedge
                                uut.uut_uart_core.w_tick16
                        );


                // Start
                @(negedge
                        uut.uut_uart_core.w_tick16
                );

                r_uartRx = 1'b0;


                repeat (16)
                        @(posedge
                                uut.uut_uart_core.w_tick16
                        );


                // Data
                for (
                        bitIndex = 0;
                        bitIndex < 8;
                        bitIndex = bitIndex + 1
                ) begin

                        @(negedge
                                uut.uut_uart_core.w_tick16
                        );

                        r_uartRx = data[bitIndex];


                        repeat (16)
                                @(posedge
                                        uut.uut_uart_core.w_tick16
                                );

                end


                // Even Parity
                @(negedge
                        uut.uut_uart_core.w_tick16
                );

                r_uartRx = parityBit;


                repeat (16)
                        @(posedge
                                uut.uut_uart_core.w_tick16
                        );


                // Stop
                @(negedge
                        uut.uut_uart_core.w_tick16
                );


                if (badStop)
                        r_uartRx = 1'b0;
                else
                        r_uartRx = 1'b1;


                repeat (16)
                        @(posedge
                                uut.uut_uart_core.w_tick16
                        );


                // Idle
                @(negedge
                        uut.uut_uart_core.w_tick16
                );

                r_uartRx = 1'b1;


                repeat (4)
                        @(posedge
                                uut.uut_uart_core.w_tick16
                        );

        end

endtask


// RX Entry Check
task rx_entry_check;

        input   [7:0]   expectedData;
        input           expectedParity;
        input           expectedFrame;

        begin

                apb_read(
                        ADDR_RXDATA,
                        r_readData
                );


                if (
                        r_readData[7:0] !==
                        expectedData
                ) begin

                        $display(
                                "FAIL: DATA expected=%02h actual=%02h",
                                expectedData,
                                r_readData[7:0]
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: DATA = %02h",
                                r_readData[7:0]
                        );

                end


                if (
                        r_readData[8] !==
                        expectedParity
                ) begin

                        $display(
                                "FAIL: PARITY expected=%b actual=%b",
                                expectedParity,
                                r_readData[8]
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: PARITY ERROR = %b",
                                r_readData[8]
                        );

                end


                if (
                        r_readData[9] !==
                        expectedFrame
                ) begin

                        $display(
                                "FAIL: FRAME expected=%b actual=%b",
                                expectedFrame,
                                r_readData[9]
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: FRAME ERROR = %b",
                                r_readData[9]
                        );

                end

        end

endtask


initial begin

        $dumpfile("uart_apb_rxmeta.vcd");
        $dumpvars(0, tb_uart_apb_rxmeta);


        clk         = 1'b0;
        rst_n       = 1'b0;

        r_psel      = 1'b0;
        r_penable   = 1'b0;
        r_pwrite    = 1'b0;

        r_paddr     = 8'd0;
        r_pwdata    = 32'd0;

        r_uartRx    = 1'b1;

        r_readData  = 32'd0;

        r_errorCnt  = 0;


        // Reset
        repeat (5)
                @(posedge clk);

        rst_n = 1'b1;

        repeat (3)
                @(posedge clk);


        $display("");
        $display("========================================");
        $display(" UART V3 APB RX METADATA TEST");
        $display("========================================");


        // Baud
        apb_write(
                ADDR_BAUDDIV,
                BAUD_DIV
        );


        // UART + RX + EVEN
        apb_write(
                ADDR_CTRL,
                CTRL_8E1_RX
        );


        // =================================================
        // TEST 1 : NORMAL
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 1 : NORMAL RX DATA");
        $display("----------------------------------------");


        send_frame(
                8'h5A,
                1'b0,
                1'b0
        );


        wait (
                uut.w_rxFifoCount == 5'd1
        );


        $display(
                "PASS: RX FIFO COUNT = 1"
        );


        // =================================================
        // TEST 2 : PARITY ERROR
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : PARITY ERROR");
        $display("----------------------------------------");


        send_frame(
                8'hA5,
                1'b1,
                1'b0
        );


        wait (
                uut.w_rxFifoCount == 5'd2
        );


        $display(
                "PASS: RX FIFO COUNT = 2"
        );


        // =================================================
        // TEST 3 : FRAME ERROR
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 3 : FRAME ERROR");
        $display("----------------------------------------");


        send_frame(
                8'h3C,
                1'b0,
                1'b1
        );


        wait (
                uut.w_rxFifoCount == 5'd3
        );


        r_uartRx = 1'b1;


        $display(
                "PASS: RX FIFO COUNT = 3"
        );


        // =================================================
        // TEST 4 : APB RXDATA
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 4 : RXDATA + ERROR BITS");
        $display("----------------------------------------");


        // Normal
        rx_entry_check(
                8'h5A,
                1'b0,
                1'b0
        );


        // Parity Error
        rx_entry_check(
                8'hA5,
                1'b1,
                1'b0
        );


        // Frame Error
        rx_entry_check(
                8'h3C,
                1'b0,
                1'b1
        );


        repeat (3)
                @(posedge clk);


        // =================================================
        // TEST 5 : FINAL STATUS
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 5 : FINAL STATUS");
        $display("----------------------------------------");


        apb_read(
                ADDR_FIFO_LEVEL,
                r_readData
        );


        if (
                r_readData[15:8] !==
                8'd0
        ) begin

                $display(
                        "FAIL: RX FIFO COUNT = %0d",
                        r_readData[15:8]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO COUNT = 0"
                );

        end


        apb_read(
                ADDR_STATUS,
                r_readData
        );


        if (r_readData[2] !== 1'b1) begin

                $display(
                        "FAIL: RX FIFO EMPTY = 0"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO EMPTY = 1"
                );

        end


        // =================================================
        // RESULT
        // =================================================
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART V3 APB RX METADATA: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART V3 APB RX METADATA: %0d ERROR(S)",
                        r_errorCnt
                );
                $display("========================================");
                $display("");

        end


        #100;

        $finish;

end


initial begin

        #50000000;

        $display("");
        $display("========================================");
        $display(" UART V3 APB RX METADATA: TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end


endmodule
