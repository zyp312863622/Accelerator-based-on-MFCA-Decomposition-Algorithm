`timescale 1 ns / 1 ps
module CNN_prefetch_controller
(
init_clk,
clk,
rst,
Bx,
By,

ksize,
ksize_pow,
stride,

image_addr,
image_size,
pad,
win_dim,

new_block,
//use_finish,
read_finish,
BD_end,
new_bd,

prefetch_length,


image_size_pow,

data_in,
data_in_address,

prefetch_write,
prefetch_select,
prefetch_enable,
prefetch_finish,

dma_req,

FIFO_amfull,

use_read_d1,

buffer0_state,
buffer1_state,
start_address,

dma_ready,

data_out_buffer0,
data_out_buffer1,

use_select

);
input init_clk;
input clk;
input rst;
input [15:0]Bx;
input [15:0]By;

input [3:0]ksize;
input [6:0]ksize_pow;

input [3:0] stride;

input [31:0]image_addr;
input [7:0]image_size;
input [1:0]pad;
input [15:0] win_dim;

input new_block;
//input use_finish;
input read_finish;
input BD_end;
input new_bd;

input [31:0] prefetch_length;

input [15:0]image_size_pow;

input [63:0]data_in;
input [31:0]data_in_address;

input prefetch_select;
input prefetch_enable;
input prefetch_finish;
input prefetch_write;

input dma_req;
input FIFO_amfull;


output [2:0] buffer0_state;
output [2:0] buffer1_state;
output [31:0]data_out_buffer0;
output [31:0]data_out_buffer1;


output dma_ready;
output use_read_d1;
output use_select;
output [31:0] start_address;





wire  [31:0] start_address;
wire [15:0]next_block_x;
wire [15:0]next_block_y;

wire new_block;
wire read_finish;
wire BD_end;
wire new_bd;

wire new_block_d0;
wire read_finish_d0;
wire BD_end_d0;
wire new_bd_d0;

wire read_finish_d1;
wire [2:0] buffer0_state;
wire [2:0] buffer1_state;
wire [31:0]data_out_buffer0;
wire [31:0]data_out_buffer1;

wire [63:0]data_in;

wire [31:0]data_out_address;
wire [31:0]data_in_address;



wire [31:0] start_address_input_buffer0;
wire wait_prefetch_enable_buffer0;
wire prefetch_enable_buffer0;
wire prefetch_finish_buffer0;
wire use_enable_buffer0;
wire use_finish_buffer0;

wire [31:0] start_address_input_buffer1;
wire wait_prefetch_enable_buffer1;
wire prefetch_enable_buffer1;
wire prefetch_finish_buffer1;
wire use_enable_buffer1;
wire use_finish_buffer1;


wire [2:0] current_buffer_state;
wire [2:0] next_buffer_state;

wire write0;
wire write1;

wire use_read;
wire prefetch_write;

wire req_ready;
wire dma_ready;

reg use_select_change;

reg wait_prefetch_enable_current;
reg wait_prefetch_enable_next;

reg use_select;
wire prefetch_select;

wire prefetch_enable;
wire prefetch_finish;

reg [31:0] start_address_input_current;
reg [31:0] start_address_input_next;



reg use_enable;
reg use_finish;
wire FIFO_amfull;

wire use_read_d0,use_read_d1;

wire [31:0] addr_current;

wire [31:0] block_addr_current;
wire [31:0] block_addr_next;

wire [99:0] read_addr_stage;
wire [31:0] addr_current_stage;
wire [31:0] addr_next_stage;

wire [31:0] block_addr_current_stage;
wire [31:0] block_addr_next_stage;

wire 			 req_valid_stage;
wire 			 req_valid0_stage;
wire 			 req_valid1_stage;
wire [3:0] bd_block_d_stage;

wire [99:0] stage_dout;
wire FIFO_stage_rd_en;
wire FIFO_stage_empty;

wire FIFO_stage_rd_en0;
wire FIFO_stage_rd_en1;

wire full;

wire [31:0] buffer0_start_address_output;
wire [31:0] buffer1_start_address_output;

assign next_block_x = Bx + ksize_pow;
assign next_block_y = By;

assign current_buffer_state = (use_select)?buffer1_state:buffer0_state;
assign next_buffer_state = (use_select)?buffer0_state:buffer1_state;

assign write0 = (prefetch_select)?'b0:prefetch_write;
assign write1 = (prefetch_select)?prefetch_write:'b0;

assign wait_prefetch_enable_buffer0 = (use_select)?wait_prefetch_enable_next:wait_prefetch_enable_current;
assign wait_prefetch_enable_buffer1 = (use_select)?wait_prefetch_enable_current:wait_prefetch_enable_next;

assign prefetch_enable_buffer0 = (prefetch_select)?'b0:prefetch_enable;
assign prefetch_enable_buffer1 = (prefetch_select)?prefetch_enable:'b0;

assign prefetch_finish_buffer0 = (prefetch_select)?'b0:prefetch_finish;
assign prefetch_finish_buffer1 = (prefetch_select)?prefetch_finish:'b0;

assign use_enable_buffer0 = (use_select)?'b0:use_enable;
assign use_enable_buffer1 = (use_select)?use_enable:'b0;

assign use_finish_buffer0 = (use_select)?'b0:use_finish;
assign use_finish_buffer1 = (use_select)?use_finish:'b0; 

//assign start_address_input_buffer0=(prefetch_select)?start_address_input_next:start_address_input_current;
//assign start_address_input_buffer1=(prefetch_select)?start_address_input_current:start_address_input_next;

assign start_address_input_buffer0=(use_select)?start_address_input_next:start_address_input_current;
assign start_address_input_buffer1=(use_select)?start_address_input_current:start_address_input_next;

assign req_ready= ~full;


assign data_out_address=FIFO_stage_rd_en?addr_current:32'b0;
assign start_address=(prefetch_select)?buffer1_start_address_output:buffer0_start_address_output;
assign req_valid_stage = req_valid0_stage&req_valid1_stage;
assign read_addr_stage = {addr_current_stage,block_addr_current_stage,block_addr_next_stage,bd_block_d_stage};
assign addr_current = (FIFO_stage_empty)?'b0:stage_dout[99:68];
assign block_addr_current = (FIFO_stage_empty)?'b0:stage_dout[67:36];
assign block_addr_next = (FIFO_stage_empty)?'b0:stage_dout[35:4];
assign {new_block_d0,read_finish_d0,BD_end_d0,new_bd_d0} = (FIFO_stage_empty)?'b0:stage_dout[3:0];


assign FIFO_stage_rd_en = (current_buffer_state==3'b100)&&(~FIFO_amfull);

addr_cvt cvt_current
(
.clk(clk),
.rst(rst),

.Bx(Bx),
.By(By),

.ksize(ksize),
.ksize_pow(ksize_pow),
.stride(stride),

.image_addr(image_addr),
.image_size(image_size),
.pad(pad),
.win_dim(win_dim),

.req_ready(req_ready),
.image_size_pow(image_size_pow),

.dma_req(dma_req),

.addr(addr_current_stage),
.addr_block(block_addr_current_stage),

.dma_ready(dma_ready),
.req_valid(req_valid0_stage)
);




addr_cvt cvt_next
(
.clk(clk),
.rst(rst),

.Bx(next_block_x),
.By(next_block_y),

.ksize(ksize),
.ksize_pow(ksize_pow),

.stride(stride),
.image_addr(image_addr),
.image_size(image_size),
.pad(pad),
.win_dim(win_dim),

.req_ready(req_ready),
.image_size_pow(image_size_pow),

.dma_req(dma_req),

.addr(addr_next_stage),
.addr_block(block_addr_next_stage),

.dma_ready(dma_ready),
.req_valid(req_valid1_stage)
);

delayer #(.depth(37),.width(4)) bd_block_d
(
.clk(clk),
.rst(rst),
.stall(~req_ready),
//.stall(1'b0),//?
.data_in({new_block,read_finish,BD_end,new_bd}),
//.data_out({new_block_d0,read_finish_d0,BD_end_d0,new_bd_d0})
.data_out(bd_block_d_stage)
);

fifo_generator_4 FIFO_stage
(		
.clk(clk),
.rst(rst),
.din(read_addr_stage),
.wr_en(req_valid_stage),
.rd_en(FIFO_stage_rd_en),
.dout(stage_dout),
//.full(~req_ready),
.full(full),
.empty(FIFO_stage_empty)
//.prog_full(prog_full)
);





///////////////////////////

delayer #(.depth(1),.width(1))use_read0
(
.clk(clk),
.rst(rst),
.stall(1'b0),
.data_in(FIFO_stage_rd_en),
.data_out(use_read_d0)
);

delayer #(.depth(2),.width(1))use_read1
(
.clk(clk),
.rst(rst),
.stall(1'b0),
.data_in(FIFO_stage_rd_en),
.data_out(use_read_d1)
);

delayer #(.depth(1),.width(1))read_finish_d
(
.clk(clk),
.rst(rst),
.stall(1'b0),
.data_in(read_finish_d0),
.data_out(read_finish_d1)
);

//assign prefetch_buffer0_read= (FIFO_stage_rd_en | use_read_d0) && ?
assign FIFO_stage_rd_en0=FIFO_stage_rd_en && (buffer0_state==3'b100)&&(~FIFO_amfull);
assign FIFO_stage_rd_en1=FIFO_stage_rd_en && (buffer1_state==3'b100)&&(~FIFO_amfull);
///////////////////////////


prefetch_buffer0 pf0
(
.init_clk(init_clk),
.clk(clk),
.rst(rst),

.data_in(data_in),
.data_in_address(data_in_address),
.write(write0),
//.read(use_read | use_read_d0),
//.read(FIFO_stage_rd_en | use_read_d0),
.read(FIFO_stage_rd_en0),
.data_out(data_out_buffer0),
.data_out_address(data_out_address),

.state(buffer0_state),

.wait_prefetch_enable(wait_prefetch_enable_buffer0),
.prefetch_enable(prefetch_enable_buffer0),
.prefetch_finish(prefetch_finish_buffer0),
.use_enable(use_enable_buffer0),
.use_finish(use_finish_buffer0),

.start_address_input(start_address_input_buffer0),
.length_input(prefetch_length),
.start_address_output(buffer0_start_address_output)

);

prefetch_buffer1 pf1
(
.clk(clk),
.rst(rst),

.data_in(data_in),
.data_in_address(data_in_address),
.write(write1),
//.read(use_read | use_read_d0),
//.read(FIFO_stage_rd_en | use_read_d0),
.read(FIFO_stage_rd_en1),
.data_out(data_out_buffer1),
.data_out_address(data_out_address),

.state(buffer1_state),

.wait_prefetch_enable(wait_prefetch_enable_buffer1),
.prefetch_enable(prefetch_enable_buffer1),
.prefetch_finish(prefetch_finish_buffer1),
.use_enable(use_enable_buffer1),
.use_finish(use_finish_buffer1),

.start_address_input(start_address_input_buffer1),
.length_input(prefetch_length),
.start_address_output(buffer1_start_address_output)

);



always @(posedge clk)
begin
	if(rst)
	begin
		use_select <= 'b0;
	end
	else
	begin
//		if(select_change)
if(use_select_change)
		 begin
		 	use_select <= ~use_select;
		 end
	end
end

always @ (*)
begin
	wait_prefetch_enable_current = 'b0;
	start_address_input_current = 'b0;
	wait_prefetch_enable_next = 'b0;
	start_address_input_next = 'b0;
	use_finish = 'b0;
	use_select_change = 'b0;
	use_enable='b0;
		case(current_buffer_state)
		  
			3'b000: //空闲
				begin
				 if(new_block_d0&&(next_buffer_state==3'b000))
				 begin
				 	wait_prefetch_enable_current = 1'b1;
				 	start_address_input_current = block_addr_current;		
				 	if(!BD_end_d0)
				 	begin			 	
				 		wait_prefetch_enable_next = 1'b1;
				 		start_address_input_next = block_addr_next;	
				 	end	  	
				 end
				end
			3'b001:  begin
			         end//等待预取
			3'b010:  begin
			         end//正在预取
			3'b011:  
			         //预取完毕
			  begin
				 if((new_block_d0&&(next_buffer_state==3'b000))|| (new_bd_d0 &&(next_buffer_state==3'b001)))
				 begin
				 	use_enable = 1'b1; 
				 	if(!BD_end_d0)
				 	begin			 	
				 		wait_prefetch_enable_next = 1'b1;
				 		start_address_input_next = block_addr_next;	
				 	end	 	
			 end
				end
			3'b100: //正在读取
			begin
			//	if(read_finish&&req_ready)
			//   if(read_finish_d0 && req_ready)
			  if(read_finish_d0)
			 // if(read_finish_d1)//////////?
			     begin
					   use_finish = 1'b1;
					   use_select_change = 1'b1;
					 end
			end
			default: //保留状态
			   // current_buffer_state='b0;
			     begin
			       end
			         
		endcase
end

endmodule