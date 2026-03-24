.data
        .align 2
        train_head:  .word 0
        .align 0

        msg_welcome: .asciz "Bem-vindo ao jogo Montagem de Trem!\n\n"

        msg_menu: .asciz "Menu:\n1 - Adicionar vagão no início\n2 - Adicionar vagão no final\n3 - Remover vagão por ID\n4 - Listar trem\n5 - Buscar vagão\n6 - Sair\n\nOpção: "

        msg_ok: .asciz "Operação realizada.\n\n"
        msg_invalid: .asciz "Opção inválida.\n\n"

.text
        .align 2
        .globl main

main:
        # Mensagem inicial
        la a0, msg_welcome
        li a7, 4
        ecall

        # Inicializa o trem com a locomotiva (ID = 0, Tipo = 0, prox = 0)
        li a0, 0
        li a1, 0
        li a2, 0

        call create_wagon # a0 = &locomotiva
	
        la t0, train_head
        sw a0, 0(t0)

menu_loop:
        # Mostra menu e lê a opção selecionada
        la a0, msg_menu
        li a7, 4
        ecall

        li a7, 5
        ecall
        mv t0, a0 # t0 = opção

        # li t1, 1
        # beq t0, t1, opcao_insert_front

        # li t1, 2
        # beq t0, t1, opcao_add_back

        # li t1, 3
        # beq t0, t1, opcao_remover

        # li t1, 4
        # beq t0, t1, opcao_listar

        # li t1, 5
        # beq t0, t1, opcao_buscar

        li t1, 6
        beq t0, t1, opcao_sair

        j opcao_invalida

opcao_invalida:
        la a0, msg_invalid
        li a7, 4
        ecall

        j menu_loop

opcao_sair:
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
insert_front:	# Salvamento de registradores
		addi sp, sp, -4
		sw s0, 0(sp)
		addi sp, sp, -4
		sw ra, 0(sp)

		# Armazenamento de argumento
		mv s0, a0
		mv t1, a1
		mv t2, a2
								
		# Criacao de novo vagao
		mv a0, a1
		mv a1, a2
		addi a2, zero, 0
		call create_wagon # a0 = &vagao_criado
		
		# Atualizar prox.vagao do novo vagao
		lw t0, 8(s0) # t0 = locomotiva.prox_vagao
		sw t0, 8(a0) # vagao_criado.prox_vagao = locomotiva.prox_vagao
		
		sw a0, 8(s0) # locomotiva.prox_vagao = &vagao_criado
		
		# Restauracao de registradores
		lw ra, 0(sp)
		addi sp, sp, 4
		lw s0, 0(sp)
		addi sp, sp, 4
		
		ret

# -----------------------------------------------
# insert_back
# argumentos:
#	- a0 : endereco da locomotiva
#	- a1 : ID
#	- a2 : tipo
# -----------------------------------------------
insert_back:	# salvamento de registradores
		addi sp, sp, -4
		sw s0, 0(sp)
		addi sp, sp, -4
		sw s1, 0(sp)
		addi sp, sp, -4
		sw ra, 0(sp)
		
		# armazenamento de argumentos
		mv s0, a0 # s0 = &locomotiva
		mv t0, a1 # t0 = ID
		mv t1, a2 # t1 = tipo

		# s1 = create_wagon(a0, a1, 0)
		mv a0, t0
		mv a1, t1
		li a2, 0
		call create_wagon
		mv s1, a0
		
		mv t1, s0 #t1 = &locomotiva
		lw t2, 8(t1) # t2 = locomotiva.prox_vagao

loop_insBack:	# t1 = &ultimo_vagao
		beq t2, zero, exLoop_insBack
		lw t1, 8(t1) # t1 = &prox_vagao
		lw t2, 8(t1) # t2 = prox_vagao.prox_vagao
		j loop_insBack
		
exLoop_insBack:	sw s1, 8(t1) # ultimo_vagao.prox_vagao = &vagao_criado
		
		# restauracao de registradores
		lw ra, 0(sp)
		addi sp, sp, 4
		lw s1, 0(sp)
		addi sp, sp, 4
		lw s0, 0(sp)
		addi sp, sp, 4
		
		ret
		
		
		
		
		
		
		 
		
		
		
		
		
		
		
		
		
		
		
		




