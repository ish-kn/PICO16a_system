//////////////////////////////////////////////////////////////////////////
// LCD controller
//////////////////////////////////////////////////////////////////////////
//  2007.08.06    Created by Y.Okuyama (based on LCD_TEST.v in DE2 CDROM)
//  2007.08.28    Added the status register (and check check......) 
//  2007.09.05    Modified the micro ctr. logics (for speed up)
//  2009.12.13    Modified bitwidth of adrs (6bit -> 5bit)
//////////////////////////////////////////////////////////////////////////

// `define CLK_27MHz
`define CLK_50MHz

// initialization delay (4.1ms)
`ifndef iDLY_CLK
 `ifdef CLK_50MHz
  `define iDLY_CLK  18'h3FFFE
 `else
  `define iDLY_CLK  18'h228F4
 `endif
`endif

// write delay (43us)
`ifndef wDLY_CLK
 `ifdef CLK_50MHz
  `define wDLY_CLK  18'h3FFFE
 `else
  `define wDLY_CLK  18'h003DD
 `endif
`endif


module dev_interface_LCD
  (
   // Host Side
   cpu_clk, sys_clk, rst,
   adrs, from_cpu, to_cpu, we, cs,
   // LCD Side
   LCD_DATA, LCD_RW, LCD_EN, LCD_RS
   );


   // Host Side
   input         cpu_clk,sys_clk,rst;
   input  [4:0]  adrs;
   input  [15:0] from_cpu;
   output [15:0] to_cpu;
   input         cs;
   input         we;

   // LCD Side
   output [7:0]  LCD_DATA;
   output        LCD_RW, LCD_EN, LCD_RS;

   // Internal Wires/Registers
   // for LCD driver
   reg    [2:0]  mLCD_ST;     // LCD control state reg.
   reg    [17:0] mDLY;        // LCD delay reg.
   reg           mLCD_Start;  // LCD command issue status(H:command transfer L: ready)
   reg    [7:0]  mLCD_DATA;   // LCD data reg.
   reg           mLCD_RS;     // LCD mode select (H:DATA, L:Instruction code)
   wire          mLCD_Done;   // LCD command accept signal
   wire   [8:0]  cmd_data;    // LCD data bits
   reg    [5:0]  INDEX;       // program counter for micro corde
   reg    [9:0]  micro_rom;   // instruction register for micro code
   wire   [7:0]  scan_data;   // charactor rom data

   wire          write;

   assign write = we & cs;

   parameter ST_LCD_INIT = 0;
   parameter ST_LCD_SCAN = 1;

   parameter LCD_LOOP = 4;
   parameter LCD_END  = 37;


   // timing generator
   always @(posedge sys_clk or negedge rst) begin

      if(!rst) begin
	 INDEX      <= 0;
	 mLCD_ST    <= 0;
	 mDLY       <= 0;
	 mLCD_Start <= 0;
	 mLCD_DATA  <= 0;
	 mLCD_RS    <= 0;
      end

      else begin
	 case(mLCD_ST)
           0 : begin
	      mLCD_DATA  <= cmd_data[7:0];
	      mLCD_RS    <= cmd_data[8];
	      mLCD_Start <= 1;
	      mLCD_ST    <= 1;
           end // case: 0

           1 : begin
	      if(mLCD_Done) begin
		 mLCD_Start <= 0;
		 mLCD_ST    <= 2;
	      end
           end // case: 1

           2 : begin
	      if(INDEX >= LCD_LOOP)
		if(mDLY < `iDLY_CLK) mDLY <= mDLY+1;
		else begin
		   mDLY    <= 0;
		   mLCD_ST <= 3;
		end
	      else
		if(mDLY<`wDLY_CLK) mDLY <= mDLY+1;
		else begin
		   mDLY    <= 0;
		   mLCD_ST <= 3;
		end
           end // case: 2

           3 : begin
	      if(INDEX == LCD_END) INDEX <= LCD_LOOP;
	      else                 INDEX <= INDEX+1;
	      mLCD_ST <= 4;
           end // case: 3

           4 : begin
	      mLCD_ST <= 0;
           end // case: 4

	 endcase
      end // else: !if(!rst)

   end // always @ (posedge sys_clk or negedge rst)


   // micro command format
   // cmd[9] mode (0:raw/ 1:ram)
   // for raw mode
   //  cmd[8]   -> RS
   //  cmd[7:0] -> DB[7:0]
   //  This mode issues the instruction 
   //  specified with cmd[8:0]
   // for ram mode
   //  cmd[8:5] -> reserved
   //  cmd[4:0] -> char ram address
   //  This mode issues the write Data instruction
   //  with the address of char ram
   parameter [9:0] ClearDisplay = 10'h001;   
   parameter [9:0] ReturnHome   = 10'h002;
   function [9:0] EntryModeSet; input ID,SH; begin EntryModeSet = {8'h01,ID,SH}; end endfunction
   function [9:0] DisplayOnOffControl; input D,C,B; begin DisplayOnOffControl = {7'h01,D,C,B}; end endfunction
   function [9:0] CursorOrDisplayShift; input SC,RL; begin CursorOrDisplayShift = {6'h01,SC,RL,2'h0}; end endfunction
   function [9:0] FunctionSet; input DL,N,F; begin FunctionSet = {5'h01, DL, N, F, 2'h0}; end endfunction
   function [9:0] SetCGRAMAddress; input [5:0] AC; begin SetCGRAMAddress = {4'h1,AC}; end endfunction
   function [9:0] SetDDRAMAddress; input [6:0] AC; begin SetDDRAMAddress = {3'h1,AC}; end endfunction
   function [9:0] OutputData; input [4:0] ADR; begin OutputData = {1'b1,4'h0, ADR}; end endfunction
   parameter [9:0] MoveToFirstLine  = SetDDRAMAddress(7'h00);
   parameter [9:0] MoveToSecondLine = SetDDRAMAddress(7'h40);



   // microcode
   always @(INDEX) begin
      case(INDEX)
	// Initial
	0 :   micro_rom <= FunctionSet(1,1,0);
	1 :   micro_rom <= DisplayOnOffControl(1,0,0);
	2 :   micro_rom <= ClearDisplay;
	3 :   micro_rom <= EntryModeSet(1,0); 
	4 :   micro_rom <= MoveToFirstLine;   // SCAN cycle
	5 :   micro_rom <= OutputData(5'h00);
	6 :   micro_rom <= OutputData(5'h01);
	7 :   micro_rom <= OutputData(5'h02);
	8 :   micro_rom <= OutputData(5'h03);
	9 :   micro_rom <= OutputData(5'h04);
	10 :  micro_rom <= OutputData(5'h05);
	11 :  micro_rom <= OutputData(5'h06);
	12 :  micro_rom <= OutputData(5'h07);
	13 :  micro_rom <= OutputData(5'h08);
	14 :  micro_rom <= OutputData(5'h09);
	15 :  micro_rom <= OutputData(5'h0A);
	16 :  micro_rom <= OutputData(5'h0B);
	17 :  micro_rom <= OutputData(5'h0C);
	18 :  micro_rom <= OutputData(5'h0D);
	19 :  micro_rom <= OutputData(5'h0E);
	20 :  micro_rom <= OutputData(5'h0F);
	21 :  micro_rom <= MoveToSecondLine;
	22 :  micro_rom <= OutputData(5'h10);
	23 :  micro_rom <= OutputData(5'h11);
	24 :  micro_rom <= OutputData(5'h12);
	25 :  micro_rom <= OutputData(5'h13);
	26 :  micro_rom <= OutputData(5'h14);
	27 :  micro_rom <= OutputData(5'h15);
	28 :  micro_rom <= OutputData(5'h16);
	29 :  micro_rom <= OutputData(5'h17);
	30 :  micro_rom <= OutputData(5'h18);
	31 :  micro_rom <= OutputData(5'h19);
	32 :  micro_rom <= OutputData(5'h1A);
	33 :  micro_rom <= OutputData(5'h1B);
	34 :  micro_rom <= OutputData(5'h1C);
	35 :  micro_rom <= OutputData(5'h1D);
	36 :  micro_rom <= OutputData(5'h1E);
	37 :  micro_rom <= OutputData(5'h1F);
	default : micro_rom <= 10'hxxx;
      endcase // case (INDEX)
   end // always @ (INDEX)


   assign  cmd_data = (!micro_rom[9]) ? micro_rom[8:0] : {1'b1, scan_data};
   assign  to_cpu[15:8] = 8'h0;


   dpram8x32 scan_ram
     (
      .address_a(adrs[4:0]),
      .address_b(micro_rom[4:0]),
      .clock_a(cpu_clk),
      .clock_b(sys_clk),
      .data_a(from_cpu[7:0]),
      .data_b(/* nc */),
      .wren_a(write),
      .wren_b(/* nc */),
      .q_a(to_cpu[7:0]),
      .q_b(scan_data)
      );

   testram test_ram
     (
      .address(adrs[4:0]),
      .clock(cpu_clk),
      .data(from_cpu[7:0]),
      .wren(write),
      .q(/* nc */)
      );

   LCD_raw_controller u0
     (
      // Host Side
      .iDATA(mLCD_DATA),
      .iRS(mLCD_RS),
      .iStart(mLCD_Start),
      .oDone(mLCD_Done),
      .iCLK(sys_clk),
      .iRST_N(rst),
      // LCD Interface
      .LCD_DATA(LCD_DATA),
      .LCD_RW(LCD_RW),
      .LCD_EN(LCD_EN),
      .LCD_RS(LCD_RS)
      );

endmodule // dev_interface_LCD
