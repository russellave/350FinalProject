module divider(divisor, dividend, out, clk, clrn, prn, ena, ready);

	input[31:0] divisor, dividend; 
	output[31:0] out; 
	input clk, clrn, prn, ena;
	output ready;   

	//make sure both divisor and dividend are positive and keep track of switches
	//may need to place negCombos in DFF so that the value won't get lost..
	wire[1:0] negCombos; 
	assign negCombos[0] = dividend[31];
	assign negCombos[1] = divisor[31]; 
	
	
	//get negative divisor and dividend
	wire[31:0] not_divisor, neg_divisor, not_dividend, neg_dividend; 
	wire[63:0] quotient; 
	genvar i; 
	generate
		for (i = 0; i<32; i=i+1) begin: loop1
			not not1(not_divisor[i], divisor[i]); 
			not not2(not_dividend[i], dividend[i]); 
		end
	endgenerate

	wire[31:0] one_wire; 
	assign one_wire[0] = 1; 
	wire c_out1, c_out2; 
	cla_adder adder1(.data_a(not_divisor), .data_b(one_wire), .data_out(neg_divisor), .c_in(1'b0), .c_out(c_out1)); 
	cla_adder adder11(.data_a(not_dividend), .data_b(one_wire), .data_out(neg_dividend), .c_in(1'b0), .c_out(c_out2)); 

	wire [31:0] pos_dividend, pos_divisor, new_neg_divisor; 
	mux_2 mux_2_1(.select(negCombos[0]),.in0(dividend),.in1(neg_dividend), .out(pos_dividend)); 
	mux_2 mux_2_2(.select(negCombos[1]),.in0(divisor),.in1(neg_divisor), .out(pos_divisor)); 
	mux_2 mux_2_3(.select(negCombos[1]),.in0(neg_divisor),.in1(divisor), .out(new_neg_divisor)); 
	
	//create registers for quotient and counter, dff for neg combos
	wire[63:0] old_quo;

	wire [1:0] negComboDFF_out;
		
//	register counter(.data(count_in),.clk(clk), .clrn(clrn), .prn(prn), .ena(ena), .qout(count_out)); 
	register quo_reg(.data(quotient[31:0]),.clk(clk), .clrn(clrn), .prn(prn), .ena(ena), .qout(old_quo[31:0])); 
	register quo_over(.data(quotient[63:32]),.clk(clk), .clrn(clrn), .prn(prn), .ena(ena), .qout(old_quo[63:32])); 

	//calculate if ready from counter 

	wire[31:0] count; 
	wire ready; 

	wire data_in_counter;
	not not4(data_in_counter, ready); 
	
	sipo_counter sipo_counter1(.data_in(data_in_counter), .out(count), .clock(clk), .clrn(clrn));
	and and1(ready,count[0], count[1], count[2], count[3], count[4], count[5], count[6], count[7], count[8], count[9], count[10], count[11], count[12], count[13], count[14], count[15], count[16], count[17], count[18], count[19], count[20], count[21], count[22], count[23], count[24], count[25], count[26], count[27], count[28], count[29], count[30], count[31]); 
	
	
	
	
	//update quotient from control 
	divider_ctrl div_ctrl(.count(count),.old_quo(old_quo), .dividend(pos_dividend), .divisor(pos_divisor), .neg_divisor(new_neg_divisor), .new_quo(quotient)); 
	
	//negate the output
	wire [31:0] not_quotient_lsb_32, neg_quotient_lsb_32, quotient_lsb_32; 
	genvar j; 
	generate
		for (i = 0; i<32; i=i+1) begin: loop2
			not not1(not_quotient_lsb_32[i], quotient[i]); 
		end
	endgenerate
	wire c_out3; 
	cla_adder adder3(.data_a(not_quotient_lsb_32), .data_b(one_wire), .data_out(neg_quotient_lsb_32),.c_in(1'b0), .c_out(c_out3));
	
	assign quotient_lsb_32 = quotient[31:0];
	
	//select based on the negative combinations
	mux_4 mux4(.select(negCombos), .in0(quotient_lsb_32), .in1(neg_quotient_lsb_32), .in2(neg_quotient_lsb_32), .in3(quotient_lsb_32), .out(out)); 
	


endmodule