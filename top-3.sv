module top;

bit CLK = '0;
bit MNMX = '1;
bit TEST = '1;
bit RESET = '0;
bit READY = '1;
bit NMI = '0;
bit INTR = '0;
bit HOLD = '0;

wire logic [7:0] AD;
logic [19:8] A;
logic HLDA;
//logic OE;
logic IOM;
logic WR;
logic RD;
logic SSO;
logic INTA;
logic ALE;
logic DTR;
logic DEN;
logic [3:0] CS;
logic OE;
logic [19:0] Address;
wire [7:0]  Data;


Intel8088 P(CLK, MNMX, TEST, RESET, READY, NMI, INTR, HOLD, AD, A, HLDA, IOM, WR, RD, SSO, INTA, ALE, DTR, DEN);
MEMORY_IO #(.VALID(0),.addr_bits(20),.data_bits(8)) M1(.CS(CS[0]),.*);
MEMORY_IO #(.VALID(0),.addr_bits(20),.data_bits(8)) M2(.CS(CS[1]),.*);
MEMORY_IO #(.VALID(1),.addr_bits(16),.data_bits(8)) I1(.CS(CS[2]),.*);
MEMORY_IO #(.VALID(1),.addr_bits(16),.data_bits(8)) I2(.CS(CS[3]),.*);

assign CS[0] = Address[19] == 1;
assign CS[1] = Address[19] == 0;
assign CS[2]= Address[15:4] == 12'hFF0 ;
assign CS[3]= Address[15:9] == 7'h0E ;

// 8282 Latch to latch bus address
always_latch
begin
if (ALE)
	Address <= {A, AD};
end

// 8286 transceiver
assign Data =  (DTR & ~DEN) ? AD   : 'z;
assign AD   = (~DTR & ~DEN) ? Data : 'z;


always #50 CLK = ~CLK;

initial
begin
$dumpfile("dump.vcd"); $dumpvars;

repeat (2) @(posedge CLK);
RESET = '1;
repeat (5) @(posedge CLK);
RESET = '0;

repeat(10000) @(posedge CLK);
$finish();
end

endmodule
