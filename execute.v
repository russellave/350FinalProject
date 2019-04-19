module execute(a,b_in,ir, out, b_out, pc_in, pc_out,case_jal,overflow,pc_jal,flush, disable_latches, isMultDiv_in, clock,
BR, JP, ALUinB, isReady, case1,bex_sat, isBex, case2,held_mult_out, out_mult_div_final, case3, case4, case5,isNotEqual, isLessThan, blt_sat, bne_sat, notBLessThanA, imm_extended, b, imm_extended_shifted, imm_shift_plus_pc); // 
	input [31:0] a,b_in,ir,pc_in; 
	output[31:0] out,b_out, pc_out;
	
	output overflow; 	
	output isNotEqual, isLessThan; 
	input isMultDiv_in, clock; 
	assign b_out = b_in; 
	
	//control for ALU
	output ALUinB;
	wire[4:0] ALUop; 
 
	//ALUinB
	
	wire [4:0] not_opcode; 
	not not1(not_opcode[0], ir[27]);
	not not2(not_opcode[1], ir[28]);
	not not3(not_opcode[2], ir[29]);
	not not4(not_opcode[3], ir[30]);
	not not5(not_opcode[4], ir[31]);
	
	output case1, case2, case3, case4, case5; //sw, lw, bne, blt, addi
	and andImm1(case1, not_opcode[4], not_opcode[3], ir[29], ir[28], ir[27]);
	and andImm2(case2, not_opcode[4], ir[30], not_opcode[2], not_opcode[1], not_opcode[0]);
	and andImm3(case3, not_opcode[4], not_opcode[3], not_opcode[2], ir[28], not_opcode[0]);
	and andImm4(case4, not_opcode[4], not_opcode[3], ir[29], ir[28], not_opcode[0]);
	and andImm5(case5, not_opcode[4], not_opcode[3], ir[29], not_opcode[1], ir[27]);
	
	or orImm(ALUinB, case1,case2,case5); 

	//ALUop
	wire isALUop; 
	and andOP(isALUop, not_opcode[4], not_opcode[3], not_opcode[2], not_opcode[1], not_opcode[0]);
	
	assign ALUop = isALUop ? ir[6:2]: 5'b0; //2 input mux //this means that if not ALUop, will add automatically
	
	
	output [31:0] imm_extended, b, imm_extended_shifted, imm_shift_plus_pc;
	
	//get immediate extended
	sign_extend se1(.in(ir[15:0]), .out(imm_extended)); 
	
	//perform alu operation
	mux_2 mux2(.in0(b_in),.in1(imm_extended), .select(ALUinB), .out(b)); 
	
	wire BLessThanA, overflow_alu; 
	wire[31:0] out_alu; 
	alu alu_1(.data_operandA(a), .data_operandB(b), .ctrl_ALUopcode(ALUop), .ctrl_shiftamt(ir[11:7]), .data_result(out_alu), .isNotEqual(isNotEqual), .isLessThan(BLessThanA), .overflow(overflow_alu));
	
	//multdiv
	
	wire isMult, isDiv, isMultDiv, multdiv_exception, isNotReady;
   output isReady; 	
	output disable_latches; 
	wire [31:0] out_multdiv;
	
	wire [4:0] not_aluop; 
	not not11(not_aluop[0], ALUop[0]);
	not not22(not_aluop[1], ALUop[1]);
	not not33(not_aluop[2], ALUop[2]);
	not not44(not_aluop[3], ALUop[3]);
	not not55(not_aluop[4], ALUop[4]);
//	and andmult(isMult, not_aluop[4], not_aluop[3], ALUop[2], ALUop[1],not_aluop[0]);
//	and anddiv(isDiv, not_aluop[4], not_aluop[3], ALUop[2], ALUop[1],ALUop[0]);

//	multdiv md(.data_operandA(a), .data_operandB(b), .ctrl_MULT(isMult), .ctrl_DIV(isDiv), .clock(clock), .data_result(out_multdiv), .data_exception(multdiv_exception), .data_resultRDY(isReady));
	
	output [31:0] held_mult_out, out_mult_div_final; 
   register holdmultout(.data(out_multdiv), .clk(clock), .clrn(1'd1), .ena(isReady), .qout(held_mult_out));
	assign out_mult_div_final = isReady ? out_multdiv : held_mult_out; 
	
//	or orismultdiv(isMultDiv, isMult, isDiv, isMultDiv_in); 
	
	
	not notready(isNotReady, isReady); 
	
	//outputs of alu and multdiv
	assign out = isMultDiv ? out_mult_div_final : out_alu; 
	
	and andDisableLatches(disable_latches, isNotReady, isMultDiv); 
	
	or oroverflow(overflow, overflow_alu, multdiv_exception); 
	
	
	//modify pc 
	
	//control for jumping and branching
	output BR, JP; 

	sll_shifter shifter1(.in(imm_extended), .out(imm_extended_shifted), .shamt(5'd0));
	
	//c_in is 1 because PC = PC+1+N for branching
	cla_adder adder(.data_a(pc_in), .data_b(imm_extended_shifted), .data_out(imm_shift_plus_pc), .c_in(1'd0)); 
//	cla_adder adder(.data_a(32'd0), .data_b(imm_extended_shifted), .data_out(imm_shift_plus_pc), .c_in(1'd0)); 
	
	//BR control 
	
//if bne and not equal, then BR=1
//if blt and less than, then BR=1
	wire [31:0] pc_br_wo_bex, pc_jp; 
	output blt_sat, bne_sat, notBLessThanA;
	not notBltA(notBLessThanA, BLessThanA);
	and andlt(isLessThan, notBLessThanA, isNotEqual); 
	
   and andblt(blt_sat, isLessThan, case4); 
   and andbne(bne_sat, isNotEqual, case3); 	
	or(BR, blt_sat, bne_sat); 
	
	mux_2 mux_branch_or_not(.in0(pc_in), .in1(imm_shift_plus_pc), .out(pc_br_wo_bex), .select(BR)); 
	
	wire[31:0] pc_br; 
	output bex_sat, isBex; 
	and andbex(isBex, ir[31], not_opcode[3], ir[29], ir[28],not_opcode[0]); 
	and andbexsat(bex_sat,isNotEqual, isBex); 
	mux_2 mux_bex(.in0(pc_br_wo_bex), .in1(ir[26:0]), .select(bex_sat), .out(pc_br)); 
	
	//JP control 
	wire case_j, case_jr;
	output case_jal; 
	
	and andj(case_j, not_opcode[4], 	not_opcode[3], not_opcode[2], not_opcode[1], ir[27]); 
	and andjr(case_jr, not_opcode[4], not_opcode[3], ir[29], not_opcode[1], not_opcode[0]);
	and andjal(case_jal, not_opcode[4], not_opcode[3], not_opcode[2], ir[28], ir[27]);
	
	//inputs for JP mux
	or(JP, case_j, case_jr, case_jal); 
	wire [31:0] pc_j, pc_jr, pc_jal; 
	
	wire[31:0] t_shifted; 
	sll_shifter shifter_ex(.in(ir[26:0]), .out(t_shifted), .shamt(5'd0));
	
	wire is_J_or_JAL; 
	or orisjorjal(is_J_or_JAL, case_j, case_jal); 
	
	mux_2 mux_decide_where_to_jump(.in0(a), .in1(t_shifted), .out(pc_jp), .select(is_J_or_JAL)); 

	
	mux_2 mux_jump_or_not(.in0(pc_br), .in1(pc_jp), .out(pc_out), .select(JP)); 

	output [31:0] pc_jal; 
	cla_adder adder_pc_jal(.data_a(pc_in), .data_b(32'd0), .data_out(pc_jal), .c_in(1'd1)); 
	
	output flush; 
	or orflush(flush, case_j, case_jr, case_jal, blt_sat, bne_sat, isBex); 
	
	
endmodule 