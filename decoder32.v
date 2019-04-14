module decoder32(out, select, enable); 
	input [4:0] select; 
	input enable; 
	output [31:0] out; 
	
	wire [3:0] enable_sub_decoder;
	decoder decoder_first(.out(enable_sub_decoder),.in(select[4:3]), .enable(enable)); 
	decoder8 decoder8_first(.out(out[31:24]), .in(select[2:0]), .enable(enable_sub_decoder[3])); 
	decoder8 decoder8_second(.out(out[23:16]), .in(select[2:0]), .enable(enable_sub_decoder[2]));	
	decoder8 decoder8_third(.out(out[15:8]), .in(select[2:0]), .enable(enable_sub_decoder[1]));
	decoder8 decoder8_fourth(.out(out[7:0]), .in(select[2:0]), .enable(enable_sub_decoder[0]));
endmodule