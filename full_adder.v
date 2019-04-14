module full_adder(S, A, B, c_in); 
	input [7:0] A,B; 
	input c_in; 
	output [7:0] S; 
	//output c_out;

	wire [8:0] c_out_vals; 
	assign c_out_vals[0] = c_in; 
	genvar i; 
	generate
		for (i=0; i<8; i=i+1) begin : loop1
			one_bit_full_adder one_bit_full_adder1(.c_out(c_out_vals[i+1]),.S(S[i]), .A(A[i]), .B(B[i]), .c_in(c_out_vals[i])); 
		end
	endgenerate
	
endmodule