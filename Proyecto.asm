# asm

.data

ingLoc: .asciiz "Ingrese el equipo local: "
ingVis: .asciiz "Ingrese el equipo visitante: "
ingGLoc: .asciiz "Ingrese los goles del equipo local: "
ingGVis: .asciiz "Ingrese los goles del equipo visitante: "
bienvenidaTexto: .asciiz "Bienvenido al visor de la tabla del Campeonato Ecuatoriano:\n"
menuTexto: .asciiz "\nSeleccione su opcion:\n1. Ver tabla\n2. Ver 3 mejores\n3. Ingresar partido\n4. Salir\n"
adios: .asciiz "\nAdios, gracias por usar este programa, cuídate\n"

.text
li $v0, 4
la $a0, bienvenidaTexto
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


salir:
	li $v0, 4
	la $a0, adios
	syscall
	li $v0, 10
	syscall

