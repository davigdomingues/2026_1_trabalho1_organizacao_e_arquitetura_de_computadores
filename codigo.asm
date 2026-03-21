		.data
		.align 0
train_head	.word 0
		.text
		.align 2
		.globl main
	
main:		

		# Return 0
		li a7, 10
		ecall


# -----------------------------------------------
# create_wagon
# argumentos:
#	- a0 : ID
#	- a1 : Tipo
#	- a2 : Prox vagao
# retorno:
#	- a0 : Endereco do no' do vagao
# -----------------------------------------------
create_wagon:	# Armazenamento dos argumentos em registradores temporários
		mv t1, a0
		mv t2, a1
		mv t3, a2	

		# Alocacao de espaco
		li a7, 9 # codigo de sbrk
		li a0, 12 # 12 bytes = 4 bytes (ID=Int) + 4 bytes (Tipo=Int) + 4 bytes (End. do prox. no')
		ecall # a0 = endereco da area reservada
	
		# Armazenamento do ID
		sw t1, 0(a0)
		
		# Armazenamento do tipo
		sw t2, 4(a0)
		
		# Armazenamento do endereco do prox vagao
		sw t3, 8(a0)
		
		ret

# -----------------------------------------------
# insert_front
# argumentos:
#	- a0 : endereco da locomotiva
#	- a1 : ID
#	- a2 : Tipo
# -----------------------------------------------
insert_front:	# Salvamento de registrador salvo
		addi sp, sp, -4
		sw s0, 0(sp)

		# Armazenamento de argumento
		mv s0, a0
		mv t1, a1
		mv t2, a2
		
		# Salvamento de ra
		addi sp, sp, -4
		sw ra, 0(sp)
								
		# Criacao de novo vagao
		mv a0, a1
		mv a1, a2
		call create_wagon # a0 = &vagao_criado
		
		# Atualizar prox vagao do novo vagao
		lw t0, 8(s0) # t0 = locomotiva.prox_vagao
		sw t0, 8(a0) # vagao_criado.prox_vagao = locomotiva.prox_vagao
		
		sw a0, 8(s0) # locomotiva.prox_vagao = &vagao_criado
		
		# Restauracao do ra
		lw ra, 0(sp)
		addi sp, sp, 4

		# Restauracao de registrador salvo
		lw s0, 0(sp)
		addi sp, sp, 4
		
		ret






