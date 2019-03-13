module generate_key(
	input new_key, //key check is complete 
	input reset, 
	input clk, 
	output logic [23:0] secret_key,
	output logic 	done); 

// secret key is 24 bits
// the 2 MSBs of the key are zero 
wire pulse; 

always_ff @ (posedge clk) begin
	if (!reset) begin 
		secret_key <= 24'b0; 
		done <= 1'b0; 
		end 
	else if (new_key) begin 
		secret_key <= secret_key + 1; 
		end 
	else if (secret_key >= 24'h3FFFFF) begin 
		secret_key <= 24'hFFFFFF;
		done <= ~done; 
		end 
	else begin  
		secret_key <= secret_key; 
		end 
		
end

edge_detector sync_sig(
	.async_in(new_key),
	.clk(clk), 
	.out(pulse)); 

endmodule 
		
		