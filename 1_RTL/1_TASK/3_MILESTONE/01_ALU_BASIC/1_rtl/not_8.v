`timescale 1ns/1ps

module not_8 (
	i_a	,
	o_not
);


input  [7:0]  i_a   ;

output [7:0]  o_not ;


assign o_not = ~i_a;


endmodule
