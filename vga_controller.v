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
							 score,
							 mistake);

	
input iRST_n;
input iVGA_CLK;

input[31:0] screen;
input[31:0] score;
input[31:0] mistake;
input[31:0] sensor_input; 
input[31:0] sensor_output; 
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
	.q ( index )
	);
	
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
reg [10:0] count_left;
reg [10:0] count_right;
reg [10:0] count_middle; 
reg [31:0] sensor_in; 
reg [31:0] sensor_out; 
reg [7:0] score; 
reg [31:0] adjusted_sensor_out; 
//   
always@(posedge VGA_CLK_n) 
begin
	bgr_data <= bgr_data_raw;
	if(sensor_input != 0) sensor_in <= sensor_input; 
	if(sensor_output != 0) 
	begin 
		sensor_out<= sensor_output; 
		if(sensor_out[6:0] >0)
		begin
			adjusted_sensor_out[6:0] <= 7'b1111111; 
		end
		if(sensor_out[13:7] >0)
		begin
			adjusted_sensor_out[13:7] <= 7'b1111111; 
		end
		if(sensor_out[20:14] >0)
		begin
			adjusted_sensor_out[20:14] <= 7'b1111111; 
		end
	end
	
	if((adjusted_sensor_out != 0) && (sensor_in != 0)) score <= adjusted_sensor_out & sensor_in; 
	x <= ADDR % 10'd640;
   y <= ADDR / 10'd640;

	if((sensor[6:0] < 7'd40)&& sensor[6:0] >7'd0) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h006400; 

	else if((sensor[13:7] < 7'd80)&& sensor[6:0] >7'd40) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h32CD32; 

	else if((sensor[20:14] < 7'd120)&& sensor[6:0] >7'd80) && (x > 10'd154) && (x<10'd193) && (y<10'd247) && (y>10'd198)) color_output <= 24'h90EE90; 
		
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