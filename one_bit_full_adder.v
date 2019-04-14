module one_bit_full_adder(c_out,S, A, B, c_in); 
	input A,B,c_in; 
	output S,c_out;

	wire w1, temp0, temp1, temp2;
	
	xor xor1(temp0, A, B); 
	xor xor2(S, temp0, c_in);
	and and1(temp1, temp0, c_in); 
	and and2(temp2, A, B);
	or or1(c_out, temp1, temp2); 
	
	
endmodule