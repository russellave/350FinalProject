/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB                   // I: Data from port B of regfile
	 
	 ,sensor_input, sensor_output, controller, screen_out, score_out, mistake
	 
	 ,latch_4_o_out, isSetX,latch_4_d_out, latch_4_ir_out,latch_3_o_out, latch_3_b_out, latch_3_ir_out
	, Rwd, isALU, latch_2_pc_out, execute_out, execute_b_out, pc_jal, execute_pc, final_A, final_B,disabled_latch_prevclock_twice, ir_in_execute,isReady,latch_2_ir_out, latch_2_a_out, latch_2_b_out, isAddi, WE, latch_3_pc_jal_out, disabled_latch_prevclock,latch_4_pc_jal_out, flush, XM_a_bypass, XM_b_bypass, MW_b_bypass, is_jal, exception, disable_latches, enable //for debugging
);
    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [11:0] address_dmem;
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;
	 
	 input [31:0] sensor_input; //addr 0

	 input [31:0] controller; // addr 2
	 
	 
	 output [31:0] sensor_output; // addr 1
	 output [31:0] mistake; // addr 5
	 output [31:0] screen_out; //addr 3
	 output [31:0] score_out; //addr 4

    /* YOUR CODE STARTS HERE */
	 
	 
///////////////////////////////////////////////////////////////////////////////////////////////////


	// stall logic
	 wire stall_wo_mult, isStall; 
	 stall_logic stall(.isStall(stall_wo_mult), .irFD(latch_1_ir_out), .irDX(latch_2_ir_out), .rd_as_b(case_rd_as_b)); 

	 or orTotalStall(isStall, stall_wo_mult, disable_latches); 
///////////////////////////////////////////////////////////////////////////////////////////////////

	//some control signals

	 output flush; 
	 wire not_clear_latches, clear_latches, not_reset, not_clock; //useful for clrn  
	 or or_clear(clear_latches, reset, flush); 
	 not notclearlatch(not_clear_latches,clear_latches); 
	 not notreset(not_reset, reset); 
	 //fetch
	 
	 
	 //program counter
	 wire [31:0] counter, execute_pc_32;
	 assign execute_pc_32[11:0] = execute_pc;  
	 
	 pc prog_counter(.clock(clock), .clrn(not_reset), .out(counter), .pc_in(execute_pc_32), .use_pc_in(flush), .isStall(isStall)); 
			 
	 assign address_imem = counter; 		 
	 
	 //latch1
	 
	 wire[31:0] latch_1_ir_out, latch_1_pc_out, ir_latch_1_in; 
	 
	 mux_2 mux_stall(.out(ir_latch_1_in), .in0(q_imem), .in1(32'd0), .select(isStall)); 
	 
	 latch_1 latch_FD(.pc_in(counter),.ir_in(ir_latch_1_in), .ir_out(latch_1_ir_out), .clock(clock), .clrn(not_clear_latches),.pc_out(latch_1_pc_out), .enable(enable)); 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
	 //decode
	
	
	 //control for decode

	 //outputs for decode
	 wire[31:0] regA_out; 
	 wire[31:0] regB_out;
	 
	 wire [4:0] read_A_reg, read_A_reg_jr, read_B_reg, not_opcode_latch_1;
	 // a is $rd if jr, else $rs
	 //b is $rd if sw, blt, or bne, else $rt 
	 
	 not not1(not_opcode_latch_1[0], latch_1_ir_out[27]);
	 not not2(not_opcode_latch_1[1], latch_1_ir_out[28]);
	 not not3(not_opcode_latch_1[2], latch_1_ir_out[29]);
	 not not4(not_opcode_latch_1[3], latch_1_ir_out[30]);
	 not not5(not_opcode_latch_1[4], latch_1_ir_out[31]);
	 
 	 wire case_jr, case_bex; 
	 and andjr(case_jr, not_opcode_latch_1[4], not_opcode_latch_1[3], latch_1_ir_out[29], not_opcode_latch_1[1], not_opcode_latch_1[0]);
	 and andbex(case_bex, latch_1_ir_out[31], not_opcode_latch_1[3], latch_1_ir_out[29], latch_1_ir_out[28], not_opcode_latch_1[0] ); 
	 assign read_A_reg_jr = case_jr ? latch_1_ir_out[26:22]: latch_1_ir_out[21:17];
	 assign read_A_reg = case_bex ? 5'd30 : read_A_reg_jr; 
	 //NOTE: For branches, $rd should be a and $rs should be b, but I have it backwards. This was accounted for in the execute module. 
	 wire case_sw, case_bne, case_blt, case_rd_as_b; 
	 and andsw(case_sw, not_opcode_latch_1[4], not_opcode_latch_1[3], latch_1_ir_out[29], latch_1_ir_out[28], latch_1_ir_out[27] ); 
	 and andbne(case_bne, not_opcode_latch_1[4], not_opcode_latch_1[3], not_opcode_latch_1[2], latch_1_ir_out[28], not_opcode_latch_1[0]);
	 and andblt(case_blt, not_opcode_latch_1[4], not_opcode_latch_1[3], latch_1_ir_out[29], latch_1_ir_out[28],not_opcode_latch_1[0] );
	 or or_rdasb(case_rd_as_b, case_sw, case_bne, case_blt); 
	 assign read_B_reg = case_rd_as_b ? latch_1_ir_out[26:22]: latch_1_ir_out[16:12]; 
	 
	 assign ctrl_readRegA = read_A_reg; 
	 assign ctrl_readRegB = read_B_reg;

	 
//////////////////////////////////////////////////////////////////////////////////////////////////

	 
	 //latch2
	 output[31:0] latch_2_pc_out, latch_2_ir_out, latch_2_a_out, latch_2_b_out; 
		 
	 
	 
	 latch_2 latch_2_DX(.pc_in(latch_1_pc_out), .ir_in(latch_1_ir_out), .a_in(data_readRegA), .b_in(data_readRegB), .pc_out(latch_2_pc_out), .ir_out(latch_2_ir_out), .a_out(latch_2_a_out), .b_out(latch_2_b_out), .clock(clock), .clrn(not_clear_latches), .enable(enable));
	 
//////////////////////////////////////////////////////////////////////////////////////////////////


	 //execute 
	 output is_jal, exception, disable_latches, enable, isReady; 
	 output[31:0] execute_out, execute_b_out, pc_jal, execute_pc; 
	 
	 output disabled_latch_prevclock, disabled_latch_prevclock_twice; 
	 not not_enable(enable, disable_latches);  //allow for next instruction/a/b to be placed in DX latch

	 dflipflop store_latch_disabled_prevclock(.d(disable_latches), .clk(clock), .clrn(1'd1), .ena(1'd1), .q(disabled_latch_prevclock));
	 dflipflop store_latch_disabled_prevclock_twice(.d(disabled_latch_prevclock), .clk(clock), .clrn(1'd1), .ena(1'd1), .q(disabled_latch_prevclock_twice));
	 wire choose_ir; 
	 or or_choose_ir(choose_ir,disabled_latch_prevclock_twice ,disabled_latch_prevclock); 
	 output [31:0] ir_in_execute, final_A, final_B; 
	 assign ir_in_execute = choose_ir ? 32'd0 : latch_2_ir_out;
	 assign final_A = disabled_latch_prevclock ? 32'd0 : XM_a_bypass;
	 assign final_B = disabled_latch_prevclock ? 32'd0 : XM_b_bypass;
	 
	 execute execute1(.clock(clock), .isMultDiv_in(disabled_latch_prevclock),.a(XM_a_bypass),.b_in(XM_b_bypass),.ir(ir_in_execute), .out(execute_out),.b_out(execute_b_out), .pc_in(latch_2_pc_out), .pc_out(execute_pc), .case_jal(is_jal), .overflow(exception), .pc_jal(pc_jal),.flush(flush), .disable_latches(disable_latches), .isReady(isReady));


//////////////////////////////////////////////////////////////////////////////////////////////////
	 
	 //latch3
	 output[31:0] latch_3_o_out, latch_3_b_out, latch_3_ir_out, latch_3_pc_jal_out; 
	 wire latch_3_exception_out, latch_3_jal_out; 
	 latch_3 latch_3_XM(.o_in(execute_out), .ir_in(latch_2_ir_out), .b_in(execute_b_out), .o_out(latch_3_o_out), .ir_out(latch_3_ir_out), .b_out(latch_3_b_out), .clock(clock), .clrn(not_reset),
	 .jal_in(is_jal), .jal_out(latch_3_jal_out), .exception_in(exception), .exception_out(latch_3_exception_out), .pc_jal_in(pc_jal), .pc_jal_out(latch_3_pc_jal_out), .enable(enable)); 

//////////////////////////////////////////////////////////////////////////////////////////////////

	 
	 //memory
	 
	 //control for memory
	 wire [31:0] not_opcode_latch_3; 
	not not000(not_opcode_latch_3[0],latch_3_ir_out[0]);                                                            
	not not111(not_opcode_latch_3[1],latch_3_ir_out[1]);                                                            
	not not222(not_opcode_latch_3[2],latch_3_ir_out[2]);                                                            
	not not333(not_opcode_latch_3[3],latch_3_ir_out[3]);                                                            
	not not444(not_opcode_latch_3[4],latch_3_ir_out[4]);                                                            
	not not555(not_opcode_latch_3[5],latch_3_ir_out[5]);                                                            
	not not666(not_opcode_latch_3[6],latch_3_ir_out[6]);                                                            
	not not777(not_opcode_latch_3[7],latch_3_ir_out[7]);                                                            
	not not888(not_opcode_latch_3[8],latch_3_ir_out[8]);                                                            
	not not999(not_opcode_latch_3[9],latch_3_ir_out[9]);                                                            
	not not101010(not_opcode_latch_3[10],latch_3_ir_out[10]);                                                       
	not not111111(not_opcode_latch_3[11],latch_3_ir_out[11]);                                                       
	not not121212(not_opcode_latch_3[12],latch_3_ir_out[12]);                                                       
	not not131313(not_opcode_latch_3[13],latch_3_ir_out[13]);                                                       
	not not141414(not_opcode_latch_3[14],latch_3_ir_out[14]);                                                       
	not not151515(not_opcode_latch_3[15],latch_3_ir_out[15]);                                                       
	not not161616(not_opcode_latch_3[16],latch_3_ir_out[16]);                                                       
	not not171717(not_opcode_latch_3[17],latch_3_ir_out[17]);                                                       
	not not181818(not_opcode_latch_3[18],latch_3_ir_out[18]);                                                       
	not not191919(not_opcode_latch_3[19],latch_3_ir_out[19]);                                                       
	not not202020(not_opcode_latch_3[20],latch_3_ir_out[20]);                                                       
	not not212121(not_opcode_latch_3[21],latch_3_ir_out[21]);                                                       
	not not222222(not_opcode_latch_3[22],latch_3_ir_out[22]);                                                       
	not not232323(not_opcode_latch_3[23],latch_3_ir_out[23]);                                                       
	not not242424(not_opcode_latch_3[24],latch_3_ir_out[24]);                                                       
	not not252525(not_opcode_latch_3[25],latch_3_ir_out[25]);                                                       
	not not262626(not_opcode_latch_3[26],latch_3_ir_out[26]);                                                       
	not not272727(not_opcode_latch_3[27],latch_3_ir_out[27]);                                                       
	not not282828(not_opcode_latch_3[28],latch_3_ir_out[28]);                                                             
	not not292929(not_opcode_latch_3[29],latch_3_ir_out[29]);                                                       
	not not303030(not_opcode_latch_3[30],latch_3_ir_out[30]);                                                       
	not not313131(not_opcode_latch_3[31],latch_3_ir_out[31]);         
	 //wren for only  sw 
	 
	 and andswM(wren,not_opcode_latch_3[31],not_opcode_latch_3[30],latch_3_ir_out[29],latch_3_ir_out[28],latch_3_ir_out[27]); 
	
	 assign address_dmem = latch_3_o_out[11:0]; 
	 assign data = MW_b_bypass; 


//////////////////////////////////////////////////////////////////////////////////////////////////


 
	 //latch4
	 output[31:0] latch_4_o_out, latch_4_d_out, latch_4_ir_out, latch_4_pc_jal_out; 
	 wire latch_4_exception_out, latch_4_jal_out; 
	 //ADD MEMORY MAPPED I/O HERE. INPUTS TO SYSTEM. 
	 wire case_lwM, case_swM, addr0, addr1, addr2, addr3, addr4, addr5, addr6, addr7, addr8; 
	 and andlwM(case_lwM,not_opcode_latch_3[31],latch_3_ir_out[30],not_opcode_latch_3[29],not_opcode_latch_3[28],not_opcode_latch_3[27]); 

	 and andaddr0(addr0, not_opcode_latch_3[0],not_opcode_latch_3[1],not_opcode_latch_3[2],not_opcode_latch_3[3],not_opcode_latch_3[4],not_opcode_latch_3[5],not_opcode_latch_3[6],not_opcode_latch_3[7],not_opcode_latch_3[8],not_opcode_latch_3[9],not_opcode_latch_3[10],not_opcode_latch_3[11],not_opcode_latch_3[12],not_opcode_latch_3[13],not_opcode_latch_3[14],not_opcode_latch_3[15]);                                                                                                                                               
	 and andaddr1(addr1, latch_3_ir_out[0],not_opcode_latch_3[1],not_opcode_latch_3[2],not_opcode_latch_3[3],not_opcode_latch_3[4],not_opcode_latch_3[5],not_opcode_latch_3[6],not_opcode_latch_3[7],not_opcode_latch_3[8],not_opcode_latch_3[9],not_opcode_latch_3[10],not_opcode_latch_3[11],not_opcode_latch_3[12],not_opcode_latch_3[13],not_opcode_latch_3[14],not_opcode_latch_3[15]);                                                                                                                                                   
	 and andaddr2(addr2, not_opcode_latch_3[0],latch_3_ir_out[1],not_opcode_latch_3[2],not_opcode_latch_3[3],not_opcode_latch_3[4],not_opcode_latch_3[5],not_opcode_latch_3[6],not_opcode_latch_3[7],not_opcode_latch_3[8],not_opcode_latch_3[9],not_opcode_latch_3[10],not_opcode_latch_3[11],not_opcode_latch_3[12],not_opcode_latch_3[13],not_opcode_latch_3[14],not_opcode_latch_3[15]);                                                                                                                                                   
	 and andaddr3(addr3, latch_3_ir_out[0],latch_3_ir_out[1],not_opcode_latch_3[2],not_opcode_latch_3[3],not_opcode_latch_3[4],not_opcode_latch_3[5],not_opcode_latch_3[6],not_opcode_latch_3[7],not_opcode_latch_3[8],not_opcode_latch_3[9],not_opcode_latch_3[10],not_opcode_latch_3[11],not_opcode_latch_3[12],not_opcode_latch_3[13],not_opcode_latch_3[14],not_opcode_latch_3[15],);                                                                                                                                                       
	 and andaddr4(addr4, not_opcode_latch_3[0],not_opcode_latch_3[1],latch_3_ir_out[2],not_opcode_latch_3[3],not_opcode_latch_3[4],not_opcode_latch_3[5],not_opcode_latch_3[6],not_opcode_latch_3[7],not_opcode_latch_3[8],not_opcode_latch_3[9],not_opcode_latch_3[10],not_opcode_latch_3[11],not_opcode_latch_3[12],not_opcode_latch_3[13],not_opcode_latch_3[14],not_opcode_latch_3[15]);                                                                                                                                                   
	 and andaddr5(addr5, latch_3_ir_out[0],not_opcode_latch_3[1],latch_3_ir_out[2],not_opcode_latch_3[3],not_opcode_latch_3[4],not_opcode_latch_3[5],not_opcode_latch_3[6],not_opcode_latch_3[7],not_opcode_latch_3[8],not_opcode_latch_3[9],not_opcode_latch_3[10],not_opcode_latch_3[11],not_opcode_latch_3[12],not_opcode_latch_3[13],not_opcode_latch_3[14],not_opcode_latch_3[15]);                                                                                                                                                       
	 and andaddr6(addr6, not_opcode_latch_3[0],latch_3_ir_out[1],latch_3_ir_out[2],not_opcode_latch_3[3],not_opcode_latch_3[4],not_opcode_latch_3[5],not_opcode_latch_3[6],not_opcode_latch_3[7],not_opcode_latch_3[8],not_opcode_latch_3[9],not_opcode_latch_3[10],not_opcode_latch_3[11],not_opcode_latch_3[12],not_opcode_latch_3[13],not_opcode_latch_3[14],not_opcode_latch_3[15]);                                                                                                                                                       
	 and andaddr7(addr7, latch_3_ir_out[0],latch_3_ir_out[1],latch_3_ir_out[2],not_opcode_latch_3[3],not_opcode_latch_3[4],not_opcode_latch_3[5],not_opcode_latch_3[6],not_opcode_latch_3[7],not_opcode_latch_3[8],not_opcode_latch_3[9],not_opcode_latch_3[10],not_opcode_latch_3[11],not_opcode_latch_3[12],not_opcode_latch_3[13],not_opcode_latch_3[14],not_opcode_latch_3[15]);          
	 and andaddr8(addr8, not_opcode_latch_3[0],not_opcode_latch_3[1],not_opcode_latch_3[2],latch_3_ir_out[3],not_opcode_latch_3[4],not_opcode_latch_3[5],not_opcode_latch_3[6],not_opcode_latch_3[7],not_opcode_latch_3[8],not_opcode_latch_3[9],not_opcode_latch_3[10],not_opcode_latch_3[11],not_opcode_latch_3[12],not_opcode_latch_3[13],not_opcode_latch_3[14],not_opcode_latch_3[15]);                                                                                                                                                   
                                                                                     
	 

	 //0: sensor in, 1: sensor out, 2: controller, 3: screen out, 4: score out, 5: mistake
	 
	 wire case_sensor_output, case_mistake, case_screen_out, case_score_out; //work with sw 
	 wire case_sensor_input, case_controller; //work with lw

	 and and_sensor_in(case_sensor_input, case_lwM, addr0); 
	 and and_sensor_out(case_sensor_output, wren, addr1); 
	 and and_controller(case_controller, case_lwM, addr2); 
	 and and_screen_out(case_screen_out, wren, addr3); 
	 and and_score_out(case_score_out, wren, addr4);
	 and and_mistake(case_mistake, wren, addr5); 
	 
	 mux_2 mux_sensor_output(.in0(32'd0), .in1(latch_3_o_out), .select(case_sensor_output), .out(sensor_output));
	 mux_2 mux_mistake(.in0(32'd0), .in1(latch_3_o_out), .select(case_mistake), .out(mistake));
 	 mux_2 mux_screen_out(.in0(32'd0), .in1(latch_3_o_out), .select(case_screen_out), .out(screen_out));
	 mux_2 mux_score_out(.in0(32'd0), .in1(latch_3_o_out), .select(case_score_out), .out(score_out));

	 wire [31:0]latch_4_d_in; 
	 
	 mux_2 mux_sensor_input(.in0(q_dmem), .in1(sensor_input), .select(case_sensor_input), .out(out_sensor_input));
	 mux_2 mux_controller(.in0(out_sensor_input), .in1(controller), .select(case_controller), .out(latch_4_d_in));
	 
	 
	 
	 latch_4 latch_4_MW(.ir_in(latch_3_ir_out), .ir_out(latch_4_ir_out), .o_in(latch_3_o_out), .d_in(latch_4_d_in), .o_out(latch_4_o_out), .d_out(latch_4_d_out), .clock(clock), .clrn(not_reset),
	 .jal_in(latch_3_jal_out), .jal_out(latch_4_jal_out), .exception_in(latch_3_exception_out), .exception_out(latch_4_exception_out), .pc_jal_in(latch_3_pc_jal_out), .pc_jal_out(latch_4_pc_jal_out), .enable(enable));


	 
//////////////////////////////////////////////////////////////////////////////////////////////////

	 
	 //writeback
	 //control for writeback
	 output Rwd, isALU, isAddi,WE, isSetX ; //Rwd is same as isLW

	 wire[31:0] data_write, out_not_jal_not_exception, out_check_jal,output_exception; 
	 
	 wire [4:0] not_opcode_latch_4; 
	 not not11(not_opcode_latch_4[0], latch_4_ir_out[27]);
	 not not12(not_opcode_latch_4[1], latch_4_ir_out[28]);
	 not not13(not_opcode_latch_4[2], latch_4_ir_out[29]);
	 not not14(not_opcode_latch_4[3], latch_4_ir_out[30]);
	 not not15(not_opcode_latch_4[4], latch_4_ir_out[31]);
	 
	 and andRWD(Rwd, not_opcode_latch_4[4], latch_4_ir_out[30],not_opcode_latch_4[2],not_opcode_latch_4[1], not_opcode_latch_4[0]); 
	 and andALU(isALU, not_opcode_latch_4[4], not_opcode_latch_4[3],not_opcode_latch_4[2],not_opcode_latch_4[1], not_opcode_latch_4[0]); 
	 and andAddi(isAddi,not_opcode_latch_4[4], not_opcode_latch_4[3], latch_4_ir_out[29], not_opcode_latch_4[1], latch_4_ir_out[27] ); 
	 and andSetX(isSetX, latch_4_ir_out[31],not_opcode_latch_4[3],latch_4_ir_out[29],not_opcode_latch_4[1], latch_4_ir_out[27]);  
	 
	 or orWE(WE, Rwd, isALU, isAddi, latch_4_jal_out,latch_4_exception_out, isSetX); 
	 
	 
	 
	 mux_2 mux1_wb(.out(out_not_jal_not_exception), .in0(latch_4_o_out), .in1(latch_4_d_out), .select(Rwd)); 
	 mux_2 mux2_wb(.out(out_check_jal), .in0(out_not_jal_not_exception), .in1(latch_4_pc_jal_out), .select(latch_4_jal_out)); 
	 
	 assign output_exception[4:0] = latch_4_ir_out[6:2]; 
	 wire [31:0] out_check_jal_exception; 
	 mux_2 mux3_wb(.out(out_check_jal_exception), .in0(out_check_jal), .in1(output_exception), .select(latch_4_exception_out)); 
	 mux_2 mux4_wb(.out(data_write), .in0(out_check_jal_exception), .in1(latch_4_ir_out[26:0]), .select(isSetX)); 
 	 assign ctrl_writeEnable = WE; 
	 wire [4:0] write_reg; 
    
	 wire exception_or_setex; 
	 or ex_or_set(exception_or_setex, isSetX, latch_4_exception_out); 
	 assign write_reg = exception_or_setex ? 5'b11110 : latch_4_ir_out[26:22];
    
	 assign ctrl_writeReg = latch_4_jal_out ? 5'b11111 : write_reg; 
	 
	 assign data_writeReg = data_write;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	output [31:0] XM_a_bypass, XM_b_bypass, MW_b_bypass; 
	 //bypass logic
	 bypass_logic bypasslog(.DX_ir(latch_2_ir_out), .XM_ir(latch_3_ir_out), .MW_ir(latch_4_ir_out),
	 .DX_a_in(latch_2_a_out), .DX_b_in(latch_2_b_out), .MW_b_in(latch_3_b_out), .data_write(data_write), .XM_o(latch_3_o_out), 
	 .DX_a_out(XM_a_bypass), .DX_b_out(XM_b_bypass), .MW_b_out(MW_b_bypass), .case_rd_as_b(case_rd_as_b));
	 
	 //end
	 
	 
endmodule
