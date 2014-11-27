`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: makkosik
// 
// Description: Clock Resampler (120 MHz to 60MHz .. 15Hz)
//
//////////////////////////////////////////////////////////////////////////////////
module  resampler (
    // Config
    input [7:0] port_id,
    input [7:0] out_port,
	 output [7:0] in_port,
    input write_strobe,
   // input read_strobe,

	 // Clocks
	 input wire clk_in, // 120 MHz
	 output wire clk_out,
	 output wire clk_60,
	 
	 // Data
	 input wire [7:0] data_in,
	 output reg [7:0] data_out_max,
	 output reg [7:0] data_out_min,
	 
	 output reg [7:0] CURR_MIN
);

parameter BASE = 0;

reg t;
always @ (posedge clk_in)
begin
  t <= ~t;
end
assign clk_60 = t;

// PPS
reg [27:0] rpps;

// counter of transitions by zero line
reg [27:0] cntpps;
reg [27:0] cntppsout;
reg [7:0] data_mid; // zero line
reg [7:0] data_tmp; // old value

reg [7:0] mmax;
reg [7:0] mmin;

wire prev_bel = data_tmp < data_mid;
wire next_abv = data_in >= data_mid;
always @ (posedge clk_60)
begin
  // calc pps
  if (rpps == 60000000)
  begin 
    rpps <= 0;
  end else begin
    rpps <= rpps + 1;
  end

  // pps ?
  if (rpps == 0)
  begin
     cntpps <= 0;//(prev_bel && next_abv)? 1 : 0;
     cntppsout <= cntpps;//12345678; //cntpps;
	  
	  // min max mid
	  mmax <= data_in;
	  mmin <= data_in;
	  CURR_MIN <= mmin;
	  data_mid <= {1'b0, mmax[7:1]} + {1'b0, mmin[7:1]};
	  
  end else begin
	  if (prev_bel && next_abv) 
	  begin
		 cntpps <= cntpps + 1;
	  end
	
	  // max min
     mmin <= (mmin > data_in) ? data_in : mmin;
	  mmax <= (mmax < data_in) ? data_in : mmax;
  end
  data_tmp <= data_in;
end

// read values from port (valid)
assign in_port = 
 (port_id == BASE + 0) ? cntppsout[7:0] : 
((port_id == BASE + 1) ? cntppsout[15:8] : 
((port_id == BASE + 2) ? cntppsout[23:16] : 
((port_id == BASE + 3) ? {4'b0, cntppsout[27:24]} : 8'bz)));



// Clock resampler
reg [23:0] divider;
reg [23:0] counter;
reg trigger;

// Data calcs
reg [7:0] cur_min;
reg [7:0] cur_max;

always @ (posedge clk_in)
begin
  if (counter == divider)
  begin
	 counter <= 0;
	 if (trigger == 1'b1)
	 begin
		 // flush min max
		 data_out_max <= cur_max;
		 data_out_min <= cur_min;
       
		 cur_min <= data_in;
		 cur_max <= data_in;
	 end else begin
	    // check min max (already set)
		 cur_min <= (cur_min > data_in) ? data_in : cur_min;
		 cur_max <= (cur_max < data_in) ? data_in : cur_max;
	 end
    trigger <= !trigger;
  end else begin  
    counter <= counter + 1;
	 // check min max (already set)
	 cur_min <= (cur_min > data_in) ? data_in : cur_min;
	 cur_max <= (cur_max < data_in) ? data_in : cur_max;
  end 
end

assign clk_out = trigger;

always @ (posedge write_strobe)
begin
  if (port_id == BASE + 0)
  begin
    case (out_port[7:0])
		 //0: divider <= 24'hFFFFFF;
		 //1: divider <= 24'h98967F;
		 0: divider <= 24'h3D08FF;
		 1: divider <= 24'h1E847F;
		 2: divider <= 24'h0F423F;
		 3: divider <= 24'h061A7F;
		 4: divider <= 24'h030D3F;
		 5: divider <= 24'h01869F;
		 6: divider <= 24'h009C3F;
		 7: divider <= 24'h004E07;
		 8: divider <= 24'h00270F;
		 9: divider <= 24'h000F9F;
		 10: divider <= 24'h0007CF;
		 11: divider <= 24'h0003EF;
		 12: divider <= 24'h00018F;
		 13: divider <= 24'h0000C7;
		 14: divider <= 24'h000063;
		 15: divider <= 24'h000027;
		 16: divider <= 24'h000013;
		 17: divider <= 24'h000009;
		 18: divider <= 24'h000003;
		 19: divider <= 24'h000001;
		 20: divider <= 24'h000000;
	 endcase
  end
end

initial
begin
  counter = 0;
  divider = 1;
  trigger = 0;
  cur_min = 0;
  cur_max = 0;
  data_out_max = 0;
  data_out_min = 0;
end

endmodule
