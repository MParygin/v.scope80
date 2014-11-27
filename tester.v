`timescale 1ns / 1ps
module tester(
    input IN,
    output OUT
    );

// test case for flash LEDs
reg [20:0] ledcnt;
always @ (posedge IN)
begin
  ledcnt <= ledcnt + 1;
end
// konnektim LEDs k schetchiku
assign OUT = ledcnt[9];

endmodule
