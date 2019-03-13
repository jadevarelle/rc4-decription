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
	assign reset_n = (KEY[3] & ~get_new_key); // reset if get_new_key = 1 OR external input 
	
	
	logic[7:0] address_s;
	logic[7:0] loop1_out; 
	logic[7:0] loop2_out; 
	logic[7:0] address_out_2;
   logic[7:0] address_e;
	logic[7:0] address_s3;
	logic[7:0] address_out_d;	
	logic[7:0] RAM_data_s;
	logic[7:0] RAM_data_d;	
	logic[7:0] output_data_s;
	logic[7:0] output_data_e;
	logic[7:0] output_data_d;
   logic[7:0] loop3_out_s;
   logic[7:0] loop3_out_d;	
	logic loop2_wren, loop1_wren, wren, loop3_wren_s, wren_d;
	logic loop2_done, loop3_done;
	logic[7:0] i_out ;
	logic[7:0] k;
	
	logic[7:0] decrypted_byte; 
	logic start_task3, byte_valid, get_new_key; 
	
//	parameter secret_key = 24'b00000000_00000010_01001001;
	logic [23:0] secret_key ; 
	/*
		.clk(clk),
	.reset_n(reset_n),
	.start(loop2_done),
	.RAMdata_s(output_data_s),
	.RAMdata_e(output_data_e),
	.data_out_s(loop3_out_s),
	.address_out_s(address_s3),
	.address_out_e(address_e),
	.data_out_d(loop3_out_d),
	.address_out_d(address_out_d),
	.wren(loop3_wren_s),
	.wren(loop3_wren_d),
	.done(loop3_done)
	);*/
	
	assign LEDR[0] = wren;
	assign LEDR[1] = init_array_full;
	assign LEDR[2] = loop2_done;
	assign LEDR[5] = loop3_done;
	assign LEDR[9] = start_task3; 
	assign LEDR[7] = byte_valid; 
	assign LEDR[6] = get_new_key; 
// clk divide
generate_clk clkddd(
	.in_clk(clk),
	.div_clk_count(32'h17D7840),
	.out_clk(clk_1hz),
	.reset(reset_n))
	; 
//----- instantiate hex display----//	
SevenSegmentDisplayDecoder seven_seg_1( 
	.nIn(secret_key[3:0]), 
	.ssOut(HEX0)); 
	
SevenSegmentDisplayDecoder seven_seg_2( 
	.nIn(secret_key[7:4]), 
	.ssOut(HEX1)); 

SevenSegmentDisplayDecoder seven_seg_3( 
	.nIn(secret_key[11:8]), 
	.ssOut(HEX2)); 
	
SevenSegmentDisplayDecoder seven_seg_4( 
	.nIn(secret_key[15:12]), 
	.ssOut(HEX3)); 
	
SevenSegmentDisplayDecoder seven_seg_5( 
	.nIn(k[3:0]), 
	.ssOut(HEX4)); 
	
SevenSegmentDisplayDecoder seven_seg_6( 
	.nIn(k[7:4]), 
	.ssOut(HEX5)); 
	
//----- instantiate memory module -----//
s_memory mem_inst_s(
	.address(address_s), 
	.clock(clk),
	.data(RAM_data_s), 
	.wren(wren),
	.q(output_data_s) ); 

d_memory mem_inst_d(
	.address(address_out_d), 
	.clock(clk),
	.data(loop3_out_d), 
	.wren(wren_d),
	.q(output_data_d) ); 
	
e_memory mem_inst_e(
	.address(address_e), 
	.clock(clk),
	.q(output_data_e) ); 
	
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
	//.start(1'b0),
	.RAMdata(output_data_s),
	.secret_key(secret_key),
	.data_out(loop2_out),
	.address_out(address_out_2),
	.wren(loop2_wren),
	.done(loop2_done)
	);

loop3 loop3_inst(
	.clk(clk),
	.reset_n(reset_n),
	.start(loop2_done),
	.RAMdata_s(output_data_s),
	.RAMdata_e(output_data_e),
	.data_out_s(loop3_out_s),
	.address_out_s(address_s3),
	.address_out_e(address_e),
	.data_out_d(loop3_out_d),
	.address_out_d(address_out_d),
	.wren_s(loop3_wren_s),
	.wren_d(wren_d),
	.done(loop3_done),
	.k(k),
	.decrypt_out(decypted_byte),
	.byte_ready(start_task3),
	.valid_byte(byte_valid)
	);
	
generate_key get_key(
	.new_key(get_new_key), 
	.reset(KEY[3]),
	.clk(clk), 
	.secret_key(secret_key_out),
	.done(LEDR[8])); 
	
	
task3 wtf_lol(
	.clk(clk), 
	.secret_key(secret_key_out),
	.decrypted_byte(decrypted_byte),
	.start(start_task3),
	.byte_valid(byte_valid),
	.new_key(get_new_key)); 

always_comb begin 
if (loop2_done) begin 
		RAM_data_s = loop3_out_s; 
		address_s = address_s3; 
		wren = loop3_wren_s ;
		end 
else if (init_array_full) begin 
		RAM_data_s = loop2_out ; 
		address_s = address_out_2; 
		wren = loop2_wren ; 
		end 
else begin 
		RAM_data_s = loop1_out; 
		address_s = loop1_out;
		wren = loop1_wren; 
		end
end 

/*
always_comb begin 
RAM_data_s = loop2_done ? (loop3_out_s) : (init_array_full ? (loop2_out) : (loop1_out)); 
address_s = loop2_done ? (address_s3) : (init_array_full ? address_out_2 : loop1_out); 
wren = loop2_done ? (loop3_wren_s) : (init_array_full ? loop2_wren : loop1_wren); 
end */
endmodule 