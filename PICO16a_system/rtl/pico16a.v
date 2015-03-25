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
//                                                                        //
//------------------------------------------------------------------------//

// Intrrupt routine address
`define INTADDR1 16'h0100
`define INTADDR2 16'h0180

`define IF_rst   5'b00001
`define IF       5'b00010
`define DEC      5'b00100
`define EX       5'b01000
`define WB       5'b10000

// IR15-11
`define RTYPE    5'b00000
`define ADDI     5'b00110
`define SUBI     5'b00111
`define ANDI     5'b00010
`define ORI      5'b00011
`define XORI     5'b00100
`define LDLI     5'b11100
`define LDHI     5'b11101
`define BNEZ     5'b01001
`define BEQZ     5'b01010
`define BMI      5'b01011
`define BPL      5'b01100
`define JMP      5'b01111
`define JR       5'b01110
`define JAL      5'b01101
`define JALR     5'b01000

// IR4-0
`define NOP      5'b00000
`define MV       5'b00001
`define LD       5'b01000
`define ST       5'b01001
`define SL       5'b01100
`define SR       5'b01101
`define EINT     5'b10001
`define RFI      5'b10000
`define DINT     5'b10100
`define LIAR     5'b10010
`define SIAR     5'b10011

// ALU
`define THA      4'b0000
`define THB      4'b0001
`define AND      4'b0010
`define OR       4'b0011
`define XOR      4'b0100
`define NOT      4'b0101
`define ADD      4'b0110
`define SUB      4'b0111
`define SHL      4'b1100
`define SHR      4'b1101


module pico16a
  (
   //-- input --//
   clk, 
   rst,
   int_req1, 
   int_req2, 
   to_cpu, 
   //-- output --//
   cpu_clk,
   we,
   adrs,
   from_cpu,
   irout
   );
   
   //-- input
   input         clk;
   input         rst;
   input         int_req1;
   input         int_req2;
   input  [15:0] to_cpu;
   //-- output
   output        we;
   output        cpu_clk;
   output [15:0] from_cpu;
   output [15:0] adrs;
   output [15:0] irout;
   
   //-- wire
   wire          ir_we;        // enable signal of IR reg
   wire          pc_we;        // enable signal of PC reg
   wire          rf_we;        // enable signal of Resigter File
   wire          reg1_we;      // enable signal of Reg1 reg
   wire          reg2_we;      // enabel signal of Reg2 reg
   wire          iar_we;       // enable signal of IAR reg
   wire          doutSel;
   wire          addrSel;
   wire          isZero_reg1;
   wire          sign_reg1;
   wire          jal_op;
   wire          mem_addr_bit;
   wire          ienable_in;
   wire          ienable_out;
   wire          ienable_we;
   wire          pcSel;
   wire          iarSel;
   wire   [1:0]	 aluSrc1;
   wire   [1:0]  aluSrc2;
   wire   [1:0]  ir_extendSel;
   wire   [2:0]  dSel;
   wire          dSel2;
   wire   [3:0]  alu_func;
   wire   [4:0]  op;
   wire   [4:0]  func;


   assign  cpu_clk = clk;

   datapath dp
     (
      //-- input
      .clk(clk), 
      .rst(rst),
      .din(to_cpu), 
      .ir_we(ir_we), 
      .pc_we(pc_we), 
      .rf_we(rf_we), 
      .reg1_we(reg1_we), 
      .reg2_we(reg2_we), 
      .iar_we(iar_we),
      .doutSel(doutSel),
      .addrSel(addrSel), 
      .pcSel(pcSel), 
      .jal_op(jal_op), 
      .ienable_in(ienable_in), 
      .ienable_we(ienable_we), 
      .iarSel(iarSel),
      .aluSrc1(aluSrc1), 
      .aluSrc2(aluSrc2), 
      .ir_extendSel(ir_extendSel),
      .dSel(dSel), 
      .dSel2(dSel2), 
      .alu_func(alu_func),
      //-- output
      .dout(from_cpu), 
      .address(adrs),
      .op(op),
      .func(func),
      .isZero_reg1(isZero_reg1), 
      .sign_reg1(sign_reg1),
      .mem_addr_bit(mem_addr_bit),
      .ienable_out(ienable_out),
      .observe_out(irout)
      );
   
   
   controller cunit
     (
      //-- input 
      .clk(clk), 
      .rst(rst),
      .op(op),
      .func(func), 
      .isZero_reg1(isZero_reg1),
      .sign_reg1(sign_reg1),
      .mem_addr_bit(mem_addr_bit),
      .int_req1(int_req1), 
      .int_req2(int_req2), 
      .ienable_out(ienable_out), 
      //-- output
      .ir_we(ir_we),
      .pc_we(pc_we),
      .rf_we(rf_we),
      .reg1_we(reg1_we),
      .reg2_we(reg2_we),
      .iar_we(iar_we),
      .doutSel(doutSel), 
      .addrSel(addrSel), 
      .jal_op(jal_op), 
      .ienable_in(ienable_in), 
      .ienable_we(ienable_we), 
      .iarSel(iarSel),
      .aluSrc1(aluSrc1), 
      .aluSrc2(aluSrc2),
      .ir_extendSel(ir_extendSel),
      .dSel(dSel),
      .dSel2(dSel2), 
      .alu_func(alu_func),
      .we(we),
      .pcSel(pcSel)
      );

endmodule // pico16a



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
//                                                                        //
//------------------------------------------------------------------------//

module datapath
  (
   //-- input --//
   clk, 
   rst,
   din, 
   ir_we, 
   pc_we, 
   rf_we, 
   reg1_we, 
   reg2_we, 
   iar_we,
   doutSel, 
   addrSel, 
   jal_op, 
   ienable_in, 
   ienable_we, 
   iarSel,
   aluSrc1, 
   aluSrc2, 
   ir_extendSel,
   dSel, 
   dSel2, 
   alu_func,
   pcSel,
   //-- output --//
   dout, 
   address,
   op, 
   func, 
   isZero_reg1, 
   sign_reg1, 
   mem_addr_bit,
   ienable_out,
   observe_out
   );
   
   //-- input      
   input         clk;
   input         rst;
   input  [15:0] din;
   input         ir_we;
   input         pc_we;
   input         rf_we;
   input         reg1_we;
   input         reg2_we;
   input         iar_we;
   input         doutSel;
   input         addrSel;
   input         jal_op;
   input         ienable_in;
   input         ienable_we;
   input         iarSel;
   input  [1:0]  aluSrc1;
   input  [1:0]  aluSrc2;
   input  [1:0]  ir_extendSel;
   input  [2:0]  dSel;
   input         dSel2;
   input  [3:0]  alu_func;
   input         pcSel;
   
   //-- output
   output [15:0] dout;
   output [15:0] address;
   output [4:0]  op;
   output [4:0]  func;
   output        isZero_reg1;
   output        sign_reg1;
   output        mem_addr_bit;
   output        ienable_out;
   output [15:0] observe_out;
   
   //-- wire
   wire   [15:0] reg1_out;
   wire   [15:0] reg2_out;
   wire   [15:0] pc_out;
   wire   [15:0] iar_out;
   wire   [15:0] dmux_out;
   wire   [15:0] pc_in;
   wire   [15:0] dmux2_out;
   wire   [15:0] smux1_out;
   wire   [15:0] smux2_out;
   wire   [15:0] ir_extend_out;
   wire   [15:0] rf_out1;
   wire   [15:0] rf_out2;
   wire   [15:0] alu_out;
   wire   [2:0]  regaddr1;
   wire   [15:0] iar_in;
   wire   [15:0] ir_out;


   assign  observe_out = ir_out;
   
   register ir
     (
      .din(dmux_out), 
      .we(ir_we), 
      .dout(ir_out), 
      .clk(clk), 
      .rst(rst)
      );
   
   register reg1
     (
      .din(rf_out1), 
      .we(reg1_we), 
      .dout(reg1_out), 
      .clk(clk), 
      .rst(rst)
      );
   
   register reg2
     (
      .din(rf_out2), 
      .we(reg2_we), 
      .dout(reg2_out), 
      .clk(clk), 
      .rst(rst)
      );
   
   register pc
     (
      .din(pc_in), 
      .we(pc_we), 
      .dout(pc_out), 
      .clk(clk), 
      .rst(rst)
      );
   
   
   register iar
     (
      .din(iar_in), 
      .we(iar_we), 
      .dout(iar_out), 
      .clk(clk), 
      .rst(rst)
      );
   
   regfile rf
     (
      .addr1(regaddr1), 
      .addr2(ir_out[7:5]),
      .din(dmux2_out), 
      .we(rf_we), 
      .dout1(rf_out1), 
      .dout2(rf_out2),
      .clk(clk), 
      .rst(rst)
      );
   
   alu16 alu
     (
      .din1(smux1_out), 
      .din2(smux2_out), 
      .func(alu_func), 
      .dout(alu_out)
      );
   
   
   register_1bit intrrupt_enable
     (
      .din(ienable_in), 
      .we(ienable_we), 
      .dout(ienable_out), 
      .clk(clk), 
      .rst(rst)
      );
   
   
   // dmux
   assign  dmux_out = (dSel == 3'b000) ? din :
                      (dSel == 3'b001) ? alu_out : 
                      (dSel == 3'b100) ? `INTADDR1:
                      (dSel == 3'b101) ? `INTADDR2: `INTADDR1;
   // dmux2
   assign  dmux2_out = (dSel2 == 1'b0)? dmux_out : pc_out;


   // alu src 1
   assign  smux1_out = (aluSrc1 == 2'b00) ? reg1_out :
                       (aluSrc1 == 2'b01) ? pc_out : 
                       (aluSrc1 == 2'b10) ? iar_out : iar_out;
   
   // alu src 2
   assign  smux2_out = (aluSrc2 == 2'b00) ? reg2_out :
                       (aluSrc2 == 2'b01) ? ir_extend_out :
                       (aluSrc2 == 2'b10) ? 16'h0001: 16'h0001;
   
   // mdrmux
   assign  dout = (doutSel == 1'b0) ? din : rf_out2;
   
   // pcmux
   assign  pc_in = (pcSel == 1'b0) ? dmux_out : rf_out1;
   
   // addr mux
   assign  address = (addrSel == 1'b0) ? pc_out : dmux_out;
   
   // imm mux
   assign  ir_extend_out = (ir_extendSel == 2'b00) ?
                           {{8{ir_out[7]}}, ir_out[7:0]} :

                           (ir_extendSel == 2'b01) ? 
                           {ir_out[7:0], 8'h00} : 

                           (ir_extendSel == 2'b10)?
                           {{5{ir_out[10]}}, ir_out[10:0]}:

                           (ir_extendSel == 2'b11)?
                           {8'h00, ir_out[7:0]} : {8'h00, ir_out[7:0]};
   
   // iar mux
   assign  iar_in = (iarSel == 1'b0) ? pc_out : alu_out;


   assign  op = ir_out[15:11];
   assign  func = ir_out[4:0];

   assign  isZero_reg1 = (reg1_out == 16'b0);
   assign  sign_reg1 = reg1_out[15];

   assign  regaddr1 = (jal_op == 1'b1) ? 3'b111 : ir_out[10:8];
   assign  mem_addr_bit = dmux_out[0];

endmodule // datapath



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
//  0.03  2009/08/20  Y.Ikegaki     Revise descriptions for the state     //
//                                  transition                            //
//                                                                        //
//------------------------------------------------------------------------//

module controller
  (
   //-- input --//
   clk, 
   rst,
   op, 
   func, 
   isZero_reg1, 
   sign_reg1, 
   mem_addr_bit,
   int_req1,
   int_req2,
   ienable_out,
  
   //-- output --//
   ir_we, 
   pc_we, 
   rf_we, 
   reg1_we, 
   reg2_we, 
   iar_we,
   doutSel, 
   addrSel, 
   jal_op, 
   ienable_in, 
   ienable_we, 
   iarSel,
   aluSrc1, 
   aluSrc2, 
   ir_extendSel,
   dSel, 
   dSel2, 
   alu_func,
   we,
   pcSel
   );
   
   //-- input 
   input         clk;
   input         rst;
   input  [4:0]  op;
   input  [4:0]  func;
   input         isZero_reg1;
   input         sign_reg1;
   input         mem_addr_bit;
   input         ienable_out;
   input         int_req1;
   input         int_req2;

   //-- output
   output        ir_we;
   output        pc_we;
   output        rf_we;
   output        reg1_we;
   output        reg2_we;
   output        iar_we;
   output        doutSel;
   output        addrSel;
   output        pcSel;
   output [1:0]  aluSrc1;
   output [1:0]  aluSrc2;
   output [1:0]  ir_extendSel;
   output [2:0]  dSel;
   output        dSel2;
   output [3:0]  alu_func;

   output        we;
   output        jal_op;
   output        ienable_in;
   output        ienable_we;
   output        iarSel;

   //-- register        
   reg           ir_we;
   reg           pc_we;
   reg           rf_we;
   reg           reg1_we;
   reg           reg2_we;
   reg           iar_we;
   reg           doutSel;
   reg           addrSel;
   reg           pcSel;
   reg           we;
   reg           jal_op;
   reg           ienable_in;
   reg           ienable_we;
   reg           iarSel;
   reg    [1:0]  aluSrc1;
   reg    [1:0]  aluSrc2;
   reg    [1:0]  ir_extendSel;
   reg    [2:0]  dSel;
   reg           dSel2;
   reg    [3:0]  alu_func;
   reg    [4:0]  state;


   // state transition
   always @(posedge clk or negedge rst) begin

      if(!rst) state <= `IF_rst;
      else begin
	 case(state)
           `IF_rst : state <= `IF;
           `IF     : state <= (ienable_out == 1'b1 
			       && (int_req1 == 1'b1||int_req2 == 1'b1)) ? `IF : `DEC;
           `DEC    : state <= `EX;
           `EX     : state <= (op == `RTYPE && (func == `LD||func == `ST||func == `RFI)) ? `WB :
                              (op == `JALR) ? `WB : 
                              (op == `BNEZ || op == `BEQZ || op == `BMI || op == `BPL
			       || op == `JMP || op == `JR || op == `JAL) ? `WB : `IF;
           `WB     : state <= `IF;
           default : state <= `IF;
         endcase
      end

   end
   

   // output function
   always @( state or op or func or sign_reg1 or 
             isZero_reg1 or mem_addr_bit or 
             ienable_out or int_req1 or int_req2 ) begin
      
      alu_func     <= 4'b0000;
      ir_we        <= 1'b0;
      pc_we        <= 1'b0;
      rf_we        <= 1'b0;
      reg1_we      <= 1'b0;
      reg2_we      <= 1'b0;
      dSel         <= 3'b000;
      dSel2        <= 1'b0;
      aluSrc1      <= 2'b00;
      doutSel      <= 1'b0;
      addrSel      <= 1'b0;
      aluSrc2      <= 2'b00;
      ir_extendSel <= 2'b00;
      we           <= 1'b0;
      jal_op       <= 1'b0;
      iar_we       <= 1'b0;
      iarSel       <= 1'b0;
      ienable_in   <= 1'b0;
      ienable_we   <= 1'b0;
      pcSel        <= 1'b0;

      case(state)
        `IF_rst : begin

        end // case: `IF_rst


	`IF : begin
	   // interrupt
	   if(ienable_out == 1'b1 && (int_req1 == 1'b1 || int_req2 == 1'b1)) begin
              addrSel    <= 1'b1;
              iar_we     <= 1'b1;
              pc_we      <= 1'b1;
              ienable_we <= 1'b1;

              if(int_req1)      dSel <= 3'b100;
              else if(int_req2) dSel <= 3'b101;
           end
           else begin
              ir_we <= 1'b1;
              dSel  <= 3'b000;
           end
	end // case: `IF


        `DEC : begin
           ir_we    <= 1'b0;
           addrSel  <= 1'b1;
           alu_func <= 4'b0110; // ADD
           aluSrc1  <= 2'b01;   // pc_out
           aluSrc2  <= 2'b10;   // 16'h0001
           dSel     <= 3'b001;
           pc_we    <= 1'b1;

           if(op == `RTYPE && (func == `LD || func == `SIAR || func == `SL || func == `SR)) begin
              reg2_we <= 1'b1;
           end
           else if(op != `RTYPE && (op[4:3] == 2'b00 || op == `JAL || op == `BNEZ || op == `BEQZ
				    || op == `BMI || op == `BPL|| op == `JR)) begin
              reg1_we <= 1'b1;
           end
           else if(op == `RTYPE && ((func[4:3] == 2'b00) || func == `ST)) begin
              reg1_we <= 1'b1;
              reg2_we <= 1'b1;
           end
           else if(op != `RTYPE && op == `JALR) begin
              jal_op  <= 1'b1;
              rf_we   <= 1'b1;
           end
	end // case: `DEC


        `EX : begin
           if(op == `RTYPE) begin
              if(func == `LD) begin
                 alu_func   <= 4'b0001;
                 addrSel    <= 1'b1;
                 dSel       <= 3'b001;
              end
              else if(func == `ST) begin
                 doutSel    <= 1'b1;
                 addrSel    <= 1'b1;
                 dSel       <= 3'b001;
                 we         <= 1'b1;
              end
              else if(func == `SL || func == `SR) begin
                 alu_func   <= {1'b1, func[2:0]};
                 rf_we      <= 1'b1;
                 dSel       <= 3'b001;
              end
              else if(func[4:3] == 2'b00)begin
                 alu_func   <= func[3:0];
                 rf_we      <= 1'b1;
                 dSel       <= 3'b001;
              end
              else if(func == `RFI) begin
                 dSel       <= 3'b001;
                 aluSrc1    <= 2'b10;
                 pc_we      <= 1'b1;
                 ienable_in <= 1'b1;
                 ienable_we <= 1'b1;
              end
	      else if(func == `EINT) begin
                 ienable_in <= 1'b1;
                 ienable_we <= 1'b1;
              end
	      else if(func == `DINT) begin
                 ienable_we <= 1'b1;
              end
	      else if(func == `LIAR) begin
                 dSel       <= 3'b001;
                 aluSrc1    <= 2'b10;
                 rf_we      <= 1'b1;
              end
	      else if(func == `SIAR) begin
                 dSel       <= 3'b001;
                 alu_func   <= 4'b0001;
                 iarSel     <= 1'b1;
                 iar_we     <= 1'b1;
              end
	   end // if (op == `RTYPE)

           else begin
              if(op == `LDLI || op == `LDHI) begin
                 alu_func <= 4'b0001;
                 aluSrc2  <= 2'b01;
                 dSel     <= 3'b001;
                 rf_we    <= 1'b1;
                 if(op == `LDHI) ir_extendSel <= 2'b01;
              end
              // immediate instruction
              else if(op[4:3] == 2'b00) begin
                 alu_func <= op[3:0];
                 aluSrc2  <= 2'b01;
                 dSel     <= 3'b001;
                 rf_we    <= 1'b1;
                 if(op[2:1] == 2'b11) ir_extendSel <= 2'b00;
                 else                 ir_extendSel <= 2'b11;
              end

              else if(op == `BNEZ) begin
                 aluSrc1  <= 2'b01;
                 aluSrc2  <= 2'b01;
                 dSel     <= 3'b001;
                 pc_we    <= ~isZero_reg1;
                 alu_func <= 4'b0110;
              end
	      else if(op == `BEQZ) begin
                 aluSrc1  <= 2'b01;
                 aluSrc2  <= 2'b01;
                 dSel     <= 3'b001;
                 pc_we    <= isZero_reg1;
                 alu_func <= 4'b0110;
              end
	      else if(op == `BMI) begin
                 aluSrc1  <= 2'b01;
                 aluSrc2  <= 2'b01;
                 dSel     <= 3'b001;
                 pc_we    <= sign_reg1;
                 alu_func <= 4'b0110;
              end
	      else if(op == `BPL) begin
                 aluSrc1  <= 2'b01;
                 aluSrc2  <= 2'b01;
                 dSel     <= 3'b001;
                 pc_we    <= ~sign_reg1;
                 alu_func <= 4'b0110;
              end
	      else if(op == `JMP) begin
                 aluSrc1      <= 2'b01;
                 aluSrc2      <= 2'b01;
                 dSel         <= 3'b001;
                 pc_we        <= 1'b1;
                 ir_extendSel <= 2'b10;
                 alu_func     <= 4'b0110;
              end
	      else if(op == `JR) begin
                 dSel     <= 3'b001;
                 pc_we    <= 1'b1;
              end
	      else if(op == `JAL) begin
                 aluSrc1      <= 2'b01;
                 aluSrc2      <= 2'b01;
                 dSel         <= 3'b001;
                 dSel2        <= 1'b1;
                 pc_we        <= 1'b1;
                 rf_we        <= 1'b1;
                 jal_op       <= 1'b1;
                 alu_func     <= 4'b0110;
                 ir_extendSel <= 2'b10;
              end
	      else if(op == `JALR) begin 
                 addrSel  <= 1'b1;
                 pcSel    <= 1'b1;
                 pc_we    <= 1'b1;
              end
	   end // else: !if(op == `RTYPE)
	end // case: `EX


        `WB : begin
           if(op == `RTYPE) begin
              if(func == `LD) rf_we <= 1'b1;
           end
	end // case: `WB


        default : begin
           alu_func     <= 4'b0000;
           ir_we        <= 1'b0;
           pc_we        <= 1'b0;
           rf_we        <= 1'b0;
           reg1_we      <= 1'b0;
           reg2_we      <= 1'b0;
           dSel         <= 3'b000;
           aluSrc1      <= 2'b00;
           doutSel      <= 1'b0;
           addrSel      <= 1'b0;
           aluSrc2      <= 2'b00;
           ir_extendSel <= 2'b00;
           we           <= 1'b0;
           jal_op       <= 1'b0;
           iar_we       <= 1'b0;
           iarSel       <= 1'b0;
           ienable_in   <= 1'b0;
           ienable_we   <= 1'b0;
           pcSel        <= 1'b0;
	end // case: default

      endcase // case (state)
   end // always @ ( state or op or func or sign_reg1 or...

endmodule // controller



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
//                                                                        //
//------------------------------------------------------------------------//

module alu16
  (
   //-- input --//
   din1, 
   din2, 
   func, 
   //-- output --//
   dout
   );
   
   //-- input 
   input  [15:0] din1;
   input  [15:0] din2;
   input  [3:0]  func;

   //-- output
   output [15:0] dout;

   //-- reg
   reg    [15:0] dout;

   always @(din1 or din2 or func) begin
      case(func)
        `THA : dout <= din1;
        `THB : dout <= din2;
        `AND : dout <= din1 & din2;
        `OR  : dout <= din1 | din2;
        `XOR : dout <= din1 ^ din2;
        `NOT : dout <= ~din2;
        `ADD : dout <= din1 + din2;
        `SUB : dout <= din1 - din2;
        `SHL : dout <= {din2[14:0], 1'b0};
        `SHR : dout <= {1'b0, din2[15:1]};
        default : dout <= 16'b0;
      endcase
   end

endmodule // alu16



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
//                                                                        //
//------------------------------------------------------------------------//

module regfile
  (
   //-- input --//
   clk, 
   rst,
   addr1, 
   addr2, 
   din, 
   we,
   //-- output --//
   dout1, 
   dout2
   );
   
   //-- input
   input         clk;
   input         rst;
   input  [2:0]  addr1;
   input  [2:0]  addr2;
   input  [15:0] din;
   input         we;
   
   //-- output
   output [15:0] dout1;
   output [15:0] dout2;

   //-- reg
   reg    [15:0] regs[0:7];
   
   always @(posedge clk or negedge rst) begin
      if(rst == 1'b0) begin
         regs[3'b000] <= 16'b0;
         regs[3'b001] <= 16'b0;
         regs[3'b010] <= 16'b0;
         regs[3'b011] <= 16'b0;
         regs[3'b100] <= 16'b0;
         regs[3'b101] <= 16'b0;
         regs[3'b110] <= 16'b0;
         regs[3'b111] <= 16'b0;
      end else begin
         if(we == 1'b1) regs[addr1] <= din;
      end
   end
   
   assign  dout1 = regs[addr1];
   assign  dout2 = regs[addr2];
   
endmodule // regfile

