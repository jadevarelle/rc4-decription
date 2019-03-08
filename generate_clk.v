module generate_clk(
	input in_clk,
	input [31:0] div_clk_count, 
	input reset, 
	
	output reg out_clk
	); 
	
	reg[31:0] count; 
	
	always @ (posedge in_clk) begin
		if (reset) begin 
			out_clk <= 1'b0; 
			count <= 32'b0; 
			end
		else if(count >= div_clk_count) begin
			out_clk <= ~out_clk; 
			count <= 0; 
		end else begin 
			count <= count + 1;
		end
	end
endmodule
			
		