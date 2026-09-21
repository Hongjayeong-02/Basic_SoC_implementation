`timescale 1ns/1ps

module uart_fifo #(
        parameter FIFO_DEPTH = 8
)(
        input   wire            clk,
        input   wire            rst_n,

        input   wire            i_wrEn,
        input   wire    [7:0]   i_wrData,

        input   wire            i_rdEn,
        output  reg     [7:0]   o_rdData,

        output  wire            o_full,
        output  wire            o_empty,
        output  wire    [4:0]   o_count
);


localparam PTR_WIDTH = $clog2(FIFO_DEPTH);


reg     [7:0]   r_mem [0:FIFO_DEPTH-1];

reg     [PTR_WIDTH-1:0] r_wrPtr;
reg     [PTR_WIDTH-1:0] r_rdPtr;

reg     [4:0]   r_count;


wire            w_wrEn;
wire            w_rdEn;


assign o_full  = (r_count == FIFO_DEPTH);
assign o_empty = (r_count == 0);
assign o_count = r_count;


assign w_wrEn = i_wrEn &&
                !o_full;

assign w_rdEn = i_rdEn &&
                !o_empty;


always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin

                r_wrPtr   <= 0;
                r_rdPtr   <= 0;
                r_count   <= 0;

                o_rdData  <= 8'd0;

        end else begin

                case ({
                        w_wrEn,
                        w_rdEn
                })

                        // Write
                        2'b10: begin

                                r_mem[r_wrPtr] <= i_wrData;

                                if (r_wrPtr == FIFO_DEPTH - 1)
                                        r_wrPtr <= 0;
                                else
                                        r_wrPtr <= r_wrPtr + 1'b1;

                                r_count <= r_count + 1'b1;

                        end


                        // Read
                        2'b01: begin

                                o_rdData <= r_mem[r_rdPtr];

                                if (r_rdPtr == FIFO_DEPTH - 1)
                                        r_rdPtr <= 0;
                                else
                                        r_rdPtr <= r_rdPtr + 1'b1;

                                r_count <= r_count - 1'b1;

                        end


                        // Read + Write
                        2'b11: begin

                                r_mem[r_wrPtr] <= i_wrData;

                                o_rdData <= r_mem[r_rdPtr];


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
