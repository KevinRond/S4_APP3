.data
sinput: 		.word 0, 0, 0, 0	
soutput: 		.word 0, 0, 0, 0	
metriques: 		.word 4, 3, 3, 2,	0, 3, 5, 2,		4, 3, 3, 2,		2, 5, 3, 2

.text 0x400000
.globl main

# Avec les valeurs sortient de genmetrique, on s'attend a obtenir 2 0 2 2 comme soutput lors du premier appel
# de la fonction CalculSurvivants dans la boucle for quand i = 1.

main: 
	la $a0, sinput
	la $a1, soutput
	la $a2, metriques
	jal calculSurvivants
	
	li $v0, 1                  			# syscall va print un entier si $v0 set a 1
    la $t0, soutput						# on met soutput dans $t0
    lw $a0, 0($t0)						# on load soutput[0] dans $a0
    syscall                             # print soutput[0]
    li $a0, 32							# on load un espace dans $a0, 32 est la valeur du code ASCII
    li $v0, 11							# on load 11 dans $v0 pour que syscall print un char
    syscall                             # print un espace
    li $v0, 1
    lw $a0, 4($t0)
    syscall                             # print soutput[1]
    li $a0, 32
    li $v0, 11
    syscall                             # print un espace
    li $v0, 1
    lw $a0, 8($t0)
    syscall                             # print soutput[2]
    li $a0, 32
    li $v0, 11
    syscall                             # print un espace
    li $v0, 1
    lw $a0, 12($t0)
    syscall                             # print soutput[3]
	
    li $v0, 10
    syscall                            

# void CalculSurvivants( unsigned int *met, int *sinput, int *soutput)
calculSurvivants:
	move $t0, $a0						# sinput
	move $t1, $a1						# soutput
	move $t2, $a2						# metriques
	
	li $t3, 0							# initiation de notre index i
	li $t4, 4							# Valeur de N

loop_calculSurvivants:
	beq $t3, $t4, fin_calculSurvivants	# si i < N
	li $t5, 250							
	sw $t5, 0($t1)						# on sauve la valeur de soutput[i] = 250 dans $t5
	move $t5, $t2
	sll $t6, $t3, 4						# index du parametre &met (i * N)
	addu $a2, $t5, $t6
	
	# On veut storer i, N et ra sur le stack
	addiu $sp, $sp, -24
	sw $t0, 0($sp) 
	sw $t1, 4($sp) 
	sw $t2, 8($sp) 
	sw $t3, 12($sp) 
	sw $t4, 16($sp)
	sw $ra, 20($sp) 
	
	# On set les arguments pour ACS
	move $a0, $t0
	move $a1, $t1
	
	jal acs
	
	# On libere l'espace sur le stack
	lw $t0, 0($sp) 
	lw $t1, 4($sp) 
	lw $t2, 8($sp) 
	lw $t3, 12($sp) 
	lw $t4, 16($sp)
	lw $ra, 20($sp) 
	addiu $sp, $sp, 24
	
	# incremente nos variables
	addiu $t1, $t1, 4					# incremente le pointeur de l'addresse soutput
	addiu $t3, $t3, 1					# incremente l'index i
	j loop_calculSurvivants
	
fin_calculSurvivants:
	jr $ra
	
# void acs(unsigned *met, int *sinput, int *soutput)
acs:
	lwv $v0, 0($a2)
	lwv $v1, 0($a0)
	addv $v0, $v0, $v1
	lwv $v1, 0($a1)
	vmin $v0, $v0, $v1
	swv $v0, 0($a1)
	j fin_acs
	
fin_acs:
	jr $ra
