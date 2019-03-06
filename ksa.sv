module ksa( 
	input	CLK_50, 
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
	logic [6:0] ssOut; 
	logic [3:0] nIn; 
	
	assign clk = CLK_50; 
	assign reset_n = KEY[3]; 
	
	logic[7:0] counter; // use in for loop in task 1 
	logic[7:0] output_data; //not using this atm, output from s_memory module 
	
//----- instantiate hex display----//	
SevenSegmentDisplayDecoder seven_seg( 
	.nIn(nIn), 
	.ssOut(ssOut)); 
	
//----- instantiate memory module -----//
s_memory mem_inst(
	.address(counter), 
	.clock(clk),
	.data(counter), 
	.wren(1'b1), // write enable? Always 1? idk!! maybe have to make an FSM? 
	.q(output_data) ); 
	
always @(posedge clk) begin
	if (reset_n) 	// assume reset_n is active high? 
		counter <= 8'b0 ; 
	else begin 
		counter <= counter + 1;
		end	
end 

endmodule 