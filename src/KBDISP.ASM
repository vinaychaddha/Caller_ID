;; sense_kbd:
;; routine to sense the key
;; scan line is selected from refresh grids routine ( since grids and scan lines
;; are multiplexed).

sense_kbd:      lda     #initda_cid
                sta     ddra
                bclr    cid_sel,cid_port

start_sense:    lda     kbd_port                ; read kbd port
                and     #kbd_sense_byte         ;
                clrx                            ; store to pointer
chk_next_key:   cmp     kbd_table,x             ; compare data with kbd_table
                beq     key_found
                incx                            ; increment table pointer
                cpx     #max_row_keys
                bne     chk_next_key

key_n_found:    lda     #0f0h                   ; load the code = 0f0 for no key
                bra     cmp_old_key

key_found:      txa                             ; restore from regx to rega and
cmp_old_key:    cmp     kbd_pos                 ; is it previous key ?
                beq     chk_for_f0
                bra     chk_for_last

chk_for_f0:     cmp     #0f0h                   ; if old key is some key,
                bne     set_key_timeout         ; goto set timeout
                bra     read_kbd_over           ; else, direct quit

chk_for_last:   cmp     last_key
                bne     new_key
                lda     #max_debnce
                cmp     same_key
                beq     upd_key
                inc     same_key
                rts
new_key:        sta     last_key
                clr     same_key
                rts
upd_key:        lda     last_key
                sta     kbd_pos
                cmp     #0f0h
                beq     read_kbd_over
                bset    new_key_found,hw_status ; else set new_key_found flag
                clr     key_byte_cnt    ; counter for keys repeat time control


;; routine comes here only when a key is pressed
;; after a key is pressed, routine enters into "start_sense" only when the same
;; scan line found (total 4 scan lines) i.e, after 4 * 5ms(intrpt = 20 ms)

set_key_timeout: cmp    #max_keys
                blo     store_timeout
                bra     read_kbd_over

store_timeout   inc     key_byte_cnt    ; increase key_byte_count
                lda     key_byte_cnt
                cmp     #cnt_onesec     ; is 1 second over
                bne     read_kbd_over   ; no, quit. Else increase repeat key cnt
                bset    new_key_found,hw_status
                lda     #cnt_halfsec
                sta     key_byte_cnt    ; and reset key_byte_cnt

read_kbd_over:  rts


kbd_table       db      80h,40h,20h,10h
max_row_keys    equ     4
if      debug
max_debnce      equ     00
$elseif
max_debnce      equ     05t
$endif
max_keys        equ     6
kbd_sense_byte  equ     0f0h

