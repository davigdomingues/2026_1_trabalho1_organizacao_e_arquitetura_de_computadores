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
#	- a1 : ID
#	- a2 : Tipo
#	- a3 : Prox vagao
# retorno:
#	- a0 : Endereco do no' do vagao
# -----------------------------------------------

create_wagon:	# Alocacao de espaco
		li a7, 9 # codigo de sbrk
		li a0, 12 # 12 bytes = 4 bytes (ID=Int) + 4 bytes (Tipo=Int) + 4 bytes (End. do prox. no')
		ecall # a0 = endereco da area reservada
	
		# Armazenamento do ID
		sw a1, 0(a0)
		
		# Armazenamento do tipo
		sw a2, 4(a0)
		
		# Armazenamento do endereco do prox vagao
		sw a3, 8(a0)
		
		jr ra

# -----------------------------------------------
# insert_front
# argumentos:
#	- a1 : endereco da locomotiva
#	- a2 : ID
#	- a3 : Tipo
# -----------------------------------------------


		
				
