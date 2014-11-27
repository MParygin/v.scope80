`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Description: Module for out text layer
//////////////////////////////////////////////////////////////////////////////////
module m_text(
    input [7:0] port_id,
    input [7:0] out_port,
    input write_strobe,
    input wire CLK, 
	 
	 //input wire ENABLE_A,
//	 input wire ENABLE_B,
	 
    input wire [8:0] HDATA, // HOR counter
    input wire [8:0] VDATA, // VERT counter
	 
	 output wire [5:0] COLOR_A,
	 output wire [5:0] COLOR_B,
	 
    output wire [5:0] OUT // Out data
);

parameter BASE = 0;

// bit arrays
reg [6:0] layer_address;
reg [127:0] L0;
reg [127:0] L1;
reg [127:0] L2;
reg [127:0] L3;
reg [127:0] L4;
reg [127:0] L5;
reg [127:0] L6;

// Corrected vertical
wire [8:0] correction;
assign correction = VDATA + 2;
wire [8:0] correction2;
assign correction2 = HDATA + 8;


// colors
reg [5:0] curr_color_a;
reg [5:0] curr_color_b;
assign COLOR_A = curr_color_a;
assign COLOR_B = curr_color_b;

// Write
reg [6:0] w_data; // data for write
reg w_flag; // write flag in first clock domain

wire [5:0] column = correction2[8:3];//3
wire [6:0] la = {correction[7:4], column[2:0]};
wire [6:0] out_code = {L6[la],L5[la],L4[la],L3[la],L2[la],L1[la],L0[la]};

wire font_out;
pc_vga_8x16_00_7F font (
	.clk(CLK),
	.ascii_code(out_code),
	.row(correction[3:0]),
	.col(correction2[2:0]),
	.row_of_pixels(font_out)
);
                                          //52
assign OUT = (font_out == 1'b1 && column <= 7) ? ((la[6] == 0) ? curr_color_a : curr_color_b) : 6'b000000;

// up
always @ (posedge write_strobe)
begin
  if (port_id == BASE + 0)
  begin
	 layer_address[6:0] <= out_port[6:0];
  end
  if (port_id == BASE + 1)
  begin
    curr_color_a[5:0] <= out_port[5:0];
  end
  if (port_id == BASE + 2)
  begin
    curr_color_b[5:0] <= out_port[5:0];
  end
  if (port_id == BASE + 3)
  begin
 	 L0[layer_address] <= out_port[0];
 	 L1[layer_address] <= out_port[1];
 	 L2[layer_address] <= out_port[2];
 	 L3[layer_address] <= out_port[3];
 	 L4[layer_address] <= out_port[4];
 	 L5[layer_address] <= out_port[5];
 	 L6[layer_address] <= out_port[6];
	 layer_address <= layer_address + 1;
  end
end

initial
begin
  curr_color_a = 6'b000000;
  curr_color_b = 6'b000000;
end

endmodule
