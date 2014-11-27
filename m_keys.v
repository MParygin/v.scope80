`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module m_keys(
    input [7:0] port_id,
	 output [7:0] in_port,
    //input read_strobe,
    input CLK,
    input wire COL1,
    input wire COL2,
    input wire COL3,
    input wire COL4,
    output wire ROW1,
    output wire ROW2,
    output wire ROW3,
    output wire ROW4
);

parameter BASE = 0;

// Registers
reg [3:0] VCOL1;
reg [3:0] VCOL2;
reg [3:0] VCOL3;
reg [3:0] VCOL4;

// Row
reg  [2:0] ROW ;
always @ (posedge CLK)
begin
  ROW <= ROW + 1 ;
  if (ROW[0] == 1)
  begin
    if (ROW[2:1] == 0)
	 begin
	   VCOL1 <= {COL4, COL3, COL2, COL1};
	 end
    if (ROW[2:1] == 1)
	 begin
	   VCOL2 <= {COL4, COL3, COL2, COL1};
	 end
    if (ROW[2:1] == 2)
	 begin
	   VCOL3 <= {COL4, COL3, COL2, COL1};
	 end
    if (ROW[2:1] == 3)
	 begin
	   VCOL4 <= {COL4, COL3, COL2, COL1};
	 end
  end
end

// Rows
assign ROW1 = ROW[2:1] == 0;
assign ROW2 = ROW[2:1] == 1;
assign ROW3 = ROW[2:1] == 2;
assign ROW4 = ROW[2:1] == 3;

// pool
assign in_port = (port_id == BASE + 0) ? {VCOL2, VCOL1} : ((port_id == BASE + 1) ? {VCOL4, VCOL3} : 8'bz);

endmodule
