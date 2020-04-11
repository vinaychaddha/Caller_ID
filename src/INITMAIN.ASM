cid_port        equ     porta
kbd_port        equ     portb
kbd_sel         equ     3
cid_sel         equ     1
lcd_rs          equ     2
lcd_e           equ     3
lcdcont         equ     porta
lcdport         equ     porta
inita           equ     00h
initda_lcd      equ     0ffh
initda_cid      equ     0fh
initda_kbd      equ     0ffh
initdb          equ     00h


oh_in           equ     2               ; pb3 is offhook in and active high
oh_port         equ     portb
bl              equ     5               ; pb5 is back light and active high
bl_port         equ     portb

scl             equ     0
sda             equ     2
iicport         equ     porta
iicont          equ     ddra



start           rsp
                clr     porta
                lda     #initda_lcd
                sta     ddra
;               lda     #initb
;               sta     portb
                lda     #initdb
                sta     ddrb


;; clear memory from c0 to ff
cold_boot       clrx
nxt_mem_clr     clr     0c0h,x
                incx
                cmpx    #40h
                bne     nxt_mem_clr

                jsr     initlcd                 ; init lcd

;; read switch position at power on
;; if erase key pressed (up and dn together)
;;     then erase whole memory with ff
;;
warm_boot
                lda     #amsg_blank\256t
                ldx     #amsg_blank%256t
                jsr     write_line1
                jsr     sense_kbd
                lda     last_key
                cmp     #swerase
                bne     erase_over

;; erase memory

                lda     #amsg_erase\256t
                ldx     #amsg_erase%256t
                jsr     write_line1

erase_mem       jsr     fill_buff_ff
                clr     lcd_temp
erase_nxt       lda     lcd_temp
                jsr     save_in_memory
                lda     lcd_temp
                cmp     #max_call_memory
                beq     erase_call_counter
                inc     lcd_temp
                bra     erase_nxt

;; set call_counter to 1
;; and save in memory

erase_call_counter lda     #1
                sta     call_counter
                jsr     upd_counter

erase_over

                lda     #def_tscr               ; enable real time int
                sta     tscr
                cli                             ; enable interrupt


;; read 8 bytes of memory from address 0
;; check two consecutive same values seven times
;; if any match, save it in call_counter
;; else set call counter to 1
;; if value is zero or more than max_call_memory set call_counter to 1

                clra
                jsr     get_from_memory         ; get call counter
                clrx

nxt_match       lda     buff_cid,x
                cmp     buff_cid+1,x
                beq     match_found
                incx
                cmpx    #6
                bne     nxt_match
                lda     #1

match_found     cmp     #max_call_memory
                bls     match_ok
                tsta
                bne     match_ok
                lda     #1
match_ok        sta     call_counter

