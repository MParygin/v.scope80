`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Description: Resampler
//
//
//////////////////////////////////////////////////////////////////////////////////
module m_clock(
    input [7:0] port_id,
    input [7:0] out_port,
    input write_strobe,
	 input IN,
	 input ENABLE,
	 output OUT
);

parameter BASE = 0;

reg [23:0] divider;
reg [23:0] counter;
reg trigger;

always @ (posedge IN)
begin
  if (counter == divider)
  begin
	 counter <= 0;
	 if (counter == 24'hFFFFFF)
	 begin
	   trigger <= IN;
	 end else begin
	   trigger <= !trigger;
	 end	
  end else begin  
    counter <= counter + 1;
  end 
end

assign OUT = trigger && ENABLE;

always @ (posedge write_strobe)
begin
  if (port_id == BASE + 0)
  begin
    divider[7:0] <= out_port[7:0];
  end
  if (port_id == BASE + 1)
  begin
    divider[15:8] <= out_port[7:0];
  end
  if (port_id == BASE + 2)
  begin
    divider[23:16] <= out_port[7:0];
  end
end

endmodule
