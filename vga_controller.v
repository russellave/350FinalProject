module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data, 
							 in_left,
							 screen,
							 score,
							 mistake);

	
input iRST_n;
input iVGA_CLK;

input[2:0] in_left; 
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;      



input [31:0] screen, score, mistake;                   
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
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
dummy_data	dummy_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index_dummy )
	);

splash_data	splash_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index_splash )
	);
	
save_load_data	sl_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index_sl )
	);
	
game_data	game_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index_game )
	);
	

reg [7:0] holdIndex;
always@(posedge VGA_CLK_n)
begin
	if((screen == 32'd0) && ((holdIndex == 7'd0)||(holdIndex == index_splash))) holdIndex <=index_splash;
	if(screen == 32'd1) holdIndex <=index_dummy;
	if(screen == 32'd2) holdIndex <= index_sl;
	if(screen == 32'd4) holdIndex <= index_game; 
end
assign index = holdIndex; 
/////////////////////////
//////Add switch-input logic here
	
	
	
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

//input [2:0] in_right;
//input [2:0] in_up;
//input [2:0] in_down;
//   
always@(posedge VGA_CLK_n) 
begin
	bgr_data <= bgr_data_raw;
	x <= ADDR % 10'd640;
   y <= ADDR / 10'd640;

	if((in_left[2] == 1'b1) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400; 

	else if((in_left[1] == 1'b1) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h32CD32; 

	else if((in_left[0] == 1'b1) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90; 
		
	else color_output <=bgr_data; 

	

end
assign b_data = color_output[23:16];
assign g_data = color_output[15:8];
assign r_data = color_output[7:0]; 

///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end



endmodule