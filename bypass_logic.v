module bypass_logic(DX_ir, XM_ir, MW_ir, DX_a_in, DX_b_in, MW_b_in, data_write, XM_o, DX_a_out, DX_b_out, MW_b_out, case_rd_as_b);
	input [31:0] DX_ir, XM_ir, MW_ir, DX_a_in, DX_b_in, MW_b_in, data_write, XM_o; 
	output [31:0] DX_a_out, DX_b_out, MW_b_out; 
   input case_rd_as_b; 
	wire [1:0] DX_a_select, DX_b_select; 
	wire XM_b_select; 
	
	
	//DX_a_select
	
	wire [4:0] dx_ir_rs1, xm_ir_rd, mw_ir_rd, dx_ir_rt; 
	assign dx_ir_rs1 = DX_ir[21:17]; 
	assign xm_ir_rd = XM_ir[26:22];
	assign mw_ir_rd = MW_ir[26:22];
	assign dx_ir_rt = case_rd_as_b ? DX_ir[26:22] : DX_ir[16:12]; 
	
	genvar i; 
	wire[4:0] out_first, out_second, out_first_b, out_second_b, out_m; //first: fd_ir_rs1 == dx_ir_rd, second: fd_ir_rs2 == dx_ir_rd
	generate
		for (i = 0; i<5; i=i+1) begin: loop1
			xor xor_check(out_first[i],dx_ir_rs1[i],xm_ir_rd[i]);
			xor xor_check2(out_second[i],dx_ir_rs1[i],mw_ir_rd[i]);
			xor xor_checkb(out_first_b[i],dx_ir_rt[i],xm_ir_rd[i]);
			xor xor_check2b(out_second_b[i],dx_ir_rt[i],mw_ir_rd[i]);
			xor xor_checkm(out_m[i],xm_ir_rd[i],mw_ir_rd[i]);
		end
	endgenerate
	
	nor nor_1(DX_a_select[0], out_first[0],out_first[1],out_first[2],out_first[3],out_first[4]); 
	nor nor_2(DX_a_select[1], out_second[0],out_second[1],out_second[2],out_second[3],out_second[4]);

	
	nor nor_1b(DX_b_select[0], out_first_b[0],out_first_b[1],out_first_b[2],out_first_b[3],out_first_b[4]); 
	nor nor_2b(DX_b_select[1], out_second_b[0],out_second_b[1],out_second_b[2],out_second_b[3],out_second_b[4]);
	

	nor nor_m(XM_b_select, out_m[0],out_m[1],out_m[2],out_m[3],out_m[4]); 

	
	
	//mw_ir_rd == xm_i_rd
	//select correct outputs
	
	//00 means neither case, 01 means xm case, 10 means mw case, 11 means mw case
//	mux_4 mux_DX_a(.out(DX_a_out), .in0(DX_a_in), .in1(XM_o), .in2(data_write), .in3(data_write), .select(DX_a_select)); 
//	mux_4 mux_DX_b(.out(DX_b_out), .in0(DX_b_in), .in1(XM_o), .in2(data_write), .in3(data_write), .select(DX_b_select)); 
//	
//	
//	mux_2 mux_XM_b(.out(MW_b_out), .in0(MW_b_in), .in1(data_write), .select(XM_b_select)); 

//next 3 lines are to replace previous 3 lines for NO bypassing 
	mux_4 mux_DX_a(.out(DX_a_out), .in0(DX_a_in), .in1(XM_o), .in2(data_write), .in3(data_write), .select(2'd0)); 
	mux_4 mux_DX_b(.out(DX_b_out), .in0(DX_b_in), .in1(XM_o), .in2(data_write), .in3(data_write), .select(2'd0)); 
	mux_2 mux_XM_b(.out(MW_b_out), .in0(MW_b_in), .in1(data_write), .select(1'd0)); 

	
	endmodule