`timescale 1ns / 1ps
`define BD_LENGTH 5
//////////////////////////////////////////////////////////////////////////////////
// Company: MASA
// Engineer: Qiao Yuran
// 
// Create Date: 2013/08/29 15:46:23
// Design Name: Wishbone bus readdma
// Module Name: readdma
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module readdma1(
init_clk,
clk,
reset,


rd_req_ack,
//rd_data,
//rd_data_en,
//hp_datain,
//hp_rvalid,
gp_wdata,
gp_wvalid,
gp_waddr,


//rd_req_addr,
//rd_req_en,
//rd_req_burst_length,
//rd_data_ready,

Pe_done,
dma_done,
//rready,
ready,
new_block,
read_finish,
Loc_X,
Loc_Y,
req_valid,
BD_end,
new_bd,

ksize,
ksize_pow,
stride,
image_size,
pad,
win_dim,
image_size_pow,
 image_addr,
prefetch_length,


data_out_buffer0,
data_out_buffer1,
use_select,
use_read,
rd_b,
empty_b,
dout_b ,
FIFO_amfull

    );
    input init_clk;
    input clk;
    input reset;
    
    input [31:0]data_out_buffer0;
    input [31:0]data_out_buffer1;
    input use_select;
    input use_read;
    input rd_b;

    
    
   input                rd_req_ack;
   //

   input [31:0] gp_wdata;
   input [31:0] gp_waddr;
   input gp_wvalid;
//   input rd_a,rd_b;
   //input stop;
   input  ready;
  // input [6:0] ksize_pow;
   input    Pe_done;
   input    dma_done;
   
   output new_block;
//   reg new;
 
   output read_finish;
   


//   output		 [31:0]				rd_req_addr;
//   output	 						rd_req_en;
//   output         [3:0]             rd_req_burst_length;
//   output	 						rd_data_ready;
 //  output      rready;
   
   output [15:0] Loc_X,Loc_Y;
   output  BD_end;
   output  req_valid;
   
    output  new_bd;
    
    output [3:0]ksize;
    output [6:0]ksize_pow;
    output [3:0] stride;
    output [7:0]image_size;
    output [1:0]pad;
    
    output [15:0] win_dim;
    output [15:0]image_size_pow;
    
    output [31:0] image_addr;
    output [31:0] prefetch_length; 
  
    output FIFO_amfull;
  //  output rready;
    
    output empty_b;
    output [31:0] dout_b;
   

////////////////////////// 
 
    
    wire   [63:0]     				    rd_data;
    wire            				    rd_data_en;

    wire            				    rd_req_ack;
    wire   [3:0]                       burst_length;
    
//    reg        [31:0]                 Fout_a,Fout_b;
    reg        [20:0]                          DMAreqcounter;
    reg        [20:0]                          DMArplcounter;
    reg        [31:0]                          currentsaddr;
    reg        [31:0]                          currentdaddr;
//    reg        [1:0]                               state; 
  
    reg      [63:0]                            wbtoaxififo[127:0];
    reg      [7:0]							    head;
    reg      [7:0]							   	tail;
      
    wire               empty;
    wire									     full;
    wire     [31:0]   req_addr;
    wire     [7:0]    length;
    
    
    
   reg [31:0] config_addr, NextBD_addr, Aaddr ,  Baddr,Stride_A ,Stride_B ,RStrideB,trans_length, dimen_N ,bd_endaddr,trans_A,trans_B;
   reg [7:0] BD_counter,BD_Num;

   
   reg [14:0] counter,counter0;//
   reg flag,flag0;
   reg [2:0] state0;
   reg [1:0]  state;
   reg BD_done,start_BD,end_BD;
   
   reg rvalid_rready_reg;
   reg [63:0] dch_fifo_in;
   reg flag_r;
   
   reg read_flag;
   
  // reg [15:0] Loc_X,Loc_Y,Pre_X;
  
/////////////////////////////////////////////////
    reg [3:0]ksize;
    reg [6:0]ksize_pow;
    reg [3:0] stride;
    reg [7:0]image_size;
    reg [1:0]pad;
    
    reg [15:0] win_dim;
    reg [15:0]image_size_pow;
    
    reg [31:0] image_addr;
    reg [31:0] prefetch_length; 
     
    wire [15:0] Loc_X,Loc_Y;
    reg [15:0] Pre_Y,Pre_Y0;
    reg [7:0] counter2,counter3,BD_Rcounter;
    reg [7:0] Num,K;
    
    reg [31:0] gp_wdata0;
    reg use_select_d0, use_select_d1;
    reg [7:0] Div;
  // reg req_valid;
  // reg BD_end;
   wire  BD_end;
   
   wire req_valid;
   wire stop;
   wire rvalid_rready;
   wire new_block;
   wire read_finish;
   wire final_d0;
   
   wire new_bd;
 //////////////////////////////
 wire [31:0]din;
 wire [31:0]dout;
// wire empty;
// wire full;
 wire prog_full;
 wire rd_en;
 wire rst;
 wire wr_en;  
wire full_b,empty_b;
 wire [31:0] dout_b;
//  ila_6 ila_6 (
//                // input wire clk
//         .clk(init_clk),
//               .probe0(ksize),
//               .probe1(ksize_pow),
//               .probe2(stride),
//               .probe3(image_size),
//               .probe4(pad),
//               .probe5(win_dim),
//               .probe6(image_size_pow),
//               .probe7(image_addr),
//               .probe8(prefetch_length),
//               .probe9(Loc_X),
//               .probe10(Loc_Y),
//               .probe11(Pre_Y),
//               .probe12(counter2),
//               .probe13(counter3),
//               .probe14(BD_Rcounter),
//               .probe15(Num),
//               .probe16(K),
//               .probe17(state[1:0]),
//               .probe18(state0[1:0]),
//               .probe19(new_block),
//               .probe20(read_finish),
//               .probe21(req_valid),
//               .probe22(new_bd),
//               .probe23(BD_end),
//               .probe24(ready),
//               .probe25(counter0),
//               .probe26(Pe_done),
//               .probe27(dma_done)  
//               );
    
    assign empty = (head == tail)?1:0;
    assign full =  (head == tail + 1)?1:0;
    
    assign burst_length = (DMAreqcounter> 16)?15:DMAreqcounter-1;
    assign  rd_data_ready = ~full;

   
      
    always @(posedge clk or posedge reset)
    if(reset)
        begin
          DMArplcounter <='b0;
          state <= 2'b0;
          tail <= 8'b0;
          head <= 8'b0;
          end_BD <= 1'b0;
          flag <= 1'b0;
          counter <= 'b0;
          BD_done <= 1'b1;
        end
    else begin
        case(state)
        2'b0:
          begin
            if(start_BD)
              begin
               BD_done <= 1'b0;
//               DMArplcounter <= `BD_LENGTH ;
              state<=state +1'b1;
              end
            else state <= state;
          end
        2'b1:
        begin
//           if(rd_data_ready && hp_rvalid)
//               begin                        
//                    wbtoaxififo[tail] <=hp_datain;
//                    tail <= tail + 1;
//                    DMArplcounter<= DMArplcounter-1'b1;
//                end  
//            if(DMArplcounter == 0) 
//               begin
               end_BD <= 1'b1;
               state <= 2'b10;
               tail <= 'b0;
               head <= 'b0;
         //      DMArplcounter <=  wbtoaxififo[2][63:32]-1'b1;
//               end  
           //   state <= 2'b10;
            end
        2'b10:
           begin 
                  end_BD <= 1'b0; 
                  state <= 2'b0;
                  BD_done <=1'b1;   
             end
            
          default: state<= 'b0;
      endcase
      end
    
    always @(posedge clk or posedge reset)
    if(reset)
        begin
            DMAreqcounter <=22'b0;
            currentsaddr <=32'b0;
            state0<=3'b0;
            config_addr <=32'b0;
            NextBD_addr <=32'b0;
            Aaddr <= 32'b0;
            Baddr <= 32'b0;
            Stride_A <= 32'b0;
            Stride_B  <=32'b0;
            RStrideB <=32'b0;
           trans_A <= 32'b0;
           trans_B <= 32'b0;
            dimen_N <= 32'b0;
            bd_endaddr<=32'h0;
 //           flag <= 1'b0;
            flag0 <=1'b0;
 //           counter <= 10'b0;
            counter0 <=15'b0;
            BD_counter <= 8'b0;
            start_BD <= 1'b0;
            
            BD_Rcounter <= 8'b0;
            Num <= 8'b0;
            counter2 <=8'b0;
            counter3 <=8'b0;
            K <=8'b0;
            Pre_Y<= 16'b0;
            Pre_Y0<=16'b0;
            BD_Num<=8'b0;
            ksize<='b0;
            ksize_pow<='b0;
            stride<='b0;
            image_size<='b0;
            pad<='b0;
            win_dim<='b0;
            image_size_pow<='b0;
            image_addr<='b0;
            prefetch_length<='b0; 
            Div<='b0;
        end
     else
        begin
            case(state0)// idle
            3'b0:  
            begin
                 K <=8'b0; 
                if(gp_wdata[31:28]==4'b0100)//4
                  begin
                     stride<=gp_wdata[3:0];
                     ksize <=gp_wdata[7:4];
                     ksize_pow<=gp_wdata[15:8];
                     image_size<=gp_wdata[23:16];
                     pad<=gp_wdata[25:24];
                  end
                else if(gp_wdata[31:28]==4'b0101)//5
                    begin
                      image_size_pow<=gp_wdata[15:0];
                      win_dim<=gp_wdata[27:16];  //12 bit 
                    end   
                else if(gp_wdata0[31:28]==4'b0101 && gp_wdata[31:28] != gp_wdata0[31:28])//
                      image_addr<=gp_wdata;
                
                else if(gp_wdata[31:28]==4'b0110)//6
                       prefetch_length<=gp_wdata[27:0];
                  
                else if(gp_wdata[31:28]==4'b0111)//7
                        dimen_N<=gp_wdata[27:0];
                        
                 else if(gp_wdata[31:28]==4'b1011)//b   
                        Div <= gp_wdata[7:0];   
                        
                else if(gp_wdata0[31:28]==4'b1000 && gp_wdata[31:28] != gp_wdata0[31:28])
                     config_addr<= {2'b0,gp_wdata[29:0]};                      
                else if(gp_wdata[31:28]==4'b1101)//d
                      RStrideB <= gp_wdata[27:0];
                else if(gp_wdata[31:28]==4'b1110)//e
                      Num <= gp_wdata[27:0];
                else if(gp_wdata[31:28]==4'b1111)//f
                     begin
                      Pre_Y <= gp_wdata[27:0];
                      Pre_Y0<= gp_wdata[27:0];
                      end
                else if(gp_wdata[31:28]==4'b1001)//9
                 begin
                      BD_Num <= gp_wdata[7:0]-1'b1;
                      BD_counter <= gp_wdata[7:0]-1'b1; 
                      state0 <= state0 +1;
                   end        
             
               else    state0<=state0;   
             end 
           3'b001:
              begin 
//                    currentsaddr  <= config_addr;
//                  DMAreqcounter <= `BD_LENGTH ;

                    if(dma_done)//??????????
                    begin
                    state0 <=3'b10;
                    start_BD <= 1'b1;
                    end
              end
           3'b010:     // get bd
               begin       
                    start_BD <= 1'b0;
                    state0<=3'b011;          
                end
                3'b011:
                     begin
                      if(ready)
                       begin
                    //   if((((counter2 == (RStrideB-1'b1)) && (RStrideB<128)) || ((counter2 == 127) && (RStrideB>=128)))) 
                         if((((counter2 == (RStrideB-1'b1)) && (RStrideB<Div)) || ((counter2 == Div-1) && (RStrideB>=Div)))) 
                             begin
                                counter2 <= 8'b0;
                              //  counter0 <= counter0 + 1'b1;
                                
                                if(counter3 == ksize_pow-1)
                                   counter3 <=8'b0;
                                else 
                                   counter3 <= counter3 + 1'b1; 

                              if(counter0==dimen_N -1)// last time
                                    begin
                                      counter0 <= 15'b0;
                                      if(BD_done)
                                          begin
                                          if(BD_counter==8'b0) 
                                            begin
                                               state0 <= 3'b0;
                                               Pre_Y <= 'b0; 
                                            //   K <=8'b0; 
                                            end
                                          else 
                                            begin  
                                                BD_counter <= BD_counter-1'b1;
                                                config_addr<=NextBD_addr;
                                                state0 <= 3'b1;
                                            end  
                                      
                                            if(BD_Rcounter==Num-1)
                                              begin
                                                BD_Rcounter <= 8'b0;
                                            //    K <=K + 1'b1;
                                                Pre_Y <= Pre_Y0; 
                                              end
                                           else 
                                               begin
                                               BD_Rcounter <= BD_Rcounter + 1'b1;
                                            //   Pre_Y <= Pre_Y + 128; 
                                                Pre_Y <= Pre_Y + Div;
                                               end
                                            
                                     
                                    end
                                   end 
                          else
                                 counter0 <= counter0 + 1'b1;
                           end
                         else
                              counter2 <=counter2 + 1'b1;
                       end
                     else
                         begin
                           counter0<=counter0;
                           counter2<=counter2;
                           counter3<=counter3;
                        end
            end          
                     
                   default: state0 <= 'b0;
           endcase
        end   

always@(posedge clk or posedge reset) 
 if(reset)
   read_flag <=1'b0;
else
 begin
   if(read_finish)
      read_flag <=1'b1;
   else
     if(final_d0)
       read_flag <=1'b0;
   else 
       read_flag <=read_flag;
 end

                    
   always @ (posedge clk or posedge reset)
         if(reset)
            gp_wdata0 <= 'b0;
          else 
            gp_wdata0 <= gp_wdata; 

always@(posedge clk or posedge reset)
 if(reset)
  begin
    use_select_d0<='b0;
    use_select_d1<='b0;
  end
else
  begin
   use_select_d0<=use_select;
   use_select_d1<=use_select_d0;
 end




fifo_generator_3 FIFO_B
(.clk(clk),
    .rst(reset),
    .din(din),
   .wr_en(wr_en),
    .rd_en(rd_en),
    .dout(dout_b),
    .full(full_b),
    .empty(empty_b),
    .prog_full(prog_full)
    );
assign wr_en = use_read;
assign rd_en = rd_b;
assign din = use_read? (use_select_d1?data_out_buffer1:data_out_buffer0):32'b0;
assign FIFO_amfull=prog_full;   

//assign Loc_Y = Pre_Y + (BD_Num-BD_counter-K*Num) * 56 + counter2; 
assign Loc_Y  = Pre_Y + counter2;
assign Loc_X = counter0;  
assign new_block = ( counter3==8'b0 && counter2==8'b0 && req_valid);
//assign read_finish=( counter3==ksize_pow-1 && (((counter2 == (RStrideB-1'b1)) && (RStrideB<128)) || ((counter2 == 127) && (RStrideB>=128))) && req_valid );
assign read_finish=( counter3==ksize_pow-1 && (((counter2 == (RStrideB-1'b1)) && (RStrideB<Div)) || ((counter2 == Div-1) && (RStrideB>=Div))) && req_valid );
assign req_valid=(state0==3'b011);
assign new_bd = ( counter0==8'b0 && counter2==8'b0 && req_valid);
assign BD_end=( counter3==8'b0 && counter2==8'b0 && req_valid && counter0==dimen_N-ksize_pow);
    
endmodule
