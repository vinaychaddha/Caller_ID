;; if cid_rcvd set  do not read further cid
;; if std pin inactive clear tone_detect and return
;; if tone detect set then return
;; set tone detect flag
;; if byte_cnt = 0
;;      clear display
;; the set data line direction as input
;; ensure kbd is switched off
;; set cid_sel active
;; read data
;; clear cid_sel
;; set data line direction as output
;; convert to ascii (for 0-9 convert to 30-39, for A-F convert to 41-46)
;;      A is converted to 30H and not to 41H (special case)
;;      0 is convert to 44H and not to 30H (special case)
;; store in buff+byte_cnt
;; store in lcd
;; increment byte count
;; return

;; fill cid_buff with ff
fill_buff_ff    clrx
                lda     #0ffh
fill_buff:      sta     buff_cid,x
                incx
                cmpx    #8
                bne     fill_buff
                rts


read_cid        brset   cid_rcvd,hw_status,ret_readcid1
                bil     cid_inactive
cid_active      clr     cid_low
                inc     cid_high
                lda     cid_high
                cmp     #def_cid_len
                bne     ret_readcid1
                bra     tone_found

cid_inactive    clr     cid_high
                inc     cid_low
                lda     cid_low
                cmp     #def_cid_len
                bne     ret_readcid
                bra     tone_missing

ret_readcid1    jmp     ret_readcid

tone_found      brset   tone_detect,hw_status,ret_readcid
                bset    tone_detect,hw_status
                tst     byte_cnt                ; is byte_cnt = 0
                bne     read_cid1

                lda     #amsg_blank\256t
                ldx     #amsg_blank%256t
                jsr     write_line1
                jsr     fill_buff_ff            ; fill buffer with ff
                jsr     one_job_over            ; clear variabled of old job
                                                ; ie mem display etc..

read_cid1       lda     #initda_cid
                sta     ddra
                bset    cid_sel,cid_port

rc_store:       ldx     byte_cnt                ; store up to max_num_len
                cmpx    #max_num_length
                blo     rc_store1
                bra     set_toe                 ; else update toe only

;; store data in buff (same as data_line1)
;; store nibble by nibble (so total of eight bytes)
rc_store1:      lsrx
                lda     cid_port
                bcc     even_byte
odd_byte        ora     #0fh            ; keep data at higher byte
                bra     even_odd_byte
even_byte       lsra                    ; shift data to lower nibble
                lsra
                lsra
                lsra
                ora     #0f0h           ; set upper nibble as 1111
even_odd_byte:  and     buff_cid,x      ; and with buffer byte which is ff
                sta     buff_cid,x      ; and store back

;; get the data again from 8870

                lda     cid_port        ; get back the data
                lsra                    ; on lower 4 bits
                lsra
                lsra
                lsra
                bsr     con_ascii
                inc     byte_cnt
                ldx     byte_cnt
                cmpx    #8                      ; if 8 byte written
                bne     set_toe
                lda     #0c0h                   ; set next byte at nxt line
                jsr     write_lcd_comm          ;
set_toe         lda     #def_dtmf_outoe
                brset   oh_det,oh_status,set_toe1
set_intoe       lda     #def_dtmf_intoe         ; set dtmf toe for on hook
set_toe1:       sta     dtmf_toe
ret_readcid     rts



tone_missing
clr_tdf         bclr    tone_detect,hw_status
                rts

;; convert it to ascii
;; input in Accumulator
con_ascii       cmp     #0fh                    ; if 0f convert to blank
                bne     chk_00
                lda     #20h
                bra     ascii2lcd
chk_00          cmp     #00h                    ; if 00 then convert to 0d
                bne     chk_0a
                lda     #0dh
chk_0a          cmp     #0ah                    ; if 0A then convert to 00
                bne     add_30h
                lda     #0
add_30h         add     #30h                    ; add 30 to convert to ascii num
                cmp     #39h
                bls     ascii2lcd
                add     #7                      ; add 7 to convert 3A to 41
;; display on lcd

ascii2lcd       bclr    cid_sel,cid_port
                ldx     #initda_lcd
                stx     ddra
upd_lcd         jmp     write_lcd_data          ; A contain the ascii code

