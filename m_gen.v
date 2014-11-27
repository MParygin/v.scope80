`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Description: DDS on SPI
//
//////////////////////////////////////////////////////////////////////////////////
module m_gen(
    input CLK30,
	 output SCLK,
	 output SDIN,
	 output SYNC
);


reg [25:0] s;
always @ (posedge CLK30)
begin
  s <= s + 1;
end
wire CLK = s[3];

reg [23:0] phase;
reg [23:0] current;
reg [23:0] shadow;

// cnt of bit [0..19]
reg [4:0] cnt;
always @ (posedge CLK)
begin
  phase <= phase + current;
  if (cnt == 19)
  begin
    cnt <= 0;
//	 shadow <= phase;
  end else
  begin
    cnt <= cnt + 1;  
  end 
end

assign SCLK = CLK;
assign SYNC = (cnt == 0) || (cnt == 17) || (cnt == 18) || (cnt == 19) ;// && CLK30 == 1;

assign SDIN = 
 //((cnt == 3) && phase[23]) ||
  ((cnt == 4) && phase[22])
 || ((cnt == 5) && phase[21])
 || ((cnt == 6) && phase[20])
 || ((cnt == 7) && phase[19])
 || ((cnt == 8) && phase[18])
 || ((cnt == 9) && phase[17])
 || ((cnt == 10) && phase[16])
 || ((cnt == 11) && phase[15])
 || ((cnt == 12) && phase[14])
 || ((cnt == 13) && phase[13])
 || ((cnt == 14) && phase[12]);
 

 
initial
begin
  current <= 559; // 1kHz on 30MHz
end

endmodule
