module task3(
	//port definitions
	input				clk, 
	input [23:0]	secret_key,
	input [7:0] 	decrypted_byte, 
	input				start,
	
	output logic 	byte_valid,
	output logic	new_key
	); 
	
	logic[4:0]	state; 

//------------- state declaration ----------------//
	parameter idle						= 5'b000_00;
	parameter check_dbyte 			= 5'b001_00;
	parameter check_next				= 5'b010_00; 
	parameter invalid_byte 			= 5'b011_00;
	parameter increment_key 		= 5'b100_01; 
	parameter wait_increment_key 	= 5'b101_00; 	
	parameter valid_byte				= 5'b110_10; 
	parameter wait_valid_byte 		= 5'b111_00; 
	
//------ output bits -----------------------------//	
	assign new_key = state[0]; 
	assign byte_valid = state[1] ; 
	
always_ff @(posedge clk) begin 
		case(state)
			idle: begin 
					if (start) state <= check_dbyte; //decrypted byte needs to not change; make sure loop3 is waiting for a resume signal 
					else state <= idle; 
					end 

			check_dbyte:
					begin 
						if ((decrypted_byte > 8'h7A) | (decrypted_byte < 8'h0)) state <= check_next; 
							else state <= invalid_byte; 
					end 
			check_next: 
				begin 
					if ((decrypted_byte > 8'h0) & (decrypted_byte < 8'h61)) state <= valid_byte; 
							else state <= invalid_byte; 
				end 
			invalid_byte: 
				begin 
					state <= increment_key; 
				end 
			increment_key: 
				begin 
					state <= wait_increment_key;
				end 	
			wait_increment_key: 
				begin 
					state <= idle; 
				end 
			valid_byte:
				begin 
					state <= wait_valid_byte ; 
				end
			wait_valid_byte: 
				begin 
					state <= idle; 
				end 
				
			default: state <= idle; 
	
	endcase
	end
endmodule
	
	
	