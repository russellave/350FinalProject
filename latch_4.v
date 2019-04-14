module latch_4(o_in, ir_in, d_in, o_out, ir_out, d_out, clock, clrn, jal_in, jal_out, exception_in, exception_out, pc_jal_in, pc_jal_out, enable);
	input [31:0] o_in,ir_in, d_in, pc_jal_in; 
	output[31:0] o_out,ir_out,d_out, pc_jal_out;
	input clock,clrn,enable; 
	input jal_in, exception_in; 
	output jal_out, exception_out; 
	register hold_ir(.data(ir_in), .clk(clock), .clrn(clrn), .prn(1'b0), .ena(enable), .qout(ir_out)); 
	register hold_o(.data(o_in), .clk(clock), .clrn(clrn), .prn(1'b0), .ena(enable), .qout(o_out)); 
	register hold_d(.data(d_in), .clk(clock), .clrn(clrn), .prn(1'b0), .ena(enable), .qout(d_out)); 
	register hold_pc_jal(.data(pc_jal_in), .clk(clock), .clrn(clrn), .prn(1'b0), .ena(enable), .qout(pc_jal_out)); 
	dflipflop hold_jal(.d(jal_in), .q(jal_out), .clk(clock), .ena(enable), .clrn(clrn), .prn(prn));
	dflipflop hold_ex(.d(exception_in), .q(exception_out), .clk(clock), .ena(enable), .clrn(clrn), .prn(prn));
		
endmodule