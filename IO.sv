module InputOutput (input logic CS,input logic OE,input logic WR,input RD,input bit RESET,input bit CLK,output logic [7:0] Data,input logic ALE,input logic [19:0] Address,input logic IOM);
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
        VALID = 5'b00010,
        READ = 5'b00100,
        WRITE = 5'b01000,
        HALT = 5'b10000
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
            IDLE: begin
                    if (IOM && ALE) begin
                        NextState = VALID;
                    end
                    else
                        NextState = IDLE;
                 end

            VALID:  if (!RD) begin
                        NextState = READ;
                    end
                    else if(WR==0) begin
                        NextState = WRITE;
                    end

            READ:   if(RD)
                       NextState = HALT;
           
            WRITE:  if(WR)
                       NextState = HALT;
           
            HALT:   if(ALE)
                       NextState = VALID;
        endcase
    end

    always_comb begin
        case (State)
            READ:   Data = memory[Address];
           
            WRITE:  memory[Address] = cpu_time;
           
            default: Data = 'z;
        endcase
end
endmodule
