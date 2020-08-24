`timescale 1 ns / 1 ps
module pipelined_divider
(
input clk,
input rst,
input stall,

input [15:0]dividend,
input [15:0]divisor,

output [15:0]quotient,
output [15:0]reminder
);

reg[31:0]temp[16:0];
wire[31:0]diff[16:0];
reg[16:0]s[16:0];

genvar j;
generate
for(j=0; j<=15; j=j+1)
begin:diffs
  assign diff[j] = temp[j] + {s[j],15'b0};
end
endgenerate

integer i;
always @ (posedge clk)
begin
if(rst)
begin
	for(i=0; i<=16; i=i+1)
	begin
		temp[i]<='b0;
		s[i]<='b0;
	end 
end
if(stall)
begin
  
end
else
begin
	temp[0] <= {16'b0,dividend};
	s[0] <= {1'b1,~divisor + 1'b1};
	for(i=1; i<=16; i=i+1)
	begin
		if(diff[i-1][31]) temp[i] <= {temp[i-1][30:0],1'b0};
		else temp[i] <= {diff[i-1][30:0],1'b1};
		s[i]<=s[i-1];
	end
end
end

assign quotient = temp[16][15:0];
assign reminder = temp[16][31:16];
endmodule