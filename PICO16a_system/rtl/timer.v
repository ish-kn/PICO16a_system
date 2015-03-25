//////////////////////////////////////////////////////
//  timer interface for PICO16a bus system
//////////////////////////////////////////////////////

// Internal status
`define IDLE      2'b00
`define WORK      2'b10
`define LOAD      2'b11
`define INTR      2'b01

module timer
  (
   //-- input --//
   from_cpu,
   cpu_clk,
   rst,
   cs,
   we,
   adrs,

   //-- output --//
   int_req,
   to_cpu
  );

   //-- input
   input                   cpu_clk;
   input                   rst;
   input                   we;
   input                   cs;
   input [2:0]             adrs;
   input [15:0]            from_cpu;
   //-- output
   output [15:0]           to_cpu;
   output                  int_req;

   //-- wires
   wire                    zero_detect;
   wire [15:0]             out_control;
   wire [15:0]             out_status;
   // internal registers
   reg [31:0]              init_value;
   reg                     run;
   reg [31:0]              counter;
   reg [31:0]              count_in;
   reg [1:0]               status;
   reg                     init_load;
   reg                     init_we;
   reg                     read;
   reg                     read_finish;
   reg [31:0]              data;
   reg [15:0] 		   to_cpu; 			   

   reg [1:0]               count_sel;
   reg                     interrupt;
   reg                     int_ack;

   // [control unit]
   //     * state transition
   always @(posedge cpu_clk or negedge rst) begin
      if(!rst) status <= `IDLE;
      else begin
        case(status)
		  `IDLE: if(run & !init_load)			status <= `WORK;
               else if(init_load)     		status <= `LOAD;
               else                     	status <= `IDLE;
	  // Complete following state transitions(WORK, LOAD, INTR).
		  `WORK: if (!run & !zero_detect)	status <= `IDLE;
					else if (zero_detect)		status <= `INTR;
					else								status <= `WORK;
		  `LOAD: if (!init_load)				status <= `IDLE;
					else 								status <= `LOAD;
		  `INTR: if (int_ack)					status <= `IDLE;
					else								status <= `INTR;
        default: status <= `IDLE;
        endcase
      end
   end

   // [control unit]
   //     * output generation
   always @(status or rst) begin
      if(!rst) begin
         count_sel <= 2'b0;
         interrupt <= 1'b0;
      end
      else begin
         case(status)
         `IDLE: begin
                   count_sel <= 2'b00;
                   interrupt <= 1'b0;
                end
	   // Complete following outputs of each state(WORK, LOAD, INTR).
         `WORK: begin
						count_sel <= 2'b01;
						interrupt <= 1'b0;
					 end
			`LOAD: begin
						count_sel <= 2'b10;
						interrupt <= 1'b0;
					 end
			`INTR: begin
						count_sel <= 2'b10;
						interrupt <= 1'b1;
					 end
         default: begin
                     count_sel <= 2'b00;
                     interrupt <= 1'b0;
                  end
         endcase
      end
   end

   // initial value of counter
   always @(posedge cpu_clk or negedge rst) begin
      if(!rst) init_value <= 32'b0;
      else begin
         if((adrs[2:1] == 2'b00) & cs & we & init_we) begin
            case(adrs[0])
		    1'b0:    init_value <= {from_cpu,          init_value[15:0]};
		    1'b1:    init_value <= {init_value[31:16], from_cpu};
		    default: init_value <= 32'b0;
		    endcase
         end
      end
   end

   // multiplexor for counter's input
   always @(counter or
            init_value or
            count_sel) begin
      case(count_sel)
      2'b00:   count_in <= counter;
      2'b01:   count_in <= counter - 32'h00000001;
      2'b10:   count_in <= init_value;
      default: count_in <= 32'b0;
      endcase
   end

   // counter
   always @(posedge cpu_clk or negedge rst) begin
      if(!rst) counter <= 32'b0;
      else begin
         counter <= count_in;
      end
   end

   // zero detect
   assign zero_detect = (counter == 32'h00000000);

   // control registers [input side]
   always @(posedge cpu_clk or negedge rst) begin
      if(!rst) begin
         read      <= 1'b0;
         init_load <= 1'b0;
         init_we   <= 1'b0;
         run       <= 1'b0;
      end
      else begin
         if(cs & adrs == 3'b010 & we) begin
            read      <= from_cpu[3];
            init_load <= from_cpu[2];
            init_we   <= from_cpu[1];
            run       <= from_cpu[0];
         end
      end
   end

   always @(posedge cpu_clk or negedge rst) begin
      if(!rst) int_ack <= 1'b0;
      else
         if((cs & adrs == 3'b100 & we & !from_cpu[0])) int_ack <= 1'b1;
		 else int_ack <= 1'b0;
   end
   
   // register for "finish reading"
   always @(posedge cpu_clk or negedge rst) begin
      if(!rst) read_finish <= 1'b0;
      else read_finish <= read;
   end

   // data regsiter
   always @(posedge cpu_clk or negedge rst) begin
      if(!rst)      data <= 32'b0;
      else if(read & !read_finish) data <= counter;
   end

   assign out_control = {8'b0, interrupt, 3'b0, read,        init_load, init_we, run};
   assign out_status  = {8'b0, interrupt, 3'b0, read_finish, init_load, init_we, run};

   always @(posedge cpu_clk or negedge rst) begin
      if(!rst) to_cpu <= 16'b0;
      else begin
         case(adrs)
         3'b000:  to_cpu <= data[31:16];
         3'b001:  to_cpu <= data[15: 0];
         3'b010:  to_cpu <= out_control;
         3'b011:  to_cpu <= out_status;
         3'b100:  to_cpu <= {15'b0, interrupt};
         default: to_cpu <= 16'b0;
         endcase
      end
   end

   // output "int_req"
   assign int_req = interrupt;

endmodule
