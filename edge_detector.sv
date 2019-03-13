module edge_detector (input logic async_in,
							input logic clk,
							output logic out
							);

	logic Q1 = 1'b0, Q2 = 1'b0, Q3 = 1'b0, Q4 = 1'b0; // internal signal for synchronization
	logic clr;
	
	assign clr = (Q3 & !async_in);
		
	always_ff @(posedge async_in or posedge clr) // asynchronous flip flop
		begin
			if (clr)
				Q1 <= 1'b0;
			else
				Q1 <= 1'b1;
		end
	
	always_ff @(posedge clk) // synchronous flip flops
		begin
			Q2 <= Q1;
			Q3 <= Q2;
			Q4 <= Q3;
		end

	assign out = (!Q4 & Q3);
endmodule 