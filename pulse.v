`timescale 1ns / 1ps
module pulse(
  input IN,
  input CLK,
  output wire OUT
);

reg A;
reg B;

assign OUT = A & ~B;

always @(posedge CLK)
begin
  A <= IN;
  B <= A;
end

initial
begin
  A <= 0;
  B <= 0;
end

endmodule
