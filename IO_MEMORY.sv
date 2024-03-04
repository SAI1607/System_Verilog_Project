module IO_MEMORY (input bit CS, input bit WR,input bit RD,input bit RESET,input bit CLK,output logic [7:0] Data,input bit ALE,input logic [19:0] Address,input bit IOM);
    
	parameter ACTIVE=1;
  int cpu_time;
	input bit [7:0] data_in;
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
		OE=0;
		data =cpu_time & 0xFF;
    end
	
    if(IOM==ACTIVE) begin

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
					if (ALE) begin
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

				READ:   
							NextState = HALT;
           
				WRITE:  
							NextState = HALT;
           
				HALT:   if(ALE)
							NextState = VALID;
			endcase
		end

		always_comb begin
			case (State)
				READ:   Data = memory[Address];
           
				WRITE:  memory[Address] = data_in;
           
				default: Data = 'z;
			endcase
		end
	end
	
	else begin
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
                    if (ALE) begin
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

				READ:   
							NextState = HALT;
           
				WRITE:  
							NextState = HALT;
           
				HALT:   if(ALE)
							NextState = VALID;
			endcase
		end

		always_comb begin
			case (State)
				READ:   
					OE=1
					Data = memory[Address];
           
				WRITE: memory[Address] = data_in;
           
				default: Data = 'z;
			endcase
		end
	end
endmodule
