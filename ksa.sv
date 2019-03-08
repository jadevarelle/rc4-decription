module ksa( 
	input	CLK_50M, 
	input[3:0]	KEY,                 
   input[9:0]	SW,                
   output[9:0]	LEDR, 
   output[6:0]	HEX0, 
   output[6:0]	HEX1, 
	output[6:0]	HEX2, 
	output[6:0]	HEX3, 
	output[6:0]	HEX4, 
	output[6:0]	HEX5); //inputs/outputs taken from ksa.vhd 

	
	logic clk; 
	logic reset_n;
	logic init_array_full;
	logic [6:0] ssOut; 
	logic [3:0] nIn; 
	
	
	assign clk = CLK_50M; 
	assign reset_n = KEY[3]; 
	
	
	logic[7:0] address_counter;
	logic[7:0] loop1_out; // use in for loop in task 1 
	logic[7:0] loop2_out; // use in for loop in task 1 
	logic[7:0] address_out; // use in for loop in task 1 
	logic[7:0] RAM_data; // use in for loop in task 1 
	logic[7:0] output_data; //not using this atm, output from s_memory module 
	logic loop2_wren, loop1_wren, wren;
	logic[7:0] i_out ; 
	parameter secret_key = 24'b00000000_00000010_01001001;
	
	assign LEDR[0] = wren;
	assign LEDR[1] = init_array_full;
	
// clk divide
generate_clk clkddd(
	.in_clk(clk),
	.div_clk_count(32'h17D7840),
	.out_clk(clk_1hz),
	.reset(reset_n))
	; 
//----- instantiate hex display----//	
SevenSegmentDisplayDecoder seven_seg_1( 
	.nIn(output_data[3:0]), 
	.ssOut(HEX0)); 
	
SevenSegmentDisplayDecoder seven_seg_2( 
	.nIn(output_data[7:4]), 
	.ssOut(HEX1)); 
	
SevenSegmentDisplayDecoder seven_seg_3( 
	.nIn(i_out[3:0]), 
	.ssOut(HEX4)); 
	
SevenSegmentDisplayDecoder seven_seg_4( 
	.nIn(i_out[7:4]), 
	.ssOut(HEX5)); 
//----- instantiate memory module -----//
s_memory mem_inst(
	.address(address_counter), 
	.clock(clk),
	.data(RAM_data), 
	.wren(wren),
	.q(output_data) ); 
	
init_array loop1(
	.clk(clk),
	.reset_n(reset_n),
	.counter(loop1_out),
	.done(init_array_full),
	.wren(loop1_wren));

loop2 loop2_inst(
	.clk(clk),
	.clk_1hz(clk_1hz),
	.reset_n(reset_n),
	.start(init_array_full),
	.RAMdata(output_data),
	.secret_key(secret_key),
	.data_out(loop2_out),
	.address_out(address_out),
	.wren(loop2_wren),
	.i(i_out)
	);
/*
always @(posedge clk) begin
	if (!init_array_full) begin
		RAM_data <= loop1_out;
		address_counter <= loop1_out;
		wren <= loop1_wren;
	end
	else begin
		RAM_data <= loop2_out;
		address_counter <= address_out;
		wren <= loop2_wren;
	end
end */
always_comb begin 
RAM_data = init_array_full ? (loop2_out) : (loop1_out); 
address_counter = init_array_full ? address_out : loop1_out; 
wren = init_array_full ? loop2_wren : loop1_wren; 
end 
endmodule 