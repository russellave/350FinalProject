module multdiv(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, data_result, data_exception, data_resultRDY);
    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

	//my code here
	 
	 //if ctrl_MULT or ctrl_DIV, clrn = 0 --> clears registers
	 //if ctrl_MULT or ctrl_DIV, enable write in dff to store operation
	 
	 wire clrn, enable_if_op; 
	 
	 or or1(enable_if_op, ctrl_MULT, ctrl_DIV); 
	 not not1(clrn, enable_if_op); 
	
	 wire isDivide; 

	 dflipflop dff_store_operation(.d(ctrl_DIV), .clk(clock), .clrn(1'b1), .prn(1'b0),.ena(enable_if_op), .q(isDivide)); 
	 
	 //multiplier and divider
	 
	 wire[31:0] out_multiplier,out_divider; 
	 wire ready_multiplier, ready_divider; 
	 
	 wire isOverflow; 

	 multiplier multiplier1(.mult_cand(data_operandA), .multiplier(data_operandB), .out(out_multiplier), .clk(clock), .clrn(clrn),.prn(1'b0), .ena(1'b1), .ready(ready_multiplier), .overflow(isOverflow));
 	 divider divider1(.dividend(data_operandA), .divisor(data_operandB), .out(out_divider), .clk(clock), .clrn(clrn), .ena(1'b1), .prn(1'b0), .ready(ready_divider));

	 
	 //mux set output to either mult or div(use mult_div ctrl) 
	 wire[31:0] out_op; 
	 assign data_resultRDY = isDivide ? ready_divider : ready_multiplier;
	 
	 mux_2 selectCorrectOpOut(.select(isDivide), .in0(out_multiplier), .in1(out_divider), .out(out_op)); 
	 
	 //mux to select output (use data_resultRDY)
	 wire[31:0] zero_wire; 
	 mux_2 selectIfReady(.select(data_resultRDY), .in0(zero_wire), .in1(out_op), .out(data_result)); 
	 
	 //find exceptions 
	 //check if b is 0 and operation is divide
	 wire divide_by_zero, b_is_zero; 
	 nor nor33(b_is_zero,data_operandB[0], data_operandB[1], data_operandB[2], data_operandB[3], data_operandB[4], data_operandB[5], data_operandB[6], data_operandB[7], data_operandB[8], data_operandB[9], data_operandB[10], data_operandB[11], data_operandB[12], data_operandB[13], data_operandB[14], data_operandB[15], data_operandB[16], data_operandB[17], data_operandB[18], data_operandB[19], data_operandB[20], data_operandB[21], data_operandB[22], data_operandB[23], data_operandB[24], data_operandB[25], data_operandB[26], data_operandB[27], data_operandB[28], data_operandB[29], data_operandB[30], data_operandB[31]); 
	 and and33(divide_by_zero,isDivide, b_is_zero); 
	 
	 
	 //find mult_overflow
	 wire isMultiply,mult_overflow_ready; 
	 not not12(isMultiply, isDivide); 
	 and and44(mult_overflow_ready, isMultiply, isOverflow, data_resultRDY); 

	 
	 or or55(data_exception, mult_overflow_ready, divide_by_zero); 
endmodule
