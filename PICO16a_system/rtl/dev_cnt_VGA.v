`define  BASE_VGA   16'ha000
`define  SPACE_VGA  13        // 8192 words (4800 active / 3392 reserve)

module dev_cnt_VGA
  (
   // Host Side
   cpu_clk, sys_clk, rst,
   adrs, from_cpu, to_cpu, we,
   
   // VGA Side
   VGA_R, VGA_G, VGA_B,
   VGA_HS, VGA_VS, VGA_SYNC,
   VGA_BLANK, VGA_CLK
   );

   // Host Side
   input         cpu_clk, sys_clk, rst;
   input  [15:0] adrs;
   input  [15:0] from_cpu;
   output [15:0] to_cpu;
   input         we;

   // VGA Side
   output [9:0]  VGA_R;
   output [9:0]  VGA_G;
   output [9:0]  VGA_B;
   output  	 VGA_HS;
   output 	 VGA_VS;
   output 	 VGA_SYNC;
   output 	 VGA_BLANK;
   output 	 VGA_CLK;

   //-- wires / registers
   wire          cs;
   wire   [15:0] vga_out;
   reg 	         read;

   
   // bus I/F
   // address decoder
  
   // Write the code that generates cs, read and to_cpu.
   // a) For generating cs, use the macro-definition "BASE_VGA" and "SPACE_VGA".
   // b) The read signal is no hint.
   // c) For generating cpu, use the vga_out.

	assign cs = (adrs[15:13] == (`BASE_VGA) >> `SPACE_VGA) ? 1'b1 : 1'b0;
   
	always @(posedge cpu_clk or negedge rst) begin
		if (!rst) read <= 1'b0;
		else if (cs && !we) read <= 1'b1;
		else read <= 1'b0;
	end
	
	assign to_cpu = (read) ? vga_out : 16'hzzzz;

   
   // peripheral controller
   dev_interface_VGA vga
     (
      // Host Side
      .adrs(adrs[12:0]),
      .cpu_clk(cpu_clk),
      .sys_clk(sys_clk),
      .rst(rst),
      .from_cpu(from_cpu),
      .to_cpu(vga_out),
      .we(we),
      .cs(cs),

      // VGA Side
      .oVGA_R(VGA_R),
      .oVGA_G(VGA_G),
      .oVGA_B(VGA_B),
      .oVGA_HS(VGA_HS),
      .oVGA_VS(VGA_VS),
      .oVGA_SYNC(VGA_SYNC),
      .oVGA_BLANK(VGA_BLANK),
      .oVGA_CLK(VGA_CLK)
      );

endmodule // dev_cnt_VGA
