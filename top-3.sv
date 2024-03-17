interface Intel8088Pins(input CLK,input RESET);
logic MNMX='1;
logic TEST='1;
logic READY='1;
logic NMI='0;
logic INTR='0;
logic HOLD='0;
logic HLDA;
tri [7:0] AD;
tri [19:8] A;
logic IOM;
logic WR;
logic RD;
logic SSO;
logic INTA;
logic ALE;
logic DTR;
logic DEN;
logic [19:0] Address;
wire [7:0]  Data;

modport Processor(input CLK,input RESET,inout AD,output A,input HOLD,output IOM,output WR,output RD,output SSO,input READY,
            input TEST,input MNMX,output DEN,output DTR,output ALE,output INTA,input INTR,input NMI,input HLDA);
			
modport Peripheral (input WR,input RD,input RESET,input CLK,inout Data,input ALE,input Address,input IOM);

			
endinterface

module top;
bit CLK = '0;
bit RESET = '0;
logic [3:0] CS;

Intel8088Pins I8088pins(CLK,RESET);
Intel8088 P (I8088pins.Processor);
MEMORY_IO #(.VALID(0),.addr_bits(20),.data_bits(8),.file(2)) M1(.I8088pins(I8088pins.Peripheral),.CS(CS[0]));
MEMORY_IO #(.VALID(0),.addr_bits(20),.data_bits(8),.file(3)) M2(.I8088pins(I8088pins.Peripheral),.CS(CS[1]));
MEMORY_IO #(.VALID(1),.addr_bits(16),.data_bits(8),.file(0)) I1(.I8088pins(I8088pins.Peripheral),.CS(CS[2]));
MEMORY_IO #(.VALID(1),.addr_bits(16),.data_bits(8),.file(1)) I2(.I8088pins(I8088pins.Peripheral),.CS(CS[3]));

assign CS[0] = I8088pins.Address[19] == 1;
assign CS[1] = I8088pins.Address[19] == 0;
assign CS[2]= I8088pins.Address[15:4] == 12'hFF0 ;
assign CS[3]= I8088pins.Address[15:9] == 7'h0E ;

// 8282 Latch to latch bus address
always_latch
begin
if (I8088pins.ALE)
	I8088pins.Address <= {I8088pins.A, I8088pins.AD};
end

// 8286 transceiver
assign I8088pins.Data =  (I8088pins.DTR & ~I8088pins.DEN) ? I8088pins.AD   : 'z;
assign I8088pins.AD   = (~I8088pins.DTR & ~I8088pins.DEN) ? I8088pins.Data : 'z;


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
