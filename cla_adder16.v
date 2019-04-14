module cla_adder16(data_a, data_b, data_out, c_in, c_out);
	input c_in;
	input [ 15 : 0 ] data_a, data_b;
	output [ 15 : 0 ] data_out;
	output c_out; 
	
	wire [15:0] out_or, out_and, p_vals, g_vals; 
	
	genvar i; 
	generate
		for (i = 0; i<16; i=i+1) begin: loop1
			and and1(g_vals[i], data_a[i], data_b[i]); 
			or or1(p_vals[i], data_a[i], data_b[i]); 
		end
	endgenerate
	
	
	
	wire [1:0] P,G; 
	wire c8; 
	
	
	cla_block cla_block1(.S(data_out[7:0]), .A(data_a[7:0]), .B(data_b[7:0]), .c_in(c_in), .P(P[0]), .G(G[0]), .p_vals(p_vals[7:0]), .g_vals(g_vals[7:0]));
	
	wire temp0; 
	and and1(temp0, c_in, P[0]); 
	or or1(c8, temp0, G[0]); 
	

	cla_block cla_block2(.S(data_out[15:8]), .A(data_a[15:8]), .B(data_b[15:8]), .c_in(c8), .P(P[1]), .G(G[1]), .p_vals(p_vals[15:8]), .g_vals(g_vals[15:8]));
	

	wire temp1; 
	and and2(temp1, c8, P[1]); 
	or or2(c_out, temp1, G[1]); 
	

	
endmodule