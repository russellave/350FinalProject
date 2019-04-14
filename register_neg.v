module register_neg(data, clk, clrn, prn, ena, qout);
	input clk, clrn, prn, ena;
   input [31:0] data;
	output [31:0] qout;
	
	
	genvar i; 
	generate
		for (i = 0; i<32; i=i+1) begin: loop1
			dflipflop_neg dff(.d(data[i]), .q(qout[i]), .clk(clk), .ena(ena), .clrn(clrn), .prn(prn));
		end
	endgenerate
	
endmodule