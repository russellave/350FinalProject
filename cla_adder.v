module cla_adder(data_a, data_b, data_out, c_in, c_out);
	input c_in;
	input [ 31 : 0 ] data_a, data_b;
	output [ 31 : 0 ] data_out;
	output c_out; 
	
	wire [31:0] p_vals, g_vals; 
	
	wire [3:0] P,G; 
	wire c8, c16, c24, c32; 
	
	genvar i; 
	generate
		for (i = 0; i<32; i=i+1) begin: loop1
			and and1(g_vals[i], data_a[i], data_b[i]); 
			or or1(p_vals[i], data_a[i], data_b[i]); 
		end
	endgenerate
	
	cla_block cla_block1(.S(data_out[7:0]), .A(data_a[7:0]), .B(data_b[7:0]), .c_in(c_in), .P(P[0]), .G(G[0]), .p_vals(p_vals[7:0]), .g_vals(g_vals[7:0]));
	
	wire temp0; 
	and and1(temp0, c_in, P[0]); 
	or or1(c8, temp0, G[0]); 
	

	cla_block cla_block2(.S(data_out[15:8]), .A(data_a[15:8]), .B(data_b[15:8]), .c_in(c8), .P(P[1]), .G(G[1]), .p_vals(p_vals[15:8]), .g_vals(g_vals[15:8]));
	

	wire temp1; 
	and and2(temp1, c8, P[1]); 
	or or2(c16, temp1, G[1]); 
	
	cla_block cla_block3(.S(data_out[23:16]), .A(data_a[23:16]), .B(data_b[23:16]), .c_in(c16), .P(P[2]), .G(G[2]), .p_vals(p_vals[23:16]), .g_vals(g_vals[23:16]));
	
	wire temp2; 
	and and3(temp2, c16, P[2]); 
	or or3(c24, temp2, G[2]); 
	
	cla_block cla_block4(.S(data_out[31:24]), .A(data_a[31:24]), .B(data_b[31:24]), .c_in(c24), .P(P[3]), .G(G[3]), .p_vals(p_vals[31:24]), .g_vals(g_vals[31:24]));

	wire temp3; 
	and and4(temp3, c24, P[3]); 
	or or4(c_out, temp3, G[3]); 
	
endmodule