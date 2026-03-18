		.data
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
create_wagon:	# Salvamento dos argumentos
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
		
		jr ra

# -----------------------------------------------
# insert_front
# argumentos:
#	- a0 : endereco da locomotiva
#	- a1 : ID
#	- a2 : Tipo
# -----------------------------------------------
insert_front:	# Salvamento dos argumentos
		mv t1, a0
		mv t2, a1
		mv t3, a2
		
		# Salvamento do endereco de retorno
		# ...

		# Criar vagao
		mv a0, t1
		mv a1, t2
		lw a2, 8(t1) # carregar como argumento do novo vagao o vagao que vinha logo apos a locomotiva		
		jal ra, create_wagon # < --- Problema
		
		# Atualizar prox endereco da locomotiva
		sw a0, 8(t1)
		
		jr ra # < --- Problema
		
				
