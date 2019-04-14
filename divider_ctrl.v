module divider_ctrl(dividend, divisor, neg_divisor,count, old_quo, new_quo);
input [31:0] dividend, divisor, neg_divisor, count; 
input [63:0] old_quo; 
output [63:0] new_quo; 


wire count_select; 

//see if first iteration (count = 0). if so, add dividend to right 16 bits and have left 16 bits be 0. 
//else, get the previous quouct saved in the register
or or1(count_select, count[0], count[1],count[2],count[3],count[4], count[5],count[6],count[7],count[8],count[9],count[10],count[12],count[11],count[13],count[14],count[15]); 

wire [63:0] quo_start; 
assign quo_start[31:0] = dividend; 

wire [63:0] old_quo_selected; 
mux_2_64 mux2(.select(count_select), .in0(quo_start), .in1(old_quo), .out(old_quo_selected)); 

//calculate  subtract divisor to left 32 bits of quo and add 1 to quotient 

wire[63:0] sub_div_add_quo; 
wire[31:0] one_wire,zero_wire; 
assign one_wire[0] = 1; 

wire [31:0] old_quo_msb32, old_quo_lsb32; 
assign old_quo_msb32 = old_quo_selected[63:32];
assign old_quo_lsb32 = old_quo_selected[31:0]; 
assign sub_div_add_quo[31:0] = old_quo_lsb32; 
wire c_out3; 
cla_adder adder1(.data_a(old_quo_msb32), .data_b(neg_divisor), .data_out(sub_div_add_quo[63:32]), .c_in(1'b0),.c_out(c_out3)); 

//shift sub_div_add_quo
wire [63:0] shift_sub_div_add_quo;  
assign shift_sub_div_add_quo[63:1] = sub_div_add_quo[62:0]; 
wire[63:0] final_pos_case;
wire c_out, c_out2; 
cla_adder adder2(.data_a(shift_sub_div_add_quo[31:0]), .data_b(one_wire), .data_out(final_pos_case[31:0]), .c_in(1'b0), .c_out(c_out)); 
cla_adder adder3(.data_a(shift_sub_div_add_quo[63:32]), .data_b(zero_wire), .data_out(final_pos_case[63:32]), .c_in(c_out), .c_out(c_out2));

//decide whether sub_div_add_quo or old_quo
//output 0 if sub_div_add_quo msb32 is NEGATIVE, output 1 if not negative
wire perform_sub; 
nand nand1(perform_sub, sub_div_add_quo[63], 1'b1); 



wire[63:0] old_quo_selected_shift; 
assign old_quo_selected_shift[63:1] = old_quo_selected[62:0];

mux_2_64 mux2_2(.select(perform_sub), .in0(old_quo_selected_shift), .in1(final_pos_case), .out(new_quo)); 

endmodule