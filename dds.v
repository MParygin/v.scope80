`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// Create Date:    21:29:50 03/06/2012 
// Module Name:    dds 
// Revision: 
//////////////////////////////////////////////////////////////////////////////////
module dds #(parameter BASE = 0)(
    // clk
	 input wire clk,
	 // out
	 output wire FSYNC,
	 output wire SCLK,
	 output wire SDATA,
	 // io
    input [7:0] port_id,
    input [7:0] out_port,
    input write_strobe
);

reg [4:0] pos;
reg [15:0] data;
reg flagA;
reg flagB;

always @ (posedge clk)
begin
  if (flagA != flagB)
  begin
    if (pos == 5'b11111)
	 begin
	   flagB <= flagA;
		pos <= 0;
	 end else begin
	   pos <= pos + 1;
	 end
  end
end

assign SCLK = clk;
assign FSYNC = (pos == 0) || (pos > 16);
assign SDATA = (~FSYNC) ? data[16-pos] : 0;

// up
always @ (posedge write_strobe)
begin
  if (port_id == BASE + 0)
  begin
    data[7:0] <= out_port[7:0];
  end
  if (port_id == BASE + 1)
  begin
    data[15:8] <= out_port[7:0];
  end
  if (port_id == BASE + 2)
  begin
	 flagA <= ~flagA;
  end
end

initial 
begin
  pos <= 0;
  data <= 0;
  flagA <= 0;
  flagB <= 0;
end

endmodule
