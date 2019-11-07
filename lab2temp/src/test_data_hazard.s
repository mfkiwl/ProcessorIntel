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
	LDR R10, TARGET 
	LDR R1, ONE;
	STR R1, [R10]
	LDR R2, TWO;
	LDR R5, BIGNUM1;
	LDR R6, BIGNUM2;
	CMN R5, R6;
	ADD R7, R1, R2 ;R7 should be 3
	AND R8, R7, R2 ; R8 should be 2
	LDR R5, FIFTEEN;
	LDR R6, TEN;
LOOP
	SUB R5, R5, #1;
	TEQ R5, R6;
	BNE LOOP;
	LDR R5, BIGNUM1;
	LDR R6, BIGNUM2;
	LDR R1, ONE;
	LDR R2, TWO;
LOOP2
	B LOOP2;


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
ONE
		DCD 0x00000001		; constant 1
TWO
		DCD 0x00000002		; constant 2
THREE
		DCD 0x00000003		; constant 3
FOUR
		DCD 0x00000004		; constant 4
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
BIGNUM1
		DCD 0x8000000F		; constant 2147483663
BIGNUM2
		DCD 0x81000004		; constant 2164260868
BIGNUM3
		DCD 0x00008010		; constant 32784
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
		