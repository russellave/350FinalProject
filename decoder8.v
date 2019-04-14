module decoder8(out, in, enable); 
	input [2:0] in; 
	input enable; 
	output [7:0] out; 
	

	//declare nIn (the NOT of the input)
	wire [ 2 : 0 ] nIn;
	//wire in through not gates to nIn
	not not0(nIn[ 0 ], in[ 0 ]);
	not not1(nIn[ 1 ], in[ 1 ]);
	not not2(nIn[ 2 ], in[ 2 ]); 
	//decode with AND gates
	
	and and0(out[ 0 ], nIn[2], nIn[ 1 ], nIn[ 0 ], enable);
	and and1(out[ 1 ], nIn[2], nIn[ 1 ], in[ 0 ], enable);
	and and2(out[ 2 ], nIn[2], in[ 1 ], nIn[ 0 ], enable);
	and and3(out[ 3 ], nIn[2], in[ 1 ], in[ 0 ], enable);
	and and4(out[ 4 ], in[2], nIn[ 1 ], nIn[ 0 ], enable);
	and and5(out[ 5 ], in[2], nIn[ 1 ], in[ 0 ], enable);
	and and6(out[ 6 ], in[2], in[ 1 ], nIn[ 0 ], enable);
	and and7(out[ 7 ], in[2], in[ 1 ], in[ 0 ], enable);
	
	
endmodule