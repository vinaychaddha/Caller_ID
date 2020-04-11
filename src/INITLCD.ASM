
lcd_table       db      28h,0ch,01h,06h,14h
lcd_initable    db      03h,03h,03h,02h
initlcd:
                bsr     extra_delay
                bclr    lcd_rs,lcdcont          ; only for nibble mode
                clr     e_add
nxt_lcd_init    ldx     e_add
                lda     lcd_initable,x
                bsr     write_lcd_comm1
                bsr     long_delay
                inc     e_add
                lda     e_add
                cmp     #4
                bne     nxt_lcd_init

;; send five bytes from lcd_table

                clr     e_add
nxt_lcd_byte    ldx     e_add
                lda     lcd_table,x
                bsr     write_lcd_comm
                clra
                bsr     short_loop
                inc     e_add
                lda     e_add
                cmp     #5
                bne     nxt_lcd_byte
                bra     long_delay              ; auto return



;; save data in lcd_data
;; set direction as output
;; set rs = 0 , rw = 0
;; set data = upper 4 bits of lcd_data
;; pulse e
;; set data = lower 4 bits of lcd_data
;; pulse e

write_lcd_data: bset     lcd_rs,lcdcont
                bra      write2lcd


write_lcd_comm: bclr    lcd_rs,lcdcont
write2lcd:


                sta     lcd_data
                lda     lcdport         ; read lcd port
                and     #0fh            ; keep non lcd bits
                sta     lcd_temp        ; save in lcd_temp
                lda     lcd_data        ; get lcd data
                and     #0f0h           ; upper nibble
                ora     lcd_temp        ; or with nonlcd bits
                sta     lcdport
                bset    lcd_e,lcdcont
                nop
                nop
                nop
                bclr    lcd_e,lcdcont
                lda     lcd_data
write_lcd_comm1:sta     lcd_data
                lda     lcdport
                and     #0fh
                sta     lcd_temp
                lda     lcd_data
                lsla
                lsla
                lsla
                lsla
                and     #0f0h
                ora     lcd_temp
                sta     lcdport
                bset    lcd_e,lcdcont
                nop
                nop
                nop
                bclr    lcd_e,lcdcont
                bra     short_delay             ; auto return



extra_delay:    ldx     #30t
                bra     long_loop


long_delay:     ldx     #5t
long_loop:      clra
                sta     copr
                bsr     short_loop
                decx
                bne     long_loop
                rts


short_delay:    lda     #25t
short_loop:
$if     debug
                rts
$endif
                nop
                deca
                bne     short_loop
                rts


;; transfer data to line1
;; first 8 char at 00
;; select data lines as output
;; disable 8870 output

write_line1:    sta     get_byte+1
                stx     get_byte+2
                lda     #0d6h           ; transfer lda  tmsg1,x/rts
                sta     get_byte        ; to memory
                lda     #81h
                sta     get_byte+3
                bclr    cid_sel,porta
                lda     #initda_lcd
                sta     ddra
                lda     #80h
write_line:     bsr     write_lcd_comm
                clrx
next_lcd_byte:  jsr     get_byte
                bsr     write_lcd_data
                incx
                cmpx    #10h
                beq     ret_write_line1
                cmpx    #08h
                bne     next_lcd_byte
                lda     #0c0h
                bsr     write_lcd_comm
                bra     next_lcd_byte
ret_write_line1 rts




