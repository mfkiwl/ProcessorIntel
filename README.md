For lab 2 we added in basic instruction processing functionality, including
LDR, STR with positive immediate offset
AND, OR, ADD, SUB where Src2 is register or immediate without shifts
B
CMP and CMN instructions
LDR, STR to support negative immediate offset
Src2 for DP instructions support register with immediate shifts (LSL, LSR, ASR, ROR)

as required of us to complete this lab session.

We used the following assembly code to test it out:
```
LOOP
	LDR R6, ZERO ; R6 is 0 
	LDR R7, SEVEN ; R7 is 7
	LDR R4, TARGET ; pre-loads value of memory into R4 first, 0x00000804
	STR R7, [R4, #4]
	LDR R5, [R4, #4] ; R5 should now have the contents of R7, 7
	LDR R7, SIX ; R7 is 6 now
	STR R7, [R4, #-4]
	LDR R12, [R4, #-4] ; R12 is 6
	CMP R6, R7 ; N flag set
	CMN R6, R7 ; No flags set
	LDR R0, NINE ; R0 is 9
	LDR R1, TEN ; R1 is A
	AND R2, R0, R1 ; R2 will be 8, AND 1001 and 1010 > 1000
	ORR R3, R0, R1; R3 will be B, OR 1001 and 1010 > 1011
	ADD R1, #3 ; A + 3, R1 will be D
	SUB R0, #3 ; 9 - 3, R0 will be 6
	ORR R8, R6, R7, LSR #2 ; R8 will  be 1
	ORR R9, R6, R7, LSL #2 ; R9 will be 18
	ORR R10, R6, R7, ASR #2 ; R10 will be 1
	ORR R11, R6, R7, ROR #2 ; R11 will be 0x80000001
	B LOOP
```
as well as using the hardware components of the FPGA to test the correctness of our project.
We implemented the usage of the 7-segment display, along with the DIP switches to display the contents of
the registers within the register bank, with each DIP switch corresponding to the register of the same value.
A DIP switch activated at position 5 (starting from 0) would cause the contents of register 5 to be 
displayed on the 7-segment display at the next clock cycle.
This was done through modifying Wrapper.V to pass the DIP instructions to the 7-segment module, as well as 
passing the values in the regbank in the RegFile back to Wrapper as a single array.
The LEDs were also configured by default to display the current program counter, with the front 6 bits being 
displayed on the last 6 LEDs on the FPGA.

The functions were added by modifying the CondLogic, Decoder and ARM files, according to how the flags would 
be set in a real ARM processor. 
