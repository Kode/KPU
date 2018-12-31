.data
satz1:
	.asciiz "Bewege Scheibe "
satz2:
	.asciiz " von "
satz3:
	.asciiz " nach "
satz4:
	.asciiz "\n"
.text
#int main() {
.globl main
main:

#hanoi(3, 1, 2, 3);
	addi $t0, $zero, 0xff00ffff
	addi $t1, $zero, 0x800000
	sw $t0, 30000($t1)

	addi $v0,$zero,5
	syscall
	addi $a0,$v0,0
	addi $a1,$zero,1
	addi $a2,$zero,2
	addi $a3,$zero,3
	jal hanoi
#

# }
hanoi:
	sw $a0, 0($sp)	#n
	sw $a1, 4($sp)	#Start
	sw $a2, 8($sp)	#Ziel
	sw $a3,12($sp)	#Extra
rekhan:
	sw $ra,16($sp)
	lw $t0, 0($sp)
	beq $t0,$zero,endhanoi
	
#hanoi(n - 1, Start, Extra, Ziel);
	#lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3,12($sp)
	addi $sp,$sp,20
	addi $t0,$t0,-1
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t3, 8($sp)
	sw $t2,12($sp)
	jal rekhan
#

#printf("Bewege Scheibe %i von %i nach %i\n", n, Start, Ziel);
	addi $v0,$zero,4
	la $a0,satz1
	syscall
	addi $v0,$zero,1
	lw $a0,0($sp)
	syscall
	addi $v0,$zero,4
	la $a0,satz2
	syscall
	addi $v0,$zero,1
	lw $a0,4($sp)
	syscall
	addi $v0,$zero,4
	la $a0,satz3
	syscall
	addi $v0,$zero,1
	lw $a0,8($sp)
	syscall
	addi $v0,$zero,4
	la $a0,satz4
	syscall
#

#hanoi(n - 1, Extra, Ziel, Start);
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3,12($sp)
	addi $sp,$sp,20
	addi $t0,$t0,-1
	sw $t0, 0($sp)
	sw $t3, 4($sp)
	sw $t2, 8($sp)
	sw $t1,12($sp)
	jal rekhan
#

endhanoi:
	#addi $sp,$sp,-20
	lw $ra,16($sp)
	addi $sp,$sp,-20
	jr $ra
# }

end:
