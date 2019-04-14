module sll_shifter16(in, out, shamt);
	input [ 15 : 0 ] in; 
	output [ 15 : 0 ] out;
	input [3:0] shamt; 
	
	wire [16:0] out_8, out_4, out_2, out_1, out_mux_8, out_mux_4, out_mux_2; 
	
	
	eight_bit_sll eight_shift(.out(out_8), .in(in)); 
	
	mux_2 mux2(.out(out_mux_8), .select(shamt[3]), .in0(in), .in1(out_8)); 
	
	four_bit_sll four_shift(.out(out_4), .in(out_mux_8)); 
	
	mux_2 mux3(.out(out_mux_4), .select(shamt[2]), .in0(out_mux_8), .in1(out_4)); 

	two_bit_sll two_shift(.out(out_2), .in(out_mux_4)); 
	
	mux_2 mux4(.out(out_mux_2), .select(shamt[1]), .in0(out_mux_4), .in1(out_2)); 

	one_bit_sll one_shift(.out(out_1), .in(out_mux_2)); 
	
	mux_2 mux5(.out(out), .select(shamt[0]), .in0(out_mux_2), .in1(out_1)); 

endmodule