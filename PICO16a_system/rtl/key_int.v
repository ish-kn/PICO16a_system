////////////////////////////////////////////////////////////////////
// key_int.v
//
//
////////////////////////////////////////////////////////////////////

`define int_wait   2'b01
`define int_occur  2'b10

module key_int
  (
   //-- Bus I/F
   from_cpu,
   cs, 
   we,
   sys_clk,
   cpu_clk,
   rst,
   adrs,
   to_cpu,
  
   //-- peripheral I/F
   key3,
   int_req
   );
   
   //-- bus I/F
   input         we;
   input         cs;
   input         sys_clk;
   input         cpu_clk;
   input         rst;
   input  [15:0] adrs;
   input  [15:0] from_cpu;
   output [15:0] to_cpu;

   //-- peripheral I/F
   input         key3;
   output        int_req;

   //-- registers
   reg    [1:0]  state_key3;
   reg    [19:0] clk_count;
   reg           sw_reg0;
   reg           sw_reg1;
   reg           sw_out_reg;
   reg           sw_mask;
   reg           key3_int_negate;
   reg    [9:0]  key3_int_detect;
   wire          key3_int_assert;
   wire          bounced_key3;


   always@(posedge sys_clk or negedge rst)begin

      if(!rst) begin
         clk_count  <= 10'b0;
         sw_reg1    <= 1'b0;
         sw_reg0    <= 1'b0;
         sw_out_reg <= 1'b0;
         sw_mask    <= 1'b0;    
         sw_reg1    <= 1'b0;
         sw_reg0    <= 1'b0;            
      end
      else begin
         sw_reg1 <= sw_reg0;
         sw_reg0 <= ~key3;
         if(sw_mask == 1'b0) begin // switch input available
            if(sw_reg1 != sw_reg0) begin
               sw_mask   <= 1'b1;
               clk_count <= 10'h000;
            end
         end
         else begin
            // sim
            if(clk_count[3] == 1'b1)begin
               // for FPGA
               // if(clk_count[19]==1'b1)begin

               sw_mask    <= 1'b0;
               sw_out_reg <= sw_reg1;
            end
	    else begin
               clk_count <= clk_count + 10'h001;
            end
         end
      end // else: !if(!rst)

   end // always@ (posedge sys_clk or negedge rst)

   assign  bounced_key3 = sw_out_reg;


   // key3_int_assart edge detection
   always @(posedge cpu_clk or negedge rst) begin
      if(!rst) key3_int_detect <= 10'h000;
      else     key3_int_detect <= {key3_int_detect[8:0], bounced_key3};
   end

   assign  key3_int_assert = (key3_int_detect == 10'h200) ? 1'b1 : 1'b0;


   // key3_int_negate edge detection
   always @(posedge cpu_clk or negedge rst)begin
      if(!rst) key3_int_negate <= 1'b0;
      else begin
         if(cs & we & (!from_cpu[0])) key3_int_negate <= 1'b1;
         else                         key3_int_negate <= 1'b0;
      end
   end


   assign  intreq_key3 = (state_key3 == `int_occur) ? 1'b1 : 1'b0;

   always @(posedge cpu_clk or negedge rst) begin
      if(!rst) state_key3 <= `int_wait;
      else begin
	 case(state_key3)
           `int_wait  : state_key3 <= (key3_int_assert == 1'b1) ? `int_occur : `int_wait;
           `int_occur : state_key3 <= (key3_int_negate == 1'b1) ? `int_wait  : `int_occur;
           default    : state_key3 <= `int_wait;
	 endcase // case (state_key3)
      end
   end


   // interrupt request
   assign  int_req = intreq_key3;
   assign  to_cpu  = {15'h00, intreq_key3};


endmodule // keyint_ctr
