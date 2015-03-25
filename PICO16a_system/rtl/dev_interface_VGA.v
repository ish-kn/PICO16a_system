module dev_interface_VGA
  (
   // Host Side
   input         cpu_clk, sys_clk, rst,
   input  [12:0] adrs,
   input  [15:0] from_cpu,
   output [15:0] to_cpu,
   input 	 we,
   input 	 cs,
   
   // VGA Side
   output [9:0]  oVGA_R,
   output [9:0]  oVGA_G,
   output [9:0]  oVGA_B,
   output  	 oVGA_HS,
   output  	 oVGA_VS,
   output 	 oVGA_SYNC,
   output 	 oVGA_BLANK,
   output 	 oVGA_CLK
   );

   wire   [9:0]  mRed, mGreen, mBlue;
   wire   [9:0]  VGA_X, VGA_Y;
   wire          VGA_Read;

   wire   [7:0]  char_code = from_cpu[7:0];
   wire          write     = we & cs;


   assign  to_cpu[15:8] = 8'h00;

   VGA_controller vga_ctrl
     (
      // Host Side
      .iRed(mRed),
      .iGreen(mGreen),
      .iBlue(mBlue),
      .oCurrent_X(VGA_X),
      .oCurrent_Y(VGA_Y),
      .oRequest(VGA_Read),

      // VGA Side
      .oVGA_R(oVGA_R),
      .oVGA_G(oVGA_G),
      .oVGA_B(oVGA_B),
      .oVGA_HS(oVGA_HS),
      .oVGA_VS(oVGA_VS),
      .oVGA_SYNC(oVGA_SYNC),
      .oVGA_BLANK(oVGA_BLANK),
      .oVGA_CLK(oVGA_CLK),

      // Control Signal
      .pixel_clk(sys_clk),
      .rst(rst)
      );

   char_disp_ctrl char_ctrl
     (
      .cpu_clk(cpu_clk),
      .pixel_clk(sys_clk),

      // Read from frame buffer
      .iCoord_X(VGA_X),
      .iCoord_Y(VGA_Y),		      
      .oRed(mRed),
      .oGreen(mGreen),
      .oBlue(mBlue),
      .re(VGA_Read),

      // Write character code
      .char_code(char_code),
      .w_adrs(adrs),
      .we(write),
      .char_code_out(to_cpu[7:0])
      );


endmodule // dev_interface_VGA
