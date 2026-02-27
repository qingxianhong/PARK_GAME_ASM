TITLE park_game.asm
INCLUDE Irvine32.inc

BLOCK_WIDTH = 6
BLOCK_HEIGHT = 3
MAP_WIDTH = BLOCK_WIDTH * 8
MAP_HEIGHT = BLOCK_HEIGHT * 8

LEVELS = 3

Car STRUCT
	what BYTE ?
	orient BYTE ?
	len BYTE ?
	head COORD <?,?>
	tail COORD <?,?>
	target BYTE ?
	color WORD ?
Car ENDS

getKeyInputInLevel PROTO,
	graph: PTR BYTE,
	arr: PTR Car,
	arrSize: DWORD

moveCar PROTO,
	graph: PTR BYTE,
	arr: PTR Car,
	arrSize: DWORD,
	key: WORD

chooseCar PROTO,
	arr: PTR Car,
	arrSize: DWORD,
	key: WORD

drawGraph PROTO,
	graph: PTR BYTE,
	arr: PTR Car,
	arrSize: DWORD

screenGraph PROTO

randomChooseLevel PROTO

.data
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	L1_graph byte "NNNNNNNN",
				  "NBBCYYYN",
				  "NYYCYDDN",
				  "NAAYYKGZ",
				  "NEYHHKGN",
				  "NEYIYJJN",
				  "NFFIYYYN",
				  "NNNNNNNN", 0
	L1_CarArr Car <"A","H",2,<2,3>,<1,3>,1,0C1h> , <"B","H",2,<2,1>,<1,1>,0,64h> , <"C","V",2,<3,2>,<3,1>,0,21h> , <"D","H",2,<6,2>,<5,2>,0,9Ah> , <"E","V",2,<1,5>,<1,4>,0,5Eh> , <"F","H",2,<2,6>,<1,6>,0,24h> , <"G","V",2,<6,4>,<6,3>,0,0B4h> , <"H","H",2,<4,4>,<3,4>,0,0E1h> , <"I","V",2,<3,6>,<3,5>,0,64h> , <"J","H",2,<6,5>,<5,5>,0,1Ah>, <"K","V",2,<5,4>,<5,3>,0,2Ch>

	L2_graph byte "NNNNNNNN",
				  "NYBYCCYN",
				  "NYBDDYYN",
				  "NAAEYYFZ",
				  "NGGEYYFN",
				  "NHYEYYYN",
				  "NHIIJJJN",
				  "NNNNNNNN", 0
	L2_CarArr Car <"A","H",2,<2,3>,<1,3>,1,0C1h> , <"B","V",2,<2,2>,<2,1>,0,64h> , <"C","H",2,<5,1>,<4,1>,0,21h> , <"D","H",2,<4,2>,<3,2>,0,9Ah> , <"E","V",3,<3,5>,<3,3>,0,5Eh> , <"F","V",2,<6,4>,<6,3>,0,24h> , <"G","H",2,<2,4>,<1,4>,0,0B4h> , <"H","V",2,<1,6>,<1,5>,0,0E1h>, <"I","H",2,<3,6>,<2,6>,0,64h>, <"J","H",3,<6,6>,<4,6>,0,1Ah>

	L3_graph byte "NNNNNNNN",
				  "NYYYBBBN",
				  "NCCDYEEN",
				  "NYYDAAFZ",
				  "NYGGHYFN",
				  "NIIJHYFN",
				  "NYYJKKKN",
				  "NNNNNNNN", 0
	L3_CarArr Car <"A","H",2,<5,3>,<4,3>,1,0C1h> , <"B","H",3,<6,1>,<4,1>,0,64h> , <"C","H",2,<2,2>,<1,2>,0,21h> , <"D","V",2,<3,3>,<3,2>,0,9Ah> , <"E","H",2,<6,2>,<5,2>,0,5Eh> , <"F","V",3,<6,5>,<6,3>,0,24h>, <"G","H",2,<3,4>,<2,4>,0,0B4h> , <"H","V",2,<4,5>,<4,4>,0,0E1h>, <"I","H",2,<2,5>,<1,5>,0,56h>, <"J","V",2,<3,6>,<3,5>,0,1Ah> , <"K","H",3,<6,6>,<4,6>,0,64h>

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	attributes_Graph WORD (MAP_WIDTH * MAP_HEIGHT) DUP(0)
	text_Graph BYTE (MAP_WIDTH * MAP_HEIGHT) DUP(' ')
	consoleHandle DWORD ?
	bytesWritten DWORD 0
	cellsWritten DWORD 0
	xyPosition COORD <35,2>

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	caption_FINISH_GAME BYTE "Bye-Bye", 0
	details_FINISH_GAME BYTE "Good job.", 0

.code
main PROC
	PREPARE_ENVIRONMENT:
		INVOKE GetStdHandle, STD_OUTPUT_HANDLE
		mov consoleHandle, eax
	CHOOSE_LEVEL:
		INVOKE randomChooseLevel
		.IF eax==0
			jmp LEVEL_1
		.ELSEIF eax==1
			jmp LEVEL_2
		.ELSEIF eax==2
			jmp LEVEL_3
		.ENDIF
	LEVEL_1:
		INVOKE getKeyInputInLevel, offset L1_graph, offset L1_CarArr, lengthof L1_CarArr
		.IF ebx==1
			jmp FINISH_GAME
		.ENDIF
		jmp LEVEL_1
	LEVEL_2:
		INVOKE getKeyInputInLevel, offset L2_graph, offset L2_CarArr, lengthof L2_CarArr
		.IF ebx==1
			jmp FINISH_GAME
		.ENDIF
		jmp LEVEL_2
	LEVEL_3:
		INVOKE getKeyInputInLevel, offset L3_graph, offset L3_CarArr, lengthof L3_CarArr
		.IF ebx==1
			jmp FINISH_GAME
		.ENDIF
		jmp LEVEL_3
	FINISH_GAME:
		mov ebx, OFFSET caption_FINISH_GAME
		mov edx, OFFSET details_FINISH_GAME
		call MsgBox
		call Clrscr
		exit
main ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getKeyInputInLevel PROC USES eax,
	graph: PTR BYTE,
	arr: PTR Car,
	arrSize: DWORD

	INVOKE drawGraph, graph, arr, arrSize
	INVOKE screenGraph
	mov ebx, 0
	call ReadChar
	.IF ax > 4000h
		INVOKE moveCar, graph, arr, arrSize, ax
		.IF eax==1
			mov ebx, 1
			jmp Finish_Input
		.ENDIF
	.ELSE
		INVOKE chooseCar, arr, arrSize, ax
	.ENDIF
	Finish_Input:
		ret
getKeyInputInLevel ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

moveCar PROC USES ebx ecx edx esi edi,
	graph: PTR BYTE,
	arr: PTR Car,
	arrSize: DWORD,
	key: WORD

	mov eax, 0
	mov ecx, arrSize
	mov esi, arr
	mov edi, graph
	L1_moveCar:
		cmp (Car PTR [esi]).target, 1
		je GOT_CAR
		add esi, TYPE Car
		loop L1_moveCar
	GOT_CAR:
		cmp (Car PTR [esi]).orient, "H"
		je MOVE_HORIZON
		jne MOVE_VERTICAL
	MOVE_HORIZON:
		mov ebx, 0
		mov dl, (Car PTR [esi]).what
		.IF key==4B00h ;LEFT
			mov bx, (Car PTR [esi]).tail.Y
			imul bx, 8
			add bx, (Car PTR [esi]).tail.X
			dec bx
			add edi, ebx
			.IF BYTE PTR [edi]=="Y"
				mov BYTE PTR [edi], dl
				movzx ebx, (Car PTR [esi]).len
				add edi,ebx
				mov BYTE PTR [edi], "Y"
				mov bx, (Car PTR [esi]).tail.X
				dec bx
				mov (Car PTR [esi]).tail.X, bx
				mov bx, (Car PTR [esi]).head.X
				dec bx
				mov (Car PTR [esi]).head.X, bx
			.ENDIF
		.ENDIF
		.IF key==4D00h ;RIGHT
			mov bx, (Car PTR [esi]).head.Y
			imul bx, 8
			add bx, (Car PTR [esi]).head.X
			inc bx
			add edi, ebx
			.IF BYTE PTR [edi]=="Y"
				mov BYTE PTR [edi], dl
				movzx ebx, (Car PTR [esi]).len
				sub edi,ebx
				mov BYTE PTR [edi], "Y"
				mov bx, (Car PTR [esi]).tail.X
				inc bx
				mov (Car PTR [esi]).tail.X, bx
				mov bx,(Car PTR [esi]).head.X
				inc bx
				mov (Car PTR [esi]).head.X, bx
			.ELSEIF BYTE PTR [edi]=="Z"
				mov BYTE PTR [edi], dl
				movzx ebx, (Car PTR [esi]).len
				sub edi,ebx
				mov BYTE PTR [edi], "Y"
				mov bx, (Car PTR [esi]).tail.X
				inc bx
				mov (Car PTR [esi]).tail.X, bx
				mov bx,(Car PTR [esi]).head.X
				inc bx
				mov (Car PTR [esi]).head.X, bx
				mov eax, 1
			.ENDIF
		.ENDIF
		jmp FINISH_MOVE
	MOVE_VERTICAL:
		mov ebx, 0
		mov dl, (Car PTR [esi]).what
		.IF key==4800h ;UP
			mov bx, (Car PTR [esi]).tail.Y
			dec bx
			imul bx, 8
			add bx, (Car PTR [esi]).tail.X
			add edi, ebx
			.IF BYTE PTR [edi]=="Y"
				mov BYTE PTR [edi], dl
				movzx ebx, (Car PTR [esi]).len
				imul ebx, 8
				add edi,ebx
				mov BYTE PTR [edi], "Y"
				mov bx, (Car PTR [esi]).tail.Y
				dec bx
				mov (Car PTR [esi]).tail.Y, bx
				mov bx, (Car PTR [esi]).head.Y
				dec bx
				mov (Car PTR [esi]).head.Y, bx
			.ENDIF
		.ENDIF
		.IF key==5000h ;DOWN
			mov bx, (Car PTR [esi]).head.Y
			inc bx
			imul bx, 8
			add bx,(Car PTR [esi]).head.X
			add edi, ebx
			.IF BYTE PTR [edi]=="Y"
				mov BYTE PTR [edi], dl
				movzx ebx, (Car PTR [esi]).len
				imul ebx, 8
				sub edi,ebx
				mov BYTE PTR [edi], "Y"
				mov bx, (Car PTR [esi]).tail.Y
				inc bx
				mov (Car PTR [esi]).tail.Y, bx
				mov bx, (Car PTR [esi]).head.Y
				inc bx
				mov (Car PTR [esi]).head.Y, bx
			.ENDIF
		.ENDIF
		jmp FINISH_MOVE
	FINISH_MOVE:
		ret
moveCar ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

chooseCar PROC USES ebx ecx edx esi,
	arr: PTR Car,
	arrSize: DWORD,
	key: WORD

	mov ecx, arrSize
	.IF ax==1E61h ;A
		mov ebx, 0
	.ENDIF
	.IF ax==3062h ;B
		mov ebx, 1
	.ENDIF
	.IF ax==2E63h ;C
		mov ebx, 2
	.ENDIF
	.IF ax==2064h ;D
		mov ebx, 3
	.ENDIF
	.IF ax==1265h ;E
		mov ebx, 4
	.ENDIF
	.IF ax==2166h ;F
		mov ebx, 5
	.ENDIF
	.IF ax==2267h ;G
		mov ebx, 6
	.ENDIF
	.IF ax==2368h ;H
		mov ebx, 7
	.ENDIF
	.IF ax==1769h ;I
		mov ebx, 8
	.ENDIF
	.IF ax==246Ah ;J
		mov ebx, 9
	.ENDIF
	.IF ax==256Bh ;K
		mov ebx, 10
	.ENDIF
	.IF ax==266Ch ;L
		mov ebx, 11
	.ENDIF
	.IF ax==326Dh ;M
		mov ebx, 12
	.ENDIF
	cmp ebx, ecx
	jnb FINISH_CHOOSE
	mov esi, arr
	mov edx, 0
	L1_chooseCar:
			cmp edx, ebx
			je Equal
			mov (Car PTR [esi]).target, 0
	Next:
		add esi, TYPE Car
		inc edx
		loop L1_chooseCar
		jmp FINISH_CHOOSE
	Equal:
		mov (Car PTR [esi]).target, 1
		jmp Next
	FINISH_CHOOSE:
		ret

chooseCar ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

drawGraph PROC USES eax ebx ecx edx esi edi,
	graph: PTR BYTE,
	arr: PTR Car,
	arrSize: DWORD

	mov eax, graph
	mov esi, OFFSET text_Graph
	mov edi, OFFSET attributes_Graph 
	mov ecx, 64
	mov ebx, 0
	L1_drawgraph:
		dec ecx
		push ebx
		.IF BYTE PTR [eax]=="N"
			mov bl, 3Dh
			mov dx, 088h
		.ELSEIF BYTE PTR [eax]=="Y"
			mov bl, 20h
			mov dx, 077h
		.ELSEIF BYTE PTR [eax]=="Z"
			mov bl, 20h
			mov dx, 077h
		.ELSE
			mov bl, BYTE PTR [eax]
			push edi
			mov edi, arr
			push ecx
			mov ecx, arrSize
			L2_drawgraph:
				mov bh, (Car PTR [edi]).what
				cmp bh, bl
				je Equal
				jmp Next
			Equal:
				jmp Finish_choose_drawgraph
			Next:
				add edi, TYPE Car
				loop L2_drawgraph
			Finish_choose_drawgraph:
				mov bl,  (Car PTR [edi]).what
				mov dx, (Car PTR [edi]).color
				pop ecx
				pop edi
		.ENDIF
		push ecx
		mov ecx, BLOCK_HEIGHT
		L_height_drawgraph:
			push ecx
			mov ecx, BLOCK_WIDTH
			L_width_drawgraph:
				mov BYTE PTR [esi], bl
				mov bl, 20h
				mov WORD PTR [edi], dx
				add esi, 1
				add edi, 2
				loop L_width_drawgraph
			sub esi, BLOCK_WIDTH
			add esi, BLOCK_WIDTH *8
			sub edi, BLOCK_WIDTH * 2
			add edi, BLOCK_WIDTH * 16
			pop ecx
			loop L_height_drawgraph
		sub esi, MAP_WIDTH * BLOCK_HEIGHT
		add esi, BLOCK_WIDTH
		sub edi, MAP_WIDTH * BLOCK_HEIGHT * 2
		add edi, BLOCK_WIDTH * 2
		pop ecx
		inc eax
		pop ebx
		inc ebx
		cmp ebx, 8
		je NextLine
	Done_nextline:
		cmp ecx, 0
		jne L1_drawgraph
		jmp Finish_drawgraph
	NextLine:
		add esi, MAP_WIDTH * (BLOCK_HEIGHT-1)
		add edi, MAP_WIDTH * (BLOCK_HEIGHT-1) * 2
		mov ebx, 0
		jmp Done_nextline
	Finish_drawgraph:
		ret
drawGraph ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

screenGraph PROC USES ecx esi edi
	
	mov ecx, MAP_HEIGHT
	mov esi, OFFSET attributes_Graph
	mov edi, OFFSET text_Graph
	L1_screengraph:
		push ecx
		INVOKE WriteConsoleOutputAttribute,
			consoleHandle, 
			esi,
			MAP_WIDTH,
			xyPosition,
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter,
			consoleHandle,
			edi,
			MAP_WIDTH,
			xyPosition,
			ADDR bytesWritten
		inc xyPosition.Y
		add esi, MAP_WIDTH * 2
		add edi, MAP_WIDTH
		pop ecx
		loop L1_screengraph
	sub xyPosition.Y, MAP_HEIGHT
	ret
screenGraph ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

randomChooseLevel PROC
	call Randomize
	mov eax, LEVELS
	call RandomRange
	ret
randomChooseLevel ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

END main