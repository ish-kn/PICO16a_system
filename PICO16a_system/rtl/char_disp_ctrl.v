module char_disp_ctrl
  (
    input        cpu_clk, pixel_clk,
   
    input [9:0]  iCoord_X,
    input [9:0]  iCoord_Y,
    output [9:0] oRed,
    output [9:0] oGreen,
    output [9:0] oBlue,
    input 	 re,
   
    input [7:0]  char_code,
    input [12:0] w_adrs, 
    input [6:0]  wCoord_X,
    input [5:0]  wCoord_Y,
    input 	 we,
    output [7:0] char_code_out
   );

   parameter  VGA_H_SIZE    = 80;
   parameter  VGA_V_SIZE    = 60;
   parameter  VGA_ON_RED    = 0;
   parameter  VGA_ON_GREEN  = 0;
   parameter  VGA_ON_BLUE   = 0;
   parameter  VGA_OFF_RED   = 1023;
   parameter  VGA_OFF_GREEN = 1023;
   parameter  VGA_OFF_BLUE  = 1023;
   
   wire [12:0] read_adrs            = {iCoord_Y[8:3],iCoord_X[9:3]};
   wire [7:0]  read_char_code;
   wire [10:0] char_rom_adrs_offset = read_char_code << 3;
   wire [10:0] char_rom_adrs        = iCoord_Y[2:0] + char_rom_adrs_offset;
   wire [7:0]  char_rom_bits;
   wire [2:0]  char_adrs            = ~iCoord_X[2:0];
   wire        char_bit             = char_rom_bits[char_adrs];
   
   char_rom c_rom (
		   .clock( pixel_clk ),
		   .address( char_rom_adrs ),
		   .q( char_rom_bits )
		   );

   frame_buffer fb (
		    .address_a( w_adrs ),
		    .address_b( read_adrs ),
		    .clock_a( cpu_clk ),
		    .clock_b( pixel_clk ),
		    .data_a( char_code ),
		    .data_b(),
		    .wren_a( we ),
		    .wren_b(),
		    .q_a( char_code_out ),
		    .q_b( read_char_code )
		    );

   testram_vga test_ram (
			 .address( w_adrs ),
			 .clock( cpu_clk ),
			 .data( char_code ),
			 .wren( we ),
			 .q_a(),
			 );

   assign  oRed   = ( char_bit & re ) ? VGA_ON_RED   : VGA_OFF_RED;
   assign  oGreen = ( char_bit & re ) ? VGA_ON_GREEN : VGA_OFF_GREEN;
   assign  oBlue  = ( char_bit & re ) ? VGA_ON_BLUE  : VGA_OFF_BLUE;

endmodule // char_disp_ctrl
