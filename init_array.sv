module init_array(
input logic clk,
input logic reset_n,
output logic [7:0]counter,
output logic done,
output logic wren);

	assign wren = 1;
	logic inc_counter; 
	logic[1:0] state; 
	
	always@(posedge clk) begin 
		if (reset_n)
			counter <= 8'b0; 
		else if(inc_counter)
			counter <= counter +1;
		else 
			counter <= counter; 
	end 
		
	
	//state machine version: 
	parameter idle = 2'b00; 
	parameter writeToMemory = 2'b10; 
	parameter outputDone = 2'b01; 
	
	always_ff @(posedge clk) begin 
		case (state) 
			idle: begin if (reset_n) state <= idle;
					else state <= writeToMemory; 
					end 
			writeToMemory: begin if (counter == 255) state <= outputDone; 
								else state <= writeToMemory; 
								end
			outputDone: state <= outputDone; 
			default: state <= idle; 
			
		endcase
	end


always_comb 
begin
done = state[0]; 
inc_counter = state[1]; 	
end 
		
endmodule 	