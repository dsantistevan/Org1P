# 

.data
stringtext:	.space 600
numbers: 	.space 512
posiciones: 	.space 64
nombreEquipo: 	.space 256
header: 	.space 36
buffer: 	.space 1
input:		.space 16
archivo: 	.asciiz "TablaIni.txt"
archivo1: 	.asciiz "eje.txt"
#linea: .space 40
puntoEspacio:	.asciiz ". "
espacioT:	.asciiz " "
coma: 		.ascii ","
saltoLinea:	.asciiz "\n"
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

la $s7, posiciones

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
jal	Sort
jal	printEquipos
jal toString
jal 	Write



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
		li	$a0, 16
		jal	printTabla
		j	menu

	mejores:
		li	$a0, 3
		jal	printTabla
		j	menu
	
	
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
	#jal	Write
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
	beq 	$t9, $t0, exit0
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
exit0:
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
	addi 	$s1, $a1, 20
	lw 	$t0, 0($a1) 
	lw 	$t1, 0($t3) 
	lw 	$s2, 0($s1)
	addi 	$a1,$a1, 32
	addi 	$t2, $zero, 0 #numerpo iteraciones
	addi 	$v0, $zero, 0
	addi 	$t3, $a1, 28
	addi 	$s1, $a1, 20
	
forprimermayor:	
	addi 	$t2 $t2, 1
	lw 	$t5, 0($a1) 
	lw 	$t6, 0($t3) 
	lw	$s3, 0($s1)
	slt 	$t4, $t0, $t5
	bne 	$t4,$zero,mayor
	bne 	$t0, $t5, exit1
	slt 	$t4, $t1,$t6
	bne 	$t4,$zero,mayor
	bne 	$t1, $t6, exit1	
	slt	$t4, $s2,$s3
	bne 	$t4,$zero,mayor
mayor:
	add 	$t0,$t5,$zero
	add 	$t1, $t6, $zero
	add	$s2, $s3, $zero
	add 	$v0, $t2, $zero
	j 	exit1
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
	addi	$s0, $zero, 0
	addi 	$v0, $zero, 0
	add 	$a2, $zero, $zero
	
forgrande:	
	la 	$a1, numbers
	addi	$t3, $a1, 28
	addi	$s1, $a1, 20
	add 	$t2, $zero, $zero
forarr:	
	lw 	$t8, 0($a1)
	lw 	$t9, 0($t3)
	lw	$s3, 0($s1)
	slt 	$t4, $t5, $t8
	bne 	$t4, $zero, check
	slt 	$t4, $t8, $t5
	bne 	$t4, $zero, exit	
	slt 	$t4, $t6, $t9
	bne 	$t4, $zero, check
	slt 	$t4, $t9, $t6
	bne 	$t4, $zero, exit
	slt	$t4, $s0, $s3
	bne 	$t4, $zero, check
	j 	exit

check:	
	slt 	$t4, $t0, $t8
	bne 	$t4, $zero, exit
	slt 	$t4, $t8, $t0
	bne 	$t4, $zero, cambio
	slt 	$t4, $t9, $t1
	bne 	$t4, $zero, cambio
	slt 	$t4, $t1, $t9
	bne 	$t4, $zero, exit
	slt	$t4, $s3, $s2
	bne 	$t4, $zero, cambio
	j 	exit	
cambio:
	add 	$t5, $t8, $zero
	add 	$t6, $t9, $zero
	add	$s0, $s3, $zero
	add 	$v0, $t2, $zero
exit:
	addi 	$t7, $zero, 16
	beq 	$t2, $t7, exitgrande
	addi 	$t2, $t2, 1
	addi 	$a1, $a1, 32
	addi 	$t3, $a1, 28
	addi 	$s1, $a1, 20
	j 	forarr
	
exitgrande:
	sw 	$v0, 0($a0)
	addi 	$a0, $a0, 4
	addi 	$a2, $a2, 1
	addi 	$t0, $t5, 0 
	addi 	$t1, $t6, 0
	addi	$s2, $s0, 0
	addi 	$t5, $zero, -100 
	addi 	$t6, $zero, 0
	addi	$s0, $zero, 0
	addi 	$t7, $zero, 15
	bne 	$a2, $t7, forgrande
	jr 	$ra
	
# $a0 guarda la cantidad de equipos
printTabla:
	move	$t0, $a0 	#$t0 es la cantidad de equipos a imprimir
	la	$s1, posiciones
	la	$s2, nombreEquipo
	la	$s3, numbers
	
### Espacio
	la	$a0, header
	li	$v0, 4
	syscall
### Fin del Espacio

	addi	$t4, $zero, 0
recorrerPos:
	sll	$t5, $t4, 2
	add	$t6, $s1, $t5
	lw	$t5, 0($t6)
	sll	$t5, $t5, 4
	add	$t6, $t5, $s2
	move	$a0, $t6	#Nombre
	li	$v0, 4
	syscall
	sll	$t5, $t5, 1
	add	$t7, $t5, $s3	#Matriz indexada del equipo
	addi	$t8, $zero, 0
forEquipo:
	la	$a0, espacioT
	li	$v0, 4
	syscall
	sll	$t9, $t8, 2
	add	$t9, $t9, $t7
	lw	$a0, 0($t9)
	li	$v0, 1
	syscall
	addi	$t8, $t8, 1
	bne	$t8, 8, forEquipo
#Afuera del for	Equipo
	la	$a0, saltoLinea
	li	$v0, 4
	syscall
	addi	$t4, $t4, 1
	bne	$t4, $t0, recorrerPos
#Afuera de todo
	jr	$ra
	
	

Write:
	
	
	li $v0,13           	# Codigo syscall para abrir archivo
    	la $a0,archivo1     	# nombre del archivo
    	li $a1, 1          	# bandera = escribir (1)
    	syscall
    	move $s1,$v0        	# guarda el descriptor del archivo
    	
    	#Escritura
    	li $v0,15		# Codigo syscall para escribir un archivo
    	move $a0,$s1		# descriptor del archivo
    	la $a1,stringtext	# El string que se va a escribir
    	la $a2,21		# longitud del string
    	syscall
    	
	#Cerrar archivo
    	li $v0,16         	# Codigo syscall para abrir archivo
    	move $a0,$s1      	# descriptor del archivo a cerrar
    	syscall
    	
    	
    	
	jr $ra
	
	
	
	

#printEquipos()
printEquipos:
	la	$t0, nombreEquipo
	li	$t1, 16
	li	$t2, 0
recorrerEquiposPrint:
	addi	$a0, $t2, 0
	li	$v0, 1
	syscall
	la	$a0, puntoEspacio
	li	$v0, 4
	syscall
	sll	$t3, $t2, 4
	add	$a0, $t3, $t0
	li	$v0, 4
	syscall
	la	$a0, saltoLinea
	li	$v0, 4
	syscall
	addi	$t2, $t2, 1
	bne	$t1, $t2, recorrerEquiposPrint
	jr	$ra
	
	
toString:
	la $a0, stringtext
	la $a1, header
	addi $t0, $zero, 0
	addi $t1, $zero, 36
	
forcabec:
	lb $v0,0($a1)
	sb $v0,0($a0) 
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	addi $t0, $t0, 1
	bne $t1, $t0, forcabec

	la $a1, nombreEquipo
	la $a2, numbers
	addi $t0, $zero, 16
	addi $t2, $zero, 45 #-
	addi $t3, $zero, 10 #\n
	addi $t4, $zero, 44 #,
	addi $t6, $zero, 8
	addi $t7, $zero, 0 #lineas	
	addi $s7, $zero, 10

forlinea:
	addi $t1, $zero, 0
fortexto:
	lb $v0,0($a1)
	sb $v0,0($a0) 
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	addi $t1, $t1, 1
	bne $t1, $t0, fortexto

	addi $t5, $zero, 0	
intero:
	#lb $v0,0($t4)
	sb $t4,0($a0) 
	addi $a0, $a0, 1
	
	lw $t9, 0($a2)
	addi $a2,$a2,4
	
	slt $s0, $t9, $zero
	beq $s0, $zero, jumper
	#lb $v0,0($t2)
	sb $t2,0($a0) 
	addi $a0, $a0, 1
	#multiplying -1
	add $s1, $t9, $zero
	sll $s1, $s1, 2
	sub $t9, $t9, $s1
jumper:
	div $t9, $s7
	mflo $s1
	mfhi $s2
	addi $s1, $s1, 48
	addi $s2, $s2, 48
	sb $s1,0($a0) 
	addi $a0, $a0, 1
	sb $s2,0($a0) 
	addi $a0, $a0, 1
		

	addi $t5, $t5, 1
	bne $t5, $t6, intero
	#lb $v0,0($t3)
	sb $t3,0($a0) 
	addi $a0, $a0, 1
	addi $t7, $t7, 1
	bne $t7, $t0, forlinea
	jr $ra
		
