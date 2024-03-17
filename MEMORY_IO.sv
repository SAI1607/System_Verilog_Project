module MEMORY_IO #(parameter VALID=1,parameter addr_bits=20,parameter data_bits=8,parameter file=0)(Intel8088Pins I8088pins,input logic CS);
	logic LOAD;
	logic OE;
    logic [data_bits-1:0] memory [(2**addr_bits)-1:0];
	logic [7:0] datain;
    typedef enum logic [4:0] {
        T1 = 5'b00000,
        T2 = 5'b00010,
        T3R = 5'b00100,
		T3W = 5'b01000,
		T4 = 5'b10000
    } State_t;

    State_t State, NextState;
	assign datain = memory[I8088pins.Address];
	assign I8088pins.Data = OE ? datain : 'z;
    
	initial begin
		case(file)
		0: $readmemh("TRACE_IO1.txt",memory);
		1: $readmemh("TRACE_IO2.txt",memory);
		2: $readmemh("TRACE_MEM1.txt",memory);
		3: $readmemh("TRACE_MEM2.txt",memory);
		default: $readmemh("Mem1.txt",memory);
		endcase
	end

	always_ff@(posedge I8088pins.CLK) begin
	 if(LOAD) begin	
		memory[I8088pins.Address] = I8088pins.Data;
	 end
     else begin
		memory[I8088pins.Address]=memory[I8088pins.Address];
	 end	 
	end
    always_ff @(posedge I8088pins.CLK) begin
        if (I8088pins.RESET) begin
            State <= T1; 
		end
        else
            State <= NextState;
    end
    always_comb begin
        NextState = State;
        unique case (State)
            T1:  begin 
						if (CS&&I8088pins.ALE&&(I8088pins.IOM==VALID)) begin
							NextState = T2;
						end
					end
			T2:  begin
						if(!I8088pins.RD) 
						begin
							NextState = T3R;
						end
						else if(!I8088pins.WR) 
						begin
							NextState = T3W;
						end	
					end
			T3R: 	NextState = T4;
						
            T3W:  NextState = T4;
			
			T4 : NextState = T1;
        endcase
    end

    always_comb begin
	{OE,LOAD}='0;
        case (State) 
			
			T3R:    begin 
						OE='1;
					end	
            
            T3W:  LOAD='1; 
        endcase
	end
endmodule