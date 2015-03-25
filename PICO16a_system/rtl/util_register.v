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

module register
  (
   //-- input --//
   din, 
   we, 
   clk, 
   rst,
   //-- output --//
   dout
   );
   
   //-- input
   input  [15:0] din;
   input         we;
   input         clk;
   input         rst;
   
   //-- output
   output [15:0] dout;
   //-- reg
   reg    [15:0] dout;


   always @(posedge clk or negedge rst) begin
      if(!rst) dout <= 16'b0;
      else     dout <= (we) ? din : dout;
   end

endmodule // register
