module loop2(
input logic clk,
input logic clk_1hz,
input logic reset_n,
input logic start,
input logic [7:0]RAMdata,
input logic [23:0]secret_key,
output logic [7:0]data_out,
output logic [7:0]address_out,
output logic wren,
output logic done);
	
 	logic [7:0]i;
	logic [7:0]j;
	logic [7:0]s_i;
	logic [7:0]s_j;
	
	logic [8:0]state;
	logic [2:0]key_i;
	logic [7:0]secret_key_array [2:0];
	assign secret_key_array[0] = secret_key[23:16];
	assign secret_key_array[1] = secret_key[15:8];
	assign secret_key_array[2] = secret_key[7:0];
	
	assign wren = state[0];
	assign done = state[5];
	
	parameter idle                   = 9'b00000001_0;
	parameter get_s_i1               = 9'b00000010_0;
	parameter get_s_i3               = 9'b01000010_0;
	parameter wait1                  = 9'b00000011_0;
	parameter get_s_i2               = 9'b00000100_0;
	parameter calc_j                 = 9'b00000101_0;
	parameter get_s_j1               = 9'b00000110_0;
	parameter wait2                  = 9'b00000111_0;
	parameter get_s_j2               = 9'b00001000_0;
	parameter write_en_i					= 9'b00000000_1; 
	parameter swap1                  = 9'b00001001_1;
	parameter swap2                  = 9'b00001010_1;
	parameter swap3                  = 9'b00001011_1;
	parameter increment              = 9'b00001111_1;
	parameter chill                  = 9'b00010000_0;
	
	always_ff @(posedge clk) begin
//		if (reset_n) 	// assume reset_n is active high? 
//			state <= idle;
		case(state)
			idle: if (start) state <= get_s_i1; 
					else begin 
						state <= idle;
						i <= 8'b00000000;
						j <= 8'b00000000;
					end
			get_s_i3:begin
	//		   i<=i+1;
			   state <= get_s_i1;
			   end
			get_s_i1: 
				begin//Turn off wren, set address i
					address_out <= i;
					state <= wait1; 
				end
			wait1: 
				begin//wait for address to latch
					state <= get_s_i2;
				end
			get_s_i2: 
				begin//store s[i]
					s_i <= RAMdata;
					state <= calc_j;
				end
			calc_j: 
				begin//calculate j
						key_i <= i % 3;
						j <= j + s_i + secret_key_array[i % 3];						
						state <= get_s_j1;
				end
			get_s_j1: 
				begin//Turn off wren, set address j
					address_out <= j;
					state <= wait2;
				end
			wait2: 
				begin //wait for address to latch
					state <= get_s_j2;
				end
			get_s_j2: 
				begin //store s[j]
					s_j <= RAMdata;
					state <= write_en_i; 
				end
			write_en_i:
				begin //enable write data earlier 
					state <= swap1;
				end 
			//SWap
			swap1:
				begin
					data_out <= s_i;
					state <=swap2;
				end
			swap2:
				begin
					address_out <= i;
					state <= swap3;
				end
			swap3:
				begin
					data_out <= s_j;
					state <= increment;
				end
			increment :
				begin
					if (i < 255) begin
						i <= i + 1;
						state <= get_s_i1;
					end
					else state <= chill;
				end
			chill: state <= chill;
			default: state <= idle;
		endcase	
	end 
endmodule
