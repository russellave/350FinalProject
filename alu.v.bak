module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
//after overflow ix extra

   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

   output [31:0] data_result;
   output isNotEqual, isLessThan, overflow;

   // YOUR CODE HERE //
	
	wire[31:0] out_add, out_sub, out_and, out_or, out_sll, out_sra, notB, out_or_notB, out_and_notB; 
	genvar i;
	generate
		for (i=0; i<32; i=i+1) begin : loop1
			and and1(out_and[i], data_operandA[i], data_operandB[i]); 
			or or1(out_or[i], data_operandA[i], data_operandB[i]); 
			not not1(notB[i], data_operandB[i]); 
			or or11(out_or_notB[i], data_operandA[i], notB[i]); 
			and and11(out_and_notB[i], data_operandA[i], notB[i]); 
		end
	endgenerate
	wire overflow_add, overflow_sub; 

	
	cla_adder cla_adder1(.data_a(data_operandA), .data_b(data_operandB), .data_out(out_add), .c_in(1'd0), .c_out(overflow_add));
	cla_adder cla_adder2(.data_a(data_operandA), .data_b(notB), .data_out(out_sub), .c_in(1'd1), .c_out(overflow_sub));
	sra_shifter sra1(.in(data_operandA), .out(out_sra), .shamt(ctrl_shiftamt)); 
	sll_shifter sll1(.in(data_operandA), .out(out_sll), .shamt(ctrl_shiftamt)); 
	
	
	
	mux_8 mux_out(.select(ctrl_ALUopcode[2:0]),.out(data_result), .in0 (out_add), .in1 (out_sub), .in2 (out_and), .in3 (out_or), .in4 (out_sll), .in5(out_sra));

	or or2(isNotEqual, out_sub[0], out_sub[1], out_sub[2], out_sub[3], out_sub[4], out_sub[5], out_sub[6], out_sub[7], out_sub[8], out_sub[9], out_sub[10], out_sub[11], out_sub[12], out_sub[13], out_sub[14], out_sub[15], out_sub[16], out_sub[17], out_sub[18], out_sub[19], out_sub[20], out_sub[21], out_sub[22], out_sub[23], out_sub[24], out_sub[25], out_sub[26], out_sub[27], out_sub[28], out_sub[29], out_sub[30], out_sub[31]); 
	
	wire t1, t2, t3, t4, sub, not_sub, not_A31, not_out31, not_B31;
	assign sub = ctrl_ALUopcode[0]; 
	not not5(not_sub, sub); 
	not not6(not_A31, data_operandA[31]); 
	not not7(not_B31, data_operandB[31]);
	not not8(not_out31, data_result[31]); 
	
	and and5(t1, sub, data_operandA[31],  not_B31, not_out31); 
	and and6(t2, sub, not_A31, data_operandB[31], data_result[31]); 
	and and7(t3, not_sub, not_A31, not_B31, data_result[31]); 
	and and8(t4, not_sub, data_operandA[31], data_operandB[31], not_out31); 
	
	or or5(overflow, t1,t2,t3,t4); 
	wire lessThanOverFlow; 

	and and11(lessThanOverFlow, data_operandA[31],not_B31,1); 
	or or6(isLessThan, out_sub[31],lessThanOverFlow);

	
endmodule