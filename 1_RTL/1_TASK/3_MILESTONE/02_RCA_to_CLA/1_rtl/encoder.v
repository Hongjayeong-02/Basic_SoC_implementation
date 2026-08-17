`timescale 1ns/1ps

module  encoder (
	i_result	,
	i_valid		,
	o_data		,
	o_valid
);


input		[7:0]	i_result;
input			i_valid	;

output reg 	[7:0] 	o_data	;
output reg	 	o_valid	;


always @(*) begin

	o_data  = 8'h00;
	o_valid = 1'b0;

	if (i_valid) begin

		// 0 ~ 9
		if (i_result <= 8'd9) begin
			o_data  = i_result + 8'h30;
			o_valid = 1'b1;
		end

	end

end


endmodule
