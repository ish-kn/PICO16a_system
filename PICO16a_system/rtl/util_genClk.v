//------------------------------------------------------------------------//
//                                                                        //
//  Class           : Comp. Organ. and Design class                       //
//  Project         : PICO_basic_system                                   //
//  File Name       : PICO_basic_system.v                                 //
//                                                                        //
//------------------------------------------------------------------------//
//  HISTORY         :                                                     //
//  REV   DATE        AUTHOR        NOTE                                  //
//  0.01  2006        N.Hamada      Initial Version                       //
//  0.02  2007/08/06  Y.Sato        Using Megafunction Memory Version     //
//  0.03  2009/08/20  Y.Ikegaki     Revise descriptions                   //
//                                                                        //
//------------------------------------------------------------------------//

module genClk
  (
   //-- input --//
   iclk,
   rst,

   //-- output --//
   oclk
   );

   //-- input 
   input         iclk; // 50 MHz
   input         rst;
   //-- output 
   output        oclk; // 2 Hz

   //-- reg
   reg    [31:0] count;
   reg           oclk;


   always@(posedge iclk) begin
      if(!rst) begin
         count <= 32'h0;
         oclk  <= 1'b0;
      end
      else begin
         count <= count + 32'h00000001;
         if(count >= 32'h00000001 && count < 32'h00BEBC20)      oclk  <= 1'b1;
         else if(count >= 32'h00BEBC20 && count < 32'h017D7840 ) oclk  <= 1'b0;
         else if(count == 32'h017D7840)                       count <= 32'h00000000;
      end
   end

endmodule // genClk
