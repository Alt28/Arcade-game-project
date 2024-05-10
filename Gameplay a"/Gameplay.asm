.model small
.stack 100h

.data
    video_mode equ 13h ; VGA mode 320x200 pixels, 256 colors
    sky_color equ 9    ; Blue sky color index
    ground_color equ 1 ; Blue ground color index
    box_color equ 8    ; Grey color index

.code
main proc
    mov ax, @data       ; Initialize DS to point to data segment
    mov ds, ax

    mov ax, video_mode  ; Set video mode to 320x200, 256 colors
    int 10h

    mov ax, 0A000h      ; Set ES to point to the VGA memory
    mov es, ax

    mov cx, 32000       ; Total pixels in 320x200 screen (320*200/8)
    mov di, 0           ; Start writing from the beginning of VGA memory

    call fill_sky       ; Fill the entire screen with sky
    call fill_ground    ; Fill the entire screen with ground

    mov cx, 50          ; Number of frames to simulate falling
fall_loop:
    call draw_box       ; Draw the falling box
    call delay          ; Introduce a delay for smooth animation
    call clear_box      ; Clear the box from the previous position
    add di, 320         ; Move down one row for the next frame
    dec cx              ; Decrement frame counter
    jnz fall_loop       ; Repeat until all frames are drawn

    mov ax, 4C00h       ; Exit program
    int 21h

fill_sky:
    mov al, sky_color   ; Set the color to blue for the sky
    mov cx, 32000       ; Total pixels in 320x200 screen (320*200/8)
    rep stosb           ; Store the blue color in VGA memory
    ret

fill_ground:
    mov al, ground_color ; Set the color to blue for the ground
    mov cx, 32000       ; Total pixels in 320x200 screen (320*200/8)
    rep stosb           ; Store the blue color in VGA memory
    ret

draw_box:
    mov al, box_color   ; Set the color to grey for the box
    mov cx, 40          ; Width of the box (40 pixels)
    mov dx, 10          ; Starting Y-coordinate of the box (top of the screen)
    mov si, di          ; X-coordinate of the box (based on di register)
    add si, 140         ; Starting X-coordinate of the box (center of the screen - half of the box width)

draw_box_loop:
    ; Draw the box at current position
    call draw_horizontal_line ; Draw top line of the box
    call draw_horizontal_line ; Draw bottom line of the box
    call draw_vertical_line   ; Draw left side of the box
    call draw_vertical_line   ; Draw right side of the box

    ret

delay:
    mov cx, 50000       ; Increase delay loop count for slower animation
delay_loop:
    dec cx
    jnz delay_loop
    ret

clear_box:
    mov al, sky_color   ; Set the color to blue for clearing the box
    mov cx, 40          ; Width of the box (40 pixels)
    mov dx, 10          ; Y-coordinate of the box (top of the screen)
    mov si, di          ; X-coordinate of the box (based on di register)
    add si, 140         ; Starting X-coordinate of the box (center of the screen - half of the box width)

clear_box_loop:
    ; Clear the box at previous position
    call draw_horizontal_line ; Draw top line of the box
    call draw_horizontal_line ; Draw bottom line of the box
    call draw_vertical_line   ; Draw left side of the box
    call draw_vertical_line   ; Draw right side of the box
    ret

draw_horizontal_line:
    push cx             ; Save CX
    push di             ; Save DI
    mov cx, 40          ; Length of the line
    rep stosb           ; Draw horizontal line
    pop di              ; Restore DI
    pop cx              ; Restore CX
    ret

draw_vertical_line:
    push cx             ; Save CX
    push di             ; Save DI
    mov cx, 25          ; Height of the line (half of the screen height)
draw_vertical_line_loop:
    stosb               ; Draw vertical line
    add di, 320         ; Move to the next line
    loop draw_vertical_line_loop ; Repeat until CX becomes zero
    pop di              ; Restore DI
    pop cx              ; Restore CX
    ret

main endp

end main