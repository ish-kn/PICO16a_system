//////////////////////////////////////////////////////
//  timer interface for PICO16a bus system
//////////////////////////////////////////////////////
//  2007.08      Created by Hamada
//  2007.09.06   Modefied the module composition   
//

`define TIMER_BASE     16'h8000
`define TIMER_SPACE    3         // 4  words

module dev_cnt_timer
  (
   //-- input, from cpu --//
   cpu_clk,
   rst,
   we,
   adrs,
   from_cpu,

   //-- output, to cpu --//
   to_cpu,
   int_req
   );

   //-- input
   input         cpu_clk;
   input         rst;
   input         we;
   input [15:0]  adrs;
   input [15:0]  from_cpu;

   //-- output
   output [15:0] to_cpu;
   output        int_req;

   // wires/register
   wire          cs;
   wire [15:0]   timer_out;
   reg           read;

   // bus I/F
   // address decoder
   
   // Write the code that generates cs, read and to_cpu
   // a) For generating cs, use macro-definitions, "TIMER_BASE" and "TIMER_SPACE"  
   // b) The read signal is no hint.
   // c) For generating to_cpu, use the timer_out.

	assign cs = (adrs[15:3] == (`TIMER_BASE) >> `TIMER_SPACE) ? 1'b1 : 1'b0;
   
	always @(posedge cpu_clk or negedge rst) begin
		if (!rst) read <= 1'b0;
		else if (cs && !we) read <= 1'b1;
		else read <= 1'b0;
	end
	
	assign to_cpu = (read) ? timer_out : 16'hzzzz;
	
   timer timer
     (
      //-- input --//
      .from_cpu(from_cpu),
      .cpu_clk(cpu_clk),
      .rst(rst),
      .cs(cs),
      .we(we),
      .adrs(adrs[2:0]),

      //-- output --//
      .int_req(int_req),
      .to_cpu(timer_out)
      );

endmodule
