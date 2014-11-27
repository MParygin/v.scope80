`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Description: Buffer for ADC data
// 
//////////////////////////////////////////////////////////////////////////////////
module m_buffer #(parameter WIDTH = 0)(
	input wire CLK_ADC,
	input wire CLK,
   input wire [7:0] D,       // MIN
   input wire [7:0] E,       // MAX
	input wire [10:0] HDATA, // HOR counter
	input wire [10:0] VDATA, // VER counter
	input wire NEXT_FRAME,
	input wire TRG,
	
	input wire [7:0] CURR_MIN,
	input wire [7:0] TRI_SEL,
	
	output wire OUT
);


wire [7:0] pipe;
wire pos;
wire neg;
m_finder #(.WIDTH(8),.NEG_VALUE(4)) finder (
   .clk(CLK_ADC),
	.in(D),
	.out(pipe),
	.positive(pos),
	.negative(neg),
	.level(TRI_SEL)
);

// Triggers (0) = ext, (1,2) == positive. (>3) == level
wire trigger = (TRI_SEL == 8'h00) ? TRG : ((TRI_SEL > 3) ? (pipe < (CURR_MIN + 4)) : pos);

// Address of write [0..2047] 11 bit
reg [10:0] addr; 

// frames
reg oldframe;
reg frame;
reg frame2;

// Differential counter
wire [23:0] diffcounter;
synchro_counter #(.WIDTH(24)) sc (
    .clk(CLK_ADC),
	 .monitor(frame),
	 .out(diffcounter)
);

// Current Mode 
wire mode = diffcounter[23:0] >= WIDTH; // clocks > width

reg [2:0] frameskipper;
reg frameskip;
always @ (posedge CLK)
begin
  if (oldframe == 1 & NEXT_FRAME == 0)
  begin
    // Falling edge of NEXT_FRAME
    frame <= !frame;
    if (frameskip == 1'b1)
    begin
      frameskipper <= frameskipper + 1;
    end else begin
      frameskipper <= 0;
    end
  end
  oldframe <= NEXT_FRAME;
end

// Address write counter 
always @ (posedge CLK_ADC)
begin
  if (frame2 != frame) 
  begin
    frame2 <= frame;
	 	 if (mode == 1'b1) addr <= 0;
  end else begin
    if (addr == 0) 
	 begin
	   // wait positive impulse
		if (trigger == 1'b1) // selectable trigger
		begin
		  // yes signal
		  addr <= addr + 1;
		  frameskip <= 0;
		end else 
		begin
		  // not signal
        if (frameskip == 0)
		  begin
		    frameskip <= 1;
		  end else begin
			 if (frameskipper[2:0] == 4)
			 begin
            addr <= addr + 1;
				frameskip <= 0;
			 end else begin
			 end
		  end
		end
	 end else begin
	   // stop at end or goto begin
      if (addr != (WIDTH - 1)) // end of screen
      begin
        addr <= addr + 1;
      end else begin
		  if (mode == 1'b0) addr <= 0;
		end
	 end
  end	 
end


wire [15:0] value; //max & min

// pos in values
wire [10:0] p = 230 - VDATA;
wire accept= (p == value[15:8] && p == value[7:0]) || (p >= value[15:8] && p < value[7:0])  ;

assign OUT = (accept) && (HDATA < WIDTH) && (HDATA > 57);


// dual port memory for symbols buffer
RAMB16_S18_S18 #(
   .WRITE_MODE_A("WRITE_FIRST"), // WRITE_FIRST, READ_FIRST or NO_CHANGE
   .WRITE_MODE_B("WRITE_FIRST"), // WRITE_FIRST, READ_FIRST or NO_CHANGE
   .SIM_COLLISION_CHECK("NONE")  // "NONE", "WARNING_ONLY", "GENERATE_X_ONLY", "ALL" 
) buffer (
   .DOA(),      // Port A 8-bit Data Output
   .DOB(value),      // Port B 8-bit Data Output
   .DOPA(),    // Port A 1-bit Parity Output
   .DOPB(),    // Port B 1-bit Parity Output
   .ADDRA({(mode == 1'b1) ? frame : 1'b1, addr[8:0]}),  // Port A 11-bit Address Input
   .ADDRB({(mode == 1'b1) ? ~frame : 1'b1, HDATA[8:0]}),  // Port B 11-bit Address Input unable
   .CLKA(CLK_ADC),    // Port A Clock
   .CLKB(CLK),    // Port B Clock
   .DIA({D, E}),      // Port A 8-bit Data Input
   .DIB(16'h00),      // Port B 8-bit Data Input
   .DIPA(2'b0),    // Port A 1-bit parity Input
   .DIPB(2'b0),    // Port-B 1-bit parity Input
   .ENA(1'b1),      // Port A RAM Enable Input
   .ENB(1'b1),      // Port B RAM Enable Input
   .SSRA(1'b0),    // Port A Synchronous Set/Reset Input
   .SSRB(1'b0),    // Port B Synchronous Set/Reset Input
   .WEA(CLK_ADC),      // Port A Write Enable Input
   .WEB(1'b0)       // Port B Write Enable Input
);

endmodule

