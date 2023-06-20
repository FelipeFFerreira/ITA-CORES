	.text
	.globl	main
main:
	li		t0, 0            # Contador i inicializado com 0
	li		t3, 4096         # Carrega o valor 4096 no registrador t3

loop_outer:
	lui		t1, 0x404        # Carrega a parte superior do endereço de memória em t1
	sw		t0, 0(t1)        # Armazena valor de i no endereço de memória

	# Chama função de delay
	jal		x0, delay

	addi	t0, t0, 1         # Incrementa o contador i
	beq		t0, t3, reset_counter # Se i == 4096, reseta contador
	j		loop_outer        # Volta para o loop

reset_counter:
	li		t0, 0            # Reseta contador para 0
	j		loop_outer        # Volta para o loop

delay:
	li		t2, 2            # Valor inicial para o delay
delay_pass:	
	addi	t2, t2, -1        # Decrementa contador de delay
	bnez	t2, delay_pass    # Se t2 != 0, continua o delay
	jr		ra               # Retorna da função de delay

