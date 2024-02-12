.data
sinput: 		.word 0, 0, 0, 0	
soutput: 		.word 0, 0, 0, 0	
metriques: 		.word 4, 3, 3, 2,	0, 3, 5, 2,		4, 3, 3, 2,		2, 5, 3, 2

.text 0x400000
.globl main

# Avec les valeurs sortient de genmetrique, on s'attend a obtenir 2 0 2 2 comme soutput lors du premier appel
# de la fonction CalculSurvivants.

main: 
	la $a0, sinput
	la $a1, soutput
	la $a2, metriques
	jal calculSurvivants
	
	li      $v0     1                   # syscall va print un entier si $v0 set a 1
    la      $t0     soutput				# on met soutput dans $t0
    lw      $a0     0($t0)				# on load soutput[0] dans $a0
    syscall                             # print soutput[0]
    li      $a0     32					# on load un espace dans $a0, 32 est la valeur du code ASCII
    li      $v0     11					# on load 11 dans $v0 pour que syscall print un char
    syscall                             # print un espace
    li      $v0     1
    lw      $a0     4($t0)
    syscall                             # print soutput[1]
    li      $a0     32
    li      $v0     11
    syscall                             # print un espace
    li      $v0     1
    lw      $a0     8($t0)
    syscall                             # print soutput[2]
    li      $a0     32
    li      $v0     11
    syscall                             # print un espace
    li      $v0     1
    lw      $a0     12($t0)
    syscall                             # print soutput[3]
	
    li      $v0     10
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
	addiu $sp, $sp, -12
	sw $t3, 0($sp) 
	sw $t4, 4($sp)
	sw $ra, 8($sp) 
	
	# On set les arguments pour ACS
	move $a0, $t0
	move $a1, $t1
	
	jal acs
	
	# On libere l'espace sur le stack
	lw $t3, 0($sp) 
	lw $t4, 4($sp)
	lw $ra, 8($sp)
	addiu $sp, $sp, 12
	
	# incremente nos variables
	addiu $t1, $t1, 4					# incremente le pointeur de l'addresse soutput
	addiu $t3, $t3, 1					# incremente l'index i
	j loop_calculSurvivants
	
fin_calculSurvivants:
	jr $ra
	
# void acs(unsigned *met, int *sinput, int *soutput)
acs:
	li $t3, 0							# initiation de notre index j
	li $t4, 4							# Valeur de N
	

loop_acs:
	beq $t3, $t4, fin_acs				# si j < N
	lw $t5, 0($a2)						# pointer met
	lw $t6, 0($a0)						# pointer sinput
	
	addu $t5, $t5, $t6 					# add met[j] + sinput[j] for temp variable
	
	lw $t6, 0($a1)						# load la valeur soutput existante
	bgeu $t5, $t6, condition_acs		# if temp < sinput, on remplace la valeur de soutput existante
	sw $t5, 0($a1)
	
condition_acs:
	addiu $a0, $a0, 4					# update les pointers pour met et sinput pour pointer vers l'element j
	addiu $a2, $a2, 4				
	addiu $t3, $t3, 1					# incrementer l'index
	j loop_acs
	
fin_acs:
	jr $ra