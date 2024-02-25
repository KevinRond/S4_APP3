.data 0x10010000
sin: .word 0, 0, 0, 0
sout: .word 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff
met: .word 4, 3, 3, 2,   0, 3, 5, 4,   4, 3, 3, 2,   2, 5, 3, 2   #valeurs trouvees en executant le fichier DecodageViterbi.C

.text 0x400000

.globl main

main:
	#assignation des registres
	la $a0, met
	la $a1, sin
	la $a2, sout
	
	jal     acs_init        # acs(met, si, so)

    	li      $v0     10
    	syscall
	
	
	#fonction acs
	acs_init:
		li $t0, 0 #increment j
		li $t1, 4 #N
		
		lwv $s1, 0($a1) # valeur de sin
	
	acs_loop:
		bgeu $t0, $t1, acs_end #verifie si j >= N. Si oui, passe directement a la fin (acs_end)
		lwv $s0, 0($a0) #Charge la valeur met[j]
		addu $s0, $s0, $s1 #additionne met[j] avec sin[j]
		
		vmin $t2, $s0, 0	# plus petite valeur du vecteur
		
		sw $t2, 0($a2) # met la plus petite valeur dans so
		
		addi $a0, $a0, 16 #passe au prochain element (1 element = 4 bytes) * 4 elements
		addi $a2, $a2, 4 #passe au prochain element (1 element = 4 bytes)
		addi $t0, $t0, 1 #incremente de 1
		j acs_loop #recommence la boucle
	
	acs_end:
		jr $ra
