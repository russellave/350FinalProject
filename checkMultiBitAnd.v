module checkMultiBitAnd(out, in0, in1); 
output [3:0] out; 
input [3:0] in0, in1; 

not not1(out, in0); 

endmodule