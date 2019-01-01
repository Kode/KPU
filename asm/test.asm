	.data		# Datensegment
_mess:	.asciiz	"-tes MIPS-Programm beendet.\n"
	.align	2

_pc1:	.space	4	# pc des 1. Programmes
_reg1:	.space	128	# Register des 1. Prgs
_stack1:.space	1024	# Stack des 1. Prgs

_pc2:	.space	4	# pc des 2. Programmes
_reg2:	.space	128	# Register des 2. Prgs
_stack2:.space	1024	# Stack des 2. Prgs

_pc3:	.space	4	# pc des 3. Programmes
_reg3:	.space	128	# Register des 3. Prgs
_stack3:.space	1024	# Stack des 3. Prgs

_pc4:	.space	4	# pc des 4. Programmes
_reg4:	.space	128	# Register des 4. Prgs
_stack4:.space	1024	# Stack des 4. Prgs

	.text		# Textsegment
main:

#1. Initialisierungsphase

	#Initialisierung von Register und Stack
	addi	$t3,$zero,0	#Nummer des momentan zu initialisierenden Speicherbereiches
	addi	$t4,$zero,8	#Anzahl der zu initialisierenden Speicherbereiche
initstart:			#switch($t3)
	beq	$t3,$zero,reg1	#case 0:
	addi	$t5,$zero,1	#1:
	beq	$t3,$t5,reg2
	addi	$t5,$zero,2	#2:
	beq	$t3,$t5,reg3
	addi	$t5,$zero,3	#3:
	beq	$t3,$t5,reg4
	addi	$t5,$zero,4	#4:
	beq	$t3,$t5,stack1
	addi	$t5,$zero,5	#5:
	beq	$t3,$t5,stack2
	addi	$t5,$zero,6	#6:
	beq	$t3,$t5,stack3
	addi	$t5,$zero,7	#7
	beq	$t3,$t5,stack4
reg1:
	la	$t0,_reg1
	j	regs
reg2:
	la	$t0,_reg2
	j	regs
reg3:
	la	$t0,_reg3
	j	regs
reg4:
	la	$t0,_reg4
regs:
	addi	$t1,$t0,128	#Groesse des Speicherbereiches
	j	initfor
stack1:
	la	$t0,_stack1
	j	stacks
stack2:
	la	$t0,_stack2
	j	stacks
stack3:
	la	$t0,_stack3
	j	stacks
stack4:
	la	$t0,_stack4
stacks:
	addi	$t1,$t0,1024	#Groesse des Speicherbereiches
initfor:			#Schleife, die in den gesamten Speicherbereich Nuller schreibt
	sw	$zero,0($t0)
	addi	$t0,$t0,4
	slt	$t2,$t0,$t1
	bne	$t2,$zero,initfor
	
	addi	$t3,$t3,1	#Naechsten Speicherbereich waehlen und nochmal
	slt	$t2,$t3,$t4
	bne	$t2,$zero,initstart
	
	#Initialisierung der pc
	la	$t0,main1	#1
	la	$t1,_pc1
	sw	$t0,0($t1)
	la	$t0,main2	#2
	la	$t1,_pc2
	sw	$t0,0($t1)
	la	$t0,main3	#3
	la	$t1,_pc3
	sw	$t0,0($t1)
	la	$t0,main4	#4
	la	$t1,_pc4
	sw	$t0,0($t1)
	
	#Initialisierung der Stack Pointer
	la	$t0,_stack1	#1
	addi	$t0,$t0,1024
	la	$t1,_reg1
	sw	$t0,116($t1)
	la	$t0,_stack2	#2
	addi	$t0,$t0,1024
	la	$t1,_reg2
	sw	$t0,116($t1)
	la	$t0,_stack3	#3
	addi	$t0,$t0,1024
	la	$t1,_reg3
	sw	$t0,116($t1)
	la	$t0,_stack4	#4
	addi	$t0,$t0,1024
	la	$t1,_reg4
	sw	$t0,116($t1)
	
	addi	$s4,$zero,1	#s4 = aktuelles Programm
	addi	$s5,$zero,15	#s5 = noch laufende Programme
#2. Laden und Dekodieren einer Instruktion
emu:
	#Programm switch
	addi	$t0,$zero,1	#1
	beq	$t0,$s4,prog1
	addi	$t0,$zero,2	#2
	beq	$t0,$s4,prog2
	addi	$t0,$zero,3	#3
	beq	$t0,$s4,prog3	
	addi	$t0,$zero,4	#4
	beq	$t0,$s4,prog4

	#s0 = Pointer auf den aktuellen pc
	#s1 = Pointer auf die aktuellen Register
	#s2 = Pointer auf den aktuellen Stack

prog1:
	andi	$t0,$s5,0x8	#Prüfung, ob das Programm noch läuft	
	beq	$t0,$zero,einsaus
	la	$s0,_pc1	#Initialisierung der Pointer fuer das Programm
	la	$s1,_reg1
	la	$s2,_stack1
	j	start
einsaus:
	addi	$s4,$zero,2	#Falls das aktuelle Programm nicht mehr laeuft, das naechste nehmen
prog2:
	andi	$t0,$s5,0x4	#Prüfung, ob das Programm noch läuft
	beq	$t0,$zero,zweiaus
	la	$s0,_pc2	#Initialisierung der Pointer fuer das Programm
	la	$s1,_reg2
	la	$s2,_stack2
	j	start
zweiaus:
	addi	$s4,$zero,3	#Falls das aktuelle Programm nicht mehr laeuft, das naechste nehmen
prog3:
	andi	$t0,$s5,0x2	#Prüfung, ob das Programm noch läuft
	beq	$t0,$zero,dreiaus
	la	$s0,_pc3	#Initialisierung der Pointer fuer das Programm
	la	$s1,_reg3
	la	$s2,_stack3
	j	start
dreiaus:
	addi	$s4,$zero,4	#Falls das aktuelle Programm nicht mehr laeuft, das naechste nehmen
prog4:
	andi	$t0,$s5,0x1	#Prüfung, ob das Programm noch läuft
	beq	$t0,$zero,vieraus
	la	$s0,_pc4	#Initialisierung der Pointer fuer das Programm
	la	$s1,_reg4
	la	$s2,_stack4
	j	start
vieraus:
	addi	$s4,$zero,1	#Falls das aktuelle Programm nicht mehr laeuft, das naechste nehmen
	j	prog1

start:
	lw	$t0,0($s0)	#s3 = Instruktion
	lw	$s3,0($t0)
	srl	$t0,$s3,26	#Op-Code in t0 speichern
	
	#Opcode switch
	beq	$t0,$zero,Op0	#0
	addi	$t1,$zero,2	#2
	beq	$t0,$t1,Op2
	addi	$t1,$zero,4	#4
	beq	$t0,$t1,Op4
	addi	$t1,$zero,8	#8
	beq	$t0,$t1,Op8	
	addi	$t1,$zero,35	#35
	beq	$t0,$t1,Op35
	addi	$t1,$zero,43	#43
	beq	$t0,$t1,Op43
	
	
Op0:
	sll	$t0,$s3,26	#Funktionscode wird in t0 gespeichert
	srl	$t0,$t0,26
	addi	$t1,$zero,8
	beq	$t0,$t1,endprog	#Wenn Funktionscode 8 ist, wird das Programm beendet

	#add R1,R2,R3
	srl	$t0,$s3,21	#Registernummer von R2 in t0 laden
	sll	$t0,$t0,2	#t0 * 4
	add	$t0,$t0,$s1	#RegPointer und R2 Pointer addieren
	lw	$t0,0($t0)	#R2 in t0 laden
	sll	$t1,$s3,11	#Registernummer von R3 in t1 laden
	srl	$t1,$t1,27	
	sll	$t1,$t1,2	#t1 * 4
	add	$t1,$t1,$s1	#RegPointer und R3 Pointer addieren
	lw	$t1,0($t1)	#R3 in t1 laden
	add	$t1,$t0,$t1	#Rechnung ausfuehren (R2+R3)
	sll	$t0,$s3,16	#Registernummer von R1 in t0 laden
	srl	$t0,$t0,27
	sll	$t0,$t0,2	#t0 * 4
	add	$t0,$t0,$s1	#RegPointer und R1 Pointer addieren
	sw	$t1,0($t0)	#Ergebnis speichern
	j	pcplus		#pc erhoehen
	
Op2:	#j Label2
	sll	$t0,$s3,6	#Adresse2 in t0 speichern und t0 * 4
	srl	$t0,$t0,4
	lw	$t1,0($s0)	#pc in t1 laden
	srl	$t1,$t1,28	#bit 28 bis 31 von t1 * 2^28
	sll	$t1,$t1,28
	add	$t0,$t0,$t1	#Adresse von Label2 ausrechnen
	sw	$t0,0($s0)	#neue pc Adresse speichern
	j	nprog

Op4:	#beq R1,R2,Label1
	sll	$t0,$s3,6	#Registernummer von R1 in t0 laden
	srl	$t0,$t0,27
	sll	$t0,$t0,2	#t0 * 4
	add	$t0,$t0,$s1	#RegPointer und R1 Pointer addieren
	lw	$t0,0($t0)	#R1 in t0 laden
	sll	$t1,$s3,11	#Registernummer von R2 in t1 laden
	srl	$t1,$t1,27
	sll	$t1,$t1,2	#t1 * 4
	add	$t1,$t1,$s1	#RegPointer und R2 Pointer addieren
	lw	$t1,0($t1)	#R2 in t1 laden
	beq	$t0,$t1,gleich	#Pruefung durchfuehren
	j	pcplus		#pc erhoehen

gleich:
	sll	$t0,$s3,16	#Adresse1 in t0 laden und t0 * 4
	srl	$t0,$t0,14
	lw	$t1,0($s0)	#pc in t1 laden
	add	$t0,$t0,$t1	#pc und Adresse1 addieren
	sw	$t0,0($s0)	#neue pc Adresse speichern
	j	nprog

Op8:	#addi R1,R2,Wert
	sll	$t0,$s3,6	#Registernummer von R2 in t0 laden
	srl	$t0,$t0,27
	sll	$t0,$t0,2	#t0 * 4
	add	$t0,$t0,$s1	#RegPointer und R2 Pointer addieren
	lw	$t0,0($t0)	#R2 in t0 laden
	sll	$t1,$s3,16	#Wert in t1 laden
	sra	$t1,$t1,16
	add	$t0,$t0,$t1	#Rechnung durchfuehren
	sll	$t1,$s3,11	#Registernummer von R1 in t1 laden
	srl	$t1,$t1,27
	sll	$t1,$t1,2	#t1 * 4
	add	$t1,$t1,$s1	#RegPointer und R1 Pointer addieren
	sw	$t0,0($t1)	#Ergebnis in R1 speichern
	j	pcplus		#pc erhoehen

Op35:	#lw R1,Offset($sp)
	lw	$t0,116($s1)	#Stackpointer in t0 laden
	sll	$t1,$s3,16	#Offset in t1 laden
	sra	$t1,$t1,16
	add	$t0,$t0,$t1	#Offset(t1) zu t0 addieren
	lw	$t0,0($t0)	#Wert aus dem Stack in t0 laden
	sll	$t1,$s3,11	#Registernummer R1 in t1 laden
	srl	$t1,$t1,27
	sll	$t1,$t1,2	#t1 * 4
	add	$t1,$t1,$s1	#RegPointer und R1 Pointer addieren
	sw	$t0,0($t1)	#Wert in R1 speichern
	j pcplus		#pc erhoehen

Op43:	#sw R1,Offset($sp)
	lw	$t0,116($s1)	#Stackpointer in t0 laden
	sll	$t1,$s3,16	#Offset in t1 laden
	sra	$t1,$t1,16
	add	$t0,$t0,$t1	#Offset(t1) zu t0 addieren
	sll	$t1,$s3,11	#Registernummer R1 in t1 laden
	srl	$t1,$t1,27
	sll	$t1,$t1,2	#t1 * 4
	add	$t1,$t1,$s1	#RegPointer und R1 Pointer addieren
	lw	$t1,0($t1)	#R1 in t1 laden
	sw	$t1,0($t0)	#t1(R1) im Stack speichern
	j pcplus		#pc erhoehen

pcplus:
	lw	$t0,0($s0)	#pc in t0 laden
	addi	$t0,$t0,4	#pc erhoehen
	sw	$t0,0($s0)	#neue pc Adresse abspeichern
	j	nprog

endprog:
	#Programm switch
	addi	$t0,$zero,1	#1
	beq	$t0,$s4,endprog1
	addi	$t0,$zero,2	#2
	beq	$t0,$s4,endprog2
	addi	$t0,$zero,3	#3
	beq	$t0,$s4,endprog3	
	addi	$t0,$zero,4	#4
	beq	$t0,$s4,endprog4
endprog1:
	andi	$s5,$s5,0x7	#Programm als beendet markieren
	addi	$v0,$zero,1
	addi	$a0,$zero,1
	syscall
	j	print
endprog2:
	andi	$s5,$s5,0xb	#Programm als beendet markieren
	addi	$v0,$zero,1
	addi	$a0,$zero,2
	syscall
	j	print
endprog3:
	andi	$s5,$s5,0xd	#Programm als beendet markieren
	addi	$v0,$zero,1
	addi	$a0,$zero,3
	syscall
	j	print
endprog4:
	andi	$s5,$s5,0xe	#Programm als beendet markieren
	addi	$v0,$zero,1
	addi	$a0,$zero,4
	syscall
	
print:
	addi	$v0,$zero,4
	la	$a0,_mess
	syscall

nprog:				#Nächstes Programm auswählen und wieder an den Anfang der Schleife springen
	bne	$s5,$zero,weiter	#Prüfung, ob schon alle Programme beendet sind
	jr	$ra		#alles beenden
weiter:
	addi	$t0,$zero,5	#t0 auf Anzahl der Programme + 1 setzen
	addi	$s4,$s4,1	#s4 auf naechstes Programm setzen
	bne	$t0,$s4,emu	#Wenn kein Überlauf, wird gleich gesprungen
	addi	$s4,$zero,1
	j	emu
	
main1:
	addi	$t1,$zero,16
	sw	$t1,-4($sp)
	sw	$t1,-16($sp)
	addi	$t2,$zero,13
	sw	$t2,-8($sp)
	sw	$t2,-24($sp)
	addi	$t3,$zero,21
	sw	$t3,-12($sp)
	sw	$t3,-20($sp)
	addi	$s1,$zero,6
	addi	$t0,$zero,0
	addi	$s3,$zero,0
loop1:	addi	$sp,$sp,-4
	lw	$s2,0($sp)
	add	$s3,$s3,$s2
	addi	$t0,$t0,1
	beq	$t0,$s1,end1
	j	loop1
end1:	jr	$ra
	
main2:
	addi	$s1,$zero,8
	add	$t2,$zero,$s1
	addi	$s3,$zero,0
loop2:	add	$s3,$s3,$s1
	addi	$t2,$t2,-1
	beq	$t2,$zero,end2
	j	loop2
end2:	jr	$ra

main3:
	addi	$s1,$zero,101
	add	$t2,$zero,$s1
	addi	$s3,$zero,0
loop3:	add	$s3,$s3,$s1
	addi	$t2,$t2,-1
	beq	$t2,$zero,end3
	j	loop3
end3:	jr	$ra
	
main4:
	addi	$t1,$zero,64
	sw	$t1,-4($sp)
	add	$s1,$zero,$t1
	addi	$t2,$zero,67
	sw	$t2,-8($sp)
	add	$s2,$zero,$t2
loop4:	addi	$t1,$t1,-1
	addi	$t2,$t2,-1
	beq	$t1,$zero,end4a
	beq	$t2,$zero,end4b
	j	loop4
end4a:	lw	$s3,-8($sp)
	j	end4
end4b:	lw	$s3,-4($sp)
	sw	$s1,-8($sp)
	sw	$s2,-4($sp)
end4:	jr	$ra

