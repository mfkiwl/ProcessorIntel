;----------------------------------------------------------------------------------
;-- (c) Rajesh Panicker
;--	License terms :
;--	You are free to use this code as long as you
;--		(i) DO NOT post it on any public repository;
;--		(ii) use it only for educational purposes;
;--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
;--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
;--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
;--		(vi) retain this notice in this file or any files derived from this.
;----------------------------------------------------------------------------------

	AREA    MYCODE, CODE, READONLY, ALIGN=9 
   	  ENTRY
	  
; ------- <code memory (ROM mapped to Instruction Memory) begins>
; Total number of instructions should not exceed 127 (126 excluding the last line 'halt B halt').
; LOOP
	; LDR R6, ZERO ; R6 is 0 
	; LDR R7, SEVEN ; R7 is 7
	; LDR R4, TARGET ; pre-loads value of memory into R4 first, 0x00000804
	; STR R7, [R4, #4]
	; LDR R5, [R4, #4] ; R5 should now have the contents of R7, 7
	; LDR R7, SIX ; R7 is 6 now
	; STR R7, [R4, #-4]
	; LDR R12, [R4, #-4] ; R12 is 6
	; CMP R6, R7 ; N flag set
	; CMN R6, R7 ; No flags set
	; LDR R0, NINE ; R0 is 9
	; LDR R1, TEN ; R1 is A
	; AND R2, R0, R1 ; R2 will be 8, AND 1001 and 1010 > 1000
	; ORR R3, R0, R1; R3 will be B, OR 1001 and 1010 > 1011
	; ADD R1, #3 ; A + 3, R1 will be D
	; SUB R0, #3 ; 9 - 3, R0 will be 6
	; ORR R8, R6, R7, LSR #2 ; R8 will  be 1
	; ORR R9, R6, R7, LSL #2 ; R9 will be 18
	; ORR R10, R6, R7, ASR #2 ; R10 will be 1
	; ORR R11, R6, R7, ROR #2 ; R11 will be 0x80000001
	; B LOOP

	LDR R6, SIX ; R6 is 6
	LDR R5, FIVE; R5 is 5
	LDR R4, THREE; R4 is 3
	MUL R3, R4, R5; R3 will be 15
LOOP
	B LOOP



	AREA    CONSTANTS, DATA, READONLY, ALIGN=9 
; ------- <constant memory (ROM mapped to Data Memory) begins>
; All constants should be declared in this section. This section is read only (Only LDR, no STR).
; Total number of constants should not exceed 128 (124 excluding the 4 used for peripheral pointers).
; If a variable is accessed multiple times, it is better to store the address in a register and use it rather than load it repeatedly.

;Peripheral pointers
LEDS
		DCD 0x00000C00		; Address of LEDs. //volatile unsigned int * const LEDS = (unsigned int*)0x00000C00;  
DIPS
		DCD 0x00000C04		; Address of DIP switches. //volatile unsigned int * const DIPS = (unsigned int*)0x00000C04;
PBS
		DCD 0x00000C08		; Address of Push Buttons. Used only in Lab 2
CONSOLE
		DCD 0x00000C0C		; Address of UART. Used only in Lab 2 and later
CONSOLE_IN_valid
		DCD 0x00000C10		; Address of UART. Used only in Lab 2 and later
CONSOLE_OUT_ready
		DCD 0x00000C14		; Address of UART. Used only in Lab 2 and later
SEVENSEG
		DCD 0x00000C18		; Address of 7-Segment LEDs. Used only in Lab 2 and later

; Rest of the constants should be declared below.
ZERO
		DCD 0x00000000		; constant 0
THREE
		DCD 0x00000003		; constant 3
SEVEN
		DCD 0x00000007		; constant 7
SIX
		DCD 0x00000006		; constant 6
FIVE
		DCD 0x00000005		; constant 5
NINE
		DCD 0x00000009		; constant 9
TARGET
		DCD 0x00000804		; constant target
FIFTEEN
		DCD 0x0000000F		; constant 15
TEN
		DCD 0x0000000A		; constant 10
LSB_MASK
		DCD 0x000000FF		; constant 0xFF
DELAY_VAL
		DCD 0x00000002		; delay time.
variable1_addr
		DCD variable1		; address of variable1. Required since we are avoiding pseudo-instructions // unsigned int * const variable1_addr = &variable1;
constant1
		DCD 0xABCD1234		; // const unsigned int constant1 = 0xABCD1234;
string1   
		DCB  "\r\nWelcome to CG3207..\r\n",0	; // unsigned char string1[] = "Hello World!"; // assembler will issue a warning if the string size is not a multiple of 4, but the warning is safe to ignore
stringptr
		DCD string1			;
		
; ------- <constant memory (ROM mapped to Data Memory) ends>	


	AREA   VARIABLES, DATA, READWRITE, ALIGN=9
; ------- <variable memory (RAM mapped to Data Memory) begins>
; All variables should be declared in this section. This section is read-write.
; Total number of variables should not exceed 128. 
; No initialization possible in this region. In other words, you should write to a location before you can read from it (i.e., write to a location using STR before reading using LDR).

variable1
		DCD 0x00000000		;  // unsigned int variable1;
; ------- <variable memory (RAM mapped to Data Memory) ends>	

		END	
		
;const int* x;         // x is a non-constant pointer to constant data
;int const* x;         // x is a non-constant pointer to constant data 
;int*const x;          // x is a constant pointer to non-constant data
		