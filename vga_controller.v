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
							 load_signal, state_load_out, load_counter);

	
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

             
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [7:0] index_main; 
wire [7:0] index_splash; 
wire [31:0] screen; 
wire [23:0] bgr_data_raw;
wire [23:0] bgr_data_raw_splash;
wire cBLANK_n,cHS,cVS,rst;
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
reg [31:0] sensor_out_to_load_reg;

//values vga_controller calculate
 
reg [31:0] screen_reg; 
reg [31:0] counter_reg; 
//   

reg [15:0] counter_hit; 

//fsm stuff
parameter SIZE = 3, SIZE_CONTROLLER = 32, SIZE_LOAD = 3; 
parameter SPLASH  = 3'b000, MAIN= 3'b001, SL = 3'b010, GAME = 3'b011; //screens (not states but just useful)
parameter MODE_SPLASH = 3'b000, MODE_MAIN = 3'b001, MODE_SAVE = 3'b010, MODE_LOAD = 3'b011, MODE_GAME = 3'b100; //modes
parameter LOC1 = 32'd1, LOC2 = 32'd2, LOC3 = 32'd3, NONE = 32'd0;  //save locations
parameter START = 3'b000, WAIT = 3'b001; 
parameter PAD1 = 32'd1, PAD2 = 32'd2, PAD3 = 32'd3; 
//=============Internal Variables======================
reg   [SIZE-1:0] state;
reg   [SIZE_CONTROLLER-1:0] state_controller, state_controller2; 
reg	[SIZE_LOAD-1:0] state_load; 


always@(posedge VGA_CLK_n) 
begin
		screen_reg <= screen; 
		bgr_data <= bgr_data_raw;
		sensor_in <= sensor_input;
		controller_reg <= controller; 
		
		//FSM
		case(state)
		 MODE_SPLASH : if (controller_reg[1] || controller_reg[2]||controller_reg[3] || controller_reg[0]) begin
						  state <=  #1  MODE_MAIN;
						  screen_reg <= MAIN; 
						end else begin
						  state <=  #1  MODE_SPLASH;
						  screen_reg <= SPLASH; 
						end
		 MODE_MAIN : if (controller_reg[2] == 1'b1) begin
						  state <=  #1  MODE_LOAD;
						  screen_reg <= SL; 
					end else if (controller_reg[1] == 1'b1) begin
						  state <=  #1  MODE_SAVE;
						  screen_reg <= SL; 
					end else if (controller_reg[3] == 1'b1) begin
						  state <=  #1  MODE_GAME;
						  screen_reg <= GAME; 
					 end else begin
						  state <=  #1  MODE_MAIN;
						  screen_reg <= MAIN; 
						end
		 MODE_GAME : if (controller_reg[0] == 1'b1) begin
						  state <=  #1  MODE_MAIN;
						  screen_reg <= MAIN; 
						end else begin
						  state <=  #1  MODE_GAME;
						  screen_reg <= GAME; 
						end
						
		 MODE_SAVE : if (controller_reg[0] == 1'b1) begin
						  state <=  #1  MODE_MAIN;
						  screen_reg <= MAIN; 
						  save_signal_reg <=NONE; 
						end else begin
						 state <=  #1  MODE_SAVE;
						 screen_reg <= SL; 
  						 sensor_in_to_save_reg <= sensor_input; 
						 case(state_controller)
							NONE:  if (controller_reg[1] == 1'b1) begin
									  state_controller <= #1 LOC1; 
									  end else if (controller_reg[2] == 1'b1) begin
									  state_controller <= #1 LOC2; 
									  end else if (controller_reg[3] == 1'b1) begin
									  state_controller <= #1 LOC3; 
									  end else begin 
											state_controller<=NONE;
											save_signal_reg <= NONE; 
									  end
							LOC1:	if (controller_reg[0] == 1'b1) begin
									  state_controller <= #1 NONE; 
									  end else if (controller_reg[2] == 1'b1) begin
									  state_controller <= #1 LOC2; 
									  end else if (controller_reg[3] == 1'b1) begin
									  state_controller <= #1 LOC3; 
									  end else begin 
											state_controller<=LOC1; 
											save_signal_reg <= LOC1; 
									  end
							LOC2: if (controller_reg[0] == 1'b1) begin
									  state_controller <= #1 NONE; 
									  end else if (controller_reg[1] == 1'b1) begin
									  state_controller <= #1 LOC1; 
									  end else if (controller_reg[3] == 1'b1) begin
									  state_controller <= #1 LOC3; 
									  end else begin 
											state_controller<=LOC2; 
											save_signal_reg <= LOC2; 
									  end
							LOC3: if (controller_reg[0] == 1'b1) begin
									  state_controller <= #1 NONE; 
									  end else if (controller_reg[1] == 1'b1) begin
									  state_controller <= #1 LOC1; 
									  end else if (controller_reg[2] == 1'b1) begin
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
		 MODE_LOAD : if (controller_reg[0] == 1'b1) begin
						  state <=  #1  MODE_MAIN;
						  screen_reg <= MAIN; 
						  load_signal_reg <=NONE; 
						end else begin
						 state <=  #1  MODE_LOAD;
						 screen_reg <= SL; 
  						 sensor_out_to_load_reg <= sensor_output_adjusted; 
						 case(state_controller2)
							NONE:  if (controller_reg[1] == 1'b1) begin
									  state_controller2 <= #1 LOC1; 
									  end else if (controller_reg[2] == 1'b1) begin
									  state_controller2 <= #1 LOC2; 
									  end else if (controller_reg[3] == 1'b1) begin
									  state_controller2 <= #1 LOC3; 
									  end else begin 
											state_controller2<=NONE;
											load_signal_reg <= NONE; 
									  end
							LOC1:	if (controller_reg[0] == 1'b1) begin
									  state_controller2 <= #1 NONE; 
									  end else if (controller_reg[2] == 1'b1) begin
									  state_controller2 <= #1 LOC2; 
									  end else if (controller_reg[3] == 1'b1) begin
									  state_controller2 <= #1 LOC3; 
									  end else begin 
											counter_reg <= 32'd500; 
											load_signal_reg <= LOC1; 
											state_controller2<=LOC1; 
											case(state_load)
												 START : if (sensor_out_to_load_reg == PAD1) begin
																 state_load <=  #1  WAIT;
															end else begin
																  state_load <=  #1  START;
																end
												 WAIT: if(sensor_input != 32'b00000000000000000000000000011111) begin
																  state_load <=  #1  START;
																  counter_reg <= counter_reg +1;

															  end else begin
																  state_load <=  #1  WAIT;
												 end
												 default : state_load <=  #1  START;
											 endcase
									  end
							LOC2: if (controller_reg[0] == 1'b1) begin
									  state_controller2 <= #1 NONE; 
									  end else if (controller_reg[1] == 1'b1) begin
									  state_controller2 <= #1 LOC1; 
									  end else if (controller_reg[3] == 1'b1) begin
									  state_controller2 <= #1 LOC3; 
									  end else begin 
											load_signal_reg <= LOC2; 
											state_controller2<=LOC2; 
											counter_reg <= 32'd1000; 
											case(state_load)
												 START : if (sensor_out_to_load_reg == PAD1) begin
																 state_load <=  #1  WAIT;
															end else begin
																  state_load <=  #1  START;
																end
												 WAIT: if(sensor_input != 32'b00000000000000000000000000011111) begin
																  state_load <=  #1  START;
																  counter_reg <= counter_reg +1;

															  end else begin
																  state_load <=  #1  WAIT;
												 end
												 default : state_load <=  #1  START;
											 endcase
									  end
									  
							LOC3: if (controller_reg[0] == 1'b1) begin
									  state_controller2 <= #1 NONE; 
									  end else if (controller_reg[1] == 1'b1) begin
									  state_controller2 <= #1 LOC1; 
									  end else if (controller_reg[2] == 1'b1) begin
									  state_controller2 <= #1 LOC2; 
									  end else begin 
											load_signal_reg <= LOC3; 
											state_controller2<=LOC3; 
											counter_reg <= 32'd1500; 
											case(state_load)
												 START : if (sensor_out_to_load_reg == PAD1) begin
																 state_load <=  #1  WAIT;
															end else begin
																  state_load <=  #1  START;
																end
												 WAIT: if(sensor_input != 32'b00000000000000000000000000011111) begin
																  state_load <=  #1  START;
																  counter_reg <= counter_reg +1;

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
			if((sensor_in[0] ==1'b0) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90; 
			else if((sensor_in[1] == 1'b0) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90; 
			else if((sensor_in[2] == 1'b0) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90; 
			else if((sensor_in[3] == 1'b0) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90; 
//			else if((sensor_in[5] == 1'b1) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;  
			else if(((sensor_in[4] == 1'b0)) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400;  
//			else if(((sensor_in[6] == 1'b1)) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400;  

//			else if(((sensor_in[7] == 1'b0)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h90EE90; 
//			else if(((sensor_in[8] == 1'b0)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h90EE90; 
//			else if(((sensor_in[9] == 1'b0)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h32CD32; 
//			else if(((sensor_in[10] == 1'b0)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h32CD32; 
//			else if(((sensor_in[11] == 1'b0)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h006400; 
//			else if(((sensor_in[12] == 1'b0)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h006400; 
//
//		
//			else if(((sensor_in[14] == 1'b0)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;
//			else if(((sensor_in[15] == 1'b0)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;
//			else if(((sensor_in[16] == 1'b0)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h32CD32;
//			else if(((sensor_in[17] == 1'b0)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h32CD32;
//			else if(((sensor_in[19] == 1'b0)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400;
//			else if(((sensor_in[18] == 1'b0)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400;
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


///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end



endmodule