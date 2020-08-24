`timescale 1ps/1ps
module pipelined_divider_sim;

reg clk;
reg [15:0]dividend;
reg [15:0]divisor;

wire [15:0]quotient;
wire [15:0]reminder;

pipelined_divider dv0
(
.clk(clk),
.dividend(dividend),
.divisor(divisor),
.quotient(quotient),
.reminder(reminder)
);

initial
begin
clk = 'b0;
dividend = 'h3e9;
divisor = 'hfa;
#100
dividend = 'h3ea;
divisor = 'hfa;
#100
dividend = 'h3eb;
divisor = 'hfa;
#100
dividend = 'h3ec;
divisor = 'hfa;
#100
dividend = 'h3ed;
divisor = 'hfa;

# 50000000

$stop;

end

always #50 clk = ~clk;




endmodule