module MEMORY_IO (input logic CS,output logic OE,input logic WR,input RD,input bit RESET,input bit CLK,output logic [7:0] Data,input logic ALE,input logic [19:0] Address,input logic IOM);
	bit MNMX;
    bit TEST;
    bit READY;
    bit NMI ;
    bit INTR;
    bit HOLD;
    logic [7:0] AD;
    logic [19:8] A;
    logic HLDA;
    logic SSO;
    logic INTA;
    logic DTR;
    logic DEN;
    int cpu_time;
    logic [7:0] memory [0:1048575];
    typedef enum logic [5:0] {
        IDLE = 6'b000001,
        READ = 6'b000010,
        WRITE = 6'b000100,
		IO = 6'b001000,
		MEMORY = 6'b0100000,
		FINAL = 6'b1000000
    } State_t;

    State_t State, NextState;

    always @(posedge CLK) begin
        cpu_time=cpu_time+1;
    end

    initial begin
        cpu_time=0;
    end

    always_ff @(posedge CLK) begin
        if (RESET) begin
            State <= IDLE; 
		end
        else
            State <= NextState;
    end
    always_comb begin
        NextState = State;
        case (State)
            IDLE:                       begin 
						if (ALE && IOM) begin
							NextState = IO;
						end
						else if (ALE && !IOM) begin
							NextState = MEMORY;
						end
					end
	    IO:   		        if(!RD) begin
						NextState = READ;
					end
					else if(!WR) begin
						NextState = WRITE;
					end	
	    MEMORY: 			if(!RD) begin
						NextState = READ;
					end
					else if(!WR) begin
						NextState = WRITE;
					end	
            READ:  NextState = FINAL;
						
            WRITE:   NextState = FINAL;
			
	    FINAL : NextState = IDLE;
        endcase
    end

    always_comb begin
	{OE}='0;
        case (State)
	    IDLE:      Data='z; 
	
	    READ:   	begin 
				Data = memory[Address];
				OE='1;
			end	

            WRITE:      memory[Address] = cpu_time && 'hFF; 
        endcase
	end
endmodule
