module sixteen_bit_sra(in, out);
	input [ 31 : 0 ] in; 
	output [ 31 : 0 ] out;
	
	genvar i; 
	generate 
		for(i = 0; i<16;  i=i+1) begin : loop2
			assign out[i] = in[i+16]; 
		end
	endgenerate	
	
	assign out[31] = in[31]; 

	genvar j; 
	generate
		for(j = 30; j>15; j = j-1) begin : loop3
			assign out[j] = in[31]; 
		end
	endgenerate
	
	
	
	
	
endmodule