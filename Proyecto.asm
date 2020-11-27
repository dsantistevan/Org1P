# 

.data
numbers: 	.space 512
posiciones: 	.space 64
nombreEquipo: 	.space 256
header: 	.space 36
buffer: 	.space 1
archivo: 	.asciiz "TablaIni.txt"
#linea: .space 40
coma: 		.ascii ","
ingLoc: 	.asciiz "Ingrese el equipo local: "
nombreArchivo: 	.asciiz "TablaIni"
ingVis: 	.asciiz "Ingrese el equipo visitante: "
ingGLoc: 	.asciiz "Ingrese los goles del equipo local: "
ingGVis: 	.asciiz "Ingrese los goles del equipo visitante: "
bienvenidaTexto: .asciiz "\nBienvenido al visor de la tabla del Campeonato Ecuatoriano:\n"
menuTexto: 	.asciiz "\nSeleccione su opcion:\n1. Ver tabla\n2. Ver 3 mejores\n3. Ingresar partido\n4. Salir\n"
adios: 		.asciiz "\nAdios, gracias por usar este programa, cuídate\n"
#Salto de linea: '\n' es 10 en ASCII
.text

la $t0, numbers

li 	$v0, 4
la 	$a0, bienvenidaTexto
syscall

li 	$v0, 13	#Abrir archivo
la 	$a0, archivo	#Nombre de archivo
li 	$a1, 0	#Solo lectura
li 	$a2, 0
syscall
move 	$s6, $v0	#Guarda descriptor del archivo


jal 	leerEquipos	

li 	$v0, 16
move 	$a0, $s6
syscall 




menu:
	li 	$v0, 4
	la	$a0, menuTexto
	syscall
	li 	$v0, 5
	syscall
	move 	$t0, $v0
	beq 	$t0, 1, tabla
	beq 	$t0, 2, mejores
	beq 	$t0, 3, partido
	beq 	$t0, 4, salir
	j 	menu

	tabla:
		li 	$v0, 4
		la 	$a0, ingLoc
		syscall
		j 	menu

	mejores:
		li	$v0, 4
		la 	$a0, ingVis
		syscall
		j 	menu
	
	
	partido:
		li 	$v0, 4
		la 	$a0, ingGLoc
		syscall
		j 	menu

#####################Funciones######################
#exit()
salir:
	li 	$v0, 4
	la 	$a0, adios
	syscall
	li 	$v0, 10
	syscall

#leerEquipos()
#La idea es en la variable matriz almacenar las direcciones base de cada equipo
#Para cada equipo se va a almacenar un arreglo en el mismo orden de la tabla
#Hay que leer los chars 1 a 1, e ir concatenando. En cada linea i, si llegas a una ',', almacenas lo que esté en el string
# en la direccion matriz[i][j], siendo j la cantidad de comas antes de esto (o el indice de la info). Cuando encuentres un '\n',
# cuyo valor es 10, para que puedas comparar el valor del byte como entero, debes avanzar en i y reiniciar j.
leerEquipos:
	
	addi 	$t0, $zero, 44 #coma ','
	addi 	$t1, $zero, 10 #salto de linea '\n'
	addi 	$t2, $zero, 0 #ofsetnums
	addi 	$t3, $zero, 0 #ofsetchars
	addi 	$t6, $zero, 0 #numerolineas
	
	move 	$a0, $s6
	li 	$v0, 14	#Leer archivo
	
	la 	$a1, header #lectura header
	la 	$a2,36
	syscall
	
	li 	$v0, 4
	la 	$a0, header
	syscall
	
fornombre:	
	li	$s3, 1
	la 	$a3,nombreEquipo	#carga direccion nombreEquipo
	add 	$a3, $a3, $t3	#suma ofset
forchar:
        li 	$v0, 14
        move 	$a0, $s6
	la 	$a1, buffer	#Almacena en el buffer
	la 	$a2,1	
	syscall
	#instrucciones que concatena char 
	lb      $v0,0($a1)
	beq 	$v0, $t0, finishchar	#ver si llegó a una coma
	sb      $v0,0($a3)                           
    	addi    $a3,$a3,1 
    	j 	forchar
    	
finishchar:
	addi 	$t3, $t3, 16	#suma ofset chars
Runagain:   	
	la 	$a3, numbers	#cargardireccion numbers
    	addi 	$t4, $zero, 0	#variable que va acumulando el int
    	add 	$a3, $a3, $t2 	#suma ofset a la direccion
for:
	li 	$v0, 14
        move 	$a0, $s6
	la 	$a1, buffer	#Almacena en el buffer
	la 	$a2,1	
	syscall
	lb 	$t9,0($a1)
	#sentencias, com y salto de linea
	beq 	$t9, $t0, exit 
	beq	$t9, 13, for
	beq	$t9, 45, menos
	j seguirAqui
	
menos:
	li	$s3, -1
	j 	for
	
seguirAqui:	
	beq 	$t9, $t1, finlinea 
	# multiplicacion por 10 variable que iba acumulando el int
	sll 	$t5, $t4, 3
	sll 	$t4, $t4, 1
	add 	$t4, $t5, $t4
	#obtencion unidad
	addi 	$t9, $t9, -48   
	#suma unidad a variable
	add 	$t4, $t9, $t4                       
    	j 	for        
exit:
	#escritura int construido
	sw 	$t4, ($a3)
	#suma de ofset en la variable que los va almacenando
	add 	$t2, $t2, 4
	j 	Runagain
finlinea:
	#escritura int construido
	mult	$t4, $s3
	mflo	$t4
	sw 	$t4,0($a3)
	#suma de ofset en la variable que los va almacenando
	addi 	$t2, $t2, 4
	#sentencia chequea si se han leido todas las lineas
	addi 	$t7, $zero, 16
	addi 	$t6,$t6,1
	bne 	$t6, $t7, fornombre
	#cierre archivo		
	li   	$v0, 16       
	move 	$a0, $s6      
	syscall 
	jr 	$ra
	
saltoL:


Sort:
	la 	$a0, posiciones
	la 	$a1, numbers
	addi 	$t3, $a1, 28
	lw 	$t0, 0($a1) 
	lw 	$t1, 0($t3) 
	addi 	$a1,$a1, 32
	addi 	$t2, $zero, 0 #numerpo iteraciones
	addi 	$a1,$a1,4
	addi 	$v0, $zero, 0
	addi 	$t3, $a1, 28
	
forprimermayor:	
	addi 	$t2 $t2, 1
	lw 	$t5, 0($a1) 
	lw 	$t6, 0($t3) 
	slt 	$t4, $t0, $t5
	bne 	$t4,$zero,mayor
	bne 	$t0, $t5, exit1
	slt 	$t4, $t1,$t6
	bne 	$t4,$zero,mayor	
mayor:
	add 	$t0,$t5,$zero
	add 	$t1, $t6, $zero
	add 	$v0, $t2, $zero
	j 	exit
exit1:   
	addi 	$t7, $zero, 16
	addi 	$a1,$a1, 32
	addi 	$t3, $a1, 28
	bne 	$t2, $t7, forprimermayor
	
	sw 	$v0, 0($a0)	
	addi 	$a0, $a0, 4
	addi 	$t2, $zero, 0 #numerpo iteraciones
	addi 	$t5, $zero, -100 
	addi 	$t6, $zero, 0
	add 	$t2, $zero, $zero
	add 	$v0, $v0, $zero
	add 	$a2, $zero, $zero
	
forgrande:	
	la 	$a1, numbers
	addi	$t3, $a1, 28
forarr:	
	lw 	$t8, 0($a1)
	lw 	$t9, 0($t3)
	slt 	$t4, $t5, $t8
	bne 	$t4, $zero, check
	slt 	$t4, $t6, $t9
	bne 	$t4, $zero, check
	j 	exit
check:
	slt 	$t4, $t8, $t0
	bne 	$t4, $zero, cambio
	bne 	$t8, $t0, exit2
	slt 	$t4, $t9, $t1
	bne 	$t4, $zero, cambio
	j 	exit	
cambio:
	add 	$t5, $t8, $zero
	add 	$t6, $t9, $zero
	add 	$v0, $t2, $zero
exit2:
	addi 	$t7, $zero, 16
	beq 	$t2, $t7, exitgrande
	addi 	$t2, $t2, 1
	addi 	$a1, $a1, 32
	addi 	$t3, $a1, 28
	j 	forarr
	
exitgrande:
	sw 	$v0, 0($a0)
	addi 	$a0, $a0, 4
	addi 	$a2, $a2, 1
	addi 	$t0, $t5, 0 
	addi 	$t1, $t6, 0
	addi 	$t5, $zero, -100 
	addi 	$t6, $zero, 0
	addi 	$t7, $zero, 15
	bne 	$a2, $t7, forgrande
	jr 	$ra
	
	
	
