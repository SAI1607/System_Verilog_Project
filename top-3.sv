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
logic CS_0,CS_1,CS_2,CS_3;
logic OE;
logic [19:0] Address;
wire [7:0]  Data;


Intel8088 P(CLK, MNMX, TEST, RESET, READY, NMI, INTR, HOLD, AD, A, HLDA, IOM, WR, RD, SSO, INTA, ALE, DTR, DEN);
MEMORY_1 #(0) M1(.CS(CS_0),.Data(Data),.*);
MEMORY_2 #(0) M2(.CS(CS_1),.Data(Data),.RD(RD),.WR(WR),.Address(Address),.*);
IO_1 #(1) I1(.CS(CS_2),.*);
IO_2 #(1) I2(.CS(CS_3),.*);

assign CS_0 = Address[19] == 1;
assign CS_1 = Address[19] ==0;
assign CS_2= (Address[15:4] == 12'hFF0) ;
assign CS_3= (Address[15:9] == 7'h0E) ;

//assign CS_2 = (Address >= 16'hFF00 && Address <= 16'hFF0F);
//assign CS_3 = (Address >= 16'h1C00 && Address <= 16'h1D00);

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
