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
    output PCS, 
    output reg RegW,
    output reg MemW,
    output reg MemtoReg,
    output reg ALUSrc,
    output reg [1:0] ImmSrc,
    output reg [1:0] RegSrc,
    output NoWrite, //??
    output reg [1:0] ALUControl,
    output reg [1:0] FlagW
    );
    
    reg ALUOp ;
    //reg [9:0] controls ;
    reg Branch;
    //<extra signals, if any>
    
    assign PCS = (Rd == 15 & RegW) | Branch ;
    
    always@(*)
    begin
        case(Op)
            2'b00:
                if(Funct[5] == 0)
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
            2'b01:
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
            2'b10:
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
    
    always @ (ALUOp, Funct[4:0])
    begin
        if(ALUOp == 0)
        begin
            ALUControl = 2'b00;
            FlagW = 2'b00;
        end
        else 
        begin
            case(Funct[4:0])
                5'b01001:
                    begin 
                        ALUControl = 2'b00;
                        FlagW = 2'b11;
                    end
                5'b01000:
                    begin 
                        ALUControl = 2'b00;
                        FlagW = 2'b00;
                    end
                5'b00101:
                    begin 
                        ALUControl = 2'b01;
                        FlagW = 2'b11;
                    end
                5'b00100:
                    begin 
                        ALUControl = 2'b01;
                        FlagW = 2'b00;
                    end
                5'b00001:
                    begin 
                        ALUControl = 2'b10;
                        FlagW = 2'b10;
                    end
                5'b00000:
                    begin 
                        ALUControl = 2'b10;
                        FlagW = 2'b00;
                    end
                5'b11001:
                    begin 
                        ALUControl = 2'b11;
                        FlagW = 2'b10;
                    end
                5'b11000:
                    begin 
                        ALUControl = 2'b11;
                        FlagW = 2'b00;
                    end
                default:
                    begin
                        ALUControl = 2'bxx;
                        FlagW = 2'bxx;
                    end
            endcase
        end
    end
endmodule





