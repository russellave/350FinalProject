module sign_extend(in, out); 
input [15:0] in; 
output [31:0] out; 

assign out[15:0] = in; 
genvar i; 
generate 
	for(i = 16; i<32;  i=i+1) begin : loop1
		assign out[i] = in[15];  
	end
endgenerate	

endmodule
	