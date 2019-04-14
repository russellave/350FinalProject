module register_regfile(in, out, clock, in_en, reset);
	input clock, in_en, reset;
   input [31:0] in;
	output [31:0] out;
	
	
	genvar i; 
	generate
		for (i = 0; i<32; i=i+1) begin: loop1
			dffe_ref dff(.d(in[i]), .q(out[i]), .clk(clock), .en(in_en), .clr(reset));
		end
	endgenerate
	
endmodule