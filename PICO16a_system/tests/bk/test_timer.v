`timescale 1ps/1ps

module test_timer;
   reg         clock50;
   reg         exclock;
   reg  [3:0]  keys;
   reg  [17:0] sws;
   reg  [15:0] clk_num;
   
   wire [6:0]  hex_0;
   wire [6:0]  hex_1;
   wire [6:0]  hex_2;
   wire [6:0]  hex_3;
   wire [6:0]  hex_4;
   wire [6:0]  hex_5;
   wire [6:0]  hex_6;
   wire [6:0]  hex_7;
   wire [8:0]  led_g;
   wire [17:0] led_r;
   wire        lcdon;                  
   wire        lcdblon;                        
   wire        lcdrw;                          
   wire        lcden;                          
   wire        lcdrs;          
   wire [7:0]  lcddata;
   
   
   PICO16a_system top
     (
      ////////////////////   Clock Input       ////////////////////////////////
      .CLOCK_50(clock50),                        //   50 MHz
      .EXT_CLOCK(exclock),                       //   External Clock
      ////////////////////   Push Button       ////////////////////////////////
      .KEY(keys),                                //   Pushbutton[3:0]
      ////////////////////   DPDT Switch       ////////////////////////////////
      .SW(sws),                                  //   Toggle Switch[17:0]
      ////////////////////   7-SEG Display     ////////////////////////////////
      .HEX0(hex_0),                              //   Seven Segment Digit 0
      .HEX1(hex_1),                              //   Seven Segment Digit 1
      .HEX2(hex_2),                              //   Seven Segment Digit 2
      .HEX3(hex_3),                              //   Seven Segment Digit 3
      .HEX4(hex_4),                              //   Seven Segment Digit 4
      .HEX5(hex_5),                              //   Seven Segment Digit 5
      .HEX6(hex_6),                              //   Seven Segment Digit 6
      .HEX7(hex_7),                              //   Seven Segment Digit 7
      ////////////////////   LED               ////////////////////////////////
      .LEDG(led_g),                              //   LED Green[8:0]
      .LEDR(led_r),                              //   LED Red[17:0]
      ////////////////////   LCD Module 16X2   ////////////////////////////////
      .LCD_ON(lcdon),                            //   LCD Power ON/OFF
      .LCD_BLON(lcd_blon),                       //   LCD Back Light ON/OFF
      .LCD_RW(lcdrw),                            //   LCD Read/Write Select, 0 = Write, 1 = Read
      .LCD_EN(lcden),                            //   LCD Enable
      .LCD_RS(lcdrs),                            //   LCD Command/Data Select, 0 = Command, 1 = Data
      .LCD_DATA(lcddata) 
      );


   initial begin 
      $shm_open("./test_timer");
      $shm_probe(test_timer.top, "AS");
      
      $readmemh("sample_timer.mem", top.rmem.imem.altsyncram_component.mem_data);

      keys[3:0]=4'b1111;
      clock50 = 1'b1;
      sws[17:0] = 18'b101111111111111111;
      keys[0] = 1'b0;
      #100
        keys[0]= 1'b1;
      
      #10000
        $writememh("result_timer.txt", top.rmem.imem.altsyncram_component.mem_data);
      keys[0]=1'b0;
      #100
        $finish;
   end // initial begin

   always #10 clock50 = ~clock50;

endmodule // test_timer
