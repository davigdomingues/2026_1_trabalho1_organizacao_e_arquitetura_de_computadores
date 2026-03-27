.data
        .align 2
        train_head:  .word 0
        .align 0

        # Mensagens gerais
        msg_welcome: .asciz "Bem-vindo ao jogo Montagem de Trem!\n\n"
        msg_ok: .asciz "Operação realizada.\n\n"
        msg_invalid: .asciz "Opção inválida.\n\n"

        # Mensagens de entrada 
        msg_menu: .asciz "Menu:\n1 - Adicionar vagão no início\n2 - Adicionar vagão no final\n3 - Remover vagão por ID\n4 - Listar trem\n5 - Buscar vagão\n6 - Sair\n\nOpção: "
        msg_id_vagao: .asciz "Digite o ID do vagão (inteiro, maior que 0): "
        msg_tipo_vagao: .asciz "Digite o tipo do vagão (1..3):\n1 - Carga\n2 - Passageiro\n3 - Combustível\nTipo: "

        # Mensagens de erro ou comportamento inválido
        msg_id_invalido: .asciz "ID inválido. Use um inteiro positivo.\n\n"
        msg_id_duplicado: .asciz "ID já existente no trem. Escolha outro ID.\n\n"
        msg_tipo_invalido: .asciz "Tipo inválido. Use 1, 2 ou 3.\n\n"
        msg_nao_encontrado: .asciz "Vagão não encontrado.\n\n"
        msg_sem_remocao: .asciz "Não é possível remover a locomotiva.\n\n"

        # Mensagens de sucesso da operação
        msg_add_ok_front: .asciz "Vagão adicionado no início.\n\n"
        msg_add_ok_back: .asciz "Vagão adicionado no final.\n\n"
        msg_remove_ok: .asciz "Vagão removido com sucesso.\n\n"

        .align 2

menu_tabela:
        .word opcao_insert_front
        .word opcao_add_back
        .word opcao_remover
        .word opcao_listar
        .word opcao_buscar
        .word opcao_sair

        .align 2

# tabela de operações de casos durante a remoção do vagão, via ID
rem_tabela:
        .word _rem_case_ok # status 0 = ok
        .word _rem_case_nao_encontrado # status 1 = não encontrado
        .word _rem_case_id_invalido # status 2 = id inválido
        .word _rem_case_sem_remocao # status 3 = locomotiva

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
        # Mostra o menu e lê a opção selecionada
        la a0, msg_menu
        li a7, 4
        ecall

        li a7, 5
        ecall
        mv t0, a0 # t0 = opção

        # Valida intervalo [1..6]
        li t1, 1
        blt t0, t1, opcao_invalida
        li t1, 6
        bgt t0, t1, opcao_invalida

        # Índice = opção - 1 (em relação ao menu_tabela)
        addi t0, t0, -1
        slli t0, t0, 2 # offset = (op-1) * 4
        la t1, menu_tabela
        add t1, t1, t0
        lw t2, 0(t1) # t2 = endereco do handler

        jalr ra, t2, 0 # chama handler

        j menu_loop

# Handlers das opções
opcao_insert_front:
        la a0, msg_ok
        li a7, 4
        ecall

        ret

opcao_add_back:
        la a0, msg_ok
        li a7, 4
        ecall

        ret

# Remoção em lista encadeada simples, mantém (prev, curr) e ao achar faz prev.prox = curr.prox (offset 8 = prox)
opcao_remover:
        # Salvamento de ra na pilha
        addi sp, sp, -4
        sw ra, 0(sp)

        # Solicitação do ID
        la a0, msg_id_vagao
        li a7, 4
        ecall

        li a7, 5
        ecall
        mv a1, a0 # a1 = id_alvo

        # carregamento da head (economia de operação de deslocamento da pilha)
        la t0, train_head
        lw a0, 0(t0) # a0 = &locomotiva (head/sentinela)
        call remove_wagon # (a0 = head, a1 = id) -> a0 = status

        lw ra, 0(sp)
        addi sp, sp, 4

        # Status em a0: 0..3
        mv t0, a0

        # Validação de intervalo [0..3]
        bltz t0, _rem_case_default
        li t1, 3
        bgt t0, t1, _rem_case_default

        # switch via tabela (igual menu_loop)
        slli t0, t0, 2
        la t1, rem_tabela

        add t1, t1, t0
        lw t2, 0(t1)

        jalr zero, t2, 0

_rem_case_default:
        la a0, msg_invalid
        j _rem_print_and_ret

_rem_case_ok:
        la a0, msg_remove_ok
        j _rem_print_and_ret

_rem_case_nao_encontrado:
        la a0, msg_nao_encontrado
        j _rem_print_and_ret

_rem_case_id_invalido:
        la a0, msg_id_invalido
        j _rem_print_and_ret

_rem_case_sem_remocao:
        la a0, msg_sem_remocao
        j _rem_print_and_ret

_rem_print_and_ret:
        li a7, 4
        ecall

        ret

opcao_listar:
        la a0, msg_ok
        li a7, 4
        ecall

        ret

opcao_buscar:
        la a0, msg_ok
        li a7, 4
        ecall
        
        ret

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

# ----------------------------------------------------------------------------------------------
# remove_wagon
# argumentos:
#       - a0 : endereco da locomotiva (head/sentinela)
#       - a1 : ID do vagão a remover
#
# retorno (a0):
#       - 0 : removido com sucesso
#       - 1 : vagão nao encontrado
#       - 2 : ID inválido (ID < 0)
#       - 3 : não permite remover locomotiva (ID == 0)
#
# observações:
#       1 - Nó: [0] = id, [4] = tipo, [8] = prox
#
#       2 - A função foi transformada em uma Função Folha. Como ela não executa 
#       chamadas (call/jal) internamente, o registrador 'ra'permanece intacto. 
#       Logo, a alocação e a liberação de espaço na pilha não são necessárias aqui.
# ----------------------------------------------------------------------------------------------
remove_wagon:
        bltz a1, _rem_ret_id_invalido
        beqz a1, _rem_ret_sem_remocao

        mv t3, a0 # prev = locomotiva
        lw t2, 8(a0) # curr = locomotiva.prox

_rem_loop:
        beqz t2, _rem_ret_nao_encontrado
        lw t4, 0(t2) # curr.id
        beq t4, a1, _rem_found

        mv t3, t2
        lw t2, 8(t2)
        j _rem_loop

_rem_found:
        lw t5, 8(t2) # curr.prox
        sw t5, 8(t3) # prev.prox = curr.prox

        li a0, 0
        ret

_rem_ret_nao_encontrado:
        li a0, 1
        ret

_rem_ret_id_invalido:
        li a0, 2
        ret

_rem_ret_sem_remocao:
        li a0, 3
        ret