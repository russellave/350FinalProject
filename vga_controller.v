module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
							 sensor_input, 
							 sensor_output_adjusted,
							 controller, 
							 sensor_input_to_save, 
							 save_signal, 
							 load_signal, state_load_out, load_counter, final_out_dummy);

	
input iRST_n;
input iVGA_CLK;

output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;      

input [31:0] sensor_input; 
input [31:0] sensor_output_adjusted; 
input [31:0] controller; 
output [31:0] sensor_input_to_save; 
output [31:0] save_signal;  
output [31:0] load_signal; 
output [2:0] state_load_out; 
output [31:0] load_counter; 
output [31:0] final_out_dummy; 

             
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [7:0] index_main; 
wire [7:0] index_splash; 
wire [7:0] index_animation; 
wire [31:0] screen; 
wire [23:0] bgr_data_raw;
wire [23:0] bgr_data_raw_splash;
wire [23:0] bgr_data_raw_ani; 
wire cBLANK_n,cHS,cVS,rst;
wire animation; 
////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     ADDR<=19'd0;
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
     ADDR<=ADDR+1;
end
//////////////////////////
//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;

//DEFINE ALL MY MIF FILES HERE
img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index_main )
	);
//	
splash_data	splash_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index_splash )
	);
	
animation_data ani_data_inst(
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index_animation )
	);
	
/////////////////////////
//////Add switch-input logic here


////Color table output
img_index	dummy_index_inst (
	.address ( index_main ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	
	
img_index splash_index_inst(
	.address(index_splash), 
	.clock(iVGA_CLK),
	.q(bgr_data_raw_splash)); 
	
//img_index ani_index_inst(
//	.address(index_animation), 
//	.clock(iVGA_CLK),
//	.q(bgr_data_raw_ani)); 	
//////
//////latch valid data at falling edge;

//what I have to work with 

// sensor_input, sensor_output_adjusted, controller, sensor_input_to_save, save_signal;     
reg[23:0] color_output;
reg [9:0] x; 
reg [9:0] y;
reg [19:0] counter; 

//from i/o
reg [31:0] sensor_in; 
reg [31:0] sensor_out; 
reg [31:0] controller_reg; 
reg [31:0] sensor_in_to_save_reg; 
reg [31:0] save_signal_reg; 
reg [31:0] load_signal_reg; 
reg [31:0] sensor_out_to_load_reg;  //when I get an output and I want to save to constantly output it
//reg [31:0] sensor_out_to_save_reg;  //
//values vga_controller calculate
 
reg [31:0] screen_reg; 
reg [31:0] counter_reg; 
reg [31:0] counter_increment; 
reg [31:0] counter_game;
reg [31:0] counter_int;
reg [31:0] game_RNG;
reg [63:0] game_RNG_total;
reg [5:0] animation_reg; 

reg [31:0] points;


reg [15:0] counter_hit; 

//fsm stuff
parameter MAX_COUNT = 32'd200000000; 
parameter SIZE = 3, SIZE_CONTROLLER = 32, SIZE_LOAD = 3, SIZE_OUTPUT = 3; 
parameter SPLASH  = 3'b000, MAIN= 3'b001, SL = 3'b010, GAME = 3'b011; //screens (not states but just useful)
parameter MODE_SPLASH = 3'b000, MODE_MAIN = 3'b001, MODE_SAVE = 3'b010, MODE_LOAD = 3'b011, MODE_GAME = 3'b100; //modes
parameter LOC1 = 32'd1, LOC2 = 32'd2, LOC3 = 32'd3, NONE = 32'd0;  //save locations
parameter START = 3'b000, WAIT = 3'b001; 
parameter PAD1 = 32'd1, PAD2 = 32'd2, PAD3 = 32'd3; 
parameter OUT1 = 32'b11111111111111111111111111111110, OUT2 = 32'b11111111111111111111111111111101, OUT3 = 32'b11111111111111111111111111111011;
parameter CASE_NO_OUTPUT = 3'b000, CASE_NEW_OUTPUT = 3'b001, CASE_PAD1_OUTPUT = 3'B010, CASE_PAD2_OUTPUT = 3'B011, CASE_PAD3_OUTPUT = 3'B100; 
//parameter NO_INPUT = 32'b00000000000000000000000000011111; 
parameter NO_INPUT = 32'b11111111111111111111111111111111;  

parameter WAIT_GAME = 3'd0, GAME1 = 3'd1, GAME2 = 3'd2, GAME3 = 3'd3, GAMEOVER = 3'd4; 
//=============Internal Variables======================
reg   [SIZE-1:0] state;
reg   [SIZE_CONTROLLER-1:0] state_controller, state_controller2; 
reg	[SIZE_LOAD-1:0] state_load; 
reg	[SIZE_OUTPUT-1:0] state_output; 
reg [3:0] game_state;



always@(posedge VGA_CLK_n) 
begin
		screen_reg <= screen; 
		bgr_data <= bgr_data_raw;
		sensor_in <= sensor_input;
		controller_reg <= controller; 
				 //move this outside the mode fsm? just always store the output depending if there's a change or not
		 case(state_output)
			 CASE_NEW_OUTPUT : if (sensor_output_adjusted == PAD1) begin
							  state_output <=  #1  CASE_PAD1_OUTPUT;
						  end else if(sensor_output_adjusted == PAD2) begin
							  state_output <=  #1  CASE_PAD2_OUTPUT;
						  end else if(sensor_output_adjusted == PAD3) begin
							  state_output <=  #1  CASE_PAD3_OUTPUT;
						  end else begin
							  state <=  #1  CASE_NEW_OUTPUT;
							end
			 CASE_PAD1_OUTPUT : if (sensor_in != NO_INPUT) begin
							  state_output <=  #1  CASE_NEW_OUTPUT;
							end else begin
						  sensor_out_to_load_reg <= PAD1; 										  
						  state_output <=  #1 CASE_PAD1_OUTPUT;
							end
			CASE_PAD2_OUTPUT : if (sensor_in != NO_INPUT) begin
						state_output <=  #1  CASE_NEW_OUTPUT;
						end else begin
						sensor_out_to_load_reg <= PAD2; 										  
						state_output <=  #1 CASE_PAD2_OUTPUT;
				end
			 CASE_PAD3_OUTPUT : if (sensor_in != NO_INPUT) begin
						state_output <=  #1  CASE_NEW_OUTPUT;
						end else begin
						sensor_out_to_load_reg <= PAD3; 										  
						state_output <=  #1 CASE_PAD3_OUTPUT;
				end
			 default : state_output <=  #1  CASE_NEW_OUTPUT;
		 endcase
		//FSM
		case(state)
		 MODE_SPLASH : if (~controller_reg[1] || ~controller_reg[2]||~controller_reg[3] || ~controller_reg[0]) begin
						  state <=  #1  MODE_MAIN;
						  screen_reg <= MAIN; 
						end else begin
						  state <=  #1  MODE_SPLASH;
						  screen_reg <= SPLASH; 
						end
		 MODE_MAIN : if (~controller_reg[2] == 1'b1) begin
						  state <=  #1  MODE_LOAD;
						  screen_reg <= SL; 
					end else if (~controller_reg[1] == 1'b1) begin
						  state <=  #1  MODE_SAVE;
						  screen_reg <= SL; 
					end else if (~controller_reg[3] == 1'b1) begin
						  state <=  #1  MODE_GAME;
						  screen_reg <= GAME; 
					 end else begin
						  state <=  #1  MODE_MAIN;
						  screen_reg <= MAIN; 
						end
		MODE_GAME : if (~controller_reg[0] == 1'b1) begin
						  state <=  #1  MODE_MAIN;
						  screen_reg <= MAIN; 
						end else begin
						  state <=  #1  MODE_GAME;
						  screen_reg <= GAME;
						  case (game_state)
							WAIT_GAME: 
								begin
								counter_game <= counter_game+32'd1;
								counter_int <= 0; 

								game_RNG <= counter_game % 32'd3;  //just use some nonlinear function here
								
								if (game_RNG ==32'd0) begin
									sensor_out_to_load_reg <= OUT3;
									game_state <= #1 GAME3;
								end else if (game_RNG == 32'd1) begin
									sensor_out_to_load_reg <= OUT2;
									game_state <= #1 GAME2;
								end else if (game_RNG ==32'd2) begin
									sensor_out_to_load_reg <= OUT1;
									game_state <= #1 GAME1;
								end else if (counter_game >20) begin 
									game_state <= #1 GAMEOVER;
									
								end
								end
							GAME1:
								if (sensor_in[14:10] != 5'b11111) begin 
									if (sensor_in[14]==1'b0) points <= points +4;
									if (sensor_in[13:10] != 4'b1111) points <= points+2;
									game_state <= #1 WAIT_GAME;
								end else if (counter_int>MAX_COUNT) begin
									game_state <= #1 WAIT_GAME;
									counter_int <= 0; 
								end else if(counter >MAX_COUNT*2/3) begin
									animation_reg <= 6'b000011;
								end else if( counter > MAX_COUNT*1/3) begin
									animation_reg <= 6'b000010;
								end else if (counter > 0) begin
									animation_reg <= 6'b000001;
								end else begin
									counter_int <= counter_int+1;
									game_state <= GAME1; 
								end
							GAME2:
								if (sensor_in[9:5] != 5'b11111) begin 
									if (sensor_in[9]== 1'b0) points <= points +4;
									if (sensor_in[8:5] != 4'b1111) points <= points+2;
									game_state <= #1 WAIT_GAME;
								end else if (counter_int>MAX_COUNT) begin
									game_state <= #1 WAIT_GAME;
									counter_int <= 0; 
								end else if(counter >MAX_COUNT*2/3) begin
									animation_reg <= 6'b001100;
								end else if (counter > MAX_COUNT*1/3) begin
									animation_reg <= 6'b001000;
								end else if (counter > 0) begin
									animation_reg <= 6'b000100;
								end else begin
									counter_int <= counter_int+1;
									game_state <= GAME2; 
								
								end
							GAME3:
								if (sensor_in[4:0] != 5'b11111) begin 
									if (sensor_in[4]== 1'b0) points <= points +4;
									if (sensor_in[3:0] != 4'b1111) points <= points+2;
									game_state <= #1 WAIT_GAME;
								end else if (counter_int>MAX_COUNT) begin
									game_state <= #1 WAIT_GAME;
									counter_int <= 0; 
								end else if(counter >MAX_COUNT*2/3) begin
									animation_reg <= 6'b110000;
								end else if (counter > MAX_COUNT*1/3) begin
									animation_reg <= 6'b100000;
								end else if (counter > 0) begin
									animation_reg <= 6'b010000;
								end else begin
									counter_int <= counter_int+1;
									game_state <= GAME3; 

								end	
							GAMEOVER:
								begin
								game_state <= #1 GAMEOVER;
								end
						endcase
					end
						
		 MODE_SAVE : if (~controller_reg[0] == 1'b1) begin
						  state <=  #1  MODE_MAIN;
						  screen_reg <= MAIN; 
						  save_signal_reg <=NONE; 
						end else begin
						 state <=  #1  MODE_SAVE;
						 screen_reg <= SL; 
  						 sensor_in_to_save_reg <= sensor_input; 
						 case(state_controller)
							NONE:  if (~controller_reg[1] == 1'b1) begin
									  state_controller <= #1 LOC1; 
									  end else if (~controller_reg[2] == 1'b1) begin
									  state_controller <= #1 LOC2; 
									  end else if (~controller_reg[3] == 1'b1) begin
									  state_controller <= #1 LOC3; 
									  end else begin 
											state_controller<=NONE;
											save_signal_reg <= NONE; 
									  end
							LOC1:	if (~controller_reg[0] == 1'b1) begin
									  state_controller <= #1 NONE; 
									  end else if (~controller_reg[2] == 1'b1) begin
									  state_controller <= #1 LOC2; 
									  end else if (~controller_reg[3] == 1'b1) begin
									  state_controller <= #1 LOC3; 
									  end else begin 
											state_controller<=LOC1; 
											save_signal_reg <= LOC1; 
									  end
							LOC2: if (~controller_reg[0] == 1'b1) begin
									  state_controller <= #1 NONE; 
									  end else if (~controller_reg[1] == 1'b1) begin
									  state_controller <= #1 LOC1; 
									  end else if (~controller_reg[3] == 1'b1) begin
									  state_controller <= #1 LOC3; 
									  end else begin 
											state_controller<=LOC2; 
											save_signal_reg <= LOC2; 
									  end
							LOC3: if (~controller_reg[0] == 1'b1) begin
									  state_controller <= #1 NONE; 
									  end else if (~controller_reg[1] == 1'b1) begin
									  state_controller <= #1 LOC1; 
									  end else if (~controller_reg[2] == 1'b1) begin
									  state_controller <= #1 LOC2; 
									  end else begin 
											state_controller<=LOC3; 
											save_signal_reg <= LOC3; 
									  end
							default: begin 
							state_controller <= #1 NONE; 
							save_signal_reg <= #1 NONE; 
							end
							endcase
							end
		 MODE_LOAD : if (~controller_reg[0] == 1'b1) begin
						  state <=  #1  MODE_MAIN;
						  screen_reg <= MAIN; 
						  load_signal_reg <=NONE; 
						   sensor_out_to_load_reg <= NONE; 
						end else begin
						 state <=  #1  MODE_LOAD;
						 screen_reg <= SL; 

						  
						 case(state_controller2)
							NONE:  if (controller_reg[1] == 1'b0) begin
									  state_controller2 <= #1 LOC1; 
									  counter_increment <= 32'd0; 

									  end else if (controller_reg[2] == 1'b0) begin
									  state_controller2 <= #1 LOC2; 
									  counter_increment <= 32'd0; 

									  end else if (controller_reg[3] == 1'b0) begin
									  state_controller2 <= #1 LOC3; 
									  counter_increment <= 32'd0; 

									  end else begin 
											state_controller2<=NONE;
											load_signal_reg <= NONE; 
											counter_increment <= 32'd0; 
									  end
							LOC1:	if (~controller_reg[0] == 1'b1) begin
									  state_controller2 <= #1 NONE; 
									  end else if (~controller_reg[2] == 1'b1) begin
									  state_controller2 <= #1 LOC2; 
									  end else if (~controller_reg[3] == 1'b1) begin
									  state_controller2 <= #1 LOC3; 
									  end else begin 
											counter_reg <= 32'd500; 
											load_signal_reg <= LOC1; 
											state_controller2<=LOC1; 
											case(state_load)
												 START : if (sensor_out_to_load_reg == PAD1 || sensor_out_to_load_reg == PAD2 || sensor_out_to_load_reg == PAD3) begin
																 state_load <=  #1  WAIT;
															end else begin
																  state_load <=  #1  START;
																end
												 WAIT: if(sensor_input != NO_INPUT) begin
																  state_load <=  #1  START;
																  counter_reg <= counter_reg + counter_increment; 
																  counter_increment <= counter_increment + 32'd1;


															  end else begin
																  state_load <=  #1  WAIT;
												 end
												 default : state_load <=  #1  START;
											 endcase
									  end
							LOC2: if (~controller_reg[0] == 1'b1) begin
									  state_controller2 <= #1 NONE; 
									  end else if (~controller_reg[1] == 1'b1) begin
									  state_controller2 <= #1 LOC1; 
									  end else if (~controller_reg[3] == 1'b1) begin
									  state_controller2 <= #1 LOC3; 
									  end else begin 
											load_signal_reg <= LOC2; 
											state_controller2<=LOC2; 
											counter_reg <= 32'd1000; 
											case(state_load)
												 START : if (sensor_out_to_load_reg == PAD1 || sensor_out_to_load_reg == PAD2 || sensor_out_to_load_reg == PAD3) begin
																 state_load <=  #1  WAIT;
															end else begin
																  state_load <=  #1  START;
																end
												 WAIT: if(sensor_input != NO_INPUT) begin
																  state_load <=  #1  START;
																  counter_increment <= counter_increment + 32'd1;
																  counter_reg <= counter_reg + counter_increment; 
														 end else begin
																  state_load <=  #1  WAIT;
														 end
												 default : state_load <=  #1  START;
											 endcase
									  end
									  
							LOC3: if (~controller_reg[0] == 1'b1) begin
									  state_controller2 <= #1 NONE; 
									  end else if (~controller_reg[1] == 1'b1) begin
									  state_controller2 <= #1 LOC1; 
									  end else if (~controller_reg[2] == 1'b1) begin
									  state_controller2 <= #1 LOC2; 
									  end else begin 
											load_signal_reg <= LOC3; 
											state_controller2<=LOC3; 
											counter_reg <= 32'd1500; 
											case(state_load)
												 START : if (sensor_out_to_load_reg == PAD1 || sensor_out_to_load_reg == PAD2 || sensor_out_to_load_reg == PAD3) begin
																 state_load <=  #1  WAIT;
															end else begin
																  state_load <=  #1  START;
																end
												 WAIT: if(sensor_input != NO_INPUT) begin
																  state_load <=  #1  START;
																  counter_increment <= counter_increment + 32'd1;
																  counter_reg <= counter_reg + counter_increment; 
															  end else begin
																  state_load <=  #1  WAIT;
												 end
												 default : state_load <=  #1  START;
											 endcase
									  end
							default: begin 
							state_controller2 <= #1 NONE; 
							load_signal_reg <= #1 NONE; 
							end
							
							endcase	
						end						
				
					

				
		 default : state <=  #1  MAIN;
		 
		endcase
		
		
		//Colors



		x <= ADDR % 10'd640;
		y <= ADDR / 10'd640;
		// dark green: 24'h006400
		//light green: 24'h90EE90
		//middle green: h32CD32
		if(screen_reg == SPLASH) color_output <=bgr_data_raw_splash; 
		else begin //display hits
			if(((sensor_in[4] == 1'b0)) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400;  
			else if((sensor_in[0] ==1'b0) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90; 
			else if((sensor_in[1] == 1'b0) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90; 
			else if((sensor_in[2] == 1'b0) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90; 
			else if((sensor_in[3] == 1'b0) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90; 
			
			else if(((sensor_in[9] == 1'b0)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h006400; 
			else if((sensor_in[5] == 1'b0) && (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h90EE90;  
			else if(((sensor_in[6] == 1'b0)) && (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h90EE90;  
			else if(((sensor_in[7] == 1'b0)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h90EE90; 
			else if(((sensor_in[8] == 1'b0)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h90EE90; 

			else if(((sensor_in[14] == 1'b0)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400;
			else if(((sensor_in[10] == 1'b0)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;
			else if(((sensor_in[11] == 1'b0)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;
			else if(((sensor_in[12] == 1'b0)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;
			else if(((sensor_in[13] == 1'b0)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;
			
			else color_output <=bgr_data; 
		end
		
		if(screen_reg == MAIN)
		begin //display main screen
			if((x > 10'd75) && (x<10'd572)&&(y<10'd98) && (y>10'd60)) color_output<=24'hFFFFFF; //no scores
			if((x > 10'd11) && (x<10'd125)&&(y<10'd381) && (y>10'd286)) color_output<=24'hFFFFFF; //no save load play
			if((x<10'd75)&&(y<10'd33)) color_output<=24'hFFFFFF; //no back
		end
		
		
		if(screen_reg == SL) 
		begin //display sl screen
			if((x > 10'd82) && (x<10'd562)&&(y<10'd57) && (y>10'd0)) color_output<=24'hFFFFFF;
			if((x > 10'd11) && (x<10'd125)&&(y<10'd381) && (y>10'd286)) color_output<=24'hFFFFFF;

		end
		
		if(screen_reg == GAME)
		begin //display game screen
			if((x > 10'd71) && (x<10'd573)&&(y<10'd97) && (y>10'd0)) color_output<=24'hFFFFFF;
		
		
		
			if(animation_reg == 6'b000001) begin
				//182,271: 274, 334
				if((x > 10'd182) && (x<10'd271)&&(y<10'd334) && (y>10'd274)) color_output<=bgr_data_raw_ani;

			end
			if(animation_reg == 6'b000010) begin
				//152,224: 207, 263
				if((x > 10'd152) && (x<10'd207)&&(y<10'd263) && (y>10'd207)) color_output<=bgr_data_raw_ani;

			end
			if(animation_reg == 6'b000011) begin
				//74, 111, //170, 167
				if((x > 10'd74) && (x<10'd170)&&(y<10'd167) && (y>10'd111)) color_output<=bgr_data_raw_ani;

			end
			if(animation_reg == 6'b000100) begin
				//281,290, //346, 382
				if((x > 10'd281) && (x<10'd346)&&(y<10'd382) && (y>10'd290)) color_output<=bgr_data_raw_ani;

			end
			if(animation_reg == 6'b001000) begin
				//294, 219: 339,288
				if((x > 10'd294) && (x<10'd339)&&(y<10'd219) && (y>10'd288)) color_output<=bgr_data_raw_ani;
				
				
			end
			if(animation_reg == 6'b001100) begin
				//267,33 : 367, 83
				if((x > 10'd267) && (x<10'd367)&&(y<10'd83) && (y>10'd33)) color_output<=bgr_data_raw_ani;

			end
			if(animation_reg == 6'b010000) begin
				//347, 274: 431, 337
				if((x > 10'd347) && (x<10'd431)&&(y<10'd337) && (y>10'd274)) color_output<=bgr_data_raw_ani;

			end
			if(animation_reg == 6'b100000)begin
				//420, 219 : 485, 264
				if((x > 10'd420) && (x<10'd485)&&(y<10'd264) && (y>10'd219)) color_output<=bgr_data_raw_ani;

			end
			if(animation_reg == 6'b110000)begin
				//451, 118 : 557, 179
				if((x > 10'd451) && (x<10'd557)&&(y<10'd179) && (y>10'd118)) color_output<=bgr_data_raw_ani;

			end
		end
		
		
end

assign save_signal = save_signal_reg; 
assign load_signal = load_signal_reg; 
assign sensor_input_to_save = sensor_in_to_save_reg; 
assign state_load_out = state_load; 
assign b_data = color_output[23:16];
assign g_data = color_output[15:8];
assign r_data = color_output[7:0]; 
assign load_counter = counter_reg; 
assign final_out_dummy = sensor_out_to_load_reg; 

///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end
//sample comment



endmodule