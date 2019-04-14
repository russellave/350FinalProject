module two_bit_sll(in, out);
	input [ 31 : 0 ] in; 
	output [ 31 : 0 ] out;
	
	genvar i; 
	generate 
		for(i = 31; i>1;  i=i-1) begin : loop2
			assign out[i] = in[i-2]; 
		end
	endgenerate	
	

	genvar j; 
	generate
		for(j = 0; j<2; j = j+1) begin : loop3
		   assign out[j] = 0 ;
		end
	endgenerate
	
	
	
	
	
endmodule