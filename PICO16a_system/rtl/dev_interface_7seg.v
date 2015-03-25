module dev_interface_7seg
  (
   from_cpu,
   rst,
   cpu_clk,
   cs,
   we,
   to_cpu,
   HEX
   );

   input  [15:0] from_cpu;
   input         rst;
   input         cpu_clk;
   input         cs;
   input         we;

   output [15:0] to_cpu;
   output [6:0]  HEX;

   reg    [3:0]  d_reg;


   // Complete below description.
   assign  to_cpu = {12'b0, d_reg};


   // Complete below description in parentheses.
   always @(posedge cpu_clk or negedge rst) begin
      if(!rst)          d_reg <= 4'b0;
      else if(cs && we) d_reg <= from_cpu[3:0];
      else              d_reg <= d_reg;
   end


   sevenseg_dec segment0
     (
      .din(d_reg),
      .dout(HEX)
      );

endmodule // dev_interface_7seg
