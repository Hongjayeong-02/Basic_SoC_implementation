`timescale 1ns/1ps

module tb_FSM();

reg clk;
reg rst_n;
reg din_bit;

wire dout_bit;

FSM DUT (
	.clk(clk),
	.rst_n(rst_n),
	.din_bit(din_bit),
	.dout_bit(dout_bit)
);

always #5 clk = ~clk;

initial begin
	clk = 1'b0; rst_n = 1'b0; din_bit = 1'b0;

	#100 rst_n = 1'b0;
	
	#10 din_bit = 1'b0;
	#10 din_bit = 1'b0;
	#10 din_bit = 1'b1;
	#10 din_bit = 1'b1;
	#10 din_bit = 1'b1;
	#10 din_bit = 1'b0;
	#10 din_bit = 1'b0;
	#10 din_bit = 1'b0;
	#10 din_bit = 1'b0;
	#10 din_bit = 1'b1;
	#10 din_bit = 1'b1;
	#10 din_bit = 1'b1;
	#10 din_bit = 1'b1;
	#10 din_bit = 1'b1;
	#10 din_bit = 1'b0;
	#100 rst_n = 1'b0;
	#2000; $finish;
end

endmodule
