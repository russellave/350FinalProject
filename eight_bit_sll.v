module eight_bit_sll(in, out);
	input [ 31 : 0 ] in; 
	output [ 31 : 0 ] out;
	
	genvar i; 
	generate 
		for(i = 31; i>7;  i=i-1) begin : loop2
			assign out[i] = in[i-8]; 
		end
	endgenerate	
	

	genvar j; 
	generate
		for(j = 0; j<8; j = j+1) begin : loop3
		   assign out[j] = 0; 
		end
	endgenerate
	
	
	
	
	
endmodule