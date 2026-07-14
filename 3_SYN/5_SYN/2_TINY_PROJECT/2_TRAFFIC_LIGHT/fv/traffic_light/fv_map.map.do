
//input ports
add mapped point clk clk -type PI PI
add mapped point rst_n rst_n -type PI PI

//output ports
add mapped point o_red o_red -type PO PO
add mapped point o_yellow o_yellow -type PO PO
add mapped point o_green o_green -type PO PO

//inout ports




//Sequential Pins
add mapped point r_state[0]/q r_state_reg[0]/Q -type DFF DFF
add mapped point r_state[1]/q r_state_reg[1]/Q -type DFF DFF
add mapped point r_cnt[1]/q r_cnt_reg[1]/Q -type DFF DFF
add mapped point r_cnt[0]/q r_cnt_reg[0]/Q -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
