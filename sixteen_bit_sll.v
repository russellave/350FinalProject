module sixteen_bit_sll(in, out);
	input [ 31 : 0 ] in; 
	output [ 31 : 0 ] out;
	
	genvar i; 
	generate 
		for(i = 31; i>15;  i=i-1) begin : loop2
			assign out[i] = in[i-16]; 
		end
	endgenerate	
	

	genvar j; 
	generate
		for(j = 0; j<16; j = j+1) begin : loop3
		   assign out[j] = 0; 
		end
	endgenerate
	
endmodule

