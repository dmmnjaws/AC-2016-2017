; CONSTANTES SIMBOLICAS

PIN						EQU 0E000H							; endereco de periferico de entrada			
POUT					EQU 0C000H							; endereco de periferico de saida			
screen_ini				EQU 8000H							; primeira celula do ecra de pixeis
screen_out_fin			EQU 8080H							; supremo dos enderecos do ecra		
endereco_flag_rot0		EQU 5000H							; endereco da flag da rotina 0	
endereco_frag_rot1		EQU 5002H							; endereco da flag da rotina 1	
endereco_flag_tcla		EQU 5004H							; endereco da flag indicadora de tecla premida	
endereco_tcla_clic		EQU 0400H							; endereco onde se guarda a tecla clicada	
y_no_chao				EQU 001BH							; desvio máximo de y (y no chao)
endereco_desvio_plat_x	EQU 5006H							; desvio da plat em x
direcao_plat			EQU 5008H							; em que direcao vai a plataforma

;***************************************************************************************

; STACK PARA SP

PLACE 1000H													; inicio da pilha
pilha: 					TABLE 100H							; criar a pilha
fim_pilha:													; fim da pilha

; TABELA DE BYTES – PARA FACILITAR A IMPRESSAO DE PIXEIS

PLACE 1300H													; inicio da tabela
Tabelab:		STRING 80H, 40H, 20H, 10H, 8H, 4H, 2H, 1H 	; tabela

; TABELAS DE FUNCOES DAS TECLAS (O que cada tecla faz a cada pixel do boneco)

PLACE 1400H
TabelaX:				WORD -1		; 1400H
						WORD 0		; 1402H
						WORD 1		; 1404H
						WORD 0		; 1406H
						WORD -1		; 1408H
						WORD 0		; 140AH
						WORD 1		; 140CH
						WORD 0		; 140EH
						WORD -1		; 1410H
						WORD 0		; 1412H
						WORD 1		; 1414H
						WORD 0		; 1416H
						WORD 0		; 1418H
						WORD 0		; 141AH
						WORD 0		; 141CH
						WORD 0		; 141EH
TabelaY:				WORD -1		; 1420H
						WORD -1		; 1422H
						WORD -1		; 1424H
						WORD 0		; 1426H
						WORD 0		; 1428H
						WORD 0		; 142AH
						WORD 0		; 142CH
						WORD 0		; 142EH
						WORD 1		; 1430H
						WORD 1		; 1432H
						WORD 1		; 1434H
						WORD 0		; 1436H
						WORD 0 		; 1438H
						WORD 0 		; 143AH
						WORD 0 		; 143CH
						WORD 0		; 143EH

; TABELAS DE PIXEIS PARA AS FIGURAS (Endereços Pares - Coordenadas Y, Endereços Impares - Coordenadas X)

PLACE 1440H																													; inicio do espaco de tabelas
Boneco:					STRING 00, 02																						; inicio da tabela de boneco
						STRING 01, 00, 01, 01, 01, 02, 01, 03, 01, 04
						STRING 02, 02
						STRING 03, 01, 03, 03
						STRING 04, 00, 04, 03																				
fim_boneco:																													; fim da tabela de boneco
Plataforma:				STRING 20, 00, 20, 01, 20, 02, 20, 03, 20, 04, 20, 05, 20, 06, 20, 07 								; inicio da tabela de boneco
						STRING 21, 00, 21, 01, 21, 02, 21, 03, 21, 04, 21, 05, 21, 06, 21, 07 
fim_plataforma:																												; fim da tabela de plataforma

; TABELA DE ROTINAS

PLACE 1700H												; inicio da tabela
tab: 					WORD	rot0					; rotina de interrupcao 0
						WORD	rot1					; rotina de interrupcao 1

;***************************************************************************************

; PROGRAMA

PLACE 0													; inicio das instrucoes maquina
inicio:					MOV BTE, tab					; iniciar a Tabela de excecoes
						MOV SP, fim_pilha				; iniciar o Stack Pointer
						EI0								; permitir rotina de interrupcao 0
						EI1
						EI								; permitir rotinas de interrupcao
					
reset:					MOV R3, 8						; testar linha 8			

ciclo1:					CALL scan						; chamar rotina scan			
						CALL limpaecra					; chamar rotina limpaecra
						MOV R10, Boneco					; o que vai imprimir?
						MOV R0, fim_boneco				; o fim da tabela da figura
						CALL desenhaobjeto				; chamar rotina desenhaobjeto
						CALL caiboneco					; chamar rotina cai boneco
						CALL moveplat					
						SHR R3, 1						; testar linha anterior		
						AND R3, R3						; ativar flag 0
						JZ reset						; evitar testar linha que não existe
						JMP ciclo1						; repetir para a linha anterior 

;***************************************************************************************	

scan:					PUSH R1							; salvar valor de R1
						PUSH R2							; salvar valor de R2
						PUSH R3							; salvar valor de R3
						PUSH R4							; salvar valor de R4
						PUSH R5							; salvar valor de R5
						PUSH R6							; salvar valor de R6
						PUSH R7							; salvar valor de R7
						PUSH R8							; salvar valor de R8
					
						MOV R0, endereco_tcla_clic		; R0 – endereco para guardar tecla
						MOV R1, PIN						; R1 – endereco do periferico in
						MOV R2, POUT					; R2 – endereco do periferico out
					
						MOV R4, 0FH						; R4 - mascara
						MOVB [R2], R3					; R3 – linha, testar linha
						MOVB R2, [R1]					; R2 – coluna, receber coluna
						AND R2, R4						; verificar se foi premida tecla
						JZ retest_no_tcla				; se nao, salta para o fim

gravar_linha:			SHR R3, 1						; transforma linha em 0, 1, 2 ou 3	
						AND R3, R3
						JZ gravar_coluna
						ADD R5, 1
						JMP gravar_linha
					
gravar_coluna:			SHR R2, 1						; transforma coluna em 0, 1, 2 ou 3	
						AND R2, R2
						JZ gravar_tecla
						ADD R6, 1
						JMP gravar_coluna
					
gravar_tecla:			SHL R5, 2						; transforma linha e coluna em tecla	
						ADD R6, R5						
						MOV [R0], R6					
			
						MOV R7, endereco_flag_tcla		; R7 – endereco da flag de tecla
						MOV R8, 1						; R8 = 1
						MOV [R7], R8					; ativa a flag de tecla com 1
						JMP retest_com_tcla				; salta para o fim

retest_no_tcla:			MOV R7, endereco_flag_tcla		; R7 –endereco de flag de tecla
						MOV R8, 0						; R8 = 0
						MOV [R7], R8					; ativa a flag de tecla com 1
				
retest_com_tcla:		POP R8							; recuperar valor de R8
						POP R7							; recuperar valor de R7
						POP R6							; recuperar valor de R6
						POP R5							; recuperar valor de R5
						POP R4							; recuperar valor de R4
						POP R3							; recuperar valor de R3
						POP R2							; recuperar valor de R2
						POP R1							; recuperar valor de R1
						RET								; retornar (fim de scan)
				
;***************************************************************************************	
	
limpaecra:				PUSH R1							; salvar valor de R1
						PUSH R2							; salvar valor de R2
						PUSH R3							; salvar valor de R3
							
					
						MOV R3, 0H						; 0000H, o valor a colocar
						MOV R1, screen_ini				; do inicio do ecra		
						MOV R2, screen_out_fin			; ao fim do ecra	
ciclo2:					MOV [R1], R3					; colocar o valor na primeira		
						ADD R1, 2						; passar para a próxima celula	
						CMP R1, R2						; verificar se já chegou ao fim	
						JNZ ciclo2						; se nao, repetir o ciclo
					
fim_limpaecra:			POP R3							; recuperar valor de R3
						POP R2							; recuperar valor de R2
						POP R1							; recuperar valor de R1
						RET								; retornar (fim de limpaecra)

;***************************************************************************************

desenhaobjeto:			PUSH R0							; salvar valor de R0
						PUSH R1							; salvar valor de R1
						PUSH R2							; salvar valor de R2
						PUSH R3							; salvar valor de R3
						PUSH R4							; salvar valor de R4
						PUSH R5							; salvar valor de R5
						PUSH R6							; salvar valor de R6
						PUSH R7							; salvar valor de R7
					
						MOV R2, endereco_flag_tcla		; R2 – endereco da flag de tecla
						MOV R2, [R2]					; exportar flag de tecla
						SUB R2, 1						; verificar se esta a 0
						JNZ fim_desenhaobjeto			; se sim salta para o fim

						MOV R2, screen_ini				; R2 – inicio do ecra	
						MOV R7, Tabelab					; R7 – inicio da tabela de bytes
					
						CALL ajustes1					; chamar rotina ajustes1		
						ADD R8, R6						; ajustar desvio de Y		
						ADD R9, R5						; ajustar desvio de X
					
						MOV R3, R0						; detetar fim da figura
						MOV R4, R10						; R4 – inicio da tabela de pixeis
						MOV R5, R10						; R5 – inicio da tabela de pixeis
						ADD R5, 1						; os Xs sao os elementos impares
					
ciclo3:					MOVB R0, [R4]					; exportar coordenada Y do pixel	
						MOVB R1, [R5]					; exportar coordenada X do pixel
						CALL ajustaregistos				; chamar rotina ajustregistos
						CALL print						; chamar rotina print
						ADD R4, 2						; passar para o proximo pixel (Y)
						ADD R5, 2						; passar para o próximo pixel (X)
						CMP R4, R3						; detetar se chegou ao ultimo pixel
						JNZ ciclo3						; se nao, repete ciclo para proximo

fim_desenhaobjeto:		POP R7							; recuperar valor de R7
						POP R6							; recuperar valor de R6
						POP R5							; recuperar valor de R5
						POP R4							; recuperar valor de R4
						POP R3							; recuperar valor de R3
						POP R2							; recuperar valor de R2
						POP R1							; recuperar valor de R1
						POP R0							; recuperar valor de R0
						RET								; retornar (fim de desenhaboneco)
						
no_tecla:				PUSH R0
						PUSH R1
						
						MOV R0, endereco_tcla_clic
						MOV R1, 5
						MOV [R0], R1
						
						POP R1
						POP R0			
						
					
print:					PUSH R0							; salvar valor de R0
						PUSH R1							; salvar valor de R1
						PUSH R2							; salvar valor de R2
						PUSH R3							; salvar valor de R3
						PUSH R5							; salvar valor de R5
						PUSH R6							; salvar valor de R6
						PUSH R7							; salvar valor de R7
									
						MOV R3, R1						; clonar R1		
						SHL R0, 2						; ajuste ao inicio do ecrã, com Y 	
						ADD R2, R0						; ajustar endereco a Y
						SHR R1, 3						; obter ajuste extra com base em X
						ADD R2, R1						; ajustar endereco a X
						SHL R1, 3						; X sem o resto da divisao por 8
						SUB R3, R1						; obter o resto da divisao por 8
						ADD R7, R3						; selecionar byte correto na Tabelab	
						MOVB R5, [R7]					; exportar byte correto		
						MOVB R6, [R2]					; R6 – byte original
						OR R6, R5						; concatenar bytes
						MOVB [R2], R6					; produzir byte no ecra
					
						POP R7							; recuperar valor de R7
						POP R6							; recuperar valor de R6
						POP R5							; recuperar valor de R5
						POP R3							; recuperar valor de R3
						POP R2							; recuperar valor de R2
						POP R1							; recuperar valor de R1
						POP R0							; recuperar valor de R0
						RET								; retornar (fim de print)	
					
ajustes1:				PUSH R4							; salvar valor de R4
						PUSH R7							; salvar valor de R7
						MOV R7, endereco_tcla_clic		; R7 – endereco guardada tecla	
						MOV R4, [R7]					; exportar tecla clicada		
						MOV R5, TabelaX					; R5 – inicio da TabelaX		
						MOV R6, TabelaY					; R6 – inicio da TabelaY		
						SHL R4, 1						; ajustat tecla para palavras	
						ADD R5, R4						; somar tecla ao inicio de TabelaX
						ADD R6, R4						; somar tecla ao inicio de TabelaY
						MOV R5, [R5]					; exportar operação correta para X
						MOV R6, [R6]					; exportar operação correta para Y
						POP R7							; recuperar valor de R7
						POP R4							; recuperar valor de R4
						RET								; retornar (fim de ajustes1)	



					
ajustaregistos:			ADD R0, R8						; ultimo ajuste da coordenada X	
						ADD R1, R9						; ultimo ajuste da coordenada Y
						RET								; retornar (fim ajusteregistos)

;***************************************************************************************

caiboneco:				PUSH R0							; salvar o valor de R0
						PUSH R1							; salvar o valor de R1
						PUSH R2							; salvar o valor de R2
						PUSH R3							; salvar o valor de R3
						PUSH R4							; salvar o valor de R4
						PUSH R5							; salvar o valor de R5
						PUSH R6							; salvar o valor de R6
						PUSH R7							; salvar o valor de R7
					
test_tcla:				MOV R0, endereco_flag_tcla		; R0 – endereco da flag de tecla
						MOV R0, [R0]					; exportar flag de tecla
						SUB R0, 1						; verificar se esta a 1
						JZ fim_caiboneco				; se sim salta para o fim
			
test_rot0:				MOV R0, endereco_flag_rot0		; R0 – endereco da flag de rotina 0
						MOV R0, [R0]					; exportar flag de rotina
						SUB R0, 1						; verificar se esta 0 (esta no chao)
						JNZ fim_caiboneco				; se sim, salta para o fim
				
continue:				MOV R2, endereco_tcla_clic		; R2 – endereco da tecla clicada
						MOV R3, 9						; simular tecla 9
						MOV [R2], R3					; importar tecla 9
						MOV R2, endereco_flag_tcla		; R2 – endereco de flag da tecla
						MOV R3, 1						; simular que uma tecla foi premida
						MOV [R2], R3					; importar 1 para a flag
						MOV R10, Boneco					; o que vai imprimir?						
						MOV R0, fim_boneco				; o fim da tabela da figura
						CALL limpaecra					; chamar rotina limpaecra
						CALL desenhaobjeto				; chamar rotina desenhaobjeto
						MOV R3, 0						; simular que não a tecla premida
						MOV [R2], R3					; exportar 0 para a flag
						MOV R0, endereco_flag_rot0		; R3 – endereco de flag de rotina 0
						MOV R1, 0						; repor flag a 0
						MOV [R0], R1					; importar 0 para a flag
					
fim_caiboneco:			POP R7							; recuperar valor de R7
						POP R6							; recuperar valor de R6
						POP R5							; recuperar valor de R5
						POP R4							; recuperar valor de R4
						POP R3							; recuperar valor de R3
						POP R2							; recuperar valor de R2
						POP R1							; recuperar valor de R1
						POP R0							; recuperar valor de R0
						RET								; retornar (fim de caiboneco)

;***************************************************************************************

moveplat:				PUSH R0
						PUSH R1
						PUSH R2
						PUSH R3
						PUSH R4
						PUSH R5
						PUSH R6
						PUSH R7
						PUSH R8
						PUSH R9
						PUSH R10
						
						MOV R2, endereco_flag_tcla
						MOV R3, endereco_tcla_clic
						MOV R4, direcao_plat
						MOV R0, endereco_frag_rot1
						MOV R0, [R0]
						MOV R1, 1
						CMP R0, R1
						JZ direita
						MOV R1, -1
						CMP R0, R1
						JZ esquerda
						CALL print_algures
						JMP fim_moveplat
						
direita:				MOV R1, 1
						MOV [R2], R1
						MOV R1, 4
						MOV [R3], R1
						MOV [R4], R1
						CALL print_algures
						JMP fim_moveplat

esquerda:				MOV R1, 1
						MOV [R2], R1
						MOV R1, 6
						MOV [R3], R1
						MOV [R4], R1
						CALL print_algures
						JMP fim_moveplat
						
print_algures:			PUSH R8
						PUSH R9
						
						MOV R1, 1
						MOV [R2], R1
						MOV R4, [R4]
						MOV [R3], R4
						CALL limpaecra
						MOV R10, Plataforma				; o que vai imprimir?
						MOV R0, fim_plataforma			; o fim da tabela da figura
						MOV R8, 0
						MOV R9, endereco_desvio_plat_x
						MOV R9, [R9]
						CALL desenhaobjeto
						MOV R8, endereco_desvio_plat_x
						MOV [R8], R9
						
						POP R9
						POP R8
						RET
						
fim_moveplat:			POP R10
						POP R9
						POP R8
						POP R7
						POP R6
						POP R5
						POP R4
						POP R3
						POP R2
						POP R1
						RET						
						
;***************************************************************************************
				
rot0:					PUSH R1							; salvar valor de R1
						PUSH R2							; salvar valor de R2
						PUSH R3							; salvar valor de R3
						PUSH R4							; salvar valor de R4
					
						MOV R3, y_no_chao				; R3 – ajuste max de y (no chao)
						CMP R8, R3						; o boneco esta no chao?
						JZ close						; se sim, saltar para o fim
					
						MOV R1, 1						; R1 com valor de flag
						MOV R2, endereco_flag_rot0		; R2 – endereco de flag de rotina 0
						MOV [R2], R1					; importar 1 para a flag de rotina 0

					
close:					POP R4							; recuperar valor de R4
						POP R3							; recuperar valor de R3
						POP R2							; recuperar valor de R2
						POP R1							; recuperar valor de R1
						RFE								; retornar (fim da interrupcao 0)
						
rot1:					PUSH R1							; salvar valor de R1
						PUSH R2							; salvar valor de R2
						PUSH R3							; salvar valor de R3
						PUSH R4							; salvar valor de R4
						
						MOV R1, endereco_frag_rot1		; R1 - endereco da flag rot1
						MOV R2, endereco_desvio_plat_x	; R2 - endereco de desvio da plat
						MOV R2, [R2]					; exportar desvio lateral da plat
						MOV R3, 001BH					; limite direito
						CMP R2, R3						; esta encostada ao limite direito?
						JZ limdireito					; se sim, saltar para limdireito
						SUB R2, 1						; esta encostada ao limite esquerdo?
						JN limesquerdo					; se sim, saltar para limesquerdo
						JMP algures						; nem um nem outro, saltar para fim
limdireito:				MOV R3, 1						; ativar flag a 1
						MOV [R1], R3
						JMP close2
limesquerdo:			MOV R3, -1						; ativar flag a -1
						MOV [R1], R3
						JMP close2
algures:				MOV R3, 0						; ativar flag a 0
						MOV [R1], R3
						
close2:					POP R4							; recuperar valor de R4
						POP R3							; recuperar valor de R3
						POP R2							; recuperar valor de R2
						POP R1							; recuperar valor de R1
						RFE
						


					
