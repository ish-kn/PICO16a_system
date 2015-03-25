////////////////////////////////////////////////////////////////////
// KEY3 interrupt controller for PICO16a bus
////////////////////////////////////////////////////////////////////

`define BASE_INT      16'h800c
`define SPACE_INT     2       // 4 words

module dev_cnt_key3int
  (
   // Host Side
   cpu_clk, sys_clk, rst,
   adrs, from_cpu, to_cpu, we,
   // KEY3INT Side
   key,
   int_req
   );

   // Host Side
   input         cpu_clk, sys_clk, rst;
   input  [15:0] adrs;
   input  [15:0] from_cpu;
   output [15:0] to_cpu;
   input         we;

   // KEY3INT Side
   input         key;
   output        int_req;
   
   //-- wires/registers
   wire          cs;
   wire   [15:0] keyint_out;
   reg           read;
	

   // bus I/F
   // address decoder
   
   // Write the code that generates cs, read and to_cpu.
   // a) For generating cs, use the macro-definition "BASE_INT" and "SPACE_INT".
   // b) The read signal is no hint.
   // c) For generating cpu, use the keyint_out.
		
	assign cs = (adrs[15:2] == (`BASE_INT) >> `SPACE_INT) ? 1'b1 : 1'b0;
   
	always @(posedge cpu_clk or negedge rst) begin
		if (!rst) read <= 1'b0;
		else if (cs && !we) read <= 1'b1;
		else read <= 1'b0;
	end
	
	assign to_cpu = (read) ? keyint_out : 16'hzzzz;
	
   // peripheral controller
   key_int key3int_if
     (
      // Host side
      .adrs(adrs),
      .from_cpu(from_cpu),
      .cpu_clk(cpu_clk),
      .sys_clk(sys_clk),
      .rst(rst),
      .cs(cs),
      .we(we),
      .to_cpu(keyint_out),
      // Peripheral side
      .key3(key),
      .int_req(int_req)
      );

endmodule // dev_cnt_key3int
