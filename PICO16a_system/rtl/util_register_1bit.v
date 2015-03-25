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


module register_1bit
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
   input  clk;
   input  rst;
   input  din;
   input  we;
   
   //-- output
   output dout;
   //-- reg     
   reg    dout;


   always @(posedge clk or negedge rst) begin
      if(!rst) dout <= 1'b0;
      else     dout <= (we) ? din : dout;
   end

endmodule // register_1bit
