		;		ARM Programming Assignment #4: Count the ones in a binary number
		;
		;		Write a program that counts the number of ones in a binary number,
		;		stored in a word (4 bytes). Its loop should run no more times than there
		;		are ones in the number. Write the count in `numones`. For the example
		;		number given below, the loop should only run 8 times, counting 8 ones.
		;
		;		Hint:
		;		The first significant instruction in the loop is SUB r1, r1, 1, which
		;		decrements the number, assuming it's stored in register r1. Now,
		;		remember your logical operations.
		;
		;		Bonus:
		;		1. (20 extra points) For the shortest program (by instruction count),
		;		because this operation has to be FAST.
		;		2. (30 extra points) For extending the program to counting the ones
		;		in any word-aligned contiguous region of memory.
		
		;		Your code here
		
example	DCD		0xffff0000
numones	FILL		4
		mov		r3, #0		; counter for loop number of loop iterations is the numbr of set bits
		adr		r1, example	;load address for n
		ldr		r1, [r1]		;load n to r1
loop		sub		r2, r1, #1	;n - 1
		ands		r1, r2, r1	;toggles the least signifiacant set bit
		add		r3, r3, #1	;increment loop counter
		bne		loop			;branch to beginning of loop
		adr		r1, numones	;get address for numones
		str		r3, [r1]		;load result(number of set bits) to numones
		
