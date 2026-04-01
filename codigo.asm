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
        msg_wagon_id: .asciz "Digite o ID do vagão (inteiro, maior que 0): "
        msg_wagon_type: .asciz "Digite o tipo do vagão (1..3):\n1 - Carga\n2 - Passageiro\n3 - Combustível\nTipo: "

        # Mensagens de erro ou comportamento inválido
        msg_id_invalid: .asciz "ID inválido. Use um inteiro positivo.\n\n"
        msg_id_duplicate: .asciz "ID já existente no trem. Escolha outro ID.\n\n"
        msg_type_invalid: .asciz "Tipo inválido. Use 1, 2 ou 3.\n\n"
        msg_wagon_not_found: .asciz "Vagão não encontrado.\n\n"
        msg_sem_remocao: .asciz "Não é possível remover a locomotiva.\n\n"

        # Mensagens de sucesso da operação
        msg_add_ok_front: .asciz "Vagão adicionado no início.\n\n"
        msg_add_ok_back: .asciz "Vagão adicionado no final.\n\n"
        msg_remove_ok: .asciz "Vagão removido com sucesso.\n\n"
        msg_search_ok: .asciz "Vagão foi encontrado com sucesso.\n\n"

        # Mensagem para printar dados de vagão encontrado 
        next_line: .asciz "\n"
        msg_type: .asciz "Tipo: "
        msg_ID: .asciz "ID: "
        msg_cargo: .asciz "Vagão de Carga\n"
        msg_passenger: .asciz "Vagão de Passageiro\n"
        msg_fuel: .asciz "Vagão de Combustível\n"


        .align 2

menu_tabela:
        .word opcao_insert_front
        .word opcao_insert_back
        .word handle_remove_wagon
        .word opcao_listar
        .word opcao_buscar
        .word opcao_sair

        .align 2

# tabela de operações de casos durante a remoção do vagão, via ID
rem_tabela:
        .word _rem_case_ok # status 0 = ok
        .word _rem_case_not_found # status 1 = não encontrado
        .word _rem_case_invalid_id # status 2 = id inválido
        .word _rem_case_cannot_remove_locomotive # status 3 = locomotiva

# tabela de operacoes de casos durante a adicao de vagao no inicio
ins_tabela:
        .word _ins_case_ok # status 0 = ok
        .word _ins_case_invalid_type # status 1 = tipo invalido
        .word _ins_case_invalid_id # status 2 = id invalido
        .word _ins_case_id_already_inserted # status 3 = id ja inserido

#tabela para operações de casos durante busca de vagão por id
search_tabela:
        .word _search_case_ok # status 0 = ok
        .word _search_case_invalid_id # status 1 = id invalido
        .word _search_case_not_found # status 2 = id não encontrado

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
        # Salvamento de ra na pilha
        addi sp, sp, -4
        sw ra, 0(sp)

        # Solicitação do ID - a1 = id
        la a0, msg_wagon_id
        li a7, 4
        ecall
        li a7, 5
        ecall
        mv a1, a0 

        # Solicitacao do tipo - a2 = tipo
        la a0, msg_wagon_type
        li a7, 4
        ecall
        li a7, 5
        ecall
        mv a2, a0

        # carregamento da head (economia de operação de deslocamento da pilha)
        la t0, train_head
        lw a0, 0(t0) # a0 = &locomotiva (head/sentinela)
        call insert_front  # (a0 = head, a1 = id, a2 = tipo) -> a0 = status

        lw ra, 0(sp)
        addi sp, sp, 4

        # Status em a0: 0..3
        mv t0, a0

        # switch via tabela (igual menu_loop)
        slli t0, t0, 2
        la t1, ins_tabela

        add t1, t1, t0
        lw t2, 0(t1)

        jalr zero, t2, 0 #jr r2

opcao_insert_back:
        # Salvamento de ra na pilha
        addi sp, sp, -4
        sw ra, 0(sp)

        # Solicitação do ID - a1 = id
        la a0, msg_wagon_id
        li a7, 4
        ecall
        li a7, 5
        ecall
        mv a1, a0 

        # Solicitacao do tipo - a2 = tipo
        la a0, msg_wagon_type
        li a7, 4
        ecall
        li a7, 5
        ecall
        mv a2, a0

        # carregamento da head (economia de operação de deslocamento da pilha)
        la t0, train_head
        lw a0, 0(t0) # a0 = &locomotiva (head/sentinela)
        call insert_back  # (a0 = head, a1 = id, a2 = tipo) -> a0 = status

        lw ra, 0(sp)
        addi sp, sp, 4

        # Status em a0: 0..3
        mv t0, a0

        # switch via tabela (igual menu_loop)
        slli t0, t0, 2
        la t1, ins_tabela

        add t1, t1, t0
        lw t2, 0(t1)

        jalr zero, t2, 0 #jr r2


# Remoção em lista encadeada simples, mantém (prev, curr) e ao achar faz prev.prox = curr.prox (offset 8 = prox)
handle_remove_wagon:
        # Salvamento de ra na pilha
        addi sp, sp, -4
        sw ra, 0(sp)

        # Solicitação do ID
        la a0, msg_wagon_id
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
        j _print_and_ret

_rem_case_ok:
        la a0, msg_remove_ok
        j _print_and_ret

_rem_case_not_found:
        la a0, msg_wagon_not_found
        j _print_and_ret

_rem_case_invalid_id:
        la a0, msg_id_invalid
        j _print_and_ret

_rem_case_cannot_remove_locomotive:
        la a0, msg_sem_remocao
        j _print_and_ret


opcao_listar:
        la a0, msg_ok
        li a7, 4
        ecall

        ret

opcao_buscar:
        # Salvamento de ra na pilha
        addi sp, sp, -4
        sw ra, 0(sp)

        # Solicitação do ID
        la a0, msg_wagon_id
        li a7, 4
        ecall
        li a7, 5
        ecall
        mv a1, a0 #  a1 = id
        
        # carregamento da head (economia de operação de deslocamento da pilha)
        la t0, train_head
        lw a0, 0(t0) # a0 = &locomotiva (head/sentinela)
	call search_wagon
	
        # Carregamento de ra da pilha
        lw ra, 0(sp)
        addi sp, sp, 4

        # switch via tabela 
        mv t0, a0
        slli t0, t0, 2
        la t1, search_tabela

        add t1, t1, t0
        lw t2, 0(t1)

        jalr zero, t2, 0


_search_case_ok:
        # a2 contém o endereço do nó encontrado
        # Carrega ID
        lw t0, 0(a2)         # t0 = id
        # Carrega tipo
        lw t1, 4(a2)         # t1 = tipo

        # Imprime ID
        la a0, msg_ID
        li a7, 4
        ecall
        mv a0, t0
        li a7, 1
        ecall

        # Imprime nova linha
        la a0, next_line
        li a7, 4
        ecall

        # Imprime tipo
        la a0, msg_type
        li a7, 4
        ecall
        # Seleciona mensagem do tipo
        li t2, 1
        beq t1, t2, _print_tipo_carga
        li t2, 2
        beq t1, t2, _print_tipo_passageiro
        li t2, 3
        beq t1, t2, _print_tipo_combustivel
        j _print_and_ret

_print_tipo_carga:
        la a0, msg_cargo
        j _print_and_ret

_print_tipo_passageiro:
        la a0, msg_passenger
        j _print_and_ret

_print_tipo_combustivel:
        la a0, msg_fuel
        j _print_and_ret

_search_case_not_found:
        la a0, msg_wagon_not_found
        j _print_and_ret

_search_case_invalid_id:
        la a0, msg_id_invalid
        j _print_and_ret


opcao_invalida:
        la a0, msg_invalid
        li a7, 4
        ecall

        j menu_loop

opcao_sair:
        li a7, 10
        ecall


#Funções comuns a mais de uma opção 
## Funções de retorno de inserção (fim e inicio)
_ins_case_ok:
        la a0, msg_add_ok_back
        j _print_and_ret

_ins_case_invalid_type: 
        la a0, msg_type_invalid
        j _print_and_ret

_ins_case_invalid_id:
        la a0, msg_id_invalid
        j _print_and_ret

_ins_case_id_already_inserted:
        la a0, msg_id_duplicate
        j _print_and_ret

## Todas as funções de retorno 
_print_and_ret:
        li a7, 4
        ecall
        ret
# -----------------------------------------------
# create_wagon
# argumentos:
#	    - a0 : ID
#	    - a1 : Tipo
#	    - a2 : Prox vagao
# retorno:
#	    - a0 : Endereco do no' do vagao
# observacoes:
#       1 - Nó: [0] = id, [4] = tipo, [8] = prox
#       2 - Tipos:
#           - 0 : locomotiva
#           - 1 : carga
#           - 2 : passageiro
#           - 3 : combustivel 
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


# ----------------------------------------------------------------------------------------------
# verify_id
# argumentos:
#	    - a0 : endereco da locomotiva
#       - a1 : id
# retorno (a0):
#       - 0 : id nao encontrado
#       - 1 : id encontrado
# ----------------------------------------------------------------------------------------------
verify_id:
        # Salvamento de registradores
        addi sp, sp, -8
        sw s0, 0(sp)
        sw s1, 4(sp)
        
        # Salvamento de argumentos
        add s0, a0, zero
        add s1, a1, zero

        add t0, s0, zero # t0 = &locomotiva
        lw t1, 0(t0) # t1 = locomotiva.id 
        lw t2, 8(t0) # t2 = locomotiva.prox

_verify_id_loop:
        beq s1, t1, _found_verify_id
        beq t2, zero, _exit_verify_id_loop
        add t0, t2, zero # t0 = vagao.prox
        lw t1, 0(t0) # t1 = vagao.prox->id
        lw t2, 8(t0) # t2 = vagao.prox->prox
        j _verify_id_loop

_found_verify_id:
        addi a0, zero, 1
        j _end_verify_id

_exit_verify_id_loop:
        add a0, zero, zero

_end_verify_id:
        # Restauracao de registradores
        lw s0, 0(sp)
        lw s1, 4(sp)
        addi sp, sp, 8

        ret
# ----------------------------------------------------------------------------------------------
# insert_front
# argumentos:
#	    - a0 : endereco da locomotiva
#       - a1 : id
#       - a2 : tipo
# retorno (a0):
#       - 0 : adicionado com sucesso
#       - 1 : tipo invalido
#       - 2 : id invalido (id < 0)
#       - 3 : id ja inserido
# ----------------------------------------------------------------------------------------------
insert_front:	
        # salvamento de registradores
        addi sp, sp, -16
        sw s0, 0(sp)
        sw s1, 4(sp)
        sw s2, 8(sp)
        sw ra, 12(sp)

        # Salvamento de argumentos
        add s0, a0, zero # s0 = &locomotiva
        add s1, a1, zero # s1 = id
        add s2, a2, zero # s2 = tipo

        # Verificacao de id (id nao negativo)
        bge s1, zero, _insert_front_verificacao_se_id_ja_inserido
        addi a0, zero, 2 # caso id negativo
        j _end_insert_front

_insert_front_verificacao_se_id_ja_inserido:
        add a0, s0, zero
        add a1, s1, zero
        call verify_id # a0 = 0 ou 1
        beq a0, zero, _insert_front_id_valido
        # Caso id ja inserido no vagao
        addi a0, zero, 3 # codigo de id ja inserido

        j _end_insert_front 

_insert_front_id_valido:
        # Verificacao de tipo
        addi t0, zero, 1
        blt s2, t0, _insert_front_tipo_invalido
        addi t0, zero, 3
        blt t0, s2, _insert_front_tipo_invalido
        
        # Caso tipo valido - criacao de novo vagao
        add a0, s1, zero
        add a1, s2, zero
        lw a2, 8(s0) # a2 = locomotiva.prox
        call create_wagon # a0 = &vagao_criado
        
        # Atualizar locomotiva.prox
        sw a0, 8(s0) # locomotiva.prox = &vagao_criado
       
        # Codigo de sucesso
        add a0, zero, zero

        j _end_insert_front

_insert_front_tipo_invalido:
        addi a0, zero, 1 # codigo de tipo invalido

_end_insert_front:
        # Restauracao de registradores
        lw s0, 0(sp)
        lw s1, 4(sp)
        lw s2, 8(sp)
        lw ra, 12(sp)
        addi sp, sp, 16

        ret

# ----------------------------------------------------------------------------------------------
# insert_back
# argumentos:
#	    - a0 : endereco da locomotiva
#	    - a1 : ID
#	    - a2 : tipo
# retorno (a0):
#       - 0 : adicionado com sucesso
#       - 1 : tipo invalido
#       - 2 : id invalido (id < 0)
#       - 3 : id ja inserido
# ----------------------------------------------------------------------------------------------
insert_back:	
        # salvamento de registradores
        addi sp, sp, -20
        sw s0, 0(sp)
        sw s1, 4(sp)
        sw s2, 8(sp)
        sw s3, 12(sp)
        sw ra, 16(sp)

        # salvamento de argumentos
        add s0, a0, zero # s0 = &locomotiva
        add s1, a1, zero # s1 = id
        add s2, a2, zero # s2 = tipo

        # Verificacao de id (id nao negativo)
        bge s1, zero, _insert_back_verificacao_se_id_ja_inserido
        addi a0, zero, 2 # caso id negativo
        j _end_insert_back

_insert_back_verificacao_se_id_ja_inserido:
        add a0, s0, zero
        add a1, s1, zero
        call verify_id # a0 = 0 ou 1
        beq a0, zero, _insert_back_id_valido
        # Caso id ja inserido no vagao
        addi a0, zero, 3 # codigo de id ja inserido
        j _end_insert_back

_insert_back_id_valido:
        # Verificacao de tipo
        addi t0, zero, 1
        blt s2, t0, _insert_back_tipo_invalido
        addi t0, zero, 3
        blt t0, s2, _insert_back_tipo_invalido
        
        # caso tipo valido - s3 = create_wagon(s1, s2, 0)
        add a0, s1, zero
        add a1, s2, zero
        addi a2, zero, 0
        call create_wagon
        add s3, a0, zero

        mv t1, s0 #t1 = &locomotiva
        lw t2, 8(t1) # t2 = locomotiva.prox

        # t1 = &ultimo_vagao apos o loop
_loop_insert_back:	
        beq t2, zero, _exit_loop_insert_back
        add t1, t2, zero # t1 = &vagao.prox
        lw t2, 8(t1) # t2 = vagao.prox->prox
        j _loop_insert_back
        
_exit_loop_insert_back:
        sw s3, 8(t1) # ultimo_vagao.prox_vagao = &vagao_criado
        add a0, zero, zero # codigo de sucesso
        j _end_insert_back

_insert_back_tipo_invalido:
        addi a0, zero, 1

_end_insert_back:
        # restauracao de registradores
        lw s0, 0(sp)
        lw s1, 4(sp)
        lw s2, 8(sp)
        lw s3, 12(sp)
        lw ra, 16(sp)
        addi sp, sp, 20
        
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
        # Condicional para a remoção do vagão identificado
        bltz a1, _rem_ret_invalid_id
        beqz a1, _rem_ret_no_remotion

        mv t3, a0 # prev = locomotiva
        lw t2, 8(a0) # curr = locomotiva.prox

# Iteração para a lógica de remove_wagon
_rem_loop:
        beqz t2, _rem_ret_not_found
        lw t4, 0(t2) # curr.id
        beq t4, a1, _rem_found # Vagão encontrado

        mv t3, t2
        lw t2, 8(t2)
        j _rem_loop

# Atualização das referências da lista encadeada simples
_rem_found:
        lw t5, 8(t2) # curr.prox
        sw t5, 8(t3) # prev.prox = curr.prox

        li a0, 0
        ret

_rem_ret_not_found:
        li a0, 1
        ret

_rem_ret_invalid_id:
        li a0, 2
        ret

_rem_ret_no_remotion:
        li a0, 3
        ret

# ----------------------------------------------------------------------------------------------
# search_wagon: busca vagão por id
# argumentos:
#       - a0 : endereco da locomotiva (head/sentinela)
#       - a1 : ID alvo da busca
# retorno:
#       - a0: 
#             0 : encontrado com sucesso
#            1 : ID inválido (ID < 0)
#            2 : não encontrado
#       - a2: 
#             (se a0 == 0) endereco do nó encontrado
# ----------------------------------------------------------------------------------------------
search_wagon: 
        
        mv t1, a1 # copia ID alvo para t1
        bltz t1, _search_invalid_id # se (t1 < 0) id inválido
        beqz t1, _search_invalid_id # se (t1 == 0) id inválido (locomotiva)
        mv t0, a0 # t0 = ponteiro para nó atual

loop_search: 
        beqz t0, _search_id_not_found # se (t0 == NULL) não encontrado
        lw t2, 0(t0) # t2 = nó_atual.id
        beq t2, t1, _search_id_found # se (t2 == t1) encontrado
        lw t0, 8(t0) # t0 = nó_atual.prox
        j loop_search # continua o loop

_search_id_found: 
        mv a2, t0 # a2 = endereço do nó encontrado
        li a0, 0
        ret        
_search_invalid_id: 
        li a0, 1
        ret
_search_id_not_found: 
        li a0, 2
        ret