`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Maxim Parygin
// 
// Create Date:    11:23:51 01/30/2012 
// Module Name:    m_finder 
// Description:    Finder of transitions - delta comparator
//
// Revision: 
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////
module m_finder #(parameter WIDTH = 8, NEG_VALUE = 1)(
    input wire clk,
    input wire [WIDTH-1:0] in,
	 output reg [WIDTH-1:0] out,
	 output wire [WIDTH:0] delta,
	 output wire positive,
	 output wire negative,
	 input wire [WIDTH-1:0] level
);

reg [WIDTH-1:0] tmp;

always @ (posedge clk)
begin
  tmp <= in;
  out <= tmp;
end

assign delta = tmp - out;

assign positive = (delta[WIDTH] == 1'b0) && (delta[WIDTH-1:0] > level);
assign negative = 0;//(delta[WIDTH] == 1'b1) && (~delta[WIDTH-1:0] > NEG_VALUE);

endmodule
