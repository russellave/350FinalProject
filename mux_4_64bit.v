module mux_4_64bit(select, in0, in1, in2, in3, out);
	input [ 1 : 0 ] select;
	input [ 63 : 0 ] in0, in1, in2, in3;
	output [ 63 : 0 ] out;
	wire [ 63 : 0 ] w1, w2;
	mux_2_64 first_top(. select (select[0]), . in0 (in0), . in1 (in1), . out (w1));
	mux_2_64 first_bottom(. select (select[0]), . in0 (in2), . in1 (in3), . out (w2));
	mux_2_64 second(. select (select[1]), . in0 (w1), . in1 (w2), . out (out));
endmodule