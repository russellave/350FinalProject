module sipo_counter(data_in, out, clock,clrn);

	input data_in; 
	input clock,clrn; 
	output[31:0] out; 
	 
	wire[32:0] temp;
	assign temp[0] = data_in; 
	genvar i; 
	generate
		for (i = 0; i<32; i=i+1) begin: loop1
			dflipflop dff(.d(temp[i]), .clk(clock), .clrn(clrn),.prn(1'b0), .ena(1'b1), .q(temp[i+1])); 
		end
	endgenerate

	assign out = temp[32:1];  
	
endmodule