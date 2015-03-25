//-----------------------------------------------------------------------------
// PICO16a system
// --------------------------------------------------------------------
// Copyright (c) 2005 by Terasic Technologies Inc. 
//               2007 by The University of Aizu

module PICO16a_system
  (
   ////////////////////   Clock Input       ////////////////////////////////
   CLOCK_27,                                  //   27 MHz
   CLOCK_50,                                  //   50 MHz
   EXT_CLOCK,                                 //   External Clock
   ////////////////////   Push Button       ////////////////////////////////
   KEY,                                       //   Pushbutton[3:0]
   ////////////////////   DPDT Switch       ////////////////////////////////
   SW,                                        //   Toggle Switch[17:0]
   ////////////////////   7-SEG Display     ////////////////////////////////
   HEX0,                                      //   Seven Segment Digit 0
   HEX1,                                      //   Seven Segment Digit 1
   HEX2,                                      //   Seven Segment Digit 2
   HEX3,                                      //   Seven Segment Digit 3
   HEX4,                                      //   Seven Segment Digit 4
   HEX5,                                      //   Seven Segment Digit 5
   HEX6,                                      //   Seven Segment Digit 6
   HEX7,                                      //   Seven Segment Digit 7
   ////////////////////   LED               ////////////////////////////////
   LEDG,                                      //   LED Green[8:0]
   LEDR,                                      //   LED Red[17:0]
   ////////////////////   LCD Module 16X2   ////////////////////////////////
   LCD_ON,                                    //   LCD Power ON/OFF
   LCD_BLON,                                  //   LCD Back Light ON/OFF
   LCD_RW,                                    //   LCD Read/Write Select, 0 = Write, 1 = Read
   LCD_EN,                                    //   LCD Enable
   LCD_RS,                                    //   LCD Command/Data Select, 0 = Command, 1 = Data
   LCD_DATA,                                  //   LCD Data bus 8 bits
   ////////////////////   VGA               ////////////////////////////////
   VGA_R, 
   VGA_G, 
   VGA_B,
   VGA_HS, 
   VGA_VS, 
   VGA_SYNC,
   VGA_BLANK, 
   VGA_CLK
   );


   ////////////////////   Clock Input       ////////////////////////////////
   input         CLOCK_27;                    //   27 MHz
   input         CLOCK_50;                    //   50 MHz
   input         EXT_CLOCK;                   //   External Clock
   ////////////////////   Push Button       ////////////////////////////////
   input  [3:0]  KEY;                         //   Pushbutton[3:0]
   ////////////////////   DPDT Switch       ////////////////////////////////
   input  [17:0] SW;                          //   Toggle Switch[17:0]
   ////////////////////   7-SEG Display     ////////////////////////////////
   output [6:0]  HEX0;                        //   Seven Segment Digit 0
   output [6:0]  HEX1;                        //   Seven Segment Digit 1
   output [6:0]  HEX2;                        //   Seven Segment Digit 2
   output [6:0]  HEX3;                        //   Seven Segment Digit 3
   output [6:0]  HEX4;                        //   Seven Segment Digit 4
   output [6:0]  HEX5;                        //   Seven Segment Digit 5
   output [6:0]  HEX6;                        //   Seven Segment Digit 6
   output [6:0]  HEX7;                        //   Seven Segment Digit 7
   ////////////////////   LED               ////////////////////////////////
   output [8:0]  LEDG;                        //   LED Green[8:0]
   output [17:0] LEDR;                        //   LED Red[17:0]
   ////////////////////   LCD Module 16X2   ///////////////////////////////
   inout  [7:0]  LCD_DATA;                    //   LCD Data bus 8 bits
   output        LCD_ON;                      //   LCD Power ON/OFF
   output        LCD_BLON;                    //   LCD Back Light ON/OFF
   output        LCD_RW;                      //   LCD Read/Write Select, 0 = Write, 1 = Read
   output        LCD_EN;                      //   LCD Enable
   output        LCD_RS;                      //   LCD Command/Data Select, 0 = Command, 1 = Data
   ////////////////////   VGA               ////////////////////////////////
   output [9:0]  VGA_R;
   output [9:0]  VGA_G;
   output [9:0]  VGA_B;
   output        VGA_HS;
   output        VGA_VS;
   output        VGA_SYNC;
   output        VGA_BLANK;
   output        VGA_CLK;


   wire          clk;
   wire          DLY_RST;

   // LCD ON
   assign  LCD_ON   = 1'b1;
   assign  LCD_BLON = 1'b1;

   assign  LEDG     = 0;
   assign  LEDR     = {clk, ~clk, 16'h00};


   //-- wire
   wire          we;
   wire  [15:0]  to_cpu;
   wire  [15:0]  from_cpu;
   wire  [15:0]  adrs;
   wire          cpu_clk;
   wire  [15:0]  irout;
   wire          clk_1;
   wire          clk_100k;
   wire          int_req1;
   wire          int_req2;
   wire          rst;
   wire  [1:0]   clkSel;
   wire          clk_key3;


   // rename
   assign  rst      = KEY[0];
   assign  clkSel   = SW[17:16];
   assign  clk_key3 = KEY[1];

   //-- Comment out here when you use int_req1 on your timer module --//
   // assign  int_req1 = 1'b0;


   // TO use clock 27MHz, td_reset must be assarted to high level
   assign  td_reset = 1'b1;
   genClk gclk
     (
      //-- input --//
      .iclk(CLOCK_27),
      .rst(rst),
      //-- output --//
      .oclk(clk_1)
      );


   // clock mux
   // NOW, because rst is not work well when you use 1 Hz clock,
   // clk is always 27 MHz when rst is negated.
   assign  clk = (rst == 1'b1 && clkSel == 2'b01) ? clk_1 :
                 (rst == 1'b1 && clkSel == 2'b11) ? clk_key3 :
                 (rst == 1'b1 && clkSel == 2'b10) ? CLOCK_27 :
                 (rst == 1'b0) ? clk_key3 : clk_key3;
   assign  irout[15:0] = 16'b0;


   pico16a pico
     (//-- input --//
      .to_cpu(to_cpu),
      .cpu_clk(cpu_clk),
      .int_req1(int_req1),
      .int_req2(int_req2),
      .clk(clk),
      .rst(rst),
      //-- output --//
      .from_cpu(from_cpu),
      .we(we),
      .adrs(adrs),
      .irout()
      );
   
   memory rmem
     (
      .from_cpu(from_cpu),
      .we(we),
      .cpu_clk(cpu_clk),
      .rst(rst),
      .adrs(adrs),
      .to_cpu(to_cpu)
      );


   // Add VGA controller module



endmodule // PICO16a_system
