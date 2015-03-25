////////////////////////////////////////////////////////////////////
// LCD controller for PICO16a bus
////////////////////////////////////////////////////////////////////

`define BASE_LCD    16'h8040
`define SPACE_LCD   5        // 32 words

module dev_cnt_LCD
  (
   // Host Side
   cpu_clk, sys_clk, rst,
   adrs, from_cpu, to_cpu, we,
   // LCD Side
   LCD_DATA, LCD_RW, LCD_EN, LCD_RS
   );

   // Host Side
   input         cpu_clk, sys_clk, rst;
   input  [15:0] adrs;
   input         we;
   input  [15:0] from_cpu;
   output [15:0] to_cpu;

   // LCD Side
   output [7:0]  LCD_DATA;
   output        LCD_RW, LCD_EN, LCD_RS;

   //-- wire
   wire 	 cs;
   wire [15:0] 	 lcd_out;

   //-- register
   reg 		 read;


   // bus I/F
   // address decoder

   // Write the code that generates cs, read, and to_cpu.
   // For generating cs, use the BASE_LCD and SPACE_LCD.
   // For generating to_cpu, use the lcd_out.
	
	assign cs = (adrs[15:5] == (`BASE_LCD) >> `SPACE_LCD) ? 1'b1 : 1'b0;
	
	always @(posedge cpu_clk or negedge rst) begin
		if (!rst) read <= 1'b0;
		else if (cs && !we) read <= 1'b1;
		else read <= 1'b0;
	end
	
	assign to_cpu = (read) ? lcd_out : 16'hzzzz;
	
   // peripheral controller
   dev_interface_LCD lcd
     (
      // Host side
      .adrs(adrs[4:0]),
      .from_cpu(from_cpu),
      .cpu_clk(cpu_clk),
      .sys_clk(sys_clk),
      .rst(rst),
      .cs(cs),
      .we(we),
      .to_cpu(lcd_out),
      
      // Peripheral side
      .LCD_DATA(LCD_DATA),
      .LCD_RW(LCD_RW),
      .LCD_EN(LCD_EN),
      .LCD_RS(LCD_RS)
      );

endmodule // dev_cnt_LCD
