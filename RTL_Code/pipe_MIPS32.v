`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 

// Engineer: 
// 
// Create Date: 23.11.2025 15:39:08
// Design Name: 
// Module Name: pipe_MIPS32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// If clk1 and clk2 concept confuses you then don't think as if we are performing shift right through a right shift register because in that case some values will be gone, instead think of it like we are performing calculation and not shifting something
// Why HALTED algorithm is simple compared to TAKEN_BRANCH? It is because the HALTED can be smoothly transferred as it falls under a type so type is forwarded but BEQ instruction is determined later if true or not and moreover taken_branch<= 0 happens outside of time period of BRANCH ins.

//==========================================================
// Clock Divider: 100 MHz → 1 Hz
//==========================================================
module clock_divider_0_1Hz (
    input  wire clk_in,      // 100 MHz input clock
    input  wire reset,       // Active-high reset
    output reg  clk_out      // 0.1 Hz output clock
);

    localparam DIVISOR = 50_000_000; // toggle every 5 sec

    
    reg [28:0] counter;
    

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end
        else begin
            if (counter == DIVISOR - 1) begin
                counter <= 0;
                clk_out <= ~clk_out;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

endmodule


module ram(
	input clk,
	input [0:0]we,
	input [9:0]addr,
	input [31:0]din,
	output [31:0] dout
	);
	 
	blk_mem_gen_0 b1 (
	  .clka (clk),
	  .wea  (we),
	  .addra(addr),
	  .dina (din),
	  .douta(dout)
	);

endmodule


module pipe_MIPS32(
    input clk,
    input rst, // remember to use this for 2 seconds initially on fpga and then turn it off fast
    output [12:0]register_2_values   // 2-Phase Clocks
    );
    
    
    wire [31:0] mem_dout;
    reg  [31:0] mem_din;
    reg  [9:0]  mem_addr;
    reg  [0:0] mem_we;

    
    wire clk1, clk2;
    
    reg phase;            // 0 or 1
    wire clk1Hz;
    
    clock_divider_0_1Hz clk_div(clk, rst , clk1Hz);
    
    always @(posedge clk or posedge rst) begin // 2-phase enable logic block
  if (rst) begin
    phase <= 1'b0;
    
  end else if(clk1Hz == 1'b1)begin
    phase <= ~phase;          // toggle each cycle

  end
end
    
        assign clk1  = (phase == 1'b1);

		assign clk2  = (phase == 1'b0);
    
    
    ram DATA_MEM(
		        .clk  (clk),
		        .we   (mem_we),
		        .addr (mem_addr),
		        .din  (mem_din),
		        .dout (mem_dout)
		    );

    
    
    // There is no output or any other input of this processor as this is directly pulling things and storing things in memory or the register
    reg [31:0]PC; reg [31:0]IF_ID_NPC; reg [31:0]IF_ID_IR; //stage 1 latches
    reg [31:0]ID_EX_NPC; reg [31:0]ID_EX_A; reg [31:0]ID_EX_B; reg [31:0] ID_EX_Imm; reg [31:0] ID_EX_IR; // stage 2: ID_EX latches
    reg EX_MEM_cond; reg [31:0] EX_MEM_ALUOut; reg [31:0] EX_MEM_B; reg [31:0] EX_MEM_IR; // stage 3: EX_MEM latches
    reg [31:0]MEM_WB_IR; reg [31:0]MEM_WB_ALUOut; reg [31:0]MEM_WB_LMD;
    
    reg [31:0] Reg [0:31]; // Register bank (32 * 32)
    
    
    reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;
    // Type is used to tell all parts of the pipeline what kind of instruction we have encountered and transfer it to the next stages
    parameter RR_ALU=3'b000, RM_ALU=3'b001, LOAD=3'b010, STORE=3'b011,
              BRANCH= 3'b100, HALT=3'b101;
    reg HALTED;
            // Set after HLT instruction is completed (in WB stage)
    reg TAKEN_BRANCH; 
    // Required to disable assembly instructions after branch instructions is decided in Ex stage using the condition variable
    reg branch_taken_reg;
    reg [31:0] branch_target_reg;

    
    // Next we declare the opcode for the specific operation that we need to perform under a type
    parameter ADD=6'b000000, SUB=6'b000001, AND=6'b000010, OR=6'b000011,
    SLT=6'b000100, MUL=6'b000101, HLT=6'b111111, LW=6'b001000,
    SW=6'b001001, ADDI = 6'b001010, SUBI=6'b001011, SLTI= 6'b001100,
    BNEQZ=6'b001101, BEQZ=6'b001110;
    
    integer k;
    
    
    
    reg [1:0]counterif;
    reg [1:0]counterld;
    assign register_2_values = Reg[2][12:0];
    
    always @(posedge clk or posedge rst) begin //Stage 1: IF(Instruction Fetch) + ID( instruction Decode)
        if (rst == 1'b1) begin 
            
        end
        
        
        
        else if (clk2 == 1'b1 && counterif == 2'd0 && counterld == 2'd0 && clk1Hz == 1'b1) begin //ID stage:2 ID_EX
                case(HALTED)
                1'b0: begin
                    if(IF_ID_IR[25:21] == 5'b00000) ID_EX_A <= #2 1'b0;// This is the R0 register so no need to access it as it is zero
                    else ID_EX_A <= #2 Reg[IF_ID_IR[25:21]]; // "rs"
                    
                    if (IF_ID_IR[20:16] ==5'b00000) ID_EX_B <=#2 1'b0;
                    else ID_EX_B <= #2 Reg [IF_ID_IR[20:16]]; // "rt"
                    
                    ID_EX_NPC <= #2 IF_ID_NPC;
                    ID_EX_IR <= #2 IF_ID_IR;
                    ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}}, {IF_ID_IR[15:0]}}; // Preserving the sign magnitude
                    // Instruction Decoding part
                    case(IF_ID_IR[31:26])
                    ADD,MUL,SUB,AND,OR,SLT: ID_EX_type <= #2 RR_ALU;
                    ADDI,SUBI,SLTI: ID_EX_type <= #2 RM_ALU;
                    LW: ID_EX_type <= #2 LOAD;
                    SW: ID_EX_type <= #2 STORE;
                    BNEQZ, BEQZ: ID_EX_type <= #2 BRANCH;
                    HLT: ID_EX_type <= #2 HALT;
                     // For this not to hit up unnecessaraly I need to input instruction before clk1 comes.
                    endcase
                end
                
                endcase
            end
        end
    
    
    always @(posedge clk or posedge rst) begin //Forcefully added IF stage here(1) EX stage 3: Execution + MEM
    // Pulled mem_we and mem_addr here 

    
    if (rst == 1'b1) begin
        TAKEN_BRANCH <= 1'b0;
        branch_taken_reg <= 1'b0;
        branch_target_reg <= 1'b0;
		counterld <= 2'd0;	
		mem_addr <= 10'b0000000000;
		mem_we <= 1'b0;
		PC <= 1'b0;
		counterif <= 2'd0;
		        
        
    end
    else if (clk1Hz == 1'b1) begin
        if(clk1 == 1'b1 && counterld == 2'd0) begin //IF Stage 1
// don't prevent a latch formatioon here by using case statement because the bigger danger is the default statement that comes with it. It is because there are many things in the pipeline at the same time so if HALTED<=HALTED then that may coincide with something else.
case(HALTED)
1'b0: begin
    // Remember that non-blocking is assigned at the end of the time step
    if(((EX_MEM_IR[31:26] == BEQZ) && (branch_taken_reg == 1)) ||
        ((EX_MEM_IR[31:26] == BNEQZ) && (branch_taken_reg == 0 ))) begin
         // Race condition here as at same time clk1 handles this var(IP/EX)
        if (counterif == 2'd0) begin
        	IF_ID_NPC <= #2 EX_MEM_ALUOut + 1; // We add +1 simply to ready this for the next clk's incoming new instructioon
        	PC <= #2 EX_MEM_ALUOut + 1;
        	mem_addr <= #2 EX_MEM_ALUOut[9:0];
        	mem_we   <= #2 1'b0;    
        	counterif <= #2 counterif +1;
        	end
       else if (counterif == 2'd1) begin counterif <= #2 counterif + 1; end
       else if(counterif == 2'd2) begin
        	IF_ID_IR <= #2 mem_dout; // Made a mistake here-: It is in if else not outside
        	counterif <= #2 2'd0;
        end
    end
    else begin
    if (counterif == 2'd0) begin
        IF_ID_NPC <= #2 PC+1;
        PC <= #2 PC+1;
        mem_addr <= #2 PC[9:0];
        mem_we   <= #2 1'b0;
        counterif <= #2 counterif +1;
        end
    else if (counterif == 2'd1) begin counterif <= #2 counterif + 1; end
    else if(counterif == 2'd2) begin
                    	IF_ID_IR <= #2 mem_dout; 
                    	counterif <= #2 2'd0;
                    end 
    end

end

endcase
end // end of else if block    
    if (clk1 == 1'b1 && counterif == 2'd0 && counterld == 2'd0) begin // Execution Stage 3
    if (HALTED==1'b0) begin
        if(((EX_MEM_IR[31:26] == BEQZ) && (branch_taken_reg == 1)) ||
                ((EX_MEM_IR[31:26] == BNEQZ) && (branch_taken_reg == 0 ))) begin
                    TAKEN_BRANCH <= #2 1'b1;
                end
        if (EX_MEM_type != BRANCH) begin
            TAKEN_BRANCH <= #2 1'b0;
          end
          
         // MY mistake: These are not always executed as they are dependent on the ID decoded
         //EX_MEM_cond <= ID_EX_A? 0: 1;
         //EX_MEM_B <= ID_EX_B;
         EX_MEM_IR <= #2 ID_EX_IR; 
         EX_MEM_type <= #2 ID_EX_type;
     case(ID_EX_type) // This is why proper indentation is necessary for readable code
         RR_ALU: begin
        
         case (ID_EX_IR[31:26])  //"opcode"
            ADD: EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_B;
            SUB: EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_B;
            AND: EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B;
            OR: EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B;
            SLT: EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_B;
            MUL: EX_MEM_ALUOut <= #2 ID_EX_A * ID_EX_B;
            default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx; // on invalid opcode
         endcase
         end
         RM_ALU: begin
                case(ID_EX_IR[31:26]) //"opcode"
                 ADDI: EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                 SUBI: EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_Imm;
                 SLTI: EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_Imm;
                 default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
                 endcase
            end
         LOAD, STORE: begin EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                            EX_MEM_B <= #2 ID_EX_B;
          end
         BRANCH: begin
                    EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm;
                    EX_MEM_cond <= #2 (ID_EX_A == 0);
                    branch_taken_reg <= #2 (ID_EX_A == 0);
                    branch_target_reg <= #2 (ID_EX_NPC + ID_EX_Imm);

                end
         default: ID_EX_type <= #2 ID_EX_type;// HALT condition included too. detected HALT but won't set HALTED here(in the next one)
         endcase
    end
    end
    	
    	
    	
    	
    	
    	else if(clk2 == 1'b1 && counterif == 2'd0) begin // // MEM_WB: stage: MEM
			// If Taken_branch is on then we need to disable this stage and wb stage also for the next 2 instructions
    	    if (HALTED == 1'b0) begin
    	    MEM_WB_type <= #2 EX_MEM_type;
    	    MEM_WB_IR <= #2 EX_MEM_IR;
    	    case(EX_MEM_type)
    	    RR_ALU,RM_ALU: begin
    	    
    	    MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
    	    end
    	    LOAD:begin
                if (counterld == 2'd0) begin


    	    		mem_addr <= #2 EX_MEM_ALUOut[9:0];
    	    		mem_we   <= #2 1'b0;    
    	    		counterld <= #2 counterld +1;
    	    	end
   	    		else if (counterld == 2'd1) begin counterld <= #2 counterld + 1; end
   	    		else if(counterld == 2'd2) begin
   	    			MEM_WB_LMD <= #2 mem_dout;
    	    		counterld <= #2 2'd0;
    	    end    	    

    	    end
    	    STORE: begin
    	        if (TAKEN_BRANCH ==0)begin // Disable write
    	        	mem_addr <= #2 EX_MEM_ALUOut;
    	        	mem_we <= #2 1'b1;
    	        	mem_din <= #2 EX_MEM_B;
    	             end
    	    end
    	    
    	    
    	    endcase
    	    
    	    end
    	    end   
    	    end 
    end    
    
    
    always @(posedge clk or posedge rst) //WB Stage
        begin
        if (rst == 1'b1) begin 
            
            
            HALTED <= 1'b0;
            for (k=0; k<31; k=k+1) 
            begin Reg[k] <= k; end
                end
        else if(clk1 == 1'b1 && counterif == 2'd0 && counterld == 2'd0 && clk1Hz == 1'b1) begin
        if (TAKEN_BRANCH == 1'b0 && HALTED ==1'b0) begin
            case(MEM_WB_type) 
                RR_ALU: Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOut; // "rd"
                
                RM_ALU: Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOut; // "rt"
                
                LOAD: Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD; // "rt"
                
                HALT: HALTED <= #2 1'b1;
                default: begin end
                endcase
                    end
                end 
        end
    endmodule


// Think about implementing a counter so that taken_branch is turned off after a fixed number of clk cycles that works on both clk1 and clk2 carefully
