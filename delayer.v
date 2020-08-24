`timescale 1 ns / 1 ps
module delayer
(
clk,
rst,
stall,
data_in,
data_out
);

parameter depth = 16;
parameter width = 32;

input clk;
input rst;
input stall;
input [width-1:0]data_in;
output [width-1:0]data_out;

reg [width-1:0] stage [depth-1:0];

integer i;
always @ (posedge clk)
begin
if(rst)
begin
 	stage[0] <= 0;
	for(i=1; i<depth; i=i+1)
	begin
		stage[i]<=0;
	end 
end
else
if(stall)
begin
end
else
begin
	stage[0] <= data_in;
	for(i=1; i<depth; i=i+1)
	begin
		stage[i]<=stage[i-1];
	end
end
end

assign data_out=stage[depth-1];
endmodule