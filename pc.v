module pc(out, clock,clrn, in_reg, pc_in, use_pc_in, isStall);
	input clock,clrn, use_pc_in, isStall; 
	output[31:0] out; 
	output [31:0] in_reg; 
	input[31:0] pc_in; 
	//out is output of register
	//in_reg is what is in the register
	register_neg reg1(.data(in_reg), .clk(clock), .clrn(clrn), .prn(1'b0), .ena(1'b1), .qout(out));
	
	//increment the output by 4 and store that value into the register
	wire [31:0] out_adder, out_adder_stall; 
	cla_adder add1(.data_a(32'd1), .data_b(out), .data_out(out_adder), .c_in(1'd0));
	
	mux_2 select_adder_stall(.out(out_adder_stall), .in0(out_adder), .in1(out), .select(isStall)); 
	mux_2 selectPC(.out(in_reg), .in0(out_adder_stall), .in1(pc_in), .select(use_pc_in)); 
endmodule