module multiplier(mult_cand, multiplier, out, clk, clrn, prn, ena, ready,overflow,old_prod);

	input[31:0] mult_cand, multiplier; 
	output[31:0] out; 
	input clk, clrn, prn, ena;
	output ready, overflow;   

	//get negative multiplicand
	wire[31:0] not_mult_cand, neg_mult_cand; 
	wire[63:0] product; 
	genvar i; 
	generate
		for (i = 0; i<32; i=i+1) begin: loop1
			not not1(not_mult_cand[i], mult_cand[i]); 
		end
	endgenerate

	wire[31:0] one_wire; 
	assign one_wire[0] = 1; 
	wire c_out; 
	cla_adder adder1(.data_a(not_mult_cand), .data_b(one_wire), .data_out(neg_mult_cand), .c_in(1'b0), .c_out(c_out)); 
	
	
	//create registers for product 
	output[63:0] old_prod;

	
	wire helper_in, helper_out; 
	
	register prod_reg(.data(product[31:0]),.clk(clk), .clrn(clrn), .prn(prn), .ena(ena), .qout(old_prod[31:0])); 
	register prod_over(.data(product[63:32]),.clk(clk), .clrn(clrn), .prn(prn), .ena(ena), .qout(old_prod[63:32])); 
	dflipflop helper_bit(.d(helper_in), .clk(clk), .clrn(clrn), .prn(prn), .ena(ena), .q(helper_out));
	
	//calculate if ready from counter 
	wire[31:0] count;	

	multiplier_ctrl mult_ctrl(.count(count),.old_prod(old_prod), .multiplier(multiplier), .mult_cand(mult_cand), .neg_mult_cand(neg_mult_cand), .new_prod(product), .helper_in(helper_out), .helper_out(helper_in)); 

	wire ready; 
	wire data_in_counter;
	not not4(data_in_counter, ready); 
	
	sipo_counter sipo_counter1(.data_in(data_in_counter), .out(count), .clock(clk), .clrn(clrn));
	and and1(ready,count[0], count[1], count[2], count[3], count[4], count[5], count[6], count[7], count[8], count[9], count[10], count[11], count[12], count[13], count[14], count[15], count[16], count[17], count[18], count[19], count[20], count[21], count[22], count[23], count[24], count[25], count[26], count[27], count[28], count[29], count[30], count[31]); 
		
	//update product from control 
	
	assign out = old_prod[31:0]; 	
	
	
	
//OVERFLOW ATTEMPTs	

//THIS GETS ME 0%, THOUGH I PASS MORE TESTBENCHES??

//	wire[31:0] old_prod_top_half; 
//	assign old_prod_top_half = old_prod[63:32]; 
//	wire overflow_not; 
//	//check if old_prod_top_half is the same value
//	wire all1, all0, one_value, msbs_two_halves_not_equal,msbs_top_half_1,msbs_top_half_0; 
//	
//	and and12(all1,old_prod_top_half[0], old_prod_top_half[1], old_prod_top_half[2], old_prod_top_half[3], old_prod_top_half[4], old_prod_top_half[5], old_prod_top_half[6], old_prod_top_half[7], old_prod_top_half[8], old_prod_top_half[9], old_prod_top_half[10], old_prod_top_half[11], old_prod_top_half[12], old_prod_top_half[13], old_prod_top_half[14], old_prod_top_half[15], old_prod_top_half[16], old_prod_top_half[17], old_prod_top_half[18], old_prod_top_half[19], old_prod_top_half[20],old_prod_top_half[21], old_prod_top_half[22], old_prod_top_half[23], old_prod_top_half[24], old_prod_top_half[25], old_prod_top_half[26], old_prod_top_half[27], old_prod_top_half[28], old_prod_top_half[29], old_prod_top_half[30], old_prod_top_half[31]);
//	nor nor11(all0,old_prod_top_half[0], old_prod_top_half[1], old_prod_top_half[2], old_prod_top_half[3], old_prod_top_half[4], old_prod_top_half[5], old_prod_top_half[6], old_prod_top_half[7], old_prod_top_half[8], old_prod_top_half[9], old_prod_top_half[10], old_prod_top_half[11], old_prod_top_half[12], old_prod_top_half[13], old_prod_top_half[14], old_prod_top_half[15], old_prod_top_half[16], old_prod_top_half[17], old_prod_top_half[18], old_prod_top_half[19], old_prod_top_half[20],old_prod_top_half[21], old_prod_top_half[22], old_prod_top_half[23], old_prod_top_half[24], old_prod_top_half[25], old_prod_top_half[26], old_prod_top_half[27], old_prod_top_half[28], old_prod_top_half[29], old_prod_top_half[30], old_prod_top_half[31]);
//	
//	
//	xor xor95(msbs_two_halves_not_equal, old_prod_top_half[31],old_prod[31]);
//	
//
//	and and95(overflow, one_value, msbs_two_halves_not_equal);
//	

	//just to commit something

	//THIS GETS ME 86%


	//overflow cases: pos*pos = neg, pos*neg = pos, neg*pos = pos, neg*neg = neg
	//overflow cases: out<input
	//account for 0's case in pos*neg/neg*pos
	wire case1, case2, case3, case4; 
	//case1
	wire is_case1, not_out_msb; 
	not not25(not_out_msb, out[31]); 
	nor nor111(case1,mult_cand[31], multiplier[31], not_out_msb); 
	//case2
	wire is_case2, not_multiplier_msb; 
	not not10(not_multiplier_msb, multiplier[31]); 
	nor nor11(case2, not_multiplier_msb, mult_cand[31], out[31]); 
	//case3
	wire is_case3, not_mult_cand_msb; 
	not not101(not_mult_cand_msb, mult_cand[31]); 
	nor nor1191(case3, not_mult_cand_msb, multiplier[31], out[31]); 
	//case4
	and and100(case4, mult_cand[31], multiplier[31], out[31]); 
		
	or or100(overflow,case1,case2,case3,case4); 
	


endmodule