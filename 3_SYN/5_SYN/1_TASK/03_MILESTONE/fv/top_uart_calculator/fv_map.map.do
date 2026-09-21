
//input ports
add mapped point i_clk i_clk -type PI PI
add mapped point i_rst_n i_rst_n -type PI PI
add mapped point i_rx i_rx -type PI PI

//output ports
add mapped point o_tx o_tx -type PO PO

//inout ports




//Sequential Pins



//Black Boxes
add mapped point u_alu_8 u_alu_8 -type BBOX BBOX
add mapped point u_baud_gen u_baud_gen -type BBOX BBOX
add mapped point u_calculator u_calculator -type BBOX BBOX
add mapped point u_encoder u_encoder -type BBOX BBOX
add mapped point u_uart_rx_9600 u_uart_rx_9600 -type BBOX BBOX
add mapped point u_uart_tx_9600 u_uart_tx_9600 -type BBOX BBOX



//Empty Modules as Blackboxes
