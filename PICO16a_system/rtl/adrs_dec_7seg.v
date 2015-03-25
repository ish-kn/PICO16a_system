`define BASE_SEVENSEG  16'h8008
`define SPACE_SEVENSEG 2

module adrs_dec_7seg
  (
   adrs,
   cpu_clk,
   we,
   cs_hex0,
   cs_hex1,
   cs_hex2,
   cs_hex3,
   rst,
   read_hex0,
   read_hex1,
   read_hex2,
   read_hex3     
   );

   input  [15:0] adrs;  
   input         cpu_clk;
   input         we;
   input         rst;

   output        read_hex0;
   output        read_hex1;
   output        read_hex2;
   output        read_hex3;
   output        cs_hex0;
   output        cs_hex1;
   output        cs_hex2;
   output        cs_hex3;

   reg           read_hex0;
   reg           read_hex1;
   reg           read_hex2;
   reg           read_hex3;

   wire   [3:0]  cs_hex;
   wire          ms;


   // Complete descriptions: 
   // Here, we compare upper 14-bit of adrs and the base address of
   // 7-segment LED; when they have same address, that means this 
   // module is selected.
   assign  ms = (adrs[15:2] == (`BASE_SEVENSEG) >> `SPACE_SEVENSEG) ? 1'b1 : 1'b0;

   // Compare lower 2-bit of adrs and ms.
   // When they have same address, set corresponded bit of cs_hex
   // to 1.
   assign  cs_hex = (ms == 1'b1 && adrs[1:0] == 2'b00) ? 4'b0001 : 
		   (ms == 1'b1 && adrs[1:0] == 2'b01) ? 4'b0010 :
		   (ms == 1'b1 && adrs[1:0] == 2'b10) ? 4'b0100 :
			(ms == 1'b1 && adrs[1:0] == 2'b11) ? 4'b1000 : 4'b0000;


   assign  cs_hex0 = cs_hex[0];
   //
   // Add descriptions for cs_hex{1-3}
   //
	assign cs_hex1 = cs_hex[1];
	assign cs_hex2 = cs_hex[2];
	assign cs_hex3 = cs_hex[3];

   always @(posedge cpu_clk or negedge rst) begin
      if (!rst) begin
		 read_hex0 <= 1'b0;
		 read_hex1 <= 1'b0;
		 read_hex2 <= 1'b0;
		 read_hex3 <= 1'b0;
      end
      
      else if (cs_hex0 && !we)
			read_hex0 <= 1'b1;
		else if (cs_hex1 && !we)
			read_hex1 <= 1'b1;
		else if (cs_hex2 && !we)
			read_hex2 <= 1'b1;
		else if (cs_hex3 && !we)
			read_hex3 <= 1'b1;
      else begin
		 read_hex0 <= 1'b0;
		 read_hex1 <= 1'b0;
		 read_hex2 <= 1'b0;
		 read_hex3 <= 1'b0;
      end

   end // always @ (posedge cpu_clk or negedge rst)
   
endmodule // adrs_dec_7seg
