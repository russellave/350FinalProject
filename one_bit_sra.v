module one_bit_sra(in, out);
	input [ 31 : 0 ] in; 
	output [ 31 : 0 ] out;
	
	genvar i; 
	generate 
		for(i = 0; i<31;  i=i+1) begin : loop2
			assign out[i] = in[i+1]; 
		end
	endgenerate	
	
	assign out[31] = in[31]; 

	
	
	
	
	
endmodule