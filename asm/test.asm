	.data
	.align 0
quadrat:
	.byte 2,9,4
	.byte 7,5,3
	.byte 6,1,8		#int Quadrat[] = {2, 9, 4, 7, 5, 3, 6, 1, 8};
n:
	.byte 3			#int n = 3;

	.text
	.globl main
main:
	lbu $s2,n($zero)
	addi $s0,$zero,1	#int s0 = 1;
				#int s1, t0, t1, t2, t3, t4;

				#/*links nach rechts*/
	addi $s1,$zero,0	#s1 = 0;
	addi $t1,$zero,0	#t1 = 0;
magieinit:
	lbu $t3,quadrat($t1)	#t3 = Quadrat[t1];
	add $s1,$s1,$t3		#s1 = s1 + t3;
	addi $t1,$t1,1		#t1 = t1 + 1;
	slt $t5,$t1,$s2		#if (t1 < n)
	beq $t5,$zero,endmagieinit
	j magieinit		#goto magieinit;
endmagieinit:

	addi $t1,$zero,1	#t1 = 1;
lnr1:
	addi $t0,$zero,0	#t0 = 0;
	addi $t2,$zero,0	#t2 = 0;
lnr2:
	addi $t4,$zero,0
	addi $t6,$zero,0
mult1:
	add $t4,$t4,$t1		#t4 = n * t1;
	addi $t6,$t6,1
	bne $t6,$s2,mult1
	
	add $t4,$t4,$t2		#t4 = t4 + t2;
	lbu $t3,quadrat($t4)	#t3 = Quadrat[t4];
	add $t0,$t0,$t3		#t0 = t0 + t3;
	addi $t2,$t2,1		#t2 = t2 + 1;
	slt $t5,$t2,$s2		#if (t2 < n)
	beq $t5,$zero,endlnr2
	j lnr2			#goto lnr2;
endlnr2:				
	beq $s1,$t0,bne1	#if (s1 != t0) {
	addi $s0,$zero,0	#s0 = 0;
	j end			#goto end;
bne1:				#}
	addi $t1,$t1,1		#t1 = t1 + 1;
	slt $t5,$t1,$s2		#if (t1 < n)
	beq $t5,$zero,endlnr1
	j lnr1			#goto lnr1;
endlnr1:

				#/*oben nach unten*/
	addi $t1,$zero,0	#t1 = 0;
onu1:
	addi $t0,$zero,0	#t0 = 0;
	addi $t2,$zero,0	#t2 = 0;

onu2:
	addi $t4,$zero,0
	addi $t6,$zero,0
mult2:
	add $t4,$t4,$t2		#t4 = t2 * n;
	addi $t6,$t6,1
	bne $t6,$s2,mult2
	
	add $t4,$t4,$t1		#t4 = t4 + t1;
	lbu $t3,quadrat($t4)	#t3 = Quadrat[t4];
	add $t0,$t0,$t3		#t0 = t0 + t3;
	addi $t2,$t2,1		#t2 = t2 + 1;
	slt $t5,$t2,$s2		#if (t2 < n)
	beq $t5,$zero,endonu2
	j onu2			#goto onu2;
endonu2:
		
	beq $s1,$t0,bne2	#if (s1 != t0) {
	addi $s0,$zero,0	#s0 = 0;
	j end			#goto end;
bne2:				#}
	addi $t1,$t1,1		#t1 = t1 + 1;
	slt $t5,$t1,$s2		#if (t1 < n)
	beq $t5,$zero,endonu1
	j onu1			#goto onu1;
endonu1:

				#/*links-oben nach rechts-unten*/
	addi $t0,$zero,0	#t0 = 0;
	addi $t1,$zero,0	#t1 = 0;
lonru:
	addi $t4,$zero,0
	addi $t6,$zero,0
mult3:
	add $t4,$t4,$t1		#t4 = n * t1;
	addi $t6,$t6,1
	bne $t6,$s2,mult3
	
	add $t4,$t4,$t1		#t4 = t4 + t1;
	lbu $t3,quadrat($t4)	#t3 = Quadrat[t4];
	add $t0,$t0,$t3		#t0 = t0 + t3;
	addi $t1,$t1,1		#t1 = t1 + 1;
	slt $t5,$t1,$s2		#if (t1 < n)
	beq $t5,$zero,endlonru
	j lonru			#goto lonru;
endlonru:

	beq $s1,$t0,bne3	#if (s1 != t0) {
	addi $s0,$zero,0	#s0 = 0;
	j end			#goto end;
bne3:				#}

				#/*links-unten nach rechts-oben*/
	addi $t0,$zero,0	#t0 = 0;
	addi $t1,$zero,1	#t1 = 1;
lunro:
	addi $t4,$zero,0
	addi $t6,$zero,0
mult4:
	add $t4,$t4,$t1		#t4 = n * t1;
	addi $t6,$t6,1
	bne $t6,$s2,mult4
	
	sub $t4,$t4,$t1		#t4 = t4 - t1;
	lbu $t3,quadrat($t4)	#t3 = Quadrat[t4];
	add $t0,$t0,$t3		#t0 = t0 + t3;
	addi $t1,$t1,1		#t1 = t1 + 1;
	addi $t6,$s2,1
	slt $t5,$t1,$t6		#if (t1 <= n)
	beq $t5,$zero,endlunro
	j lunro			#goto lunro;
endlunro:
	
	beq $s1,$t0,bne4	#if (s1 != t0) {
	addi $s0,$zero,0	#s0 = 0;
	j end			#goto end;
bne4:				#}

	addi $s0,$s1,0		#s0 = s1;

end:
	jr $ra