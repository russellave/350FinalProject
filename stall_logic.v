module stall_logic(isStall, irFD, irDX, rd_as_b,
	first_equal, second_equal,opDXisLoad, opFDisStore, NOTopFDisStore, fd_ir_rs2, dx_ir_rd, fd_ir_rs1); 
	output isStall; 
	input [31:0] irFD, irDX;
	input rd_as_b; 

	
	wire [4:0] not_opcodeDX, not_opcodeFD; 
	not not1(not_opcodeDX[0], irDX[27]);
	not not2(not_opcodeDX[1], irDX[28]);
	not not3(not_opcodeDX[2], irDX[29]);
	not not4(not_opcodeDX[3], irDX[30]);
	not not5(not_opcodeDX[4], irDX[31]);
	
	not not11(not_opcodeFD[0], irFD[27]);
	not not22(not_opcodeFD[1], irFD[28]);
	not not33(not_opcodeFD[2], irFD[29]);
	not not44(not_opcodeFD[3], irFD[30]);
	not not55(not_opcodeFD[4], irFD[31]);
	
	output opDXisLoad, opFDisStore, NOTopFDisStore; 
	and andDXLoad(opDXisLoad, not_opcodeDX[4], irDX[30], not_opcodeDX[2], not_opcodeDX[1], not_opcodeDX[0]); 
	and andFDStore(opFDisStore, not_opcodeFD[4],not_opcodeFD[3], irFD[29], irFD[28], irFD[27]); 
	not notfdstore(NOTopFDisStore, opFDisStore);
	
	output [4:0] fd_ir_rs2, dx_ir_rd, fd_ir_rs1; 
	assign fd_ir_rs2 = rd_as_b ? irFD[26:22] : irFD[16:12]; //b_register
	assign dx_ir_rd = irDX[26:22];
	assign fd_ir_rs1 = irFD[21:17]; //a_register
	
	//to check if equal, perform xor, then a nor on the output of that
	
	genvar i; 
	wire[4:0] out_first, out_second; //first: fd_ir_rs1 == dx_ir_rd, second: fd_ir_rs2 == dx_ir_rd
	generate
		for (i = 0; i<5; i=i+1) begin: loop1
			xor xor_check(out_first[i],fd_ir_rs1[i],dx_ir_rd[i]);
			xor xor_check2(out_second[i],fd_ir_rs2[i],dx_ir_rd[i]);
		end
	endgenerate
	output first_equal, second_equal; 
	nor nor_1(first_equal, out_first[0],out_first[1],out_first[2],out_first[3],out_first[4]); 
	nor nor_2(second_equal, out_second[0],out_second[1],out_second[2],out_second[3],out_second[4]);
	
	wire check_1, check_2; 
	and and_first(check_1, first_equal, NOTopFDisStore); 
	or or_second(check_2, second_equal, check_1); 
	and and_final(isStall, check_2, opDXisLoad); 
	
	
endmodule