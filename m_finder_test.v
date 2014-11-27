`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:47:55 01/30/2012
// Design Name:   m_finder
// Module Name:   /data/nprojects/x.scope/m_finder_test.v
// Project Name:  x.scope
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: m_finder
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module m_finder_test;

	// Inputs
	reg clk;
	reg [7:0] in;

	// Outputs
	wire [7:0] out;
	wire positive;
	wire [8:0] delta;
	wire negative;

	// Instantiate the Unit Under Test (UUT)
	m_finder #(.WIDTH(8),.POS_VALUE(8),.NEG_VALUE(8)) uut (
		.clk(clk), 
		.in(in), 
		.out(out), 
		.delta(delta), 
		.positive(positive), 
		.negative(negative)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		in = 0;

		// Wait 100 ns for global reset to finish
		#10;
        
		// Add stimulus here
  
		#10; in <= 10;
		#10; in <= 12;
		#10; in <= 32;
		#10; in <= 72;
		#10; in <= 12;
		#10; in <= 15;
		#10; in <= 18;
	end

    
always begin
   #1 clk <= !clk;
end  
      
endmodule

