`timescale 1ps/1ps
module addr_cvt_sim;

reg clk;
reg rst;

reg [15:0]Bx;
reg [15:0]By;

reg [3:0]ksize;

reg [31:0]image_addr;
reg [7:0]image_size;
reg [1:0]pad;
reg [15:0]win_dim;

reg req_ready;
reg [31:0]addr0;
reg [15:0]image_size_pow;

reg dma_req;

wire [31:0]addr;

wire dma_ready;
wire req_valid;
addr_cvt ac0
(
.clk(clk),
.rst(rst),

.Bx(Bx),
.By(By),

.ksize(ksize),

.image_addr(image_addr),
.image_size(image_size),
.pad(pad),
.win_dim(win_dim),

.req_ready(req_ready),
.addr0(addr0),
.image_size_pow(image_size_pow),

.dma_req(dma_req),

.addr(addr),

.dma_ready(dma_ready),
.req_valid(req_valid)
);

initial
begin
clk = 0;
rst = 1;

Bx = 0;
By = 0;

ksize = 5;

image_addr = 0;
image_size = 27;
pad = 2;
win_dim = 27;

req_ready = 0;
addr0 = 1024;
image_size_pow = 729;

dma_req = 0;

#100
rst = 0;

Bx = 2399;
By = 728;

req_ready = 1;
dma_req = 1;

#100

Bx = 0;
By = 0;

req_ready = 1;
dma_req = 1;

#100

Bx = 0;
By = 0;

req_ready = 0;
dma_req = 1;

#100

Bx = 0;
By = 0;

req_ready = 0;
dma_req = 1;
#100

Bx = 0;
By = 0;

req_ready = 1;
dma_req = 1;

#100

Bx = 0;
By = 0;

req_ready = 1;
dma_req = 0;

# 50000000

$stop;

end

always #50 clk = ~clk;




endmodule