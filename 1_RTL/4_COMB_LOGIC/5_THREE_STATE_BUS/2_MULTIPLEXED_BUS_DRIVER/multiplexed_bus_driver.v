`timescale 1ns/1ps

module multiplexed_bus_driver(

	i_dataA		,
	i_dataB		,
	i_enA		,
	i_enB		,

	o_busData
);


input 		[31:0] i_dataA	;
input 		[31:0] i_dataB	;
input		       i_enA	;
input	               i_enB	;

output reg	[31:0] o_busData;

always @(*) begin
	case({i_enA, i_enB})

		2'b00: o_busData = 32'bz	;

		2'b10: o_busData = i_dataA	;

		2'b01: o_busData = i_dataB	;

		2'b11: o_busData = i_dataA	;

		default: o_busData = 32'bz	;
	endcase
end
endmodule
