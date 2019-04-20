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
							 screen, 
							 mistake, 
							 controller);

	
input iRST_n;
input iVGA_CLK;

input[31:0] screen;
input[31:0] mistake;
input[31:0] sensor_input; 
input[31:0] sensor_output; 
input[31:0] controller; 

output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [7:0] index_main; 
wire [7:0] index_splash; 
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
img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index_main )
	);
	
splash_data	splash_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index_splash )
	);
	
/////////////////////////
//////Add switch-input logic here

wire isSplash; 
nor norSplash(isSplash, screen_reg[0], screen_reg[1], screen_reg[2], screen_reg[3], screen_reg[4], screen_reg[5], screen_reg[6], screen_reg[7], screen_reg[8], screen_reg[9]); 
assign index = isSplash ? index_splash: index_main; 
//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	
//////
//////latch valid data at falling edge;
reg[23:0] color_output;
reg [9:0] x; 
reg [9:0] y;
reg [19:0] counter; 
reg [10:0] count_left;
reg [10:0] count_right;
reg [10:0] count_middle; 
reg [31:0] sensor_in; 
reg [31:0] sensor_out; 
reg [7:0] score; 
reg [31:0] screen_reg; 
reg [31:0] adjusted_sensor_out; 
//   
always@(posedge VGA_CLK_n) 
begin
	bgr_data <= bgr_data_raw;


	x <= ADDR % 10'd640;
   y <= ADDR / 10'd640;
	
	if((screen != 32'd0)) screen_reg <= screen; 
	
	
	//GREEN IF HIT TARGET 
	//pad 1: 154-193; 198-247
	//pad 2: 296-336; 187-237
	//pad 3: 447-489; 198-248
	if((sensor_in[6:0] < 7'd40)&& (sensor_in[6:0] >7'd0) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400; 

	if((sensor_in[6:0] < 7'd80)&& (sensor_in[6:0] >7'd40) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h32CD32; 

	if((sensor_in[6:0] < 7'd120)&& (sensor_in[6:0] >7'd80) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;

	if((sensor_in[13:7] < 7'd40)&& (sensor_in[13:7] >7'd0) && (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h006400; 

	if((sensor_in[13:7] < 7'd80)&& (sensor_in[13:7] >7'd40) && (x > 10'd296) && (x<10'd336) && (y<10'd237) && (y>10'd187)) color_output <= 24'h32CD32; 

	if((sensor_in[13:7] < 7'd120)&& (sensor_in[13:7] >7'd80) && (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;
	
	if((sensor_in[20:14] < 7'd40)&& (sensor_in[20:14] >7'd0) && (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400; 

	if((sensor_in[20:14] < 7'd80)&& (sensor_in[20:14] >7'd40) && (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h32CD32; 

	if((sensor_in[20:14] < 7'd120)&& (sensor_in[20:14] >7'd80) && (x > 10'd447) && (x<10'd489) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90;
	else 
	color_output <=bgr_data; 


end
assign b_data = bgr_data_raw[23:16];
assign g_data = bgr_data_raw[15:8];
assign r_data = bgr_data_raw[7:0]; 
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end



endmodule