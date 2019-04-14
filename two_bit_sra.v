module two_bit_sra(in, out);
	input [ 31 : 0 ] in; 
	output [ 31 : 0 ] out;
	wire [ 31 : 0 ] w1, w2;
	
	genvar i; 
	generate 
		for(i = 0; i<30;  i=i+1) begin : loop2
			assign out[i] = in[i+2]; 
		end
	endgenerate	
	
	assign out[31] = in[31]; 
	assign out[30] = in[31]; 
	
	
	
endmodule