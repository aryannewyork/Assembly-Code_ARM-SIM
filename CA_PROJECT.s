.section .data
num: .word 1431686349,10,4,3				@ This is where the input numbers are stored, num1 = 1431686349, num2 = 10 and rest 4 and 3 are dummy values, which will be overwritten by the program to store the Addition and Product respectively.
bias: .word 16383										@ Given Bias, as per question


LastBitZero1:												@ This label is specifically for r4IsLess label
LSL r3,#2														@ RENORMALIZATION STEP: "xy.Mantissa" is of the form "01.Mantissa" thus the FINAL RESULTANT Mantissa will be "Mantissa" removing "01"
LSR r3,#16													@ Now all the compuation for additon is done, so putting together the SIGN BIT, EXPONENT AND MANTISSA to obtain the RESULTANT
																		@ Shifting the Mantissa resultant to right by 16 bit, so mantissa is of the form "0000 0000 0000 0000 MANTISSA"
LSL r5,#16													@ Shifting the exponent to left, so it is of the form "0 EXPONENT 0000 0000 0000 0000"
LSL r9,#31													@ Shifting the sign bit to left, so it is of the form "SIGN-BIT 000 0000 0000 0000 0000 0000 0000 0000"
ADD r9,r9,r5												@ "SIGN-BIT 000 0000 0000 0000 0000 0000 0000 0000" + "0 EXPONENT 0000 0000 0000 0000" = "SIGN-BIT EXPONENT 0000 0000 0000 0000"
ADD r9,r3														@ "SIGN-BIT EXPONENT 0000 0000 0000 0000" + "0000 0000 0000 0000 MANTISSA" = "SIGN-BIT EXPONENT MANTISSA" (RESULTANT)
str r9,[r1]													@ Putting the resultant in memory address stored by r1. The resultant is in r9, but it needs to be moved to the memory location, as 								  per question requirement.
b Finish11													@ To maintain the flow of execution, returning back to r4IsLess label ending.

LastBitOne1:												@ This label is specifically for r4IsLess label
LSL r3,#1
LSR r3,#16
LSL r5,#16
LSL r9,#31
ADD r9,r9,r5
ADD r9,r3
str r9,[r1]
b Finish12

LastBitZero2:												@ This label is specifically for r4IsGreaterOrEqual label
LSL r3,#2
LSR r3,#16
LSL r5,#16
LSL r9,#31
ADD r9,r9,r5
ADD r9,r3
str r9,[r1]
b Finish21

LastBitOne2:												@ This label is specifically for r4IsGreaterOrEqual label
LSL r3,#1
LSR r3,#16
LSL r5,#16
LSL r9,#31
ADD r9,r9,r5
ADD r9,r3
str r9,[r1]
b Finish22

r4IsGreaterOrEqual:				          @ Similar to r4IsLess label
sub r6,r4,r5
LSR r3,r6
ADD r3,r3,r2
ADD r5,r5,r6
mov r0,r3 
LSR r0,#31
AND r0,#1
cmp r0,#1
bne LastBitZero2
Finish21:
cmp r0,#1
beq LastBitOne2
Finish22:
b Finish

r4IsLess:
sub r6,r5,r4											@ since r4 < r5 thus r4 needs to be increased by r5-r4, and accordingly the manitissa needs to be adjusted
LSR r2,r6													@ Adjusting the "01.mantissa", so decimal places align properly before addtion is performed, after equalizing exponents
ADD r3,r3,r2											@ Now since the two "01.mantissa1" and "01.mantissa2" are properly aligned, with equal exponents, they is simply added to obtain the 								@ Final Resultant "xy.Mantissa" xy can be anything 01, 10, 11, BUT NOT 00, it can be checked by simple analysis of additons
ADD r4,r4,r6											@ REDUNDANT STEP, here we are simply equalizing the exponents in-reality, so r4 becomes equal to r5
mov r0,r3            							@ Making copy of the RESULTANT "xy.Mantissa", this copy will be needed in renormalization
LSR r0,#31												@ Obatining the "x" bit of the "xy.Mantissa" to see what kind of renormalisation is required
AND r0,#1
cmp r0,#1													@ If the "x" bit is "1" then simply, "1y.Mantissa" will be renormalized to "1.yMantissa"
bne LastBitZero1									@ Branching to LastBitZero1 if "x" bit is "0" 
Finish11:													@ After completion of LastBitZero1 function(label), branching to here to maintatin the flow of the execution
cmp r0,#1
beq LastBitOne1										@ Branching to LastBitOne1 if "x" bit is "1"
Finish12:													@ After completion of LastBitOne1 function(label), branching to here to maintatin the flow of the execution
b Finish													@ FINALLY FINISHING THE COMPUATION OF ADDITON, AFTER THIS BRANCH, MULTIPLICATION WILL START


lpfpAdd:							
stmfd sp!,{r2-r9,lr}						  @ Addtion starts from here

LDMIA r1,{r2-r3}									@ Loading the 2 input numbers in r2 and r3 respectively, from memory address already loaded in r1
mov r4,r2													@ Making copies of number r2 and r3 in r4 and r5 respectively
mov r5,r3
LSR r4,#31												@ Shifting the number 31 bits to the right to isolate/obtain the sign bit
LSR r5,#31												@ Now, r4 and r5 contain the sign bit of first and second number resp
cmp r4,r5													@ Comapring the sign bits of both numbers, if they are same
beq signbitgen										@ If sign bits are same then branching off to, obtain the sign bit of the RESULTANT

signbitgen:
add r1, r1, #8										@ Advancing the memory adress stored in r1 by 8x8 = 64bits, this is where the RESULTANT will be stored, as per question
mov r9,r4													@ r9 has the FINAL SIGN BIT OF THE RESULTANT

SameSignAdd:											@ Performing the actual additon of the 2 numbers, i.e, obtaining the Mantissa and exponent of the RESULTANT
stmfd sp!, {r4-r8,lr}							@ r1 has the memory address of where the resultant will be, r2 and r3 contain the actual numbers and r9 has the sign bit, thus stmfd 								@ sp!, {r4-r8, lr) and NOT {r1-r9}, because then we wouldn't be able to use what is in r2, r3, r1, and r9.
mov r4,r2													@ Again making copies of the original imput numbers, in r4 and r5 respectively, to perform further computation
mov r5,r3
LSL r4,#1													@ Left shifting by 1, to eliminate the sign bit of the input number
LSR r4,#17         								@ Right shifting by 17 bits to eliminate the Mantissa of the input number, to isolate/obtain ONLY the exponent of the imput numbers
LSL r5,#1
LSR r5,#17         								@ Now r4 and r5 have the Exponents of r2 and r1 respectively
LSL r2,#16												@ Now agin, shifting the original number to the left by 16 bits to obtain the MANTISSA-ONLY of the input numbers
LSR r2,#2          								@ Mantissa is now  to the right by 2 bits to prepare it to be added, i.e, "00.Mantissa" is the form of numbers to be added
ADD r2,r2,#1073741824							@ Now the 2nd MSB will be changed to 1, by the additon of 01000000.....32 zeros, thus changing the "Mantissa" to "01.Mantissa"
LSL r3,#16
LSR r3,#2													@ r2 is 01.Mantissa1 and r3 is 01.Mantissa2, now they can be added.
ADD r3,r3,#1073741824
cmp r4,r5													@ Now, comparing the exponents, if unequal then needs to be equalized before final additon
BLT r4IsLess											@ Branching to r4IsLess label, which will further continue the computation, if r4 < r5 
cmp r4,r5													@ If r4IsLess is not executed then certainly r4IsGreaterOrEqual will be, which has a similar functionaing as of r4IsLess
BGE r4IsGreaterOrEqual

Finish:
b Back
@ we removed "ldmfd", and instead added "b Back" to return the flow of the program to "_start:" block with MULTIPLICATION happening right after that 

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ MULTIPLICATION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

MulBit01:
LSR r7,#16
add r9,r9,r4
add r9,r9,r7
b FinishMul						 						@ Here the MULTIPLICATION IS FINISHED

lpfpMultiply:						 					@ MULTIPLICATION STARTS HERE
@stmfd sp!,{r2-r9,lr}					 		@ This was NOT WORKING THUS COMMENTED
ldr r1,=num						 						@ Loading the address of input numbers
ldmia r1,{r2,r3}					 				@ loading the 2 input numbers into r2 and r3 respectively
mov r4,r2						 							@ copying the numbers into r4 and r5 respectively
mov r5,r3
LSR r4,#31												@ Obtaining the sign bit of the input numbers, r4 and r5 have ONLY the sign bits of inputs respectively.
LSR r5,#31
EOR r9,r5,r4											@ To obtain the Final RESULTANT Sign-bit, RESULTANT DIGN-BIT = sign-bit1 XOR sign-bit2
LSL r9,#31						 						@ Shifting the sign bit of RESULTANT to make it in the form, "SIGN-BIT 000 0000 0000 0000 0000 0000 0000 0000"
mov r4,r2						 							@ Making copy of input numbers into r4 and r5 respectively to perform further computation
mov r5,r3
LSL r4,#1						 							@ Shifting to the left by 1 bit to eliminate the sign bit from the number
LSR r4,#17						 						@ Shifting the number to the right by 17 bits to eliminate the mantissa to obtain pure-exponent bits only, i.e, of 15 bits
LSL r5,#1
LSR r5,#17
add r4,r4,r5						 					@ Adding the exponents together to obatin the resultant exponent, of the form, "Ea + Eb + 2*bias"
ldr r8,=bias	
ldr r7,[r8]
sub r4,r7						 							@ Subtracting the bias from the resultant exponent to obtain the finally-properly adjusted exponent of the form, "Ea + Eb + bias"
							 										@ After subtraction the exponent is of the form, ".... .... .... .... . EXPONENT" ("." depends on sign of the resultant exponent)
LSL r4,#17						 						@ Shifting the exponent to left, so it is of the form "EXPONENT 0000 0000 0000 0000"
LSR r4,#1						 							@ Shifting the exponent to right by 1 bit, so it is of the form "0 EXPONENT 0000 0000 0000 0000"

LSL r2,#16						 						@ Left shifting the input numbers, so as to eliminate the exponent
LSR r2,#1						 							@ Right shifting by 1 to eliminate the Sign-bit and obtain the pure-Mantissa
add r2,#2147483648					 			@ Changing the MSB to 1, so that the numbers are ready to be multiplied, now the number is of the form, "1.Mantissa"
LSR r2,#15						 						@ Shifitng the number"1.Mantissa" to right by 15 bit to prepare it for multiplication
LSL r3,#16
LSR r3,#1
add r3,#2147483648
LSR r3,#15
UMULL r7,r6,r3,r2       				  @ Multiplying "1.Mantissa1" * "1.Mantissa2", each of 17 bit to obtain the result of 34 bits which is stored in r6 and r7, r6 has MSB
cmp r6,#1						 							@ When multiplying 2, 17 bit numbers the result might be of 33 or 34 bits thus, resultant will be of the form, either, 							   		   @ "01.Something" or "1x.Something" depending upon which, renormalization has to take place. So if the result starts with "01" then
							   									@ simply "Something" will be the FINAL RESULTANT MANTISSA, but in "1x" starting, renormalization has to take place, and the new 								   @ mantissa will be "xSomething" (decimal is shifted 1 bit to the left).
							 										@>Since Resultant multiplication will be of 33 or 34 bits thus, r7 will contain the 32 bits and r6 will contain the 2 MSBs or 1 MSB
							 										@>If the resultant is 33 bits long then, r6 will simply be of the form "0000 0000 0000 0000 0000 0000 0000 0001" (essentially, "1")
							 										@>If the resultant is 34 bits long then, r6 will simply be of the form "0000 0000 0000 0000 0000 0000 0000 001x"
beq MulBit01						 					@ After the comparison of r6 and 1, if they are equal then certainly the resultant is of, 33 bit, and the resultant has to be 									  truncated in a certain way, described above. Branching to MulBit01

                                  @> HERE THE FLOW WILL REACH ONLY IF THE MulBit01 label is not reached, i.e, MSB is of "1x" form
LSL r6,#31						 						@ Combining the split multiplication result here; Shifting the MSB stored in r6 in left so it is of the form "1000 0000 0000 0000 								   0000 0000 0000 0000"
LSR r7,#1						 							@ shifting the other 32 bits stored in r7 by 1 bit to make space for MSB from r6
add r6,r6,r7						 					@ "SIGN-BIT 000 0000 0000 0000 0000 0000 0000 0000" + "0 xxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx" = "SIGN-BIT xxx xxxx xxxx xxxx xxxx 							    xxxx xxxx xxxx"
LSR r6,#15						 						@ Since we only need the 16 most significant bits of the mantissa so we would truncate our 16 LSBs, stored in r6
add r9,r9,r6						 					@ r9 had the sign bit; "1000 0000 0000 0000 0000 0000 0000 0000" + "0000 0000 0000 0000 1xxx xxxx xxxx xxxx"
add r9,r9,r4						 					@ Finally inserting the calculated exponent to obtain the final RESULTANT MULTIPLICATION NUMBER;
							 										@ "SIGN-BIT 000 0000 0000 0000 1xxx xxxx xxxx xxxx" + 0 EXPONENT 0000 0000 0000 0000" = "SIGN-BIT EXPONENT 1xxx xxxx xxxx xxxx" (r9)


FinishMul:						 						@ Finally the Multiplication is finished
add r1,r1,#12						 					@ Here we are only shifting the RESULTANT int memory pointed by r1, (r1 + 12*8 = r1 + 96 bits is done because first 12 byted are 								 @ occupied by num1, num2, and additon respectively, each taking up 4 bytes (i.e, 32 bits)
str r9,[r1]						 						@ Multiplication result is finally stored into memory pointed by r1, as per question
ldmfd sp!,{r2-r9,pc}					 		@ Restoring all the registers as per question, except r1, of course because that contains the memory address of the resultants.



_start:
ldr r1,=num												@ Loading the address of stored numbers in r1
b lpfpAdd													@ Branching to ADDITION Function(label)
Back:															@ Using a label to return BACK here after ADDITION has already been implemented
b lpfpMultiply										@ Branching to MULTIPLICATION Function(label)
							