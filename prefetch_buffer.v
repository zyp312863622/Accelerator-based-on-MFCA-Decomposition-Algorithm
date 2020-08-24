`timescale 1 ns / 1 ps
module prefetch_buffer0
(
init_clk,
clk,
rst,

data_in,
data_in_address,
write,
read,

data_out,
data_out_address,

state,

wait_prefetch_enable,
prefetch_enable,
prefetch_finish,
use_enable,
use_finish,

start_address_input,
length_input,

start_address_output

);
input init_clk;
input clk;
input rst;

input [63:0] data_in;
input [31:0] data_in_address;
input write;

output [31:0] data_out;

output [31:0] start_address_output;

input [31:0] data_out_address;
input read;

output state;

input wait_prefetch_enable;
input prefetch_enable;
input prefetch_finish;
input use_enable;
input use_finish;

input [31:0] start_address_input;
input [31:0] length_input;

reg [2:0] state;

reg [31:0] start_address;
reg [31:0] length;

wire ena,wea;

wire [31:0] start_address_output;

wire buffer_read;
wire buffer_write;
wire use_read_d0,use_read_d1;

//wire [31:0] buffer_address;
wire [11:0] buffer_address;
wire [11:0] buffer_address0;

always@(posedge clk)
begin
if(rst)
	begin
	state = 3'b000; //back to idle
	end	
else
begin
	case(state)
	3'b000: //空闲
	begin
		if(wait_prefetch_enable)
		begin
			start_address <=  start_address_input;
			length <= length_input;
			state<= 3'b001;
		end
	end
	
	3'b001: //等待预取
	begin
		if(prefetch_enable)
		begin
			state<= 3'b010;
		end	
	end
	
	3'b010: //正在预取
	begin
		if(prefetch_finish)
		begin
			state<= 3'b011;
		end		
	end
	
	3'b011: //预取完毕
	begin
		if(use_enable)
		begin
			state<= 3'b100;
		end		
	end
	3'b100: //正在读取
	begin
		if(use_finish)
		begin
			state<= 3'b000;
		end	
	end
	default: //保留状态
	begin
		state<= 3'b000;
	end
	endcase
end
	
end


assign buffer_address =(state == 3'b100 && read)?(((data_out_address-start_address)>>2 )+start_address[2]):(state == 3'b010 && write)?data_in_address[11:0]:12'b0;

assign buffer_address0=(state == 3'b010 && write)?data_in_address[11:0]:((data_out_address[11:0]!=12'hfff)? buffer_address:12'hfff);//write first
assign  buffer_read =  read || use_read_d0;
assign  buffer_write = (state == 3'b010)?(write):'b0;
 
 assign ena = buffer_read | buffer_write; 
 assign wea = buffer_write;
 
 assign start_address_output=start_address;

delayer #(.depth(1),.width(1))use_read_0
(
.clk(clk),
.rst(rst),
.stall(1'b0),
.data_in(read),
.data_out(use_read_d0)
);

delayer #(.depth(2),.width(1))use_read_1
(
.clk(clk),
.rst(rst),
.stall(1'b0),
.data_in(read),
.data_out(use_read_d1)
);

blk_mem_gen_2 buffer
(
.clka(clk),
.rsta(rst),
.ena(ena),
.wea(wea),
.addra(buffer_address0),
.dina(data_in),
.douta(data_out)
);

//ila_7 ila_7
//    (.clk(init_clk),
//    .probe0(ena),
//    .probe1(wea),
//    .probe2(buffer_address0),
//    .probe3(data_in),
//    .probe4(data_out),
//    .probe5(state),
//    .probe6(data_out_address),
//    .probe7(start_address),
//    .probe8(buffer_write),
//    .probe9(buffer_read),
//    .probe10(use_read_d1)
//);


endmodule

module prefetch_buffer1
(
clk,
rst,

data_in,
data_in_address,
write,
read,

data_out,
data_out_address,

state,

wait_prefetch_enable,
prefetch_enable,
prefetch_finish,
use_enable,
use_finish,

start_address_input,
length_input,

start_address_output

);

input clk;
input rst;

input [63:0] data_in;
input [31:0] data_in_address;
input write;

output [31:0] data_out;

output [31:0] start_address_output;

input [31:0] data_out_address;
input read;

output state;

input wait_prefetch_enable;
input prefetch_enable;
input prefetch_finish;
input use_enable;
input use_finish;

input [31:0] start_address_input;
input [31:0] length_input;

reg [2:0] state;

reg [31:0] start_address;
reg [31:0] length;

wire ena,wea;

wire [31:0] start_address_output;

wire buffer_read;
wire buffer_write;
wire use_read_d0,use_read_d1;

//wire [31:0] buffer_address;
wire [11:0] buffer_address;
wire [11:0] buffer_address0;

always@(posedge clk)
begin
if(rst)
	begin
	state = 3'b000; //back to idle
	end	
else
begin
	case(state)
	3'b000: //空闲
	begin
		if(wait_prefetch_enable)
		begin
			start_address <=  start_address_input;
			length <= length_input;
			state<= 3'b001;
		end
	end
	
	3'b001: //等待预取
	begin
		if(prefetch_enable)
		begin
			state<= 3'b010;
		end	
	end
	
	3'b010: //正在预取
	begin
		if(prefetch_finish)
		begin
			state<= 3'b011;
		end		
	end
	
	3'b011: //预取完毕
	begin
		if(use_enable)
		begin
			state<= 3'b100;
		end		
	end
	3'b100: //正在读取
	begin
		if(use_finish)
		begin
			state<= 3'b000;
		end	
	end
	default: //保留状态
	begin
		state<= 3'b000;
	end
	endcase
end
	
end


assign buffer_address =(state == 3'b100 && read)?(((data_out_address-start_address)>>2 )+start_address[2]):(state == 3'b010 && write)?data_in_address[11:0]:12'b0;

assign buffer_address0=(state == 3'b010 && write)?data_in_address[11:0]:((data_out_address[11:0]!=12'hfff)? buffer_address:12'hfff);//write first
assign  buffer_read =  read || use_read_d0;
assign  buffer_write = (state == 3'b010)?(write):'b0;
 
 assign ena = buffer_read | buffer_write; 
 assign wea = buffer_write;
 
 assign start_address_output=start_address;

delayer #(.depth(1),.width(1))use_read_0
(
.clk(clk),
.rst(rst),
.stall(1'b0),
.data_in(read),
.data_out(use_read_d0)
);

delayer #(.depth(2),.width(1))use_read_1
(
.clk(clk),
.rst(rst),
.stall(1'b0),
.data_in(read),
.data_out(use_read_d1)
);

blk_mem_gen_2 buffer
(
.clka(clk),
.rsta(rst),
.ena(ena),
.wea(wea),
.addra(buffer_address0),
.dina(data_in),
.douta(data_out)
);

endmodule