module latch_2(pc_in, ir_in, a_in, b_in, pc_out, ir_out, a_out, b_out, clock, clrn, enable);
	input [31:0] pc_in,ir_in, a_in, b_in; 
	output[31:0] pc_out, ir_out, a_out, b_out;
	input clock,clrn,enable; 
	register hold_pc(.data(pc_in), .clk(clock), .clrn(clrn), .prn(1'b0), .ena(enable), .qout(pc_out)); 
	register hold_ir(.data(ir_in), .clk(clock), .clrn(clrn), .prn(1'b0), .ena(enable), .qout(ir_out)); 
	register hold_a(.data(a_in), .clk(clock), .clrn(clrn), .prn(1'b0), .ena(enable), .qout(a_out)); 
	register hold_b(.data(b_in), .clk(clock), .clrn(clrn), .prn(1'b0), .ena(enable), .qout(b_out)); 

		
endmodule