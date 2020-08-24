`timescale 1 ns / 1 ps
module addr_cvt
(
clk,
rst,

Bx,
By,

ksize,
ksize_pow,
stride,

image_addr,
image_size,
image_size_pow,

pad,
win_dim,

req_ready,


dma_req,

addr,

dma_ready,
req_valid,
addr_block
);

input clk;
input rst;

input [15:0]Bx;
input [15:0]By;

input [3:0]ksize;
input [6:0]ksize_pow;
input [3:0]stride;

input [31:0]image_addr;
input [7:0]image_size;
input [1:0]pad;
input [15:0] win_dim;

input [15:0]image_size_pow;

input dma_req;
input req_ready;


output [31:0]addr;
output [31:0]addr_block;



output dma_ready;
output req_valid;

wire dma_ready;

wire [15:0] p0_q;
wire [15:0] c_im;
wire [15:0] c_im_d0;
wire [15:0] offset_k_x;
wire [15:0] offset_k_y;
wire [15:0] offset_k_y_d0;

wire [15:0] w_x;
wire [15:0] w_y;
wire [15:0] w_x_d0;
wire [15:0] w_y_d0;

wire [31:0]addr0;

reg [15:0] image_x;
reg [15:0] image_y;

reg [31:0] addr;
reg [31:0] c_im_offset;
reg [31:0] pix_offset;
wire outrange;
wire outrange_d0;


assign addr0 = 32'hfff;
assign dma_ready = req_ready;

pipelined_divider p0
(
.clk(clk),
.rst(rst),
.stall(~req_ready),

.dividend(Bx),
.divisor({12'b0,ksize}),

.quotient(p0_q),
.reminder(offset_k_y)
);

pipelined_divider p1
(
.clk(clk),
.rst(rst),
.stall(~req_ready),
.dividend(p0_q),
.divisor({12'b0,ksize}),

.quotient(c_im),
.reminder(offset_k_x)
);

pipelined_divider p2
(
.clk(clk),
.rst(rst),
.stall(~req_ready),
.dividend(By),
.divisor(win_dim),

.quotient(w_x),
.reminder(w_y)
);

delayer #(.depth(1),.width(16))c_im_d
(
.clk(clk),
.rst(rst),
.stall(~req_ready),
.data_in(c_im),
.data_out(c_im_d0)
);

delayer #(.depth(17),.width(16))offset_k_y_d
(
.clk(clk),
.rst(rst),
.stall(~req_ready),
.data_in(offset_k_y),
.data_out(offset_k_y_d0)
);

delayer #(.depth(17),.width(16))w_x_d
(
.clk(clk),
.rst(rst),
.stall(~req_ready),
.data_in(w_x),
.data_out(w_x_d0)
);

delayer #(.depth(17),.width(16))w_y_d
(
.clk(clk),
.rst(rst),
.stall(~req_ready),
.data_in(w_y),
.data_out(w_y_d0)
);

delayer #(.depth(37),.width(1))req_d
(
.clk(clk),
.rst(rst),
.stall(~req_ready),
.data_in(dma_req),
.data_out(req_valid)
);

delayer #(.depth(1),.width(1))outrange_d
(
.clk(clk),
.rst(rst),
.stall(~req_ready),
.data_in(outrange),
.data_out(outrange_d0)
);

wire [31:0] c_im_addr_offset;
wire [31:0] pix_addr_offset;

reg [31:0] addr_block;
wire x_outrange;
wire y_outrange;

wire [15:0] block_x;
wire [15:0] block_y;

assign block_x = (x_outrange)?(image_x + pad):image_x;
assign block_y = (y_outrange)?(image_y + pad):image_y;

reg [31:0] block_pix_offset;
wire[31:0] block_addr_pix_offset;

assign  c_im_addr_offset = c_im_offset<<2;
assign  pix_addr_offset = pix_offset<<2;
assign  block_addr_pix_offset = block_pix_offset<<2;

assign outrange = x_outrange || y_outrange||(image_x>(image_size-1))||(image_y>(image_size-1));

assign x_outrange = (image_x[15]==1)?'b1:'b0;
assign y_outrange = (image_y[15]==1)?'b1:'b0;



always @ (posedge clk)
begin
if(rst)
begin
	addr <= 'b0;
	image_x <= 'b0;
	image_y <= 'b0;
  pix_offset <= 'b0;
  c_im_offset <= 'b0;
  block_pix_offset<= 'b0;
  addr_block <= 'b0;
end
if(~req_ready)
begin

end
else
begin
	image_x <= w_x_d0*stride + offset_k_x - pad;
	image_y <= w_y_d0*stride + offset_k_y_d0 - pad;
	
	pix_offset <= image_x*image_size + image_y;
	block_pix_offset <= block_x*image_size + block_y;
	
	
	c_im_offset <= c_im_d0*image_size_pow;
	addr <= outrange_d0?(addr0):(image_addr + c_im_addr_offset + pix_addr_offset);
	addr_block <= image_addr + c_im_addr_offset + block_addr_pix_offset;
end
end

endmodule

