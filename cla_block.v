module cla_block(S, A, B, c_in, P, G, p_vals, g_vals); 
	input [7:0] A,B, p_vals, g_vals; 
	input c_in; 
	output [7:0] S; 
	output P, G;

	wire [7:0] g_temp_ands; 
	//g_temp hold values to calculate G
	//p_temp hold values to calculate P and G




	full_adder full_adder1(.S(S), .A(A), .B(B), .c_in(c_in)); 

	and and1(P, p_vals[0], p_vals[1], p_vals[2],p_vals[3],p_vals[4],p_vals[5],p_vals[6],p_vals[7]);
	assign g_temp_ands[0] = g_vals[7]; 
	and and2(g_temp_ands[1], p_vals[7], g_vals[6]); 
	and and3(g_temp_ands[2], p_vals[7], p_vals[6], g_vals[5]); 
	and and4(g_temp_ands[3], p_vals[7], p_vals[6], p_vals[5],g_vals[4]); 
	and and5(g_temp_ands[4], p_vals[7], p_vals[6], p_vals[5],p_vals[4],g_vals[3]); 
	and and6(g_temp_ands[5], p_vals[7], p_vals[6], p_vals[5],p_vals[4],p_vals[3],g_vals[2]); 
	and and7(g_temp_ands[6], p_vals[7], p_vals[6], p_vals[5],p_vals[4],p_vals[3],p_vals[2],g_vals[1]); 
	and and8(g_temp_ands[7], p_vals[7], p_vals[6], p_vals[5],p_vals[4],p_vals[3],p_vals[2],p_vals[1],g_vals[0]); 
	or or1(G, g_temp_ands[0], g_temp_ands[1], g_temp_ands[2], g_temp_ands[3], g_temp_ands[4], g_temp_ands[5], g_temp_ands[6], g_temp_ands[7]);  
	
	
endmodule