module IO_1 #(parameter VALID=1)(input logic CS,input logic WR,input RD,input bit RESET,input bit CLK,output logic[7:0] Data,input logic ALE,input logic [19:0] Address,input logic IOM);
    int cpu_time;
    logic LOAD;
    logic OE;
    logic [7:0] memory [16'hFF00:16'hFF0F];
    logic [7:0] datain;
    typedef enum logic [4:0] {
        T1 = 5'b00000,
        T2 = 5'b00010,
        T3R = 5'b00100,
	T3W = 5'b01000,
	T4 = 5'b10000
    } State_t;

    State_t State, NextState;
    assign datain = memory[Address];
    assign Data = OE ? datain : 'z;
    
    initial begin
        $readmemh("Mem1.txt",memory);
    end

    always@(posedge CLK) begin
	if(LOAD) begin	
	     memory[Address] = Data;
	end	
	else begin
	     memory[Address]='0;
	end
    end
    always_ff @(posedge CLK) begin
        if (RESET) begin
            State <= T1; 
	end
        else
            State <= NextState;
    end
    always_comb begin
        NextState = State;
        unique case (State)
            T1:begin 
		if (CS&&ALE&&(IOM==VALID)) begin
		    NextState = T2;
		end
	       end
	    T2: begin
		  if(!RD) 
		    begin
		       NextState = T3R;
		    end
		  else if(!WR) 
		    begin
		       NextState = T3W;
		    end	
		end
	     T3R: NextState = T4;
						
             T3W: NextState = T4;
			
	     T4 : NextState = T1;
        endcase
    end

    always_comb begin
	{OE,LOAD}='0;
        case (State) 
	    T3R:   begin 
		      OE='1;
		   end	
            T3W:  LOAD='1; 
        endcase
	end
endmodule
