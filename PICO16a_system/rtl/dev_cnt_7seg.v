module dev_cnt_7seg
  (
   from_cpu,
   we,
   cpu_clk,
   rst,
   adrs,
   to_cpu,
   hex0,
   hex1,
   hex2,
   hex3
   );

   input         we;
   input         cpu_clk;
   input         rst;
   input  [15:0] from_cpu;
   input  [15:0] adrs;

   output [6:0]  hex0;
   output [6:0]  hex1;
   output [6:0]  hex2;
   output [6:0]  hex3;
   output [15:0] to_cpu;

   wire          cs_hex0;
   wire          cs_hex1;
   wire          cs_hex2;
   wire          cs_hex3;
   wire          read_hex0;
   wire          read_hex1;
   wire          read_hex2;
   wire          read_hex3;
   wire [15:0]   w_adrs;
   wire [15:0]   seg_out_hex0;
   wire [15:0]   seg_out_hex1;
   wire [15:0]   seg_out_hex2;
   wire [15:0]   seg_out_hex3;


   // Complete below descriptions.
   assign to_cpu = (read_hex0) ? seg_out_hex0 :
		   (read_hex1) ? seg_out_hex1 :
		   (read_hex2) ? seg_out_hex2 :
		   (read_hex3) ? seg_out_hex3	: 16'hzzzz;


   // Complete below description in parentheses.
   adrs_dec_7seg adrs_dec
     (
		.adrs(adrs),
		.cpu_clk(cpu_clk),
		.we(we),
		.cs_hex0(cs_hex0),
		.cs_hex1(cs_hex1),
		.cs_hex2(cs_hex2),
		.cs_hex3(cs_hex3),
		.rst(rst),
		.read_hex0(read_hex0),
		.read_hex1(read_hex1),
		.read_hex2(read_hex2),
		.read_hex3(read_hex3)
      );
		
   dev_interface_7seg for_hex0
     (
      .from_cpu(from_cpu),
      .rst(rst),
      .cpu_clk(cpu_clk),
      .we(we),
      .cs(cs_hex0),
      .to_cpu(seg_out_hex0),
      .HEX(hex0)
      );

   //
   // Add descriptions for for_hex{1-3} like above description.
   //
	
	   dev_interface_7seg for_hex1
     (
      .from_cpu(from_cpu),
      .rst(rst),
      .cpu_clk(cpu_clk),
      .we(we),
      .cs(cs_hex1),
      .to_cpu(seg_out_hex1),
      .HEX(hex1)
      );
		
		   dev_interface_7seg for_hex2
     (
      .from_cpu(from_cpu),
      .rst(rst),
      .cpu_clk(cpu_clk),
      .we(we),
      .cs(cs_hex2),
      .to_cpu(seg_out_hex2),
      .HEX(hex2)
      );
		
		   dev_interface_7seg for_hex3
     (
      .from_cpu(from_cpu),
      .rst(rst),
      .cpu_clk(cpu_clk),
      .we(we),
      .cs(cs_hex3),
      .to_cpu(seg_out_hex3),
      .HEX(hex3)
      );


endmodule // dev_cnt_7seg
