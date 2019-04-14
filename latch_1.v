module latch_1(pc_in,ir_in, ir_out, clock, clrn,pc_out, enable);
	input [31:0] ir_in,pc_in; 
	output[31:0] ir_out,pc_out;
	input clock,clrn, enable; 
	register hold_ir(.data(ir_in), .clk(clock), .clrn(clrn), .prn(1'b0), .ena(enable), .qout(ir_out)); 
	register hold_pc(.data(pc_in), .clk(clock), .clrn(clrn), .prn(1'b0), .ena(enable), .qout(pc_out)); 

		
endmodule