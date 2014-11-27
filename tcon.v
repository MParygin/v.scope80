`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Description: Times for TFT
// Master: Parygin Maxim
//////////////////////////////////////////////////////////////////////////////////
module tcon(
input wire CLK120, // 120 MHz clock

output reg CKV_,  // Clock
output reg STV_,  // STV[D|U]
output reg OEV_,  // OE Vertical

output reg STH_,  // STH[L|R]
output reg OEH_,  // OE Horizontal
output wire CPH1_, // CPH 
output wire CLK10_, // 10MHz clock
output reg [8:0] hdata, // HOR counter
output reg [8:0] vdata  // VERT counter


// other settings : mod = 1, LR = 1, UD = 0, CPH3 = 0, CHP2 = 0
    );
// Counter 0..9 for get 10 MHz
reg [3:0] cnt;
reg CLK10;
//----------------------------------
always @ (posedge CLK120)
begin
  if (cnt == 4) CLK10 <= 1;
  if (cnt == 9) 
  begin
    CLK10 <= 0;
  cnt <= 0;
 end
  else 
 begin
    cnt <= cnt + 1;
  end
end
assign CLK10_ = CLK10;
//----------------------------------
// CPH1 (10 MHz)
assign CPH1_ = CLK10;
// data counter

reg [8:0] _hdata; // HOR counter
reg [8:0] _vdata;  // VERT counter

always @ (posedge CLK10)
begin
  if (_hdata == 481) begin//481
    _hdata <= 0;
  if (_vdata == 240) begin//240
     _vdata <= 0;
  end else begin
     _vdata <= _vdata + 1;
  end
  end else begin
    _hdata <= _hdata + 1;
  end
end
//----------------------------------------
// STH - first hor sync
//Start pulse for horizontal scan (Gate) line      
wire _STH_ = _hdata == 0;//0
//
//Output enable input for data (Source) driver    
wire _OEH_ = _hdata != 481;//481
//
// STV - end of frame - 3   
wire _STV_ = _vdata == 240;//240 
//
//Output enable input for scan(Gate) driver    
wire _OEV_ = _hdata == 1;//1
//
//Shift clock input for scan (Gate) driver   

// synchro
always @ (posedge CLK10)
begin
  hdata <= _hdata - 1;
  vdata <= _vdata - 1;
  STH_ <= _STH_;
  OEH_ <= _OEH_;
  OEV_ <= _OEV_;
  CKV_ <= _OEV_;
  STV_ <= _STV_;
end

// initial values
initial
begin
  //cnt <= 0;
  //CLK10 <= 0;
  _hdata <= 0;
  _vdata <= 0;
end

endmodule
