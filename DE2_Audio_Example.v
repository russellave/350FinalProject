module DE2_Audio_Example (
	game_over,
	// Inputs
	CLOCK_50,
	AUD_ADCDAT,
	KEY,
	
	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	I2C_SCLK
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input game_over;
input[3:0] KEY;
input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				I2C_SCLK;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;

// Internal Registers

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
 
 /*****************************************************************************
 *                         LAB 6 SOUNDS GO HERE                               *
 *****************************************************************************/
reg[31:0] tone, Bcount,MaxBeat,MaxFreq,MaxBeatNext,MaxFreqNext,BeatIndex,BeatIncrement,fCount;
 reg flip, sign;
 initial 
 begin 
	tone <= 32'h0;
	Bcount <= 32'h0;
	MaxBeat <=32'd50000000;
	MaxFreq <= 32'd48076;
	MaxBeatNext <= 32'd25000000;
	MaxFreqNext <= 32'd71633; //f
	BeatIndex <=32'h0;
	BeatIncrement <= 32'h00000001;
end

always
begin
	case(BeatIndex)
	32'h0:begin
		MaxBeatNext <=32'd25000000;
		MaxFreqNext <=32'd48076; //c
		BeatIncrement <= 32'h00000001;
		end
	32'h00000001:begin
		MaxBeatNext <=32'd25000000;
		MaxFreqNext <=32'd40192; //eflat
		BeatIncrement <= 32'h00000002;
		end
	32'h00000002:begin         
		MaxBeatNext <=32'd25000000;
		MaxFreqNext <=32'd35816; //f
		BeatIncrement <= 32'h00000003;
		end
	32'h00000003:begin
		MaxBeatNext <=32'd50000000;
		MaxFreqNext <=32'd53608; //bflat
		BeatIncrement <= 32'h00000004;
		end
	32'h00000004:begin
		MaxBeatNext <=32'd6250000;
		MaxFreqNext <=32'd60240; //aflat
		BeatIncrement <= 32'h00000005;
		end
	32'h00000005:begin
		MaxBeatNext <=32'd6250000;
		MaxFreqNext <=32'd53608; //bflat
		BeatIncrement <= 32'h00000006;
		end
	32'h00000006:begin
		MaxBeatNext <=32'd12500000;
		MaxFreqNext <=32'd48076;//c
		BeatIncrement <= 32'h00000007;
		end
	32'h00000007:begin
		MaxBeatNext <=32'd12500000;
		MaxFreqNext <=32'd53608;//bflat
		BeatIncrement <= 32'h00000008;
		end
	32'h00000008:begin
		MaxBeatNext <=32'd12500000;
		MaxFreqNext <=32'd60240;//aflat
		BeatIncrement <= 32'h00000009;
		end
	32'h00000009:begin
		MaxBeatNext <=32'd12500000;
		MaxFreqNext <=32'd63775;//g
		BeatIncrement <= 32'h0000000A;
		end
	32'h0000000A:begin        
		MaxBeatNext <=32'd37500000;
		MaxFreqNext <=32'd71633;//f
		BeatIncrement <= 32'h0000000B;
		end
	32'h0000000B:begin
		MaxBeatNext <=32'd6250000;
		MaxFreqNext <=32'd80385;//eflat
		BeatIncrement <= 32'h000000C;
		end
	32'h0000000C:begin
		MaxBeatNext <=32'd6250000;
		MaxFreqNext <=32'd71633;//f
		BeatIncrement <= 32'h000000D;
		end
	32'h0000000D:begin
		MaxBeatNext <=32'd12500000;
		MaxFreqNext <=32'd60240;//aflat
		BeatIncrement <= 32'h000000E;
		end
	32'h0000000E:begin
		MaxBeatNext <=32'd12500000;
		MaxFreqNext <=32'd53608;//bflat
		BeatIncrement <= 32'h000000F;
		end
	32'h0000000F:begin
		MaxBeatNext <=32'd12500000;
		MaxFreqNext <=32'd63775;//g
		BeatIncrement <= 32'h00000010;
		end
	32'h00000010:begin
		MaxBeatNext <=32'd12500000;
		MaxFreqNext <=32'd80385;//eflat
		BeatIncrement <= 32'h00000011;
		end
	32'h00000011: begin
		MaxBeatNext <=32'd1000000000;
		MaxFreqNext <=32'd71633;//f
		BeatIncrement <= 32'h0;
		end
	default:begin 
		MaxBeatNext <=32'd100000000;
		MaxFreqNext <=32'd43103;
		BeatIncrement <= 32'h0;
		end
	endcase
end
always @(posedge CLOCK_50)
begin 
	if(!game_over)
	begin
		if(Bcount >= MaxBeat)
		begin
			Bcount <= 32'h0;
			fCount <= 32'h0;
			MaxBeat <= MaxBeatNext;
			MaxFreq <= MaxFreqNext;
			BeatIndex<= BeatIncrement;
		end
		else
		begin
			Bcount <= Bcount +32'h00000001;
			if(fCount >= MaxFreq)
			begin 
				fCount <=32'h0;
				sign = ~sign;
			end
			else begin 
				fCount <= fCount+32'h00000001;
			end
		end
	end
	else
	begin
		Bcount <= 32'h0;
		fCount <= 32'h0;
		MaxBeat <=32'd50000000;
		MaxFreq <= 32'd38000;
		BeatIndex <=32'h0;
	end
end
 

//reg [31:0] count;
//reg sign;
//initial begin
//	count <= 32'd0;
//end
//always @(posedge CLOCK_50)begin
//	if (count >= 12500) begin
//		count <= 32'd0;
//		sign = ~sign;
//	end
//	else begin
//		count = count + 32'd1;
//	end
//end
 /*****************************************************************************
 *                         LAB 6 SOUNDS END HERE                              *
 *****************************************************************************/


assign read_audio_in			= audio_in_available & audio_out_allowed;

wire [31:0] left_in, right_in, left_out, right_out;
assign left_in = left_channel_audio_in;
assign right_in = right_channel_audio_in;
//assign left_out = op;
//assign right_out = op;

assign left_out = sign ? -32'd100000000 : 32'd100000000;
assign right_out = sign ? -32'd100000000 : 32'd100000000;

assign left_channel_audio_out	= left_out;
assign right_channel_audio_out	= right_out;
assign write_audio_out			= audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT),

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.I2C_SCLK					(I2C_SCLK),
	.I2C_SDAT					(I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0]),
	.key1							(KEY[1]),
	.key2							(KEY[2])
);

endmodule