org 0x7c00
jmp 0x0000:MAIN

WINDOW_WIDTH DW 140h   ;the width of the window (320 pixels)
WINDOW_HEIGHT DW 0C8h  ;the height of the window (200 pixels)
WINDOW_BOUNDS DW 6     ;variable used to check collisions early
	
TIME_AUX DB 0 ;variable used when checking if the time has changed
	
BALL_X DW 0Ah ;X position (column) of the ball
BALL_Y DW 0Ah ;Y position (line) of the ball
BALL_SIZE DW 04h ;size of the ball (how many pixels does the ball have in width and height)
BALL_VELOCITY_X DW 05h ;X (horizontal) velocity of the ball
BALL_VELOCITY_Y DW 02h ;Y (vertical) velocity of the ball

MAIN:
		
		CALL CLEAR_SCREEN
		
		CHECK_TIME:
		
			MOV AH,2Ch ;get the system time
			INT 21h    ;CH = hour CL = minute DH = second DL = 1/100 seconds
			
			CMP DL,BYTE[TIME_AUX]  ;is the current time equal to the previous one(TIME_AUX)?
			JE CHECK_TIME    ;if it is the same, check again
			;if it's different, then draw, move, etc.
			
			MOV BYTE[TIME_AUX],DL ;update time
			
			CALL CLEAR_SCREEN
			
			CALL MOVE_BALL
			CALL DRAW_BALL 
			
			JMP CHECK_TIME ;after everything checks time again
		
		RET
	
MOVE_BALL:
		
		MOV AX,WORD[BALL_VELOCITY_X]    
		ADD WORD[BALL_X],AX             ;move the ball horizontally
		
		MOV AX,WORD[WINDOW_BOUNDS]
		CMP WORD[BALL_X],AX                         
		JL NEG_VELOCITY_X         ;BALL_X < 0 + WINDOW_BOUNDS (Y -> collided)
		
		MOV AX,WORD[WINDOW_WIDTH]
		SUB AX,WORD[BALL_SIZE]
		SUB AX,WORD[WINDOW_BOUNDS]
		CMP WORD[BALL_X],AX	          ;BALL_X > WINDOW_WIDTH - BALL_SIZE  - WINDOW_BOUNDS (Y -> collided)
		JG NEG_VELOCITY_X
		
		
		MOV AX,WORD[BALL_VELOCITY_Y]
		ADD WORD[BALL_Y],AX             ;move the ball vertically
		
		MOV AX,WORD[WINDOW_BOUNDS]
		CMP WORD[BALL_Y],AX   ;BALL_Y < 0 + WINDOW_BOUNDS (Y -> collided)
		JL NEG_VELOCITY_Y                          
		
		MOV AX,WORD[WINDOW_HEIGHT]	
		SUB AX,WORD[BALL_SIZE]
		SUB AX,WORD[WINDOW_BOUNDS]
		CMP WORD[BALL_Y],AX
		JG NEG_VELOCITY_Y		  ;BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS (Y -> collided)
		
		RET
		
		NEG_VELOCITY_X:
			NEG WORD[BALL_VELOCITY_X]   ;BALL_VELOCITY_X = - BALL_VELOCITY_X
			RET
			
		NEG_VELOCITY_Y:
			NEG WORD[BALL_VELOCITY_Y]   ;BALL_VELOCITY_Y = - BALL_VELOCITY_Y
			RET
		
	
	DRAW_BALL:
		
		MOV CX,WORD[BALL_X] ;set the initial column (X)
		MOV DX,WORD[BALL_Y] ;set the initial line (Y)
		
		DRAW_BALL_HORIZONTAL:
			MOV AH,0Ch ;set the configuration to writing a pixel
			MOV AL,0Fh ;choose white as color
			MOV BH,00h ;set the page number 
			INT 10h    ;execute the configuration
			
			INC CX     ;CX = CX + 1
			MOV AX,CX          ;CX - BALL_X > BALL_SIZE (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,WORD[BALL_X]
			CMP AX,WORD[BALL_SIZE]
			JNG DRAW_BALL_HORIZONTAL
			
			MOV CX,WORD[BALL_X] ;the CX register goes back to the initial column
			INC DX        ;we advance one line
			
			MOV AX,DX              ;DX - BALL_Y > BALL_SIZE (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,WORD[BALL_Y]
			CMP AX,WORD[BALL_SIZE]
			JNG DRAW_BALL_HORIZONTAL
		
		RET
	
	CLEAR_SCREEN:
			MOV AH,00h ;set the configuration to video mode
			MOV AL,13h ;choose the video mode
			INT 10h    ;execute the configuration 
		
			MOV AH,0Bh ;set the configuration
			MOV BH,00h ;to the background color
			MOV BL,00h ;choose black as background color
			INT 10h    ;execute the configuration
			
			RET
  