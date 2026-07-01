`timescale 1ns/1ps

module tb_pipeline();

reg clk;
reg rst_n;
reg state;
reg [9:0] in1;
reg [9:0] in2;
reg [9:0] in3;

wire [11:0] out;

pipeline uut (
    .clk(clk),
    .rst_n(rst_n),
    .in1(in1),
    .in2(in2),
    .in3(in3),
    .state(state),
    .out(out)
);

always begin
    #5 clk = ~clk;
end

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    state = 1'b0;

    in1 = 10'd0;
    in2 = 10'd0;
    in3 = 10'd0;

    #10
    rst_n = 1'b0;

    in1 = 10'd10;
    in2 = 10'd20;
    in3 = 10'd30;
   
    #20

    in1 = 10'd100;
    in2 = 10'd200;
    in3 = 10'd300;
   
    #10

    in1 = 10'd1023;
    in2 = 10'd1023;
    in3 = 10'd1023;
   
    #100
    $finish;

end

initial begin
    $dumpfile("./pipeline.vcd");
    $dumpvars(1, uut);
end


endmodule
