`timescale 1ns/1ps

module comparator(

	i_a,
	i_b, 

	o_gt,
	o_eq, 
	o_it

);

input [31:0] i_a;
input [31:0] i_b;

output reg 	o_gt; 
output reg	o_eq;
output reg	o_it;

integer i;

always @(*) begin
	o_gt = 1'b0;
	o_eq = 1'b1;
	o_it = 1'b0;
	
	for(i=31; i>=0; i=i-1) begin

		if(i_a[i] != i_b[i]) begin

			o_eq = 1'b0;

			if(i_a[i] > i_b[i])
				o_gt = 1'b1;
			else
				o_it = 1'b1;
			i = -1;
		end
	end
end

endmodule
