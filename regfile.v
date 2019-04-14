module regfile (
    clock,
    ctrl_writeEnable,
    ctrl_reset, ctrl_writeReg,
    ctrl_readRegA, ctrl_readRegB, data_writeReg,
    data_readRegA, data_readRegB
);

   input clock, ctrl_writeEnable, ctrl_reset;
   input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
   input [31:0] data_writeReg;

   output [31:0] data_readRegA, data_readRegB;

   /* YOUR CODE HERE */
	wire [31:0] write; 
	wire [31:0] w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31;
	wire [31:0] w0 = 0;
	decoder32 decode(.out(write), .select(ctrl_writeReg), .enable(ctrl_writeEnable));//check this logic
	//reg 0 is always 0 (read from w0)
	register_regfile reg_1(.in(data_writeReg), .out(w1), .clock(clock), .in_en(write[1]), .reset(ctrl_reset));
	register_regfile reg_2(.in(data_writeReg), .out(w2), .clock(clock), .in_en(write[2]), .reset(ctrl_reset));
	register_regfile reg_3(.in(data_writeReg), .out(w3), .clock(clock), .in_en(write[3]), .reset(ctrl_reset));
	register_regfile reg_4(.in(data_writeReg), .out(w4), .clock(clock), .in_en(write[4]), .reset(ctrl_reset));
	register_regfile reg_5(.in(data_writeReg), .out(w5), .clock(clock), .in_en(write[5]), .reset(ctrl_reset));
	register_regfile reg_6(.in(data_writeReg), .out(w6), .clock(clock), .in_en(write[6]), .reset(ctrl_reset));
	register_regfile reg_7(.in(data_writeReg), .out(w7), .clock(clock), .in_en(write[7]), .reset(ctrl_reset));
	register_regfile reg_8(.in(data_writeReg), .out(w8), .clock(clock), .in_en(write[8]), .reset(ctrl_reset));
	register_regfile reg_9(.in(data_writeReg), .out(w9), .clock(clock), .in_en(write[9]), .reset(ctrl_reset));
	register_regfile reg_10(.in(data_writeReg), .out(w10), .clock(clock), .in_en(write[10]), .reset(ctrl_reset));
	register_regfile reg_11(.in(data_writeReg), .out(w11), .clock(clock), .in_en(write[11]), .reset(ctrl_reset));
	register_regfile reg_12(.in(data_writeReg), .out(w12), .clock(clock), .in_en(write[12]), .reset(ctrl_reset));
	register_regfile reg_13(.in(data_writeReg), .out(w13), .clock(clock), .in_en(write[13]), .reset(ctrl_reset));
	register_regfile reg_14(.in(data_writeReg), .out(w14), .clock(clock), .in_en(write[14]), .reset(ctrl_reset));
	register_regfile reg_15(.in(data_writeReg), .out(w15), .clock(clock), .in_en(write[15]), .reset(ctrl_reset));
	register_regfile reg_16(.in(data_writeReg), .out(w16), .clock(clock), .in_en(write[16]), .reset(ctrl_reset));
	register_regfile reg_17(.in(data_writeReg), .out(w17), .clock(clock), .in_en(write[17]), .reset(ctrl_reset));
	register_regfile reg_18(.in(data_writeReg), .out(w18), .clock(clock), .in_en(write[18]), .reset(ctrl_reset));
	register_regfile reg_19(.in(data_writeReg), .out(w19), .clock(clock), .in_en(write[19]), .reset(ctrl_reset));
	register_regfile reg_20(.in(data_writeReg), .out(w20), .clock(clock), .in_en(write[20]), .reset(ctrl_reset));
	register_regfile reg_21(.in(data_writeReg), .out(w21), .clock(clock), .in_en(write[21]), .reset(ctrl_reset));
	register_regfile reg_22(.in(data_writeReg), .out(w22), .clock(clock), .in_en(write[22]), .reset(ctrl_reset));
	register_regfile reg_23(.in(data_writeReg), .out(w23), .clock(clock), .in_en(write[23]), .reset(ctrl_reset));
	register_regfile reg_24(.in(data_writeReg), .out(w24), .clock(clock), .in_en(write[24]), .reset(ctrl_reset));
	register_regfile reg_25(.in(data_writeReg), .out(w25), .clock(clock), .in_en(write[25]), .reset(ctrl_reset));
	register_regfile reg_26(.in(data_writeReg), .out(w26), .clock(clock), .in_en(write[26]), .reset(ctrl_reset));
	register_regfile reg_27(.in(data_writeReg), .out(w27), .clock(clock), .in_en(write[27]), .reset(ctrl_reset));
	register_regfile reg_28(.in(data_writeReg), .out(w28), .clock(clock), .in_en(write[28]), .reset(ctrl_reset));
	register_regfile reg_29(.in(data_writeReg), .out(w29), .clock(clock), .in_en(write[29]), .reset(ctrl_reset));
	register_regfile reg_30(.in(data_writeReg), .out(w30), .clock(clock), .in_en(write[30]), .reset(ctrl_reset));
	register_regfile reg_31(.in(data_writeReg), .out(w31), .clock(clock), .in_en(write[31]), .reset(ctrl_reset));
	
	mux_32 muxA(.out(data_readRegA),.select(ctrl_readRegA),.in0(w0), .in1(w1), .in2(w2), .in3(w3), .in4(w4), .in5(w5), .in6(w6), .in7(w7), .in8(w8), .in9(w9), .in10(w10), .in11(w11), .in12(w12), .in13(w13), .in14(w14), .in15(w15), .in16(w16), .in17(w17), .in18(w18), .in19(w19), .in20(w20), .in21(w21), .in22(w22), .in23(w23), .in24(w24), .in25(w25), .in26(w26), .in27(w27), .in28(w28), .in29(w29), .in30(w30), .in31(w31));
	mux_32 muxB(.out(data_readRegB),.select(ctrl_readRegB),.in0(w0), .in1(w1), .in2(w2), .in3(w3), .in4(w4), .in5(w5), .in6(w6), .in7(w7), .in8(w8), .in9(w9), .in10(w10), .in11(w11), .in12(w12), .in13(w13), .in14(w14), .in15(w15), .in16(w16), .in17(w17), .in18(w18), .in19(w19), .in20(w20), .in21(w21), .in22(w22), .in23(w23), .in24(w24), .in25(w25), .in26(w26), .in27(w27), .in28(w28), .in29(w29), .in30(w30), .in31(w31));

	
	
endmodule
