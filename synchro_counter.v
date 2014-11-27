`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Maxim Parygin
// 
// Create Date:    17:53:48 01/31/2012 
// Module Name:    Syncho Counter Between Change State of Monitor
// Project Name:   DSope
// Target Devices: Spartan3E500
// Revision: 
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////
module synchro_counter #(parameter WIDTH = 0) (
    input wire clk,
	 input wire monitor,
	 output reg [WIDTH-1:0] out
);

reg [WIDTH-1:0] data;
reg tmp;

always @ (posedge clk)
begin
  if (tmp == monitor)
  begin
    data <= data + 1;
  end else begin
    out <= data;
    data <= 0;
	 tmp <= monitor;
  end  
end

//assign out[WIDTH-1:0] = data[WIDTH-1:0];

initial
begin
  data <= 0;
  out <= 0;
  tmp <= 0;
end

endmodule
