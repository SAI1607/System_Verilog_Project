module MEMORY_IO (input logic CS,input logic OE,input logic WR,input RD,input bit RESET,input bit CLK,output logic [7:0] Data,input logic ALE,input logic [19:0] Address,input logic IOM);
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
    typedef enum logic [4:0] {
        IDLE = 5'b00001,
        IO_READ = 5'b00010,
        IO_WRITE = 5'b00100,
        MEMORY_READ = 5'b01000,
        MEMORY_WRITE = 5'b10000
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
            IDLE:   begin 
					if (ALE && IOM) begin
						if(!RD) begin
							NextState = IO_READ;
						end
						else begin
							NextState = IO_WRITE;
						end	
					end
                   			else if (ALE && !IOM) begin
						if(!RD) begin
							NextState = MEMORY_READ;
						end
						else begin
							NextState = MEMORY_WRITE;
						end	
					end
					end

            IO_READ:  NextState = IDLE;
						
            IO_WRITE:   NextState = IDLE;
            
            MEMORY_READ:  NextState = IDLE;
            
            MEMORY_WRITE:	NextState = IDLE;
        endcase
    end

    always_comb begin
        case (State)
            IO_READ:   Data = memory[Address];
            
            IO_WRITE:  memory[Address] = cpu_time && 'hFF;
			
			MEMORY_READ:   Data = memory[Address];
            
            MEMORY_WRITE:  memory[Address] = cpu_time && 'hFF;
        endcase
	end
endmodule
