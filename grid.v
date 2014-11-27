`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Description:  ,     
// Master: Maxim
//////////////////////////////////////////////////////////////////////////////////
module grid(

    // block write
    input [7:0] port_id,
    input [7:0] out_port,
    input write_strobe,

    input  Enable,
    input  Stroka, // Positive impuls stroka
  
  input  LINEA,
  input  LINEB,
  input  ENABLE_A,
  input  ENABLE_B,
  input GRID_A,
  input GRID_B,
  
  input wire [5:0] COLOR_A,
  input wire [5:0] COLOR_B,
  
    input  [7:0] IDATA,
    output [5:0] ODATA,
    input  [8:0] HDATA,
    input  [8:0] VDATA
);

parameter BASE = 0;

reg [5:0] cnt;

// colors
reg [5:0] c0;
reg [5:0] c1;

// Write in registers
always @ (posedge write_strobe)
begin
  if (port_id == BASE + 0)
  begin
    c0[5:0] <= out_port[5:0];
  end
  if (port_id == BASE + 1)
  begin
    c1[5:0] <= out_port[5:0];
  end
end


//............................................
always @ (posedge Stroka) 
begin
  if (VDATA == 9'b0)
  begin
    cnt <= 0;
  end else begin
    if (cnt == 24)//24
  begin
    cnt <= 0;
  end else begin
    cnt <= cnt + 1;
  end
  end
end
// 
//  .  255
wire vert = (HDATA == 58 || HDATA ==  88 || HDATA == 118 || HDATA == 148
         || HDATA == 178 || HDATA == 208 || HDATA == 238 || HDATA == 268
         || HDATA == 298 || HDATA == 328 || HDATA == 358 || HDATA == 388 
         || HDATA == 418 || HDATA == 448 || HDATA == 478 ) 
        ^|( HDATA == 267 || HDATA == 269 ) // . . 
         && ( cnt == 1 || cnt == 6 || cnt == 11 || cnt == 16 || cnt == 21 ) ;

wire hor = (HDATA ==  64 || HDATA ==  70 || HDATA ==  76 || HDATA ==  82 || HDATA == 88 
         || HDATA ==  94 || HDATA == 100 || HDATA == 106 || HDATA == 112 || HDATA == 118   
         || HDATA == 124 || HDATA == 130 || HDATA == 136 || HDATA == 142 || HDATA == 148
         || HDATA == 154 || HDATA == 160 || HDATA == 166 || HDATA == 172 || HDATA == 178
         || HDATA == 184 || HDATA == 190 || HDATA == 196 || HDATA == 202 || HDATA == 208
         || HDATA == 214 || HDATA == 220 || HDATA == 226 || HDATA == 232 || HDATA == 238 
         || HDATA == 244 || HDATA == 250 || HDATA == 256 || HDATA == 262 || HDATA == 268      
         || HDATA == 274 || HDATA == 280 || HDATA == 286 || HDATA == 292 || HDATA == 298
         || HDATA == 304 || HDATA == 310 || HDATA == 316 || HDATA == 322 || HDATA == 328
         || HDATA == 334 || HDATA == 340 || HDATA == 346 || HDATA == 352 || HDATA == 358
         || HDATA == 364 || HDATA == 370 || HDATA == 376 || HDATA == 382 || HDATA == 388
         || HDATA == 394 || HDATA == 400 || HDATA == 406 || HDATA == 412 || HDATA == 418
         || HDATA == 424 || HDATA == 430 || HDATA == 436 || HDATA == 442 || HDATA == 448
         || HDATA == 454 || HDATA == 460 || HDATA == 466 || HDATA == 472 || HDATA == 478) 
         && ( cnt == 16 ) ^| (VDATA == 115 || VDATA == 117 ); //. . 

wire hor1 = (HDATA == 61 || HDATA ==  67 || HDATA ==  73 || HDATA == 79  || HDATA == 85 
         || HDATA ==  91 || HDATA ==  97 || HDATA == 103 || HDATA == 109 || HDATA == 115   
         || HDATA == 121 || HDATA == 127 || HDATA == 133 || HDATA == 139 || HDATA == 145
         || HDATA == 151 || HDATA == 157 || HDATA == 163 || HDATA == 169 || HDATA == 175
         || HDATA == 181 || HDATA == 187 || HDATA == 193 || HDATA == 199 || HDATA == 205
         || HDATA == 211 || HDATA == 217 || HDATA == 223 || HDATA == 229 || HDATA == 235 
         || HDATA == 241 || HDATA == 247 || HDATA == 253 || HDATA == 259 || HDATA == 265      
         || HDATA == 271 || HDATA == 277 || HDATA == 283 || HDATA == 289 || HDATA == 295
         || HDATA == 301 || HDATA == 307 || HDATA == 313 || HDATA == 319 || HDATA == 325
         || HDATA == 331 || HDATA == 337 || HDATA == 343 || HDATA == 349 || HDATA == 355
         || HDATA == 361 || HDATA == 367 || HDATA == 373 || HDATA == 379 || HDATA == 385
         || HDATA == 391 || HDATA == 397 || HDATA == 403 || HDATA == 409 || HDATA == 415
         || HDATA == 421 || HDATA == 427 || HDATA == 433 || HDATA == 439 || HDATA == 445
         || HDATA == 451 || HDATA == 457 || HDATA == 463 || HDATA == 469 || HDATA == 475) 
         && VDATA == 116 ;//

//ramka                                                                 
wire brd = (HDATA == 57 || HDATA == 479) || ((VDATA == 0 || VDATA == 233) && HDATA <= 479); // Uslovie bordura 1
//right zone
wire blk = HDATA < 57; //
//color                           right zone             ramka                           setka   fon
wire [5:0] color = (blk  == 1'b1) ? (0) : ((brd == 1'b1) ? c1 : (((vert || hor || hor1) == 1'b1) ? c1 : c0)); // Vibiraem color
//yslovie podlojki
wire e = (Enable == 1'b0) || (Enable == 1'b1 && IDATA[5:0] == 6'b0); //
//multiplexor na vivod
wire [5:0] t;
assign t = (e == 1'b1) ? color : IDATA[5:0]; //

//assign ODATA = /* (GRID_A || GRID_B) ? 6'b111111 : (*/(LINEA && ENABLE_A) ? COLOR_A : ((LINEB && ENABLE_B) ? COLOR_B : t);
//assign ODATA = (GRID_B || GRID_A) ? 5'b11011 : ((LINEA && ENABLE_A) ? COLOR_A : ((LINEB && ENABLE_B) ? COLOR_B : t) ) ;
assign ODATA = (LINEA && ENABLE_A) ? COLOR_A : ((LINEB && ENABLE_B) ? COLOR_B : t) ;


// test grid
//assign ODATA = ((HDATA == 0 || HDATA == 239 || HDATA == 479 || VDATA == 0  || VDATA == 119 || VDATA == 233)) ? 5'b11011 : 0;

//  ,,  
//assign ODATA = {( brd || grd || blk)};

initial
begin
  cnt <= 0;
  c0 <= 0;
  c1 <= 1;
end



endmodule
