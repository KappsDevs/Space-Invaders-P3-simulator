;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR              EQU     0Ah
FIM_TEXTO       EQU     '@'

IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
INITIAL_SP      EQU     FDFFh
CURSOR		    EQU     FFFCh
CURSOR_INIT		EQU		FFFFh
ROW_POSITION	EQU		0d
COL_POSITION	EQU		0d


SHIFT_LEFT		EQU		8d

STR_COLUMN		EQU		33d			; Linha e Coluna de Win/LoseStr
STR_LINE		EQU		3d

ATIVAR_TEMP     EQU     FFF7h    	; este porto permite dar início ou parar uma contagem por escrita,
CONF_TEMP       EQU     FFF6h	 	; uma escrita para este endereço define o número de unidades de contagem
VAZIO 			EQU		' '
TIRO_NAVE		EQU		'^'


CARACTERES		EQU		81d		 	;quantidade de caracteres por linha

RIGHT_BORDER	EQU     79d
LEFT_BORDER		EQU		0d

MAX_SCORE		EQU		825d		;825d	
PONTUACAO		EQU		15d			; Pontuação obtida por inimigo		

LIMITE_BALA		EQU		4d

BORDAS			EQU		'#'

ALIEN			EQU		'X'
ALIEN_LEFT_LIM	EQU		1d
ALIEN_RIGHT_LIM	EQU		78d
ALIEN_LINE_QNT	EQU		5d			; quantidade das linhas com aliens 
ALIEN_LINE		EQU		0d			; zerar as linhas
ALIEN_LINHA_LIM	EQU		15d

ALIEN_RESET_Y	EQU		1d			; posição do alien no momento do reset
ALIEN_RESET_X	EQU		11d
ALIEN_LINHA_INI	EQU		4d
ALIEN_COL_INI	EQU		29d
STOP_RIGHT_RESET EQU	27d
STOP_LEFT_RESET	EQU		51d

QNT_SUM_ALIEN	EQU		4d			; como pra descer eu pego a coluna, eu somo mais 4 pra baixo para pegar o ultimo X

TOTAL_LINE		EQU   	24d

SHIP_TAM_MOVE	EQU		7d

LINE_SCORE_VIDA	EQU		1d
COL_THIRD_LIFE	EQU		77d
COL_SECOND_LIFE	EQU		75d
COL_FIRST_LIFE	EQU		73d

COL_THIRD_SCORE	EQU		13d
COL_SEC_SCORE	EQU		12d
COL_FIRST_SCORE	EQU		11d

TABELA_ASCII	EQU 	48d

OFF 			EQU  	0d			; variável de controle para 'ligar'	e 'desligar' a bala 
ON 				EQU     1d

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

                ORIG    8000h

LINE0			STR     '################################################################################', FIM_TEXTO
LINE1			STR     '# SCORE < 0000 >                                                   LIFE: * * * #', FIM_TEXTO
LINE2			STR     '#                                                                              #', FIM_TEXTO
LINE3			STR     '#                                                                              #', FIM_TEXTO
LINE4			STR     '#                            X X X X X X X X X X X                             #', FIM_TEXTO
LINE5			STR     '#                            X X X X X X X X X X X                             #', FIM_TEXTO
LINE6			STR     '#                            X X X X X X X X X X X                             #', FIM_TEXTO
LINE7			STR     '#                            X X X X X X X X X X X                             #', FIM_TEXTO
LINE8			STR     '#                            X X X X X X X X X X X                             #', FIM_TEXTO
LINE9			STR     '#                                                                              #', FIM_TEXTO
LINE10			STR     '#                                                                              #', FIM_TEXTO
LINE11			STR     '#                                                                              #', FIM_TEXTO
LINE12			STR     '#                                                                              #', FIM_TEXTO
LINE13			STR     '#                                                                              #', FIM_TEXTO
LINE14			STR     '#                                                                              #', FIM_TEXTO
LINE15			STR     '#                                                                              #', FIM_TEXTO
LINE16			STR     '#                                                                              #', FIM_TEXTO
LINE17			STR     '#                                                                              #', FIM_TEXTO
LINE18			STR     '#                                                                              #', FIM_TEXTO
LINE19			STR     '#                                    (^.^)                                     #', FIM_TEXTO
LINE20			STR     '#                                                                              #', FIM_TEXTO
LINE21			STR     '#______________________________________________________________________________#', FIM_TEXTO
LINE22			STR     '#                                                                              #', FIM_TEXTO
LINE23			STR     '################################################################################', FIM_TEXTO

Ship			STR 	'(^.^)'
Space			STR		' ',  FIM_TEXTO

Vida			WORD	3d 
Score			WORD	0d 			; score inical

AlienMovCtrlY	WORD	49d			;49	
AlienMovCFixo	WORD    49d
AlienMovCtrlX   WORD	4d			
AlienStopLeft	WORD	51d			
AlienStopRight	WORD	27d
AlienLineCtrl	WORD	0d
AlienDirection  WORD    0d
LinhaAlienAtual	WORD	4d
AlienReset_X	WORD	4d
AlienReset_Y	WORD	29d

WinStr			STR	'*******VOCE VENCEU******* ', FIM_TEXTO
LoseStr			STR	'*******VOCE PERDEU******* ', FIM_TEXTO

RowIndex		WORD	0d
ColumnIndex		WORD	0d

ShipLine		WORD	19d
ShipCol			WORD	37d
ShipBegin		WORD 	37d
ShipEnd			WORD 	42d
ShipLenght		WORD	5d

PrintLineArg    WORD    0d


ColunaBala 		WORD    0d
LinhaBala 		WORD    0d

BalaNaTela  	WORD    OFF


;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                ORIG    FE00h
INT0            WORD    MoveRight
INT1 			WORD	MoveLeft
INT2 			WORD	Atirar

				ORIG    FE0Fh
INT15           WORD    Timer

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

;------------------------------------------------------------------------------
; Função do Temporizador
;------------------------------------------------------------------------------


Timer:		PUSH R1
			PUSH R2

			MOV R1, ON
			MOV R2, M[ BalaNaTela ]
			CMP R1, R2
			CALL.Z MoveTiro
			
			MOV R1, M[AlienDirection]
			CMP	R1, 0d
			JMP.Z 	Direita
			CALL	MoveAlienEsquerda
			JMP		ContTime

Direita: CALL MoveAlienDireita

			

ContTime:    CALL SetTimer	
				
Fim_Timer:	POP R2
			POP R1
			RTI

;------------------------------------------------------------------------------
; Função Função SetTimer
; -> Ativa o temporizador e define seu intervalo de tempo.
;------------------------------------------------------------------------------

SetTimer:	PUSH R1

			MOV R1, ON
			MOV M[CONF_TEMP], R1

			MOV R1, ON
			MOV M[ATIVAR_TEMP], R1

			POP R1
			RET
;------------------------------------------------------------------------------
; Função para resetar os aliens
;------------------------------------------------------------------------------

ResetaAlien:    PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				
				MOV R1, ALIEN_RESET_Y													; coluna em que o primeiro alien da esquerda para a direita se encontra no momento do reset
				MOV R2, ALIEN_RESET_X												   ; linha 
				MOV M[AlienMovCtrlY], R1
				MOV M[AlienMovCtrlX], R2

PrimeiroLoopResetaAlien:    MOV R1, M[AlienMovCtrlY]
							MOV R2, M[AlienMovCtrlX]

							MOV R3, CARACTERES 						
							MUL R2, R3
							ADD R3, R1	
							MOV R2, LINE0 		
							ADD R3, R2 
							MOV R1, VAZIO

							MOV R5, M[R3] 
							CMP R5, R1
							JMP.Z SegundoLoopResetaAlien


							MOV M[R3], R1


							MOV R1, M[AlienReset_Y]
							MOV R2, M[AlienReset_X]			

							MOV R3, CARACTERES 						

							MUL R2, R3

							ADD R3, R1	

							MOV R2, LINE0 		

							ADD R3, R2 

							MOV R1, ALIEN
							MOV M[R3], R1


							MOV R1, M[AlienMovCtrlX]
							MOV R2, M[AlienMovCtrlY]

							SHL R1, SHIFT_LEFT
							OR R1, R2
							MOV R3, VAZIO
							MOV M[ CURSOR ], R1
							MOV M[ IO_WRITE ], R3

							MOV R1, M[AlienReset_X]
							MOV R2, M[AlienReset_Y]

							SHL R1, SHIFT_LEFT
							OR R1, R2
							MOV R3, ALIEN
							MOV M[ CURSOR ], R1
							MOV M[ IO_WRITE ], R3

				

SegundoLoopResetaAlien: MOV R1, M[AlienMovCtrlX]
						MOV R2, ALIEN_LINHA_LIM														
						CMP R1, R2
						JMP.Z TerceiroLoopResetaAlien
				
						MOV R1, M[AlienMovCtrlX]
						INC R1
						MOV M[AlienMovCtrlX], R1
						MOV R1, M[AlienReset_X]
						INC R1
						MOV M[AlienReset_X], R1
						 
						JMP PrimeiroLoopResetaAlien

TerceiroLoopResetaAlien: MOV R1, ALIEN_RESET_X
						 MOV M[AlienMovCtrlX], R1
					
						 MOV R2, M[AlienMovCtrlY]
						 INC R2
						 INC R2
						 MOV M[AlienMovCtrlY], R2						 
						 MOV R1, ALIEN_LINHA_INI									;linha inical dos aliens
						 MOV M[AlienReset_X], R1
						 MOV R1, M[AlienReset_Y]
						 INC R1 
						 INC R1
						 MOV M[AlienReset_Y], R1
						 MOV R1, M[AlienReset_Y]
						 MOV R2, STOP_LEFT_RESET								;compara com o limite 
						 CMP R1, R2
						 JMP.Z PreFim
						 JMP PrimeiroLoopResetaAlien

PreFim: 				 MOV R1, ALIEN_LINHA_INI
						 MOV R2, ALIEN_COL_INI
						 MOV M[AlienReset_X], R1
						 MOV M[AlienReset_Y], R2

						 MOV R2, 49d
						 MOV M[LinhaAlienAtual],  R1
						 MOV M[AlienMovCtrlY], R2
						 MOV M[AlienMovCtrlX], R1
						 MOV M[AlienMovCFixo], R2
						 MOV R1, STOP_RIGHT_RESET
						 MOV R2, STOP_LEFT_RESET								;reseta o limite para saber onde parar de "varrer" as colunas 
						 MOV M[AlienStopLeft], R2
						 MOV M[AlienStopRight], R1



FimResetaAlien: POP R5
				POP R4
				POP R3
				POP R2
				POP R1

				RET

;------------------------------------------------------------------------------
; Função para diminuir a vida
;------------------------------------------------------------------------------

SubLife: PUSH R1
		 PUSH R2
		 PUSH R3
		
		 CALL ResetaAlien

		 
		 MOV R1, M[Vida]

		 CMP R1,3d					; VIDA 3, VIDA 2, VIDA 1
		 JMP.Z SubThirdLife
		 
		 CMP R1,2d
		 JMP.Z SubSecondLife
		
		 CMP R1,1d
		 JMP.Z SubFirstLife
		
		 


SubThirdLife:		MOV R1, LINE_SCORE_VIDA
		 			MOV R2, COL_THIRD_LIFE							 

					SHL R1, SHIFT_LEFT
					OR R1, R2
					MOV R3, VAZIO
					MOV M[ CURSOR ], R1
					MOV M[ IO_WRITE ], R3
					JMP EndSubLife
					

SubSecondLife:		MOV R1, LINE_SCORE_VIDA
		 			MOV R2, COL_SECOND_LIFE

					SHL R1, SHIFT_LEFT
					OR R1, R2
					MOV R3, VAZIO
					MOV M[ CURSOR ], R1
					MOV M[ IO_WRITE ], R3
					JMP EndSubLife
					

SubFirstLife:		MOV R1, LINE_SCORE_VIDA
		 			MOV R2, COL_FIRST_LIFE

					SHL R1, SHIFT_LEFT
					OR R1, R2
					MOV R3, VAZIO
					MOV M[ CURSOR ], R1
					MOV M[ IO_WRITE ], R3
					CALL YouLose
					JMP EndSubLife



	

EndSubLife: MOV R1, M[Vida]
			DEC R1
			MOV M[Vida], R1
			

			POP R3
			POP R2
			POP R1

			RET
;------------------------------------------------------------------------------
; Função You Lose
;------------------------------------------------------------------------------

YouLose: 	PUSH R1
			PUSH R2
			PUSH R3
			PUSH R4
			PUSH R5

			MOV R1, LoseStr
			MOV R2, STR_LINE
			MOV R3, STR_COLUMN

			LoopYouLoseStrPrint: 	MOV R5, M[R1]
									CMP R5, FIM_TEXTO
									JMP.Z Halt

									SHL R2, SHIFT_LEFT
									OR R2, R3
									MOV M[ CURSOR ], R2
									MOV M[ IO_WRITE ], R5
									INC R1
									INC R3
									MOV R2, STR_LINE
									JMP LoopYouLoseStrPrint


EndLose:	POP R5
			POP R4
			POP R3
			POP R2
			POP R1
			
			RET

;------------------------------------------------------------------------------
; Função para Mover os Aliens para Baixo L
;------------------------------------------------------------------------------

MoveAlienBaixoL:PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5

				
			

				MOV	R1, M[AlienMovCtrlX]
				MOV R2, QNT_SUM_ALIEN	
				ADD R1, R2											; pega a primeira linha e soma 4 para iniciar a descida da coluna
				MOV M[AlienMovCtrlX], R1


				MOV R1, ALIEN_LINHA_LIM												
				MOV R2, M[AlienMovCtrlX]
				CMP R1, R2
				JMP.NZ MovimentoAlienBaixoL
				CALL SubLife
				JMP FimMoveAlienBaixoL
				


MovimentoAlienBaixoL:	MOV R2, M[AlienMovCtrlY]						
				
						MOV R3, CARACTERES
						MOV R1, M[AlienMovCtrlX]
						MUL R1, R3
						ADD R3, R2
						ADD R3, LINE0

					    MOV R1, VAZIO
						MOV R5, M[R3]
						CMP R1, R5
						JMP.Z MovBaixoContinueL
						
						MOV R4, VAZIO
						MOV M[R3], R4

						ADD R3, CARACTERES
						MOV R4, ALIEN
						MOV M[R3], R4

						MOV	R1, M[AlienMovCtrlX]
						MOV R2, M[AlienMovCtrlY]			
	
						SHL R1, SHIFT_LEFT
						OR R1, R2
						MOV R4, VAZIO
						MOV M[ CURSOR ], R1
						MOV M[ IO_WRITE ], R4

						MOV R1, M[AlienMovCtrlX]		
						MOV R2, M[AlienMovCtrlY]
						INC R1			
						SHL R1, SHIFT_LEFT
						OR R1, R2
						MOV R4, ALIEN
						MOV M[ CURSOR ], R1
						MOV M[ IO_WRITE ], R4

MovBaixoContinueL:		MOV R1, M[AlienMovCtrlX]
						DEC R1
						MOV M[AlienMovCtrlX], R1
						MOV R1, M[LinhaAlienAtual]
						MOV R2, M[AlienMovCtrlX]
						DEC R1
						CMP R1, R2
						JMP.Z EndDownColumnL
						JMP MovimentoAlienBaixoL

EndDownColumnL:		MOV R2, M[AlienMovCtrlY]
					DEC R2
					DEC R2
					MOV M[AlienMovCtrlY], R2
					MOV R1, M[LinhaAlienAtual]
					MOV M[AlienMovCtrlX], R1
					MOV R1, M[AlienMovCtrlX]
					MOV R5, QNT_SUM_ALIEN
					ADD R1, R5
					MOV M[AlienMovCtrlX], R1
					MOV R1, M[AlienMovCtrlY]
					MOV R2, 0d
					DEC R2
					CMP R1, R2
					JMP.Z EndLineMovDownL
					JMP MovimentoAlienBaixoL

EndLineMovDownL:	MOV R1, M[LinhaAlienAtual]
					INC R1
					MOV M[LinhaAlienAtual], R1
					MOV M[AlienMovCtrlX], R1
					MOV R1, M[AlienMovCtrlY]
					ADD R1, 22d                  							; "devolver" a posição inicial para iniciar o movimento para a direita      
					MOV M[AlienMovCtrlY], R1
					MOV M[AlienMovCFixo], R1
					JMP FimMoveAlienBaixoL


FimMoveAlienBaixoL:	POP R5
					POP R4
					POP R3
					POP R2
					POP R1

					RET

;------------------------------------------------------------------------------
; Função para Mover os Aliens para Baixo R
;------------------------------------------------------------------------------

MoveAlienBaixoR:PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5


				MOV R1, M[Vida]
				CMP R1, 0d
				CALL.Z YouLose

				MOV	R1, M[AlienMovCtrlX]
				MOV R2, QNT_SUM_ALIEN
				ADD R1, R2
				MOV M[AlienMovCtrlX], R1

				MOV R1, ALIEN_LINHA_LIM
				MOV R2, M[AlienMovCtrlX]
				CMP R1, R2
				JMP.NZ MovimentoAlienBaixoR
				CALL SubLife
				JMP FimMoveAlienBaixoR

MovimentoAlienBaixoR:	MOV R2, M[AlienMovCtrlY]			

				
						MOV R3, CARACTERES
						MOV R1, M[AlienMovCtrlX]
						MUL R1, R3
						ADD R3, R2                  
						ADD R3, LINE0

						MOV R1, VAZIO
						MOV R5, M[R3]
						CMP R1, R5
						JMP.Z MovBaixoContinueR
					
						MOV R4, VAZIO
						MOV M[R3], R4

						ADD R3, CARACTERES
						MOV R4, ALIEN
						MOV M[R3], R4

						MOV	R1, M[AlienMovCtrlX]
						MOV R2, M[AlienMovCtrlY]			

						SHL R1, SHIFT_LEFT
						OR R1, R2
						MOV R4, VAZIO
						MOV M[ CURSOR ], R1
						MOV M[ IO_WRITE ], R4

						MOV R1, M[AlienMovCtrlX]		
						MOV R2, M[AlienMovCtrlY]
						INC R1			
						SHL R1, SHIFT_LEFT
						OR R1, R2
						MOV R4, ALIEN
						MOV M[ CURSOR ], R1
						MOV M[ IO_WRITE ], R4

MovBaixoContinueR:		MOV R1, M[AlienMovCtrlX]
						DEC R1
						MOV M[AlienMovCtrlX], R1
						MOV R1, M[LinhaAlienAtual]
						MOV R2, M[AlienMovCtrlX]
						DEC R1
						CMP R1, R2
						JMP.Z EndDownColumnR
						JMP MovimentoAlienBaixoR

EndDownColumnR: 	MOV R2, M[AlienMovCtrlY]
					INC R2
					INC R2
					MOV M[AlienMovCtrlY], R2
					MOV R1, M[LinhaAlienAtual]
					MOV M[AlienMovCtrlX], R1
					MOV R1, M[AlienMovCtrlX]
					MOV R5, QNT_SUM_ALIEN
					ADD R1, R5
					MOV M[AlienMovCtrlX], R1
					MOV R1, M[AlienMovCtrlY]
					MOV R2, 80d
					CMP R1, R2
					JMP.Z EndLineMovDownR
					JMP MovimentoAlienBaixoR

EndLineMovDownR:	MOV R1, M[LinhaAlienAtual]
					INC R1
					MOV M[LinhaAlienAtual], R1
					MOV M[AlienMovCtrlX], R1
					MOV R1, M[AlienMovCtrlY]
					SUB R1, 22d 							;	para mudar a posição do primeiro X         
					MOV M[AlienMovCtrlY], R1
					MOV M[AlienMovCFixo], R1
					JMP FimMoveAlienBaixoR


FimMoveAlienBaixoR: 	POP R5
						POP R4
						POP R3
						POP R2
						POP R1

						RET
;------------------------------------------------------------------------------
; Função para Mover os Aliens para a ESQUERDA 
;------------------------------------------------------------------------------

MoveAlienEsquerda:  PUSH R1
					PUSH R2
					PUSH R3
					PUSH R4
					PUSH R5


					MOV R1, M[AlienMovCtrlY]			;coluna
					MOV R2, M[AlienMovCtrlX]			;LINHA
					
					CMP R1, ALIEN_LEFT_LIM
					JMP.NZ MoveEsquerda						

					MOV R3, 0d								; mudar a direção do alien
					MOV M[AlienDirection], R3

					MOV R2, 0d								; atualizar o ponto de parada
					DEC R2
					MOV M[AlienStopRight], R2

					ADD R1, 20d								; para atualizar a posição do primeito X
					MOV M[AlienMovCtrlY], R1 
					MOV M[AlienMovCFixo], R1
					CALL MoveAlienBaixoL
					JMP FimMoveAlienEsquerda 



MoveEsquerda:		MOV R3, CARACTERES 						

					MUL R2, R3

					ADD R3, R1	
					MOV R2, LINE0 						
					ADD R3, R2
				

					MOV R2, M[AlienMovCtrlY]		

MovimentoAlienEsquerda: MOV R1, VAZIO
						MOV R5, M[R3]
						CMP R1, R5
						JMP.Z MovLeftContinue
						
						MOV M[R3], R1


						DEC R3
						MOV R5, ALIEN
						MOV M[R3], R5
						
						MOV R1, M[AlienMovCtrlX]		
						MOV R2, M[AlienMovCtrlY]

						SHL R1, SHIFT_LEFT
						OR R1, R2
						MOV R4, VAZIO
						MOV M[ CURSOR ], R1
						MOV M[ IO_WRITE ], R4

						MOV R1, M[AlienMovCtrlX]		
						MOV R2, M[AlienMovCtrlY]
						DEC R2							
						SHL R1, SHIFT_LEFT
						OR R1, R2
						MOV R4, ALIEN
						MOV M[ CURSOR ], R1
						MOV M[ IO_WRITE ], R4
						INC R3
						INC R2

MovLeftContinue:		MOV R1, M[AlienMovCtrlX]
						INC R1
						MOV M[AlienMovCtrlX], R1

						ADD R3, CARACTERES

						MOV R1, M[AlienLineCtrl]
						INC R1
						MOV M[AlienLineCtrl], R1
						
						CMP R1, ALIEN_LINE_QNT
						JMP.Z EndLeftColumn
						JMP MovimentoAlienEsquerda

EndLeftColumn: 		MOV R2, M[AlienMovCtrlY]
					INC R2
					INC R2
					MOV R5, M[AlienStopLeft]
					CMP R2, R5
					JMP.Z EndLineMovEsquerda
					MOV M[AlienMovCtrlY], R2
					MOV R1, M[LinhaAlienAtual]
					MOV M[AlienMovCtrlX], R1

					MOV R1, M[AlienMovCtrlY]
					MOV R2, M[AlienMovCtrlX]			

					MOV R3, CARACTERES 					; tamanho da linha do mapa

					MUL R2, R3

					ADD R3, R1	
					MOV R2, LINE0 						; primeira linha do mapa
					ADD R3, R2 
					MOV R1, ALIEN_LINE
					MOV M[AlienLineCtrl], R1
					JMP MovimentoAlienEsquerda

EndLineMovEsquerda:		MOV R1, M[AlienStopLeft]
						DEC R1
						MOV M[AlienStopLeft], R1
						MOV R1, M[AlienMovCFixo]
						DEC R1
						MOV M[AlienMovCFixo], R1
						MOV M[AlienMovCtrlY], R1
						MOV R1, M[LinhaAlienAtual]
						MOV M[AlienMovCtrlX],R1
						MOV R1, ALIEN_LINE
						MOV M[AlienLineCtrl], R1
						JMP FimMoveAlienEsquerda

FimMoveAlienEsquerda:	POP R5
						POP R4
						POP R3
						POP R2
						POP R1

						RET




;------------------------------------------------------------------------------
; Função para Mover os Aliens para a DIREITA
;------------------------------------------------------------------------------

MoveAlienDireita:   PUSH R1
					PUSH R2
					PUSH R3
					PUSH R4
					PUSH R5


					MOV R1, M[AlienMovCtrlY]
					MOV R2, M[AlienMovCtrlX]		
					
					CMP R1, ALIEN_RIGHT_LIM
					JMP.NZ MoveDireita
					

					MOV R3, 1d									; é somente para alterar a direção do alien
					MOV M[AlienDirection], R3

					MOV R2, 80d										
					MOV M[AlienStopLeft], R2

					SUB R1, 20d            						;	para mudar a posição do primeiro X                     
					MOV M[AlienMovCtrlY], R1 
					MOV M[AlienMovCFixo], R1
					CALL MoveAlienBaixoR
					JMP FimMoveAlienDireita 

MoveDireita:		MOV R3, CARACTERES						

					MUL R2, R3

					ADD R3, R1	
					MOV R2, LINE0 						
					ADD R3, R2
				

					MOV R2, M[AlienMovCtrlY]				

MovimentoAlienDireita: 	MOV R1, VAZIO
						MOV R5, M[R3]
						CMP R1, R5
						JMP.Z MovRightContinue
						
						
						MOV M[R3], R1

						INC R3
						MOV R5, ALIEN
						MOV M[R3], R5
						
						MOV R1, M[AlienMovCtrlX]		
						MOV R2, M[AlienMovCtrlY]

						SHL R1, SHIFT_LEFT
						OR R1, R2
						MOV R4, VAZIO
						MOV M[ CURSOR ], R1
						MOV M[ IO_WRITE ], R4

						MOV R1, M[AlienMovCtrlX]		
						MOV R2, M[AlienMovCtrlY]
						INC R2							
						SHL R1, SHIFT_LEFT
						OR R1, R2
						MOV R4, ALIEN
						MOV M[ CURSOR ], R1
						MOV M[ IO_WRITE ], R4
						DEC R3

						DEC R2
MovRightContinue:		MOV R1, M[AlienMovCtrlX]
						INC R1

						MOV M[AlienMovCtrlX], R1

						ADD R3, CARACTERES

						MOV R1, M[AlienLineCtrl]
						INC R1
						MOV M[AlienLineCtrl], R1
		
						CMP R1, ALIEN_LINE_QNT
						JMP.Z EndRightColumn
						JMP MovimentoAlienDireita

EndRightColumn: 		MOV R2, M[AlienMovCtrlY]
						DEC R2
						DEC R2
						MOV R5, M[AlienStopRight]
						CMP R2, R5
						JMP.Z EndLineMovRight
						MOV M[AlienMovCtrlY], R2
						MOV R1, M[LinhaAlienAtual]						
						MOV M[AlienMovCtrlX], R1

						MOV R1, M[AlienMovCtrlY]
						MOV R2, M[AlienMovCtrlX]			

						MOV R3, CARACTERES 						; tamanho da linha do mapa

						MUL R2, R3

						ADD R3, R1	
						MOV R2, LINE0 							; primeira linha do mapa
						ADD R3, R2 
						MOV R1, ALIEN_LINE
						MOV M[AlienLineCtrl], R1
						JMP MovimentoAlienDireita

EndLineMovRight:		MOV R1, M[AlienStopRight]
						INC R1
						MOV M[AlienStopRight], R1
						MOV R1, M[AlienMovCFixo]
						INC R1
						MOV M[AlienMovCFixo], R1
						MOV M[AlienMovCtrlY], R1
						MOV R1, M[LinhaAlienAtual] 
						MOV M[AlienMovCtrlX],R1
						MOV R1, ALIEN_LINE
						MOV M[AlienLineCtrl], R1
						JMP FimMoveAlienDireita

FimMoveAlienDireita:	POP R5
						POP R4
						POP R3
						POP R2
						POP R1

						RET






;------------------------------------------------------------------------------
; Função You Win
;------------------------------------------------------------------------------

YouWin: 	PUSH R1
			PUSH R2
			PUSH R3
			PUSH R4
			PUSH R5

			MOV R1, WinStr
			MOV R2, STR_LINE
			MOV R3, STR_COLUMN

			LoopYouWinStrPrint: MOV R5, M[R1]
								CMP R5, FIM_TEXTO
								JMP.Z Halt

								SHL R2, SHIFT_LEFT
								OR R2, R3
								MOV M[ CURSOR ], R2
								MOV M[ IO_WRITE ], R5
								INC R1
								INC R3
								MOV R2, STR_LINE
								JMP LoopYouWinStrPrint


EndWin:		POP R5
			POP R4
			POP R3
			POP R2
			POP R1
			
			RET
;------------------------------------------------------------------------------
; Função para aumentar o score
;------------------------------------------------------------------------------
SumScore:	PUSH R1
			PUSH R2
			PUSH R3
			PUSH R4
			PUSH R5

			MOV R5, TABELA_ASCII

			MOV	R1, PONTUACAO
			MOV R2, M[Score]
			ADD R2, R1
			MOV M[Score], R2

			

ContinueScore:	MOV R1, M[ Score ]
				MOV R2, 100d
				DIV R1, R2				; R1 -> QUOCIENTE | R2 -> RESTO
										; 11, 12, 13
				MOV R3, LINE_SCORE_VIDA
				MOV R4, COL_FIRST_SCORE
				SHL R3, SHIFT_LEFT
				OR R3, R4
				MOV M[ CURSOR ], R3
				ADD R1, R5
				MOV M[IO_WRITE], R1

				
				MOV R1, 10d
				DIV R2, R1

				MOV R3, LINE_SCORE_VIDA
				MOV R4, COL_SEC_SCORE
				SHL R3, SHIFT_LEFT
				OR R3, R4
				MOV M[ CURSOR ], R3
				ADD R2, R5
				MOV M[IO_WRITE], R2

				MOV R3, LINE_SCORE_VIDA
				MOV R4, COL_THIRD_SCORE
				SHL R3, SHIFT_LEFT
				OR R3, R4
				MOV M[ CURSOR ], R3
				ADD R1, R5
				MOV M[IO_WRITE], R1
				
				MOV R1, M[Score]
				CMP R1, MAX_SCORE
				JMP.NZ FimScore
				CALL YouWin


FimScore: 	POP R5
			POP R4
			POP R3
			POP R2
			POP R1

			RET


;------------------------------------------------------------------------------
; Função para mover o tiro da NAVE e verificar colisão  
;------------------------------------------------------------------------------
MoveTiro:		PUSH	R1
				PUSH  	R2
				PUSH 	R3
				PUSH	R4
				PUSH 	R5
				PUSH  	R6
				
				; VERIFICAR COLISÃO 

				MOV R1, M[ColunaBala] 				; coluna do tiro
				MOV R2, M[LinhaBala] 				; linha do tiro
	
				MOV R3, CARACTERES 						; tamanho da linha do mapa
	
				MUL R2, R3

				ADD R3, R1	
				MOV R2, LINE0 ; primeira linha do mapa
				ADD R3, R2
				MOV R1, M[ R3 ]
				MOV R2, ALIEN 						; caractere para verificar na memória
				CMP R1, R2
				JMP.Z AlienDetectado	

				

				MOV R1,  M[ LinhaBala ]
				MOV R2,  M[ ColunaBala ] 
				MOV R3, VAZIO
				SHL R1, SHIFT_LEFT
				OR R1, R2
				MOV M[ CURSOR ], R1
				MOV M[IO_WRITE], R3
				

				MOV R1,  M[ LinhaBala ]
				MOV R2,  M[ ColunaBala ] 
				MOV R3,  LIMITE_BALA

				CMP R1, R3
				JMP.NZ ContinuarBala

				MOV	R1, OFF
				MOV M[ BalaNaTela ], R1

				JMP FimMoveTiro


				

ContinuarBala:		DEC R1
					MOV M[ LinhaBala ], R1
					SHL R1, SHIFT_LEFT 
					OR  R1, R2
					MOV M[ CURSOR ], R1
					MOV R1, TIRO_NAVE
					MOV M[ IO_WRITE ], R1
					JMP FimMoveTiro

AlienDetectado: 	MOV	R1, OFF
					MOV M[ BalaNaTela ], R1										; 'desliga' a bala
	
					MOV R1,  M[ LinhaBala ]
					MOV R2,  M[ ColunaBala ] 
					MOV R4, VAZIO															
					MOV M[R3], R4												; apaga na memoria e depois da tela	
					MOV R3, VAZIO		
					SHL R1, SHIFT_LEFT
					OR R1, R2
					MOV M[ CURSOR ], R1
					MOV M[IO_WRITE], R3
					
					CALL SumScore

				

FimMoveTiro:	POP R6
				POP R5
				POP	R4
				POP R3
				POP R2
				POP R1

				RET

;------------------------------------------------------------------------------
; Função Atirar
;------------------------------------------------------------------------------

Atirar:			PUSH	R1
				PUSH  	R2
				
				MOV R1, ON
				MOV R2, M[ BalaNaTela ]
				CMP R1, R2
				JMP.Z FimAtirar

				MOV		R1, M[ ShipBegin ]
				MOV		R2, 2d						; serve somente para calcular o meio da nave 
				ADD		R2, R1 				 		; coluna do tiro da nave
				MOV		M[ColunaBala], R2
				MOV 	R1, 18d					
				MOV 	M[LinhaBala], R1

				SHL		R1, SHIFT_LEFT
				OR		R1, R2
				MOV		M[ CURSOR ], R1
				MOV		R1, TIRO_NAVE
				MOV		M[ IO_WRITE ], R1

				MOV		R1, ON
				MOV 	M[ BalaNaTela ], R1

				
FimAtirar:		POP		R2
				POP		R1
				RTI


;------------------------------------------------------------------------------
; Função PrintMapLines
;------------------------------------------------------------------------------

PrintMapLines: 	PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6

				MOV R4, M[ PrintLineArg ] 

PrintMapLineV2:	MOV R1, 0d							;reiniciar a coluna
				MOV M[ ColumnIndex ], R1

	PrintAllLineCharactersLoop:	MOV R2, M[R4]
								CMP R2, FIM_TEXTO
								JMP.Z EndPrintAllLineCharactersLoop		


								MOV	 R2, M[ ColumnIndex ]
								MOV	 R3, M[ RowIndex ]
								SHL	 R3, SHIFT_LEFT
								OR	 R3, R2
								MOV	 M[ CURSOR ], R3
								MOV  R2, M[R4]
								MOV  M[ IO_WRITE ], R2

								INC  R4
								INC	 M[ ColumnIndex ]
								JMP  PrintAllLineCharactersLoop

	EndPrintAllLineCharactersLoop: 	INC M[RowIndex]
									INC R4
									MOV R5, M[ RowIndex ]
									MOV R6, TOTAL_LINE
									CMP R5, R6
									JMP.Z EndPrintMapLines
									JMP PrintMapLineV2
								
EndPrintMapLines: 	POP R6
					POP R5
					POP R4
					POP R3
					POP R2
					POP R1
							
					RET

;------------------------------------------------------------------------------
; Função MoveLeft
;------------------------------------------------------------------------------
MoveLeft:	PUSH R1
			PUSH R2
			PUSH R3
			PUSH R4
			PUSH R5

			MOV R1,	M[ ShipEnd ]

			MOV R2, SHIP_TAM_MOVE
			SUB R1, R2
			CMP R1, LEFT_BORDER
			JMP.Z EndMoveLeft

			MOV R2, M[ ShipBegin ]
			DEC R2
			MOV R3,	M[ ShipEnd ]
			MOV R4, M[ Space ]

			PrintSpaceLoopLeft:	MOV R1, M[ ShipLine ]
								SHL R1, SHIFT_LEFT
								OR R1, R3
								MOV M[ CURSOR ], R1
								MOV M[ IO_WRITE ], R4

								DEC R3
								CMP R2, R3
								JMP.NZ PrintSpaceLoopLeft
			
			SHL R1, SHIFT_LEFT
			OR R1, R2
			MOV M[ CURSOR ], R1
			
			MOV R4, M[ ShipCol ]
			MOV R5, M[ ShipLenght ]
			SUB R4, R5
			MOV M[ ShipCol ], R4

			MOV R1, M[ShipLine]  	
			MOV R2, M[ShipCol]
			MOV M[ ShipBegin ], R2  	; ATUALIZAR O INICIO DA NAVE
			MOV R4, M[ ShipEnd ]
			SUB R4,  R5   				; ATUALIZAR O FINAL DA NAVE
			MOV M[ ShipEnd ], R4

			SHL R1, SHIFT_LEFT
			OR  R1, R2

			MOV M[ CURSOR ] , R1

			MOV R1, Ship
			MOV R2, M[ R1 ]
			MOV R3, M[ ShipBegin ]
			MOV R5, M[ShipEnd]
			

			PrintShipLoopLeft:	CMP R3, R5
								JMP.Z EndMoveLeft

								MOV R4, M[ ShipLine ]
								MOV M[ IO_WRITE ], R2
								INC R1
								INC R3	
								SHL R4, SHIFT_LEFT
								OR R4, R3
								MOV M[CURSOR], R4

								MOV R2, M[R1]
								JMP PrintShipLoopLeft		

			EndMoveLeft:	POP R5 
							POP R4
							POP R3
							POP R2
							POP R1

							RTI

;------------------------------------------------------------------------------
; Função MoveRight
;------------------------------------------------------------------------------
MoveRight:	PUSH R1
			PUSH R2
			PUSH R3
			PUSH R4
			PUSH R5

			MOV R1,	M[ ShipBegin ]

			
			MOV R2, SHIP_TAM_MOVE
			ADD R1, R2
			CMP R1, RIGHT_BORDER
			JMP.Z EndMoveRight

			MOV R2, M[ ShipBegin ]
			MOV R3,	M[ ShipEnd ]
			MOV R4, M[ Space ]

			PrintSpaceLoop:		MOV R1, M[ ShipLine ]
								SHL R1, SHIFT_LEFT
								OR R1, R2
								MOV M[ CURSOR ], R1
								MOV M[ IO_WRITE ], R4

								INC R2
								CMP R2, R3
								JMP.NZ PrintSpaceLoop
			
			SHL R1, SHIFT_LEFT
			OR R1, R2
			MOV M[ CURSOR ], R1
			
			MOV R4, M[ ShipCol ]
			MOV R5, M[ ShipLenght ]
			ADD R4, R5
			MOV M[ ShipCol ], R4

			MOV R1, M[ShipLine]  	
			MOV R2, M[ShipCol]
			MOV M[ ShipBegin ], R2  	; ATUALIZAR O INICIO DA NAVE
			MOV R4, M[ ShipEnd ]
			ADD R4,  R5   				; ATUALIZAR O FINAL DA NAVE
			MOV M[ ShipEnd ], R4

			SHL R1, SHIFT_LEFT
			OR  R1, R2

			MOV M[ CURSOR ] , R1

			MOV R1, Ship
			MOV R2, M[ R1 ]
			MOV R3, M[ ShipBegin ]
			MOV R5, M[ShipEnd]
			

			PrintShipLoop:	CMP R3, R5
							JMP.Z EndMoveRight

							MOV R4, M[ ShipLine ]
							MOV M[ IO_WRITE ], R2
							INC R1
							INC R3	
							SHL R4, SHIFT_LEFT
							OR R4, R3
							MOV M[CURSOR], R4

							MOV R2, M[R1]
							JMP PrintShipLoop			

			EndMoveRight:	POP R5 
							POP R4
							POP R3
							POP R2
							POP R1

							RTI

;------------------------------------------------------------------------------
; Função Main
;------------------------------------------------------------------------------
Main:			ENI

				MOV		R1, INITIAL_SP
				MOV		SP, R1		 		; We need to initialize the stack
				MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
				MOV		M[ CURSOR ], R1		; with value CURSOR_INIT
			
				MOV R1, LINE0
				MOV M[ PrintLineArg ], R1
				CALL PrintMapLines
				
				CALL SetTimer	
				
		
Cycle: 			BR		Cycle	
Halt:           BR		Halt