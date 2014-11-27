`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Description: from 66 to 30MHz & 120MHz exactly
//////////////////////////////////////////////////////////////////////////////////
module dcms(
    input CLK66,
	 output CLK30,
    output CLK120
    );

// Buffer
wire clkg;
BUFG BUFG_inst (
   .O(clkg),     // Clock buffer output
   .I(CLK66)      // Clock buffer input
);

wire clkb; // out clock

// Buffer
BUFG BUFG_inst4 (
   .O(CLK30),    // Clock buffer output
   .I(clkb)      // Clock buffer input
);

// Buffer
wire _b0;
wire _b1;
BUFG BUFG_inst2 (
   .O(_b1),     // Clock buffer output
   .I(_b0)      // Clock buffer input
);

DCM_SP #(
   .CLKDV_DIVIDE(2.0), // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                       //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
   .CLKFX_DIVIDE(11),   // Can be any integer from 1 to 32
   .CLKFX_MULTIPLY(5), // Can be any integer from 2 to 32
   .CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
   .CLKIN_PERIOD(20.0),  // Specify period of input clock ns
   .CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift of NONE, FIXED or VARIABLE
   .CLK_FEEDBACK("1X"),  // Specify clock feedback of NONE, 1X or 2X
   .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                         //   an integer from 0 to 15
   .DLL_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for DLL
   .DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
   .PHASE_SHIFT(0),     // Amount of fixed phase shift from -255 to 255
   .STARTUP_WAIT("FALSE")   // Delay configuration DONE until DCM LOCK, TRUE/FALSE
) DCM_SP_inst (
   .CLK0(_b0),     // 0 degree DCM CLK output
   .CLK180(), // 180 degree DCM CLK output
   .CLK270(), // 270 degree DCM CLK output
   .CLK2X(),   // 2X DCM CLK output
   .CLK2X180(), // 2X, 180 degree DCM CLK out
   .CLK90(),   // 90 degree DCM CLK output
   .CLKDV(),   // Divided DCM CLK out (CLKDV_DIVIDE)
   .CLKFX(clkb),   // DCM CLK synthesis out (M/D)
   .CLKFX180(), // 180 degree CLK synthesis out
   .LOCKED(), // DCM LOCK status output
   .PSDONE(), // Dynamic phase adjust done output
   .STATUS(), // 8-bit DCM status bits output
   .CLKFB(_b1),   // DCM clock feedback
   .CLKIN(clkg),   // Clock input (from IBUFG, BUFG or DCM)
   .PSCLK(),   // Dynamic phase adjust clock input
   .PSEN(1'b0),     // Dynamic phase adjust enable input
   .PSINCDEC(), // Dynamic phase adjust increment/decrement
   .RST(1'b0)        // DCM asynchronous reset input
);

// phase 2

wire _c0;
wire _c1;

BUFG BUFG_inst3 (
   .O(_c1),     // Clock buffer output
   .I(_c0)      // Clock buffer input
);

DCM_SP #(
   .CLKDV_DIVIDE(2.0), // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                       //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
   .CLKFX_DIVIDE(1),   // Can be any integer from 1 to 32      //  30 
   .CLKFX_MULTIPLY(4), // Can be any integer from 2 to 32      //  120 
   .CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
   .CLKIN_PERIOD(20.0),  // Specify period of input clock ns
   .CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift of NONE, FIXED or VARIABLE
   .CLK_FEEDBACK("1X"),  // Specify clock feedback of NONE, 1X or 2X
   .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                         //   an integer from 0 to 15
   .DLL_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for DLL
   .DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
   .PHASE_SHIFT(0),     // Amount of fixed phase shift from -255 to 255
   .STARTUP_WAIT("FALSE")   // Delay configuration DONE until DCM LOCK, TRUE/FALSE
) DCM_SP_inst2 (
   .CLK0(_c0),     // 0 degree DCM CLK output
   .CLK180(), // 180 degree DCM CLK output
   .CLK270(), // 270 degree DCM CLK output
   .CLK2X(),   // 2X DCM CLK output
   .CLK2X180(), // 2X, 180 degree DCM CLK out
   .CLK90(),   // 90 degree DCM CLK output
   .CLKDV(),   // Divided DCM CLK out (CLKDV_DIVIDE)
   .CLKFX(CLK120),   // DCM CLK synthesis out (M/D)   //   120 
   .CLKFX180(), // 180 degree CLK synthesis out
   .LOCKED(), // DCM LOCK status output
   .PSDONE(), // Dynamic phase adjust done output
   .STATUS(), // 8-bit DCM status bits output
   .CLKFB(_c1),   // DCM clock feedback
   .CLKIN(clkb),   // Clock input (from IBUFG, BUFG or DCM)
   .PSCLK(),   // Dynamic phase adjust clock input
   .PSEN(1'b0),     // Dynamic phase adjust enable input
   .PSINCDEC(), // Dynamic phase adjust increment/decrement
   .RST(1'b0)        // DCM asynchronous reset input
);

endmodule
