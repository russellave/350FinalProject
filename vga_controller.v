module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
							 sensor_input, 
							 sensor_output,
							 controller, 
							 sensor_input_to_save, 
							 save_signal);

	
input iRST_n;
input iVGA_CLK;

output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;      

input [31:0] sensor_input; 
input [31:0] sensor_output; 
input [31:0] controller; 
output [31:0] sensor_input_to_save; 
output [31:0] save_signal;      

             
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [7:0] index_main; 
wire [7:0] index_splash; 
wire [31:0] screen; 
wire [23:0] bgr_data_raw;
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
	.q ( index )
	);
//	
//splash_data	splash_data_inst (
//	.address ( ADDR ),
//	.clock ( VGA_CLK_n ),
//	.q ( index_splash )
//	);
	
/////////////////////////
//////Add switch-input logic here

wire isSplash; 
nor norSplash(isSplash, screen[0], screen[1], screen[2], screen[3], screen[4], screen[5], screen[6], screen[7], screen[8], screen[9]); 
//assign index = isSplash ? index_splash: index_main; 


////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	
//////
//////latch valid data at falling edge;

//what I have to work with 

// sensor_input, sensor_output, controller, sensor_input_to_save, save_signal;     
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

//values vga_controller calculate

reg [7:0] score; 
reg [31:0] screen_reg; 
reg [31:0] adjusted_sensor_out; 
//   


//always@(posedge VGA_CLK_n) 
//begin
//	bgr_data <= bgr_data_raw;
//	sensor_in <= sensor_input; 
//	sensor_out <= sensor_output; 
//	controller_reg <= controller; 
//
//
//	
//	
//	if((screen_reg == 32'd0)) 
//	begin screen_reg <= 32'd1;
//	end
////	
//	
//	//get x and y locations of address
//	x <= ADDR % 10'd640;
//   y <= ADDR / 10'd640;
//	
	//GREEN IF HIT TARGET 
	//pad 1: 154-193; 198-247
	//pad 2: 296-336; 187-237
	//pad 3: 447-489; 198-248
	//if((screen_reg != 32'd0))
	//begin
//		if((sensor_in[6:0] < 7'd40)&& (sensor_in[6:0] >7'd0) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400; 
//
//		else if((sensor_in[6:0] < 7'd80)&& (sensor_in[6:0] >7'd40) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h32CD32; 
//
//		else if((sensor_in[6:0] < 7'd120)&& (sensor_in[6:0] >7'd80) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;
//
//		else if((sensor_in[13:7] < 7'd40)&& (sensor_in[13:7] >7'd0) && (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h006400; 
//
//		else if((sensor_in[13:7] < 7'd80)&& (sensor_in[13:7] >7'd40) && (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h32CD32; 
//
//		else if((sensor_in[13:7] < 7'd120)&& (sensor_in[13:7] >7'd80) && (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h90EE90;
//		
//		else if((sensor_in[20:14] < 7'd40)&& (sensor_in[20:14] >7'd0) && (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400; 
//
//		else if((sensor_in[20:14] < 7'd80)&& (sensor_in[20:14] >7'd40) && (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h32CD32; 
//
//		else if((sensor_in[20:14] < 7'd120)&& (sensor_in[20:14] >7'd80) && (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;
//		else 
//		color_output <=bgr_data; 
	//end
	
//	if((screen_reg == 32'd1))
//	begin
//		if(controller_reg == 32'd2) screen_reg <= 2; 
//		if(controller_reg == 32'd4) screen_reg <= 2; 
//		if(controller_reg == 32'd8) screen_reg <= 3; 
//	end
//	
//	if((screen_reg == 32'd2))
//	begin 
//	end
//	
//	if((screen_reg == 32'd3))
//	begin
//	end

//end
reg [15:0] counter_hit; 
always@(posedge VGA_CLK_n) 
begin
	begin
		bgr_data <= bgr_data_raw;
		sensor_in <= sensor_input;
		x <= ADDR % 10'd640;
		y <= ADDR / 10'd640;
		// dark green: 24'h006400
		//light green: 24'h90EE90
		//middle green: h32CD32
//		if((sensor_in[0] ==1'b1) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90; 
		if((sensor_in[1] == 1'b1) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90; 
//		else if((sensor_in[2] == 1'b1) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h32CD32; 
//		else if((sensor_in[3] == 1'b1) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h32CD32; 
//		else if((sensor_in[5] == 1'b1) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400;  
//		else if(((sensor_in[4] == 1'b1)) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400;  

//		else if(((sensor_in[7] == 1'b1)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h90EE90; 
		else if(((sensor_in[8] == 1'b1)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h90EE90; 
//		else if(((sensor_in[9] == 1'b1)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h32CD32; 
//		else if(((sensor_in[10] == 1'b1)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h32CD32; 
//		else if(((sensor_in[11] == 1'b1)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h006400; 
//		else if(((sensor_in[12] == 1'b1)) &&  (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h006400; 

	
//		else if(((sensor_in[14] == 1'b1)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;
		else if(((sensor_in[15] == 1'b1)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;
//		else if(((sensor_in[16] == 1'b1)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h32CD32;
//		else if(((sensor_in[17] == 1'b1)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h32CD32;
//		else if(((sensor_in[19] == 1'b1)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400;
//		else if(((sensor_in[18] == 1'b1)) &&  (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400;
		else color_output <=bgr_data; 
		
	end
	
	
	

end

assign b_data = color_output[23:16];
assign g_data = color_output[15:8];
assign r_data = color_output[7:0]; 
assign screen = screen_reg; 
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end



endmodule