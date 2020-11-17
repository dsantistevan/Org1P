# 

.data
archivo: .asciiz "TablaIni.txt"
nombreEquipo: .space 20
header: .space 36
buffer: .space 1
linea: .space 40
coma: .ascii ","
ingLoc: .asciiz "Ingrese el equipo local: "
ingVis: .asciiz "Ingrese el equipo visitante: "
ingGLoc: .asciiz "Ingrese los goles del equipo local: "
ingGVis: .asciiz "Ingrese los goles del equipo visitante: "
bienvenidaTexto: .asciiz "Bienvenido al visor de la tabla del Campeonato Ecuatoriano:\n"
menuTexto: .asciiz "\nSeleccione su opcion:\n1. Ver tabla\n2. Ver 3 mejores\n3. Ingresar partido\n4. Salir\n"
adios: .asciiz "\nAdios, gracias por usar este programa, cuídate\n"
#Salto de linea: '\n' es 10 en ASCII
.text




li $v0, 4
la $a0, bienvenidaTexto
syscall

li $v0, 13	#Abrir archivo
la $a0, archivo	#Nombre de archivo
li $a1, 0	#Solo lectura
li $a2, 0
syscall
move $s6, $v0	#Guarda descriptor del archivo

li $v0, 14	#Leer archivo
move $a0, $s6	#Nombre de archivo
la $a1, header	#Almacena en el buffer
li $a2, 35
syscall

li $v0, 4
la $a0, header
syscall

jal leerEquipos	

li $v0, 16
move $a0, $s6
syscall 




menu:
	li $v0, 4
	la $a0, menuTexto
	syscall
	li $v0, 5
	syscall
	move $t0, $v0
	beq $t0, 1, tabla
	beq $t0, 2, mejores
	beq $t0, 3, partido
	beq $t0, 4, salir
	j menu

	tabla:
		li $v0, 4
		la $a0, ingLoc
		syscall
		j menu

	mejores:
		li $v0, 4
		la $a0, ingVis
		syscall
		j menu
	
	
	partido:
		li $v0, 4
		la $a0, ingGLoc
		syscall
		j menu

#####################Funciones######################
#exit()
salir:
	li $v0, 4
	la $a0, adios
	syscall
	li $v0, 10
	syscall

#leerEquipos()
#La idea es en la variable matriz almacenar las direcciones base de cada equipo
#Para cada equipo se va a almacenar un arreglo en el mismo orden de la tabla
#Hay que leer los chars 1 a 1, e ir concatenando. En cada linea i, si llegas a una ',', almacenas lo que esté en el string
# en la direccion matriz[i][j], siendo j la cantidad de comas antes de esto (o el indice de la info). Cuando encuentres un '\n',
# cuyo valor es 10, para que puedas comparar el valor del byte como entero, debes avanzar en i y reiniciar j.
leerEquipos:
	li $v0, 14	#Leer archivo
	move $a0, $s6	#Nombre de archivo
	
	la $a1, header #lectura header
	la $a2,36	
	syscall
	
	la $a3,nombre	#se van concatenando los char
	la $a1, buffer	#Almacena en el buffer
	la $a2,36	
	syscall

	#instrucciones que concatena char
	lb      $v0,0($a1)   
	sb      $v0,0($a3)                           
    	addi    $a3,$a3,1          
	
	beq $a1, 10, saltoL
	
	li $v0, 4
	la $a0, linea
	syscall 
	jr $ra
	
saltoL: