# 

.data
archivo: .asciiz "TablaIni.txt"
nombreEquipo: .space 256
numbers: .space 512
header: .space 36
buffer: .space 1
#linea: .space 40
coma: .ascii ","
ingLoc: .asciiz "Ingrese el equipo local: "
nombreArchivo: .asciiz "TablaIni"
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
	addi $t0, $zero, 44 #coma
	addi $t1, $zero, 10 #salto de linea
	addi $t2, $zero, 0 #ofsetnums
	addi $t3, $zero, 0 #ofsetchars
	addi $t6, $zero, 0 #numerolineas

	la $a0, nombreArchivo
	li $v0, 14	#Leer archivo
	move $s6, $v0	#Nombre de archivo
	
	la $a1, header #lectura header
	la $a2,36	
	syscall
fornombre:	
	la $a3,nombreEquipo	#carga direccion nombreEquipo
	add $a3, $a3, $t3	#suma ofset
forchar:
	la $a1, buffer	#Almacena en el buffer
	la $a2,36	
	syscall
	#instrucciones que concatena char 
	beq $a1, $t0, finishchar 
	lb      $v0,0($a1)   
	sb      $v0,0($a3)                           
    	addi    $a3,$a3,1 
    	j forchar
    	
finishchar:
	addi $t3, $t3, 16	#suma ofset chars
Runagain:   	
	la $a3,numbers		#cargardireccion numbers
    	addi $t4, $zero, 0	#variable que va acumulando el int
    	add $a3, $a3, $t2 	#suma ofset a la direccion
for:
	la $a1, buffer	#Almacena en el buffer
	la $a2,36	
	syscall
	
	#sentencias, com y salto de linea
	beq $a1, $t0, exit 
	beq $a1, $t1, finlinea 
	# multiplicacion por 10 variable que iba acumulando el int
	sll $t4, $t4, 4
	sll $t5, $t4, 2
	add $t4, $t5, $t4
	lb  $v0,0($a1)  
	#obtencion unidad
	addi $v0, $v0, -48   
	#suma unidad a variable
	add $t4, $t4, $v0                       
    	j for        
exit:
	#escritura int construido
	sw $t4,0($a3)
	#suma de ofset en la variable que los va almacenando
	add $t2, $t2, 4
	j Runagain
finlinea:
	#escritura int construido
	sw $t4,0($a3)
	#suma de ofset en la variable que los va almacenando
	add $t2, $t2, 4
	#sentencia chequea si se han leido todas las lineas
	addi $t7, $zero, 16
	addi $t6,$t6,1
	bne $t6, $t7, fornombre
	#cierre archivo		
	li   $v0, 16       # system call for close file
	move $a0, $s6      # file descriptor to close
	syscall 
	jr $ra
	
saltoL:
