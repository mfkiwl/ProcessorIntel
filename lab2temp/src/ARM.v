`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Shahzor Ahmad and Rajesh Panicker  
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: ARM
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: ARM Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: The interface SHOULD NOT be modified. The implementation can be modified
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

//-- R15 is not stored
//-- Save waveform file and add it to the project
//-- Reset and launch simulation if you add interal signals to the waveform window

module ARM(
    input CLK,
    input RESET,
    //input Interrupt,  // for optional future use
    input [31:0] InstrF,
    input [31:0] ReadDataM,
    output reg MemWriteM,
    output [31:0] PC,
    output reg [31:0] ALUResultM,
    output [31:0] WriteDataM,
    output [511:0] bigRegBank
    );
    
    // RegFile signals
    //wire CLK ;
    wire WE3;
    wire [3:0] A1;
    wire [3:0] A2;
    reg[3:0] A3;
    wire [31:0] WD3;
    wire [31:0] R15;
    wire [31:0] RD1D;
    wire [31:0] RD2D;
    
    // Extend Module signals
    wire [1:0] ImmSrcD;
    wire [23:0] InstrImm;
    wire [31:0] ExtImmD;
    
    // Decoder signals
    wire [3:0] Rd;
    wire [1:0] Op;
    wire [5:0] Funct;
    wire [3:0] MChecker;
    //wire PCS ;
    //wire RegW ;
    //wire MemW ;
    wire MemtoRegD;
    wire ALUSrcD;
    //wire [1:0] ImmSrc ;
    wire [1:0] RegSrcD;
    //wire NoWrite ;
    //wire [1:0] ALUControl ;
    //wire [1:0] FlagW ;
    
    // CondLogic signals
    //wire CLK ;
    wire [31:0] PCPlus8D;
    wire PCSD;
    wire RegWD;
    wire NoWriteD;
    wire MemWD;
    wire [1:0] FlagWD;
    wire [3:0] CondD;
    //wire [3:0] ALUFlags,
    wire PCSrc;
    wire RegWrite; 
//    wire Carry;
    //wire MemWrite
       
    // Shifter signals
    wire [1:0] Sh;
    wire [4:0] Shamt5;
    wire [31:0] ShIn;
    wire [31:0] ShOut;
    wire [31:0] newShOut;
    
    // ALU signals
    wire [31:0] Src_AE;
    wire [31:0] Src_BE;
    //wire [31:0] ALUResult ;
    wire [3:0] ALUFlags;
    
    // ProgramCounter signals
    //wire CLK ;
    //wire RESET ;
    wire WE_PC;    
    wire [31:0] PC_IN;
    //wire [31:0] PC ; 
    
    // MCycle signals
    wire MStart = 0;
    wire [1:0] MCycleOp;
    wire Busy;
    wire [31:0] Result1;
    wire [31:0] Result2;
        
    // Other internal signals here
    wire [31:0] PCPlus4F;
    wire [31:0] PCPlus8;
    wire [31:0] ResultW;
    
    //Pipelining registers
    //D registers
    reg [31:0] InstrD;
    wire [3:0] ALUControlD;
    wire [3:0] RA1D;
    wire [3:0] RA2D;
    //E stage registers
    reg [31:0] InstrE;
    reg PCSE; //1
    reg RegWE; //1
    reg MemWE; //1
    reg [1:0] FlagWE;
    reg [3:0] ALUControlE;
    reg MemtoRegE; //1
    reg ALUSrcE; //1
    wire PCSrcE; //1
    wire RegWriteE; //1
    wire MemWriteE; //1
    reg [3:0] CondE;
    reg NoWriteE;
    wire [31:0] WriteDataE;
    wire [31:0] ALUResultE;
    reg [31:0] ExtImmE;
    reg [31:0] RD1E;
    reg [31:0] RD2E;
    reg [3:0] WA3E;
    reg [3:0] RA1E;
    reg [3:0] RA2E;
    wire CarryE;
    
    //M stage registers
    reg PCSrcM;
    reg RegWriteM;
    reg MemtoRegM;
    wire [31:0] ALUOutM;
    reg [3:0] WA3M;
    reg [3:0] RA2M;
    reg NoWriteM;
    
    // W stage registers
    reg PCSrcW;
    reg RegWriteW;
    reg MemtoRegW;
    reg [31:0] ReadDataW;
    reg [3:0] WA3W;
    reg [31:0] ALUOutW;
    reg NoWriteW;
    
    // Data Hazard Wires
    reg Match_1E_M;
    reg Match_2E_M;
    reg Match_1E_W;
    reg Match_2E_W;
    reg [1:0] ForwardAE;
    reg [1:0] ForwardBE;
    reg ForwardM;
    reg StallF = 0;
    reg StallD = 0;
    reg FlushE = 0;
    reg Match_12D_E;
    reg ldrstall;
    reg FlushD = 0;
    wire ResultM ;
    
    // datapath connections here
    assign WE_PC = 1 ; // Will need to control it for multi-cycle operations (Multiplication, Division) and/or Pipelining with hazard hardware.

    assign PCPlus4F = PC + 4;
    assign PCPlus8 = PC + 8;
    
    assign RA1D = (RegSrcD[0] == 0) ? ((MStart == 0) ? InstrD[19:16] : InstrD[11:8]) : 15;
    assign RA2D = (RegSrcD[1] == 0) ? InstrD[3:0] : InstrD[15:12];
//    assign A3 = WA3W; // if MUL A3 = Instr[19:16]
    assign WD3 = ResultW;
    assign R15 = PCPlus8D;
    assign WE3 = RegWriteW;
    assign PCPlus8D = PCPlus4F;
    assign ALUOutM = ALUResultM;
   
    
    // pipeline registers datapath connection
    // F to D block
    always@(posedge CLK)
    begin
        if (RESET || FlushD) begin
            InstrD <= 0 ;
        end
        if (~StallD) begin
            InstrD <= InstrF;
        end
    end
    // D to E block
    always@(posedge CLK)
    begin 
        if(RESET || FlushE)
        begin
            InstrE <= 0;
            PCSE <= 0;
            RegWE <= 0;
            MemWE <= 0;
            FlagWE <= 0;
            ALUControlE <= 0;
            MemtoRegE <= 0;
            ALUSrcE <= 0;
            NoWriteE <= 0;
            ExtImmE <= 0;
            CondE <= 0;
            RD1E <= 0;
            RD2E <= 0;
            WA3E <= 0;
            RA1E <= 0;
            RA2E <= 0;
        end
        else 
        begin
            InstrE <= InstrD;
            PCSE <= PCSD;
            RegWE <= RegWD;
            MemWE <= MemWD;
            FlagWE <= FlagWD;
            ALUControlE <= ALUControlD;
            MemtoRegE <= MemtoRegD;
            ALUSrcE <= ALUSrcD;
            NoWriteE <= NoWriteD;
            ExtImmE <= ExtImmD;
            CondE <= CondD;
            RD1E <= RD1D;
            RD2E <= RD2D;
            WA3E <= InstrD[15:12];
            RA1E <= RA1D;
            RA2E <= RA2D;
        end
    end
    // E to M block 
    always@(posedge CLK)
    begin 
        if(RESET)
        begin
            PCSrcM <= 0;
            RegWriteM <= 0;
            MemWriteM <= 0;
            MemtoRegM <= 0;
            ALUResultM <= 0;
            WA3M <= 0;
            RA2M <= 0;
        end
        else 
        begin
            PCSrcM <= PCSrcE;
            RegWriteM <= RegWriteE;
            MemWriteM <= MemWriteE;
            MemtoRegM <= MemtoRegE;
            ALUResultM <= ALUResultE;
            WA3M <= WA3E;
            RA2M <= RA2E;
            NoWriteM <= NoWriteE;
        end
    end
    // M to W block
    always@(posedge CLK)
    begin
        if(RESET)
        begin
            PCSrcW <= 0;
            RegWriteW <= 0;
            MemtoRegW <= 0;
            ReadDataW <= 0;
            ALUOutW <= 0;
//            WA3W <= 0;
        end
        else 
        begin
            PCSrcW <= PCSrcM;
            RegWriteW <= RegWriteM;
            MemtoRegW <= MemtoRegM;
            ReadDataW <=ReadDataM;
            ALUOutW <= ALUOutM;
            WA3W <= WA3M;
            NoWriteW <= NoWriteM;
        end
        
    end
    
    // Data Hazard Block
    always @ (*) begin
        // Data Forwarding
        Match_1E_M = (RA1E == WA3M) ;
        Match_2E_M = (RA2E == WA3M) ;
        Match_1E_W = (RA1E == WA3W) ;
        Match_2E_W = (RA2E == WA3W) ;
        if (Match_1E_M == 1 && RegWriteM == 1) begin
            ForwardAE = 2'b10 ;
        end 
        else if (Match_1E_W == 1 && RegWriteW == 1) begin
            ForwardAE = 2'b01 ;
        end
        else begin
            ForwardAE = 2'b00 ;
        end
        if (Match_2E_M == 1 && RegWriteM == 1) begin
            ForwardBE = 2'b10 ;
        end 
        else if (Match_2E_W == 1 && RegWriteW == 1) begin
            ForwardBE = 2'b01 ;
        end
        else begin
            ForwardBE = 2'b00 ;
        end
//        ForwardAE = (Match_1E_M & RegWriteM) ? 2'b10 : (Match_1E_W & RegWriteW) ? 2'b01 : 2'b00 ;
//        ForwardBE = (Match_2E_M & RegWriteM) ? 2'b10 : (Match_2E_W & RegWriteW) ? 2'b01 : 2'b00 ;
        
        // Memory-Memory Copy
        ForwardM = (RA2M == WA3W) & MemWriteM & MemtoRegW & RegWriteW ;
        A3 = (ForwardM) ? RA2M : WA3W ; 
        
        // Stalling Circuitry
        if (RA1D == WA3E) begin
            Match_12D_E = 1 ;
        end
        else if (RA2D == WA3E) begin
            Match_12D_E = 1 ;
        end
        else begin
            Match_12D_E = 0 ;
        end
//        Match_12D_E = (RA1D == WA3E) || (RA2D == WA3E); // similanjiao why is this X when RA2D is X
        ldrstall = Match_12D_E & MemtoRegE & RegWriteE ;
        FlushE = ldrstall || PCSrcE ;
        FlushD = PCSrcE ;
        StallD = FlushE ;
        StallF = StallD ;
    end
    
    // Instantiate RegFile
    RegFile RegFile1( 
                    CLK,
                    WE3,
                    RA1D,
                    RA2D,
                    A3,
                    WD3,
                    R15,
                    NoWriteW,
                    RD1D,
                    RD2D,
                    bigRegBank    
                );
                
    assign InstrImm = InstrD[23:0];
                
     // Instantiate Extend Module
    Extend Extend1(
                    ImmSrcD,
                    InstrImm,
                    ExtImmD
                );
    
    assign Rd = ( MStart == 0) ? InstrD[15:12] : InstrD[19:16];
    assign Op = InstrD[27:26];
    assign Funct = InstrD[25:20];
    assign MChecker = InstrD[7:4];
    
    // Instantiate Decoder
    Decoder Decoder1(
                    Rd,
                    Op,
                    Funct,
                    MChecker,
                    PCSD,
                    RegWD,
                    MemWD,
                    MemtoRegD,
                    ALUSrcD,
                    ImmSrcD,
                    RegSrcD,
                    NoWriteD,
                    ALUControlD,
                    FlagWD,
                    MCycleOp,
                    MStart
                );
                
    assign CondD = InstrD[31:28];
                                
    // Instantiate CondLogic
    CondLogic CondLogic1(
                    CLK,
                    PCSE,
                    RegWE,
                    NoWriteE,
                    MemWE,
                    FlagWE,
                    CondE,
                    ALUFlags,
                    PCSrcE,
                    RegWriteE,
                    MemWriteE,
                    CarryE
                );
    
    assign Sh = InstrE[6:5];
    assign Shamt5 = InstrE[11:7];
    assign ShIn = RD2E;
                
    // Instantiate Shifter        
    Shifter Shifter1(
                    Sh,
                    Shamt5,
                    ShIn,
                    ShOut
                );

    assign Src_AE = (ForwardAE == 2'b00) ? RD1E : (ForwardAE == 2'b01) ? ResultW : ResultM;
    assign newShOut =  (ForwardBE == 2'b00) ? ShOut : (ForwardBE == 2'b01) ? ResultW : ResultM;
    assign Src_BE = (ALUSrcE == 0) ? newShOut : ExtImmE;
    
    // Instantiate ALU        
    ALU ALU1(
                    Src_AE,
                    Src_BE,
                    ALUControlE,
                    CarryE,
                    ALUResultE,
                    ALUFlags
                );                
    
//    assign PC_IN = !(StallF == 1) ? (PCSrcW == 1) ? ResultW : PCPlus4F : PC;
    assign PC_IN = (PCSrcW == 1) ? ResultW : PCPlus4F;
    // Instantiate ProgramCounter    
    ProgramCounter ProgramCounter1(
                    CLK,
                    RESET,
                    WE_PC,    
                    PC_IN,
                    Busy,
                    StallF,
                    PC  
                );
                
     assign WriteDataE = newShOut;
     assign ResultW = (MemtoRegW == 1) ? ReadDataW : ((MStart) ? Result1 : ALUOutW);
     assign ResultM = (MemtoRegM == 1) ? ReadDataM : ALUOutM ;
     
     // Instantiate MCycle
     MCycle MCycle( 
                    CLK, 
                    RESET, 
                    MStart, 
                    MCycleOp, 
                    RD2D, 
                    RD1D, 
                    Result1, 
                    Result2, 
                    Busy
        ) ;         
endmodule








