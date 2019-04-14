module multiplier_ctrl(multiplier, mult_cand, neg_mult_cand, old_prod, new_prod, helper_in, helper_out,count);
input [31:0] multiplier, mult_cand, neg_mult_cand, count; 
input [63:0] old_prod; 
output [63:0] new_prod; 
input helper_in; 
output helper_out; 
wire count_select; 

//see if first iteration (count = 0). if so, add multiplier to right 16 bits and have left 16 bits be 0. 
//else, get the previous product saved in the register
or or1(count_select,count[0], count[1],count[2],count[3],count[4], count[5],count[6],count[7],count[8],count[9],count[10],count[12],count[11],count[13],count[14],count[15]); 

wire [63:0] prod_start; 
assign prod_start[31:0] = multiplier; 


wire [63:0] old_prod_selected; 
mux_2_64 mux2(.select(count_select), .in0(prod_start), .in1(old_prod), .out(old_prod_selected)); 


//figure out the booth input 
wire [1:0] booth_select; 
assign booth_select[1] = old_prod_selected[0]; 
assign helper_out = old_prod_selected[0]; 
assign booth_select[0] = helper_in; 


//booth logic
//01--> add, 10-->sub, 00 or 11-->nothing
wire[63:0] added_mult_cand, sub_mult_cand; 


wire [31:0] old_prod_msb32, old_prod_lsb32; 
assign old_prod_msb32 = old_prod_selected[63:32];
assign old_prod_lsb32 = old_prod_selected[31:0]; 
assign added_mult_cand[31:0] = old_prod_lsb32; 
assign sub_mult_cand[31:0] = old_prod_lsb32;
wire c_out1, c_out2;
cla_adder adder1(.data_a(old_prod_msb32), .data_b(mult_cand), .data_out(added_mult_cand[63:32]), .c_in(1'b0), .c_out(c_out1)); 
cla_adder adder2(.data_a(old_prod_msb32), .data_b(neg_mult_cand), .data_out(sub_mult_cand[63:32]), .c_in(1'b0), .c_out(c_out2)); 

wire[63:0] prod_before_shift; 
mux_4_64bit select_correct_output(.select(booth_select), .in0(old_prod_selected), .in1(added_mult_cand), .in2(sub_mult_cand), .in3(old_prod_selected), .out(prod_before_shift));

//shift final

assign new_prod[62:0] = prod_before_shift[63:1];
assign new_prod[63] = new_prod[62];  
endmodule