//////////////////////////////////////////////////////
//  memory controller for PICO16a bus system
//////////////////////////////////////////////////////
//  2007.08      Created by Yuka Sato
//  2007.09.06   Modify the module composition   
//  2009.08.20   Modify the assignment of cs signal (Yuki Ikegaki)
//

module memory (
               // cpu I/F
               from_cpu,
               we,
               cpu_clk,
               rst,
               adrs,
               to_cpu,

               // peripheral I/F
               // none
               );

   // cpu I/F
   input         we;
   input         rst;
   input         cpu_clk;
   input  [15:0] adrs;
   input  [15:0] from_cpu;
   output [15:0] to_cpu;

   // wires/register 
   wire          cs;
   wire   [15:0] mem_out;
   reg 	         read;

   // bus I/F
   // address decode 
   assign  cs = (adrs[15:9] == 7'b0000000) ? 1'b1 : 1'b0;

   always @(posedge cpu_clk or negedge rst)
     if(!rst)           read <= 1'b0;
     else if(cs && !we) read <= 1'b1;
     else               read <= 1'b0;

   assign  to_cpu = (read) ? mem_out : 16'hzzzz;

   // peripheral controller
   mem imem
     (
      //-- input --//
      .clock(cpu_clk),
      .data(from_cpu),
      .wren(we & cs),
      .address(adrs[8:0]),
      //-- output --//
      .q(mem_out)
      );


endmodule // memory
