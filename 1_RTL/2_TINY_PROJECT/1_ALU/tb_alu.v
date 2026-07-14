`timescale 1ns/1ps

module tb_alu();

reg [7:0] i_a;
reg [7:0] i_b;
reg [2:0] i_op;

wire [7:0] o_result;

alu uut (
	.i_a(i_a),
	.i_b(i_b),
	.i_op(i_op),
	.o_result(o_result)
);

initial begin
	$dumpfile("./alu.vcd");
	$dumpvars(0, uut);
end 


initial begin
	// ADD
	i_a = 8'd10;
	i_b = 8'd5;
	i_op = 3'b000;
	#10;

	// SUB
	i_a = 8'd20;
	i_b = 8'd7;
	i_op = 3'b001;
	#10;

	// AND
	i_a = 8'b10101010;
	i_b = 8'b11001100;
	i_op = 3'b010;
	#10;

	// OR
	i_a = 8'b10101010;
	i_b = 8'b11001100;
	i_op = 3'b011;
	#10;

	// XOR 
	i_a = 8'b10101010;
	i_b = 8'b11001100;
	i_op = 3'b100;
	#10;

	// NOT
	i_a = 8'b10101010;
	i_op = 3'b101;
	#10;

	// Shift Left
	i_a = 8'b00001111;
	i_op = 3'b110;
	#10;

	// Shift Right
	i_a = 8'b00001111;
	i_op = 3'b111;
	#10;

	$finish;
end

endmodule	
