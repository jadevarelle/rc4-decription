module loop3(
input logic clk,
input logic reset_n,
input logic start,
input logic [7:0]RAMdata_s,
input logic [7:0]RAMdata_e,
output logic [7:0]data_out_s,
output logic [7:0]address_out_s,
output logic [7:0]address_out_e,
output logic [7:0]data_out_d,
output logic [7:0]address_out_d,
output logic wren_s,
output logic wren_d,
output logic done,
output logic [7:0]k,


output logic [7:0] decrypt_out,
output logic byte_ready,

input	logic valid_byte);

	logic [7:0]i;
	logic [7:0]j;
	//logic [7:0]k;
	logic [7:0]f;
	logic [7:0]s_i;
	logic [7:0]s_j;
	logic [7:0]s_f;
	logic [7:0]e_k;
	//logic [7:0]decrypt_out;
	
	logic [8:0]state;
	logic [2:0]key_i;

	
	assign wren_s 			= state[0];
	assign wren_d 			= state[6];
	assign done   			= state[8];
	assign byte_ready 	= state[7]; 
	
	                                    //87654321_0
	parameter idle                   = 9'b0_0_0_00000_0;
	parameter increment_i            = 9'b0_0_0_00001_0;
	parameter wait_i 						= 9'b0_0_0_00010_0;
	parameter get_s_i1               = 9'b0_0_0_00011_0;
	parameter wait1                  = 9'b0_0_0_00100_0;
	parameter get_s_i2               = 9'b0_0_0_00101_0;
	parameter calc_j                 = 9'b0_0_0_00110_0;
	parameter wait_wtf					= 9'b0_0_0_00111_0; 
	parameter get_s_j1               = 9'b0_0_0_01000_0;
	parameter wait2                  = 9'b0_0_0_01001_0;
	parameter get_s_j2               = 9'b0_0_0_01010_0;
	parameter write_en_i             = 9'b0_0_0_01011_1;
	parameter swap1                  = 9'b0_0_0_01100_1;
	parameter swap2                  = 9'b0_0_0_01101_1;
	parameter swap3                  = 9'b0_0_0_01110_1;
	parameter swerve                 = 9'b0_0_0_01111_1;
	parameter swap4                  = 9'b0_0_0_10000_1;
	parameter swap5                  = 9'b0_0_0_10001_1;
	parameter calc_f                 = 9'b0_0_0_10010_1;
	parameter wait_1		 				= 9'b0_0_0_10011_1;
	parameter get_s_f1               = 9'b0_0_0_10100_0;
	parameter wait3                  = 9'b0_0_0_10101_0;
	parameter get_s_f2               = 9'b0_0_0_10110_0;
	parameter get_e_k1               = 9'b0_0_0_10111_0;
	parameter wait4                  = 9'b0_0_0_11000_0;
	parameter get_e_k2               = 9'b0_0_0_11001_0;
	parameter calc_decrypt_out       = 9'b0_0_0_11010_0; 
	parameter wren_d_high				= 9'b0_0_0_11011_0; 
	parameter store_decrypt_out1     = 9'b0_1_1_11100_0; //set byte ready to 1
	parameter store_decrypt_out2     = 9'b0_0_1_11101_0;
	parameter increment_k            = 9'b0_0_1_11110_0;
	parameter chill                  = 9'b1_0_0_11111_0;
	                                    //87654321_0
	always_ff @(posedge clk) begin
		//if (reset_n) 	//  reset_n is active low? 
		//	state <= idle;
		case(state)
			idle: if (start) state <= increment_i;
					else begin 
						state <= idle;
						i <= 8'b00000000;
						j <= 8'b00000000;
						k <= 8'b00000000;
						f <= 8'b00000000;
					end
			increment_i: 
				begin
					state <= wait_i;
					i <= i+1; 
				end
			wait_i:
				begin 
					state <= get_s_i1; 
				end 
			get_s_i1: 
				begin//Turn off wren, set address i
					address_out_s <= i;
					state <= wait1; 
				end
			wait1: 
				begin//wait for address to latch
					state <= get_s_i2;
				end
			get_s_i2: 
				begin//store s[i]
					s_i <= RAMdata_s; 
					state <= calc_j;
				end
			calc_j: 
				begin//calculate j
						j <= j + s_i;	 					
						state <= wait_wtf;
				end
			wait_wtf: 
					begin 
						state <= get_s_j1; 
					end 
			get_s_j1: 
				begin//Turn off wren, set address j
					address_out_s <= j; 
					state <= wait2;
				end
			wait2: 
				begin //wait for address to latch
					state <= get_s_j2;
				end
			get_s_j2: 
				begin //store s[j]
					s_j <= RAMdata_s;   
					state <= write_en_i;
				end
			write_en_i:
				begin //enable write data earlier 
					state <= swap1;
				end 
			//SWAP
			
			swap1:
				begin
					data_out_s <= s_i;  
					state <=swap5;
				end
			swap5:
				begin
					state <= swap2;
				end
			swap2:
				begin
					address_out_s <= i;  
					state <= swerve;
				end
			swerve: 
				begin
					state <= swap3;
				end
			swap3:
				begin
					data_out_s <= s_j;  
					state <= swap4;
				end
			swap4:
				begin
					state <= calc_f;
				end
			calc_f:
				begin
					f <= s_i + s_j;  
					state <= wait_1;
				end
			wait_1: begin 
					state <= get_s_f1; 
				end
			get_s_f1:
				begin//Turn off wren, set address i
					address_out_s <= f;  
					state <= wait3; 
				end
			wait3: 
				begin//wait for address to latch
					state <= get_s_f2;
				end
			get_s_f2:
				begin
					s_f <= RAMdata_s; 
					state <= get_e_k1;
				end
			get_e_k1: 
				begin//store s[i]
					address_out_e <= k[4:0];
					state <= wait4;
				end
			wait4:
				begin
					state <= get_e_k2;
				end
			get_e_k2: 
				begin//Turn off wren, set address i
					e_k <= RAMdata_e; 
					state <= calc_decrypt_out;
				end
			calc_decrypt_out:  
				begin
					decrypt_out <= s_f ^ e_k;
					address_out_d <= k[4:0];
					state <= wren_d_high;
				end
			wren_d_high:
				begin 
					state <= store_decrypt_out1;
				end
			store_decrypt_out1: // BYTE READY STATE --problemo: stuck in this state!!! 
				begin
					data_out_d <= decrypt_out;
					//data_out_d <= k;
					if (valid_byte) state <= store_decrypt_out2;
					else state <= store_decrypt_out1; 
				end
			store_decrypt_out2:
				begin
					state<= increment_k;
				end	
			increment_k:
				begin
					if (k < 31) begin
						k <= k + 1;
						state <= increment_i;
					end
					else state <= chill;
				end
			chill: state <= chill;
			default: state <= idle;
		endcase	
	end 
endmodule	