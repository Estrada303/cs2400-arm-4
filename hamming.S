		;		ARM Programming Assignment #4: Encode in Hamming(15, 11)
		;
		;		x-Write a subroutine that encodes 11 bits of data into a 15-bit
		;		block, using 4 parity bits. Assume even parity, that is,
		;		the parity of the bits covered by a parity bit, including
		;		the parity bit, has to be an even number. Assume the bits are
		;		written in the following sequence: p1, p2, d1, p4, d2, d3, d4,
		;		p8, d5, d6, d7, d8, d9, d10, d11, p16, d12, d13, d14, d15.
		;		Call the subroutine `hencode`.
		;
		;		Write a subroutine that decodes a H(15, 11) block to extract
		;		the 11 data bits. Call it `hdecode`. It should:
		;		x- calculate the correcting code
		;		x- dentify the case: no error (noer), one-bit error (onee)
		;		x- write the result in `case` using the encoding provided
		;		x- if there is a one-bit error, write the number of the
		;		erroneous bit in `berr`
		;		x- if there is a one-bit error, correct the data
		;		x- write the result in `corr`
		;
		;		x-Now, write a main function which uses `hencode` and `decode`
		;		to encode `data` and then, after a simulated transmission,
		;		decode `recv`. Assume that `recv` contains what is received
		;		at the other end.
		
		;		Your code here
		
data		DCD		0b10100100101
recv		DCD		0b101111010100101
		
noer		DCD		0x00
onee		DCD		0x01
		
case		FILL		4
berr		FILL		4
corr		FILL		4
main		adr		r1, data
		ldr		r0, [r1]
		bl		hencode
		;tranmit..........
		;..........recieving
		adr		r1, recv
		ldr		r1, [r1]
		bl		decode
		end
		
		
		
		
		
		
		
decode
		;store	needed registers to stack
		str		r1, [sp, #-4]!
		str		r2, [sp, #-4]!
		str		r3, [sp, #-4]!
		str		r4, [sp, #-4]!
		str		r1, [sp, #-4]! ;;needed to balence out stack use
		mov		r0,  #0b001011100000000
		orr		r0, r0, #0b1111111
		and		r0, r0, r1
		str		r1, [sp, #-4]! ;;saved to manage correct stack postions
		str		r2, [sp, #-4]! ;;for call to prodeuce a ham code form tranmited data
		mov		r1, r0
		mov		r4, lr ;save lr to beable to retuen to main when finished
		bl		hen2
		ldr		r1, [sp], #4
		cmp		r1, r0
		beq		crct ;compare and branch if the tranmited code met even parity
		adr		r2, onee
		str		r1, [r2]
		;check	for correct parity bit
		;if		parity is not met the bit is added to
		;a		register that is used to show position of bad bit r3. (p4,p3,p2,p1)
		mov		r0, #0b101010100000000 ;mask and check for p1
		orr		r0, r0, #0b1010101
		and		r0, r0, r1
		mov		r2, #0
loop		lsrs		r0, r0, #1
		adc		r2, r2, #0
		bne		loop
		and		r3, r2, #1
		mov		r0, #0b011001100000000 ;mask and check for p2
		orr		r0, r0, #0b0110011
		and		r0, r0, r1
		mov		r2, #0
loop2	lsrs		r0, r0, #1
		adc		r2, r2, #0
		bne		loop2
		and		r2, r2, #1
		lsl		r2, r2, #1
		orr		r3, r2, r3
		mov		r0, #0b000111100000000 ;mask and check for p3
		orr		r0, r0, #0b0001111
		and		r0, r0, r1
		mov		r2, #0
loop3	lsrs		r0, r0, #1
		adc		r2, r2, #0
		bne		loop3
		and		r2, r2, #1
		lsl		r2, r2, #2
		orr		r3, r2, r3
		mov		r0, #0b000000011111111 ;mask and check for p4
		and		r0, r0, r1
		mov		r2, #0
loop4	lsrs		r0, r0, #1
		adc		r2, r2, #0
		bne		loop4
		and		r2, r2, #1
		lsl		r2, r2, #3
		orr		r3, r2, r3
		adr		r2, berr
		str		r3, [r2] ;store position of bad parity bit
		;;starts	to shift out the mask for bad bit by decrementing the position every shift right
		subs		r3, r3, #1
		mov		r0, #0b100000000000000
loop5	lsrne	r0, r0, #1
		subsne	r3, r3, #1
		
		bne		loop5
		;correct	bad bit and reformat to original data only format
		eor		r0, r0, r1
		and		r1, r0, #0b000000001111111
		and		r2, r0, #0b000011100000000
		orr		r1, r1, r2, lsr #1
		and		r2, r0, #0b001000000000000
		orr		r1, r1, r2, lsr #2
		adr		r2, corr
		str		r1, [r2]
		mov		r0, r1
		mov		lr, r4 ;move address to lr get back to main
		ldr		r4, [sp], #4
		ldr		r3, [sp], #4
		ldr		r2, [sp], #4
		ldr		r1, [sp], #4
		mov		pc, lr
		
		
crct
		adr		r2, noer
		str		r1, [r2]
		mov		lr, r4
		mov		pc, lr
hencode
		str		r1, [sp, #-4]!
		str		r2, [sp, #-4]!
		;expand	to make room for parity bits
		mov		r1, #0
		and		r2, r0, #0b00001111111
		mov		r1, r2
		and		r2, r0, #0b01110000000
		add		r1, r1, r2, lsl #1
		and		r2, r0, #0b10000000000
		add		r1, r1, r2, lsl #2
		;parity	tree
hen2		;parity	bit 1
		eor		r2, r1, r1, lsl #2
		eor		r2, r2, r2, lsl #4
		eor		r2, r2, r2, lsl #8
		and		r2, r2, #0b100000000000000
		orr		r1, r1, r2
		;parity	bit 2
		eor		r2, r1, r1, lsl #1
		eor		r2, r2, r2, lsl #4
		eor		r2, r2, r2, lsl #8
		and		r2, r2, #0b010000000000000
		orr		r1, r1, r2
		;parity	bit 3
		eor		r2, r1, r1, lsl #1
		eor		r2, r2, r2, lsl #2
		eor		r2, r2, r2, lsl #8
		and		r2, r2, #0b000100000000000
		orr		r1, r1, r2
		;parity	bit 4
		eor		r2, r1, r1, lsl #1
		eor		r2, r2, r2, lsl #2
		eor		r2, r2, r2, lsl #4
		and		r2, r2, #0b000000010000000
		orr		r1, r1, r2
		mov		r0, r1
		ldr		r2, [sp], #4
		ldr		r1, [sp], #4
		mov		pc, lr
		
