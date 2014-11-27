`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Description: SCOP ADS831 80MHz
// 
//////////////////////////////////////////////////////////////////////
module main(
    input CLK66,
	 
	 // TFT
    output wire [5:0] RGB_OUT, // pixel color
	 output wire CKV,  // Clock
	 output wire STV,  // STV[D|U]
	 output wire OEV,  // OE Vertical
	 output wire STH,  // STH[L|R]
	 output wire OEH,  // OE Horizontal
	 output wire CPH1, // CPH 

	 // ADC
    input [7:0] ADC_A,  
    input [7:0] ADC_B,
    output wire ADC_A_CLOCK,
    output wire ADC_B_CLOCK,
	 
	 // KEYS
	 input wire COL1,
	 input wire COL2,
	 input wire COL3,
	 input wire COL4,
	 output wire ROW1,
	 output wire ROW2,
	 output wire ROW3,
	 output wire ROW4,
	 
	 // RELAYS
    output  RELAY_A,
    output  RELAY_B,

	 // DDS
	 output SCLK,
	 output SDIN,
	 output SYNC,
	 input ModeGen,// perekluchatel sinus-treugolnik

    // TRIGGER
	 input TRIGGER_A,
	 input TRIGGER_B,

	 // LED
    output LED0,
    output LED1
 );
assign LED1 = 0;
assign LED0 = 0;


// Clock system generator (30MHz & 120MHz)
wire CLK30, CLK120;
dcms dcms (
    .CLK66(CLK66), //  input 66 
    .CLK30(CLK30), // output 30 
    .CLK120(CLK120)// output 120 
);
// Debug slowly pin
wire SLOWLESS;
tester test(
    .IN(CLK30),
	 .OUT(SLOWLESS)
);
// processor
wire [7:0] port_id;
wire write_strobe;
wire read_strobe;
wire [7:0] out_port;
wire [7:0] in_port;
wire interrupt;
wire interrupt_ack;
embedded_kcpsm3 pico (
	.port_id(port_id),
	.write_strobe(write_strobe),
	.read_strobe(read_strobe),
	.out_port(out_port),
	.in_port(in_port),
	.interrupt(interrupt),
	.interrupt_ack(interrupt_ack),
	.reset(0),
	.clk(SLOWLESS)
);
// Enables channels
wire ENABLE_A;
wire ENABLE_B;
m_port #(.WIDTH(2),.BASE(254)) enables (
   .port_id(port_id),
	.out_port(out_port),
	.write_strobe(write_strobe),
	.out({ENABLE_B, ENABLE_A})
);
// Resampler
wire CLK_A;
wire [7:0] ADC_MIN_A;
wire [7:0] ADC_MAX_A;
wire [7:0] CURR_MIN_A;
resampler #(16) resamplerA (
   .port_id(port_id),
	.out_port(out_port),
	.write_strobe(write_strobe),
	.in_port(in_port),
	.clk_in(CLK120),
	.clk_out(CLK_A),
	.clk_60(ADC_A_CLOCK),
	.data_in(ADC_A),
	.data_out_max(ADC_MAX_A),
	.data_out_min(ADC_MIN_A),
	.CURR_MIN(CURR_MIN_A)
);
// Resampler
wire CLK_B;
wire [7:0] ADC_MIN_B;
wire [7:0] ADC_MAX_B;
wire [7:0] CURR_MIN_B;
resampler #(20) resamplerB (
   .port_id(port_id),
	.out_port(out_port),
	.write_strobe(write_strobe),
	.in_port(in_port),
	.clk_in(CLK120),
	.clk_out(CLK_B),
	.clk_60(ADC_B_CLOCK),
	.data_in(ADC_B),
	.data_out_max(ADC_MAX_B),
	.data_out_min(ADC_MIN_B),
	.CURR_MIN(CURR_MIN_B)
);
// TFT
//.........Modul TCON , timing TFT.
wire [8:0] HDATA_; // HOR counter
wire [8:0] VDATA_; // VERT counter
tcon tcon (
	.CLK120(CLK120), // Clock 120 MHz
	.CKV_(CKV),      // Clock
	.STV_(STV),      // STV[D|U]
	.OEV_(OEV),      // OE Vertical
	.STH_(STH),      // STH[L|R]
	.OEH_(OEH),      // OE Horizontal
	.CPH1_(CPH1),    // CPH 
	.hdata(HDATA_),  // HOR counter
	.vdata(VDATA_)   // VERT counter
);
// Table
wire [5:0] text_out;
wire [5:0] color_a;
wire [5:0] color_b;
m_text #(8) text (
   .port_id(port_id),
	.out_port(out_port),
	.write_strobe(write_strobe),
	.CLK(CLK120),
	.HDATA(HDATA_),
	.VDATA(VDATA_),
	.COLOR_A(color_a),
	.COLOR_B(color_b),
	.OUT(text_out)
);
// Grid сетка ,рамка, текст
reg [7:0] idata;
wire line_a;
wire line_b;
wire grid_a;
wire grid_b;
grid #(4) grid ( // Base address = 4
   .port_id(port_id),
	.out_port(out_port),
	.write_strobe(write_strobe),
	.Enable(1'b1),
	.Stroka(CKV), // Positive impuls stroka (CKV)
	.ENABLE_A(ENABLE_A),
	.ENABLE_B(ENABLE_B),
	.LINEA(line_a),
	.LINEB(line_b),
	.GRID_A(grid_a),
	.GRID_B(grid_b),
	.HDATA(HDATA_),
	.VDATA(VDATA_),   
	.COLOR_A(color_a),
	.COLOR_B(color_b),
	.IDATA(text_out),
	.ODATA(RGB_OUT)
);		  
// Trigger A синхронизация
wire [7:0] lev_a;
m_port #(.WIDTH(8),.BASE(200)) tri_a (
   .port_id(port_id),
	.out_port(out_port),
	.write_strobe(write_strobe),
	.out(lev_a)
);
// Trigger B синхронизация
wire [7:0] lev_b;
m_port #(.WIDTH(8),.BASE(201)) tri_b (
   .port_id(port_id),
	.out_port(out_port),
	.write_strobe(write_strobe),
	.out(lev_b)
);
// ADC buffer
m_buffer #(.WIDTH(479)) adca (
   .CLK_ADC(CLK_A),
	.CLK(CLK120),
	.D(ADC_MIN_A),
	.E(ADC_MAX_A),
	.HDATA({0, 0, HDATA_}),
	.VDATA({0, 0, VDATA_}),
	.NEXT_FRAME(STV),
	.TRG(TRIGGER_A),
	.TRI_SEL(lev_a),
	.CURR_MIN(CURR_MIN_A),
	.OUT(line_a)
);
// ADC buffer
m_buffer #(.WIDTH(479)) adcb (
   .CLK_ADC(CLK_B),
	.CLK(CLK120),
	.D(ADC_MIN_B),
	.E(ADC_MAX_B),
	.HDATA({0, 0, HDATA_}),
	.VDATA({0, 0, VDATA_}),
	.NEXT_FRAME(STV),
	.TRG(TRIGGER_B),
	.TRI_SEL(lev_b),
	.CURR_MIN(CURR_MIN_B),
	.OUT(line_b)
);
// Keyboard
m_keys #(24) k_keys (
   .port_id(port_id),
	.in_port(in_port),
	.CLK(SLOWLESS),
	.COL1(COL1),
	.COL2(COL2),
	.COL3(COL3),
	.COL4(COL4),
	.ROW1(ROW1),
	.ROW2(ROW2),
	.ROW3(ROW3),
	.ROW4(ROW4)
);
// Relays постоянка-переменка А
m_port #(.WIDTH(1),.BASE(28)) rel_a (
   .port_id(port_id),
	.out_port(out_port),
	.write_strobe(write_strobe),
	.out(RELAY_A)
);
// Relays постоянка-переменка Б
m_port #(.WIDTH(1),.BASE(29)) rel_b (
   .port_id(port_id),
	.out_port(out_port),
	.write_strobe(write_strobe),
	.out(RELAY_B)
);
//DDS генератор
dds #(.BASE(32)) dds (
	 .clk(CLK30),
	 .FSYNC(SYNC),
	 .SCLK(SCLK),
	 .SDATA(SDIN),
	 // io
	 .port_id(port_id),
	 .out_port(out_port),
	 .write_strobe(write_strobe)
);
//переключатель sin - treg
in_port #(.BASE(48)) trisin (
    .clk(CLK30),
	 .port_id(port_id),
	 .in_port(in_port),
	 .inp(ModeGen)
);
endmodule
//это конец...........................................
