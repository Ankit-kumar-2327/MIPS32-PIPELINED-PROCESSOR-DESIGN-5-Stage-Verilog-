module MIPS32(clk1, clk2); 
    input clk1, clk2;

    reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
    reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
    reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type; 
    reg [31:0] EX_MEM_IR, EX_MEM_ALUOUT, EX_MEM_B;
    reg        EX_MEM_cond;
    reg [31:0] MEM_WB_IR, MEM_WB_ALUOUT, MEM_WB_LMD;

    reg [31:0] Reg [0:31];      
    reg [31:0] Memory [0:1024];  

 // instruction OPCODE
    parameter ADD   = 6'b000000, SUB  = 6'b000001, AND  = 6'b000010, OR   = 6'b000011,
              SLT   = 6'b000100, MUL  = 6'b000101, HLT  = 6'b111111, LW   = 6'b001000,
              SW    = 6'b001001, ADDI = 6'b001010, SUBI = 6'b001011, SLTI = 6'b001100,
              BNEQZ = 6'b001101, BEQZ = 6'b001110, XOR  = 6'b001111, NOR  = 6'b010000,
              DIV   = 6'b010001, MOD  = 6'b010010, SLLV = 6'b010011, SRLV = 6'b010100,
              SRA   = 6'b010101;

    parameter RR_ALU = 3'b000, RM_ALU = 3'b001, LOAD = 3'b010, STORE = 3'b011,
              BRANCH = 3'b100, HALT   = 3'b101;

    reg HALTED;
    reg TAKEN_BRANCH;

    //  IF STAGE
    always @(posedge clk1) begin
        if (!HALTED) begin
            if (((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1)) ||
                ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 0))) begin
                IF_ID_IR     <= #2 Memory[EX_MEM_ALUOUT];
                IF_ID_NPC    <= #2 EX_MEM_ALUOUT + 1;
                PC           <= #2 EX_MEM_ALUOUT + 1;
                TAKEN_BRANCH <= #2 1'b1;
            end 
            else begin
    
                IF_ID_IR     <= #2 Memory[PC];
                IF_ID_NPC    <= #2 PC + 1;
                PC           <= #2 PC + 1;
            end
        end
    end

    //ID STAGE
    always @(posedge clk2) begin
        if (!HALTED) begin
            ID_EX_A    <= #2 (IF_ID_IR[25:21] == 5'b00000) ? 0 : Reg[IF_ID_IR[25:21]];
            ID_EX_B    <= #2 (IF_ID_IR[20:16] == 5'b00000) ? 0 : Reg[IF_ID_IR[20:16]];
            ID_EX_NPC  <= #2 IF_ID_NPC;
            ID_EX_IR   <= #2 IF_ID_IR;
            ID_EX_Imm  <= #2 {{16{IF_ID_IR[15]}}, IF_ID_IR[15:0]}; // Sign-extended

            case (IF_ID_IR[31:26])
                ADD,SUB,AND,OR,SLT,MUL,XOR,NOR,DIV,MOD,SLLV,SRLV,SRA : ID_EX_type <= #2 RR_ALU;
                ADDI, SUBI, SLTI          : ID_EX_type <= #2 RM_ALU;
                LW                        : ID_EX_type <= #2 LOAD;
                SW                        : ID_EX_type <= #2 STORE;
                BEQZ, BNEQZ               : ID_EX_type <= #2 BRANCH;
                HLT                       : ID_EX_type <= #2 HALT;
                default                   : ID_EX_type <= #2 HALT; 
            endcase
        end
    end

    // EX STAGE
    always @(posedge clk1) begin
        if (!HALTED) begin
            EX_MEM_type  <= #2 ID_EX_type;
            EX_MEM_IR    <= #2 ID_EX_IR;
            TAKEN_BRANCH <= #2 0;

            case (ID_EX_type)
                RR_ALU: begin
                    case (ID_EX_IR[31:26])
                        ADD     : EX_MEM_ALUOUT   <= #2 ID_EX_A + ID_EX_B;
                        SUB     : EX_MEM_ALUOUT   <= #2 ID_EX_A - ID_EX_B;
                        AND     : EX_MEM_ALUOUT   <= #2 ID_EX_A & ID_EX_B;
                        OR      : EX_MEM_ALUOUT   <= #2 ID_EX_A | ID_EX_B;
                        SLT     : EX_MEM_ALUOUT   <= #2 (ID_EX_A < ID_EX_B);
                        MUL     : EX_MEM_ALUOUT   <= #2 ID_EX_A * ID_EX_B;
                        XOR     : EX_MEM_ALUOUT   <= #2 ID_EX_A ^ ID_EX_B;
                        NOR     : EX_MEM_ALUOUT   <= #2 ~(ID_EX_A | ID_EX_B);
                        DIV     : EX_MEM_ALUOUT   <= #2 ID_EX_B != 0 ? ID_EX_A / ID_EX_B : 32'hxxxxxxxx;  // check denominator  not equal to zero 
                        MOD     : EX_MEM_ALUOUT   <= #2 ID_EX_B != 0 ? ID_EX_A % ID_EX_B : 32'hxxxxxxxx;
                        SLLV    : EX_MEM_ALUOUT   <= #2 ID_EX_B << ID_EX_A[4:0];
                        SRLV    : EX_MEM_ALUOUT   <= #2 ID_EX_B >> ID_EX_A[4:0];
                        SRA     : EX_MEM_ALUOUT   <= #2 $signed(ID_EX_B) >>> ID_EX_A[4:0];
                       default  : EX_MEM_ALUOUT   <= #2 32'hxxxxxxxx;
                        default : EX_MEM_ALUOUT   <= #2 32'hxxxxxxxx;
                    endcase
                end

                RM_ALU: begin
                    case (ID_EX_IR[31:26])
                        ADDI    : EX_MEM_ALUOUT <= #2 ID_EX_A + ID_EX_Imm;
                        SUBI    : EX_MEM_ALUOUT <= #2 ID_EX_A - ID_EX_Imm;
                        SLTI    : EX_MEM_ALUOUT <= #2 (ID_EX_A < ID_EX_Imm);
                        default : EX_MEM_ALUOUT <= #2 32'hxxxxxxxx;
                    endcase
                end

                LOAD, STORE: begin
                    EX_MEM_ALUOUT <= #2 ID_EX_A + ID_EX_Imm;
                    EX_MEM_B      <= #2 ID_EX_B;
                end

                BRANCH: begin
                    EX_MEM_ALUOUT <= #2 ID_EX_NPC + ID_EX_Imm;
                    EX_MEM_cond   <= #2 (ID_EX_A == 0);
                end
            endcase
        end
    end

    //  MEM STAGE 
    always @(posedge clk2) begin
        if (!HALTED) begin
            MEM_WB_type <= #2 EX_MEM_type;
            MEM_WB_IR   <= #2 EX_MEM_IR;

            case (EX_MEM_type)
                RR_ALU, RM_ALU: MEM_WB_ALUOUT <= #2 EX_MEM_ALUOUT;
                LOAD          : MEM_WB_LMD    <= #2 Memory[EX_MEM_ALUOUT];
                STORE         : if (!TAKEN_BRANCH)
                                    Memory[EX_MEM_ALUOUT] <= #2 EX_MEM_B;
            endcase
        end
    end

    // WB STAGE 
    always @(posedge clk1) begin
        if (!TAKEN_BRANCH) begin
            case (MEM_WB_type)
                RR_ALU : Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOUT;
                RM_ALU : Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOUT;
                LOAD   : Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD;
                HALT   : HALTED <= #2 1'b1;
            endcase
        end
    end

endmodule
