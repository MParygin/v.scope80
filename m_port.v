`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Maxim Parygin
// 
// Create Date:    10:03:32 01/30/2012 
// Module Name:    m_port 
// Description:    Output port for Picoblaze core
//
// Revision: 
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////
module m_port #(parameter WIDTH = 0, BASE = 0) (
    input [7:0] port_id,
    input [7:0] out_port,
    input write_strobe,
    output reg [WIDTH-1:0] out
);

always @ (posedge write_strobe)
begin
  if (port_id == BASE)
  begin
    out[WIDTH-1:0] <= out_port[WIDTH-1:0];
  end
end

endmodule

