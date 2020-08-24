`timescale 1 ns / 1 ps
module prefetcher
(
init_clk,
clk,
rst,

hp_datain,
hp_rvalid,

start_address,
prefetch_length,

buffer0_state,
buffer1_state,

//data_in,
//use_read,

prefetch_select,
prefetch_enable,
prefetch_finish,
prefetch_write,

data_out,
data_out_address,

rd_req_ack,

rd_req_addr,
rd_req_en,
rd_req_burst_length,
rd_data_ready,

//use_read,
//FIFO_amfull,
////read_finish
//data_out_buffer0,
//data_out_buffer1,

use_select,

rready
//rd_b,
//empty_b,
//dout_b

);

input init_clk;
input clk,rst;
input [31:0] start_address;
input [31:0] prefetch_length;

input [2:0] buffer0_state;
input [2:0] buffer1_state;

input rd_req_ack;
input [63:0] hp_datain;
input hp_rvalid;

////input [31:0] data_in;
//input  use_read;


//input [31:0]data_out_buffer0;
//input [31:0]data_out_buffer1;

input use_select;

//input rd_b;

output prefetch_select;
output prefetch_enable;
output prefetch_finish;
output prefetch_write;

output [63:0] data_out;
output [31:0] data_out_address;

 output		 [31:0]				rd_req_addr;
 output	 						rd_req_en;
 output   [3:0]                 rd_req_burst_length;
 output	 						rd_data_ready;
 
// output FIFO_amfull;
 output rready;
 
// output empty_b;
// output [31:0] dout_b;
// output read_finish;
 
 wire	[31:0]	   rd_req_addr;
 wire	 		   rd_req_en;
 wire   [3:0]     rd_req_burst_length;
 wire	 		   rd_data_ready;
 wire   [3:0]     burst_length;
 
//  wire   FIFO_amfull;
//  wire [31:0]din;
//  wire [31:0]dout;
//  wire empty;
//  wire full;
//  wire prog_full;
//  wire rd_en;
//  wire rst;
//  wire wr_en;
 
 wire [2:0] buffer0_state;
 wire  [2:0] buffer1_state;
 wire      rvalid_rready;
 wire      rready;
 //wire      read_finish;
 
// wire full_b,empty_b;
// wire [31:0] dout_b;
 

 
 reg [21:0] DMAreqcounter;
 reg [31:0] currentsaddr;
 
 reg prefetch_select;
 //reg prefetch_en;
 wire prefetch_enable;
 reg prefetch_finish;
 reg prefetch_write;
 
 reg [1:0] state,state0;
 reg [21:0] DMArplcounter;
 reg [63:0] data_out;
 reg [31:0] data_out_address;
 reg [31:0] addr;
 
// reg use_select_d0, use_select_d1;
  
always@(posedge clk or posedge rst)
 if(rst)
  begin
    state <=2'b0;
    prefetch_select<=1'b0;
    currentsaddr<=32'b0;
    DMAreqcounter<=21'b0;
  end
else
  begin
    case(state)
      2'b0:
       begin
          if(buffer0_state==3'b1 || buffer1_state==3'b1)
            begin
               state<=2'b1;
             //  prefetch_en<=1'b1;//prefetching
               if(buffer0_state==3'b1 && buffer1_state!=3'b1)
                  prefetch_select<=1'b0;
               else
                 if(buffer0_state!=3'b1 && buffer1_state==3'b1)
                  prefetch_select<=1'b1;
               else
                 begin
                   //prefetch_select<=1'b0;
                   if(~use_select)
                        prefetch_select<=1'b0;
                   else
                        prefetch_select<=1'b1;
                 end
            end
          else
             state<=state;
       end
      2'b01:
        begin
           currentsaddr<=start_address;
           DMAreqcounter<=prefetch_length;
           state <=2'b10;
        //   DMArplcounter<=prefetch_length;   
        end
      2'b10:
      begin
      if(rd_req_ack&&rd_req_en)//indecate last request is successful
        begin
           currentsaddr <= currentsaddr + ((burst_length + 1)<<3);
                                       //DMAreqcounster <= DMAreqcounter - burst_length - 1;
           DMAreqcounter <= DMAreqcounter - burst_length - 1;//if DMAreqconter.==1,means last time                                
                                                               
       end
      else if(~rd_req_ack && rd_req_en)
         begin
           currentsaddr<= currentsaddr;
           DMAreqcounter <= DMAreqcounter;//keep
         end 
      else  if(DMAreqcounter==0)
        begin
           if(prefetch_finish==1'b1)
             state<=2'b0;
           else
             state<=state;
         end 
         
      end
  default: state <=state;
  endcase
end

always@(posedge clk or posedge rst)
 if(rst)
  begin
  //  prefetch_en<=1'b0;
    prefetch_write<=1'b0;
    prefetch_finish<=1'b1;
    DMArplcounter<='b0;
    data_out<=64'b0;
    data_out_address<='b0;
    addr<='b0;
    state0<=2'b0;
  end 
else
  begin
    case(state0)
      2'b0:
       begin
     //    prefetch_en<=1'b0;//delay...
         prefetch_write<=1'b0;
         prefetch_finish<=1'b0;
         addr <='b0;
         if(state==2'b01)
           begin
            DMArplcounter<=prefetch_length-1;
         //   DMArplcounter<=8;
            state0 <=2'b01;
          end
       end
      2'b01:
        begin
          //if(rd_data_ready && rvalid_rready)
          if(rvalid_rready)
            begin
               prefetch_write<=1'b1;
               data_out_address<=addr;
               data_out <= hp_datain;
               addr <=addr + 2;
             if(DMArplcounter==0)
               begin
                prefetch_finish<=1'b1;//
                state0<=2'b0;
                addr<='b0;
               end
            else
                DMArplcounter<= DMArplcounter-1;
          end
        else
            begin
               prefetch_write<=1'b0;
            end
       end

      
  default: state0 <=2'b0;
  endcase
end



//always@(posedge clk or posedge rst)
// if(rst)
//  begin
//    use_select_d0<='b0;
//     use_select_d1<='b0;
//  end
//else
//  begin
//   use_select_d0<=use_select;
//   use_select_d1<=use_select_d0;
// end

//fifo_generator_3 FIFO_B
//(.clk(clk),
//    .rst(rst),
//    .din(din),
//   .wr_en(wr_en),
//    .rd_en(rd_en),
//    .dout(dout_b),
//    .full(full_b),
//    .empty(empty_b),
//    .prog_full(prog_full)
//    );
 
 
//    ila_3 ila_3 (
//              // input wire clk
//       .clk(init_clk),
//             .probe0(prefetch_enable),
//             .probe1(prefetch_select),
//             .probe2(prefetch_write),
//             .probe3(prefetch_finish),
//             .probe4(state),
//             .probe5(state0),
//             .probe6(currentsaddr),
//             .probe7(DMAreqcounter),
//             .probe8(rd_req_ack),
//             .probe9(rd_req_en),
//             .probe10(DMArplcounter),
//             .probe11(rvalid_rready),
//             .probe12(rready),
//             .probe13(burst_length),
//             .probe14(hp_rvalid),
//             .probe15(hp_datain),
//             .probe16(wr_en),
//             .probe17(din),
//             .probe18(prog_full),
//             .probe19(data_out_address),
//             .probe20(buffer0_state),
//             .probe21(buffer1_state),
//             .probe22(start_address),
//             .probe23(use_select_d1),
//             .probe24(use_read)
//    ); 
assign  burst_length = (DMAreqcounter> 16)?15:DMAreqcounter-1;
assign  rd_req_en = DMAreqcounter ? 1:0;
assign  rd_req_addr = currentsaddr;
assign  rd_req_burst_length = burst_length;
assign  rvalid_rready = hp_rvalid & rready;
assign  rready=((buffer0_state==3'b010 || buffer0_state==3'b001 ) && ~prefetch_select) || ((buffer1_state==3'b010 || buffer1_state==3'b001 ) &&  prefetch_select)?1'b1:1'b0;//prefetching

assign prefetch_enable=hp_rvalid && (DMArplcounter==prefetch_length-1);//the first cycle

//assign wr_en = use_read;
//assign rd_en = rd_b;
////assign rd_en = ~empty_b;
//assign din = use_read? (use_select_d1?data_out_buffer1:data_out_buffer0):32'b0;
//assign FIFO_amfull=prog_full;

//assign read_finish = ~prog_full && use_read;

endmodule