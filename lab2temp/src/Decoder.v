`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Shahzor Ahmad and Rajesh Panicker  
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: Decoder
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: Decoder Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v)	acknowledge that the program was written based on the microarchitecture described in the book Digital Design and Computer Architecture, ARM Edition by Harris and Harris;
--		(vi) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vii) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

module Decoder(
    input [3:0] Rd, 
    input [1:0] Op,
    input [5:0] Funct,
    input [3:0] MChecker,
    output PCS, 
    output reg RegW,
    output reg MemW,
    output reg MemtoReg,
    output reg ALUSrc,
    output reg [1:0] ImmSrc,
    output reg [1:0] RegSrc,
    output reg NoWrite, //??
    output reg [3:0] ALUControl,
    output reg [1:0] FlagW,
    output reg [1:0] MCycleOp,
    output reg MStart
    );
    
    reg ALUOp ;
    //reg [9:0] controls ;
    reg Branch;
    //<extra signals, if any>
    
    assign PCS = (Rd == 15 & RegW) | Branch ;
    
    always@(*)
    begin
        case(Op)
            2'b00: // DP instruction
                if(Funct[5] == 0) // Immediate flag not set
                begin
                   Branch = 0;
                   MemtoReg = 0;
                   MemW = 0;
                   ALUSrc = 0;
                   ImmSrc = 2'bxx;
                   RegW = 1;
                   RegSrc = 2'b00;
                   ALUOp = 1; 
                end
                else
                begin
                   Branch = 0;
                   MemtoReg = 0;
                   MemW = 0;
                   ALUSrc = 1;
                   ImmSrc = 2'b00;
                   RegW = 1;
                   RegSrc = 2'bx0;
                   ALUOp = 1; 
                end
            2'b01: // Memory Instruction
                if(Funct[0] == 0)
                begin
                    Branch = 0;
                    MemtoReg = 1'bx;
                    MemW = 1;
                    ALUSrc = 1;
                    ImmSrc = 2'b01;
                    RegW = 0;
                    RegSrc = 2'b10;
                    ALUOp = 0;
                end 
                else
                begin
                    Branch = 0;
                    MemtoReg = 1'b1;
                    MemW = 0;
                    ALUSrc = 1;
                    ImmSrc = 2'b01;
                    RegW = 1;
                    RegSrc = 2'bx0;
                    ALUOp = 0;
                end     
            2'b10: // Branch
                begin
                    Branch = 1;
                    MemtoReg = 1'b0;
                    MemW = 0;
                    ALUSrc = 1;
                    ImmSrc = 2'b10;
                    RegW = 0;
                    RegSrc = 2'bx1;
                    ALUOp = 0;
                end
             default:
                begin
                    Branch = 1'bx;
                    MemtoReg = 1'bx;
                    MemW = 1'bx;
                    ALUSrc = 1'bx;
                    ImmSrc = 2'bxx;
                    RegW = 1'bx;
                    RegSrc = 2'bxx;
                    ALUOp = 1'bx;
                end
            endcase

    end    
    
    always @ (ALUOp, Funct[4:0]) // Funct[4:1] is cmd
    begin
        MStart = 0;
        if(ALUOp == 0)
        begin
            ALUControl = 2'b00;
            FlagW = 2'b00;
        end
        else 
        begin
            case(Funct[4:0])
                5'b01001: // ADDS
                    begin 
                        ALUControl = 4'b0000;
                        FlagW = 2'b11;
                        NoWrite = 0;
                    end
                5'b01000: //ADD
                    begin 
                        ALUControl = 4'b0000;
                        FlagW = 2'b00;
                        NoWrite = 0;
                    end
                5'b00101: //SUBS
                    begin 
                        ALUControl = 4'b0001;
                        FlagW = 2'b11;
                        NoWrite = 0;
                    end
                5'b00100: // SUB
                    begin 
                        ALUControl = 4'b0001;
                        FlagW = 2'b00;
                        NoWrite = 0;
                    end
                5'b00001: // ANDS and MULS (MULS not required at the moment, so not configured)
                    begin 
                        ALUControl = 4'b0010;
                        FlagW = 2'b10;
                        NoWrite = 0;
                    end
                5'b00000: // AND and MUL
                    begin 
                        ALUControl = 4'b0010;
                        FlagW = 2'b00;
                        NoWrite = 0;
                        if (MChecker == 4'b1001) begin
                            MCycleOp = 2'b01;
                            MStart = 1;
                        end
                    end
                5'b11001: // ORRS
                    begin 
                        ALUControl = 4'b0011;
                        FlagW = 2'b10;
                        NoWrite = 0;
                    end
                5'b11000: // ORR
                    begin 
                        ALUControl = 4'b0011;
                        FlagW = 2'b00;
                        NoWrite = 0;
                    end
                5'b10101: // CMP
                    begin
                        ALUControl = 4'b0001;
                        FlagW = 2'b11;
                        NoWrite = 1;
                    end
                5'b11010: // MOV
                    begin
                        ALUControl = 4'b1101;
                        FlagW = 2'b00;
                        NoWrite = 0;
                    end
                5'b11011: // MOVS
                    begin
                        ALUControl = 4'b1101;
                        FlagW = 2'b10;
                        NoWrite = 0;
                    end
                5'b00010: // MLA (but use for DIV)
                    begin
                        ALUControl = 4'b0101;
                        FlagW = 2'b00;
                        NoWrite = 0;
                        if (MChecker == 4'b1001) begin
                            MCycleOp = 2'b11;
                            MStart = 1;
                        end
                    end
                5'b01010: //ADC
                    begin
                        ALUControl = 4'b0100;
                        FlagW = 2'b00;
                        NoWrite = 0;
                    end
                5'b01011: //ADCS
                    begin
                        ALUControl = 4'b0100;
                        FlagW = 2'b11;
                        NoWrite = 0;
                    end
                5'b11100: //BIC
                    begin
                        ALUControl = 4'b0110;
                        FlagW = 2'b00;
                        NoWrite = 0;
                    end
                5'b11101: //BICS
                begin
                    ALUControl = 4'b0110;
                    FlagW = 2'b10;
                    NoWrite = 0;
                end
                5'b11110: // MVN
                    begin
                        ALUControl = 4'b0111;
                        FlagW = 2'b00;
                        NoWrite = 0;
                    end
                5'b11111: // MVNS
                    begin
                        ALUControl = 4'b0111;
                        FlagW = 2'b10;
                        NoWrite = 0;
                    end
                5'b10111: // CMN
                    begin
                        ALUControl = 4'b0000;
                        FlagW = 2'b11;
                        NoWrite = 1;
                    end
                5'b00110: // RSB
                    begin
                        ALUControl = 4'b1001;
                        FlagW = 2'b00;
                        NoWrite = 0;
                    end
                5'b00111: // RSBS
                    begin
                        ALUControl = 4'b1001;
                        FlagW = 2'b11;
                        NoWrite = 0;
                    end
                5'b01110: // RSC
                    begin
                        ALUControl = 4'b1010;
                        FlagW = 2'b00;
                        NoWrite = 0;
                    end
                5'b01111: // RSCS
                begin
                    ALUControl = 4'b1010;
                    FlagW = 2'b11;
                    NoWrite = 0;
                end
                5'b01100: // SBC
                    begin
                        ALUControl = 4'b1011;
                        FlagW = 2'b00;
                        NoWrite = 0;
                    end
                5'b01101: // SBCS
                    begin
                        ALUControl = 4'b1011;
                        FlagW = 2'b11;
                        NoWrite = 0;
                    end
                5'b10011: // TEQ
                    begin
                        ALUControl = 4'b0101;
                        FlagW = 2'b10;
                        NoWrite = 1;
                    end
                5'b10001: //TST
                    begin
                        ALUControl = 4'b0010;
                        FlagW = 2'b10;
                        NoWrite = 1;
                    end
                default:
                    begin
                        ALUControl = 4'bxxxx;
                        FlagW = 2'bxx;
                        NoWrite = 1'bx;
                    end
            endcase
        end
    end
endmodule





