module decoder(out, in, enable);
	//declare inputs and outputs
	input enable;
	input [ 1 : 0 ] in;
	output [ 3 : 0 ] out;
	//declare nIn (the NOT of the input)
	wire [ 1 : 0 ] nIn;
	//wire in through not gates to nIn
	not not0(nIn[ 0 ], in[ 0 ]);
	not not1(nIn[ 1 ], in[ 1 ]);
	//decode with AND gates
	and and0(out[ 0 ], nIn[ 1 ], nIn[ 0 ], enable);
	and and1(out[ 1 ], nIn[ 1 ], in[ 0 ], enable);
	and and2(out[ 2 ], in[ 1 ], nIn[ 0 ], enable);
	and and3(out[ 3 ], in[ 1 ], in[ 0 ], enable);
endmodule
