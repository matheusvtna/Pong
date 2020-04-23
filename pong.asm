org 0x7e00
jmp 0x0000:main

; ------------- DATA ------------- 

; Window
windowWidth     dw 140h 
windowHeight    dw 0C8h
windowBounds    dw 6

; Ball variabels
xBall           dw 0A0h
yBall           dw 64h
sizeBall        dw 04h
xBallVelocity   dw 05h
yBallVelocity   dw 02h
xBallOriginal   dw 0A0h
yBallOriginal   dw 64h

; Paddles
xPaddleLeft     dw 0Ah
yPaddleLeft     dw 52h
xPaddleRight    dw 130h
yPaddleRight    dw 52h
paddleWidth     dw 05h
paddleHeight    dw 1Fh
paddleVelocity  dw 05h

; Colors
black           equ 0
blue            equ 1 
red             equ 12
white           equ 15

; ------------- CODE ------------- 

main:
    ; Initial
    xor ax, ax
    mov ds, ax
    mov es, ax

    game:
        call clearScreen
        call moveBall
        call drawBall

        call movePaddles
        call drawPaddles

        call delay
        jmp game


resetBallPosition:

    mov ax, word[xBallOriginal]
    mov word[xBall], ax

    mov ax, word[yBallOriginal]
    mov word[yBall], ax

ret

clearScreen:
    ; Video mode
    mov ah, 00h     
    mov al, 13h
    int 10h

    ; Background
    mov ah, 0bh
    mov bh, 00h
    mov bl, black
    int 10h

ret

drawBall:
    ; Initial position 
    mov cx, word[xBall]
    mov dx, word[yBall]

    drawBallHorizontal:

        ; Draw a pixel (cx,dx)
        mov ah, 0ch
        mov al, white
        mov bh, 00h
        int 10h

        ; Next column
        inc cx
        mov ax, cx
        sub ax, word[xBall]
        cmp ax, word[sizeBall]
        jng drawBallHorizontal
        
        ; Next line
        mov cx, word[xBall]
        inc dx
        mov ax, dx
        sub ax, word[yBall]
        cmp ax, word[sizeBall]
        jng drawBallHorizontal

ret

moveBall:

    ; Horizontal offset
    mov ax, word[xBallVelocity] 
    add word[xBall], ax

    mov ax, word[windowBounds]
    cmp word[xBall], ax
    jl resetPosition

    mov ax, word[windowWidth]
    sub ax, word[sizeBall]
    sub ax, word[windowBounds]
    cmp word[xBall], ax
    jg resetPosition

    ; Vertical offset
    mov ax, word[yBallVelocity]
    add word[yBall], ax

    mov ax, word[windowBounds]
    cmp word[yBall], ax
    jl negVelocity

    mov ax, word[windowHeight]
    sub ax, word[sizeBall]
    sub ax, word[windowBounds]
    cmp word[yBall], ax
    jg negVelocity

    ; Check collision with the right paddle
    mov ax, word[xBall]
    add ax, word[sizeBall]
    cmp ax, word[xPaddleRight]
    jng checkCollisionWithLefttPaddle    

    mov ax, word[xPaddleRight]
    add ax, word[paddleWidth]
    cmp word[xBall], ax
    jnl checkCollisionWithLefttPaddle

    mov ax, word[yBall]
    add ax, word[sizeBall]
    cmp ax, word[yPaddleRight]
    jng checkCollisionWithLefttPaddle

    mov ax, word[yPaddleRight]
    add ax, word[paddleHeight]
    cmp word[yBall], ax
    jnl checkCollisionWithLefttPaddle

    ; The ball is colliding with the right ball
    neg word[xBallVelocity]

    ret

    ; Check collision with the left paddle
    checkCollisionWithLefttPaddle:
        mov ax, word[xBall]
        add ax, word[sizeBall]
        cmp ax, word[xPaddleLeft]
        jng exit    

        mov ax, word[xPaddleLeft]
        add ax, word[paddleWidth]
        cmp word[xBall], ax
        jnl exit

        mov ax, word[yBall]
        add ax, word[sizeBall]
        cmp ax, word[yPaddleLeft]
        jng exit

        mov ax, word[yPaddleLeft]
        add ax, word[paddleHeight]
        cmp word[yBall], ax
        jnl exit

        ; The ball is colliding with the left ball
        neg word[xBallVelocity]

        ret

    resetPosition:
        call resetBallPosition
        ret

    negVelocity:
        neg word[yBallVelocity]
        ret

    exit:

ret

drawPaddles:
    mov cx, word[xPaddleLeft]
    mov dx, word[yPaddleLeft]

    drawPaddleLeft:

        drawPaddleLeftHorizontal:
            ; Draw a pixel (cx,dx)
            mov ah, 0ch
            mov al, blue
            mov bh, 00h
            int 10h

            inc cx
            mov ax, cx
            sub ax, word[xPaddleLeft]
            cmp ax, word[paddleWidth]
            jng drawPaddleLeftHorizontal

            mov cx, word[xPaddleLeft]
            inc dx

            mov ax, dx
            sub ax, word[yPaddleLeft]
            cmp ax, word[paddleHeight]
            jng drawPaddleLeftHorizontal

    drawPaddleRight:

        mov cx, word[xPaddleRight]
        mov dx, word[yPaddleRight]

        drawPaddleRightHorizontal:
            ; Draw a pixel (cx,dx)
            mov ah, 0ch
            mov al, red
            mov bh, 00h
            int 10h

            inc cx
            mov ax, cx
            sub ax, word[xPaddleRight]
            cmp ax, word[paddleWidth]
            jng drawPaddleRightHorizontal

            mov cx, word[xPaddleRight]
            inc dx

            mov ax, dx
            sub ax, word[yPaddleRight]
            cmp ax, word[paddleHeight]
            jng drawPaddleRightHorizontal

ret      

movePaddles:
    ; ---- Left paddle ----
    
    ; Check keyboard buffer
    mov ah, 01h
    int 16h
    jz checkRightPaddleMovement

    mov ah, 00h
    int 16h

    ; Up movement
    cmp al, 'w' 
    je moveUpLeftPaddle
    cmp al, 'W'
    je moveUpLeftPaddle

    ; Down movement
    cmp al, 's' 
    je moveDownLeftPaddle
    cmp al, 'S'
    je moveDownLeftPaddle
    
    jmp checkRightPaddleMovement 

    moveUpLeftPaddle:
        mov ax, word[paddleVelocity]
        sub word[yPaddleLeft], ax

        mov ax, word[windowBounds]
        cmp word[yPaddleLeft], ax
        jl fixPaddleLeftTopPosition
    
        jmp checkRightPaddleMovement

        fixPaddleLeftTopPosition:
            mov ax, word[windowBounds]
            mov word[yPaddleLeft], ax
            jmp checkRightPaddleMovement

    moveDownLeftPaddle:
        mov ax, word[paddleVelocity]
        add word[yPaddleLeft], ax

        mov ax, word[windowHeight]
        sub ax, word[windowBounds]
        sub ax, word[paddleHeight]
        cmp word[yPaddleLeft], ax
        jg fixPaddleLeftBottomPosition

        jmp checkRightPaddleMovement

        fixPaddleLeftBottomPosition:
            mov word[yPaddleLeft], ax
            jmp checkRightPaddleMovement


    ; ---- Right paddle ----    
    checkRightPaddleMovement:
        ; Up movement
        cmp al, 'o' 
        je moveUpRightPaddle
        cmp al, 'O'
        je moveUpRightPaddle

        ; Down movement
        cmp al, 'l' 
        je moveDownRightPaddle
        cmp al, 'L'
        je moveDownRightPaddle
        
        jmp done 

        moveUpRightPaddle:
            mov ax, word[paddleVelocity]
            sub word[yPaddleRight], ax

            mov ax, word[windowBounds]
            cmp word[yPaddleRight], ax
            jl fixPaddleRightTopPosition
        
            jmp done

            fixPaddleRightTopPosition:
                mov ax, word[windowBounds]
                mov word[yPaddleRight], ax
                jmp done

        moveDownRightPaddle:
            mov ax, word[paddleVelocity]
            add word[yPaddleRight], ax

            mov ax, word[windowHeight]
            sub ax, word[windowBounds]
            sub ax, word[paddleHeight]
            cmp word[yPaddleRight], ax
            jg fixPaddleRightBottomPosition

            jmp done

            fixPaddleRightBottomPosition:
                mov word[yPaddleRight], ax
                jmp done
        
    done:

ret

delay:              
  mov cx, 00h
  mov dx, 86a0h
  mov ah, 86h
  int 15h

ret


