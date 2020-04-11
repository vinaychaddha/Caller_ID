;; 7.1.99
;; modified initlcd program to start init in 8 bit then to 4 bit
;;
;; 5.1.99
;; added warm boot detection
;; do not initialise lcd in case of warm boot
;; add cop clear in chkbd/tx_8bits/long_loop

;; 15.12.98 auto detection addition started
;; and use of KJ1 inplace of J1

;; 14.12.98 memory for 99/63/31 finalised
;;6.12.98
;; memory for 30 locations added
;; if tel number entry in progress up/dn keys will not work
;; after some time display will revert to original position
;;
;; 1.12.98
;; convert number to nibble while incoming
;; save in 8 bytes only
;;
;; save 8 bytes in memory
;;
;; get data from memory and display on lcd screen
;;
;; display from ROM to lcd bypassing ram/data_line1


;; if incoming number on display then off hook will not blank display
;; till a number is entered

;; in cid routine check valid number for multiple times

;; mem save works only when unit is on hook ie incoming call
;; in off hook condition - number entered once is frozen and remain there till
;; unit goes on hook again
;; incoming call number remain on display till offhook-on hook or
;; another incoming call
;; or number dialled in off hook condition

;; for single line display
;; in write_line1 after 8 char change dd ram add
;; in cid.asm also after 8 char change dd ram add

;; back light goes on with ring and off hook
;; and remain on till off hook/ring timeout

;; ringer and dtmf working
;; display unknown call and display balnk out after some time

$setnot         debug


$INCLUDE        "STDj1.ASM"
$INCLUDE        "STDCID.ASM"

$setnot         disp_4094
                org     300h

$include        "initlcd.asm"
$include        "timint.asm"
$include        "offhook.asm"
$include        "cid.asm"
$include        "kbd.asm"
$include        "tx_4094.asm"
$include        "iicsub.asm"

$include        "initmain.asm"

                jsr     welcom_msg
chkbd           nop
                lda     #0
                sta     copr
$ifnot  debug
                brclr   one_tick_over,hw_status,chkbd
$endif
                bclr    one_tick_over,hw_status
                jsr     read_cid                ; sense for dtmf in
                jsr     chk_oh                  ; check for off hook status
                jsr     sense_kbd
                tst     byte_cnt                ; skip keys if entry in progress
                bne     chk_offhook

;; if new key received
;; clear new key flag
;; display data from memory for current call
;; inc/dec last_call_counter flag
;;
                brclr   new_key_found,hw_status,chk_offhook
                bclr    new_key_found,hw_status
                lda     kbd_pos

chk_del         cmp     #swdel                  ; if del key pressed
                bne     chk_up
                tst     mem_toe                 ; act only if mem display
                beq     chk_offhook
                jsr     fill_buff_ff            ; fill buffer with ff
                jsr     disp_from_memory        ; and display
                lda     last_call_counter
                jsr     save_in_memory
                bra     chk_offhook

chk_up          cmp     #swup                   ; is up key pressed
                bne     chk_dn
                tst     mem_toe
                beq     disp_cur_mem
                lda     last_call_counter
                bsr     nxt_counter
                bra     read_disp_mem           ; with address pointer in A

chk_dn          cmp     #swdn                   ; is dn key pressed
                bne     chk_offhook
                tst     mem_toe
                beq     disp_cur_mem
                lda     last_call_counter
                bsr     prev_counter
                bra     read_disp_mem


disp_cur_mem    ldx     #8                      ; shift display left by 8 pos
sl_by_1         lda     #18h
                jsr     write_lcd_comm
                decx
                bne     sl_by_1
                lda     call_counter            ; display last memory
                bsr     prev_counter

read_disp_mem   sta     last_call_counter       ; assume address pointer in A
                jsr     get_from_memory         ; display from memory
                jsr     disp_from_memory
                lda     #def_mem_toe
                sta     mem_toe
                bset    bl,bl_port              ; set light on

chk_offhook     brclr   on_hook,oh_status,chk_new_call
                bclr    on_hook,oh_status
                bclr    bl,bl_port
                bsr     one_job_over
                bsr     welcom_msg

;; if cid_rcvd flag set and unit on hook (ie incoming call)
;;      fill unused bytes with 20h
;;      if known call
;;              store in memory
;;      clear byte_cnt
;;      clear cid_rcvd flag
chk_new_call    brclr   cid_rcvd,hw_status,chk_memtoe
                brset   oh_det,oh_status,chk_memtoe
                lda     byte_cnt                ; less than 4 digit
                cmp     #3                      ; do not store
                bhi     upd_memory
                bra     upd_mem2
upd_memory      lda     call_counter
                jsr     save_in_memory
                lda     call_counter
                bsr     nxt_counter
                sta     call_counter

upd_mem1        bsr     upd_counter
upd_mem2        bsr     one_job_over


;; when mem to is over display welcom message in on hook state
chk_memtoe     brclr   mem_toe_over,hw_status,chk_something
               bclr    mem_toe_over,hw_status
               bsr     ret_home
               bclr    bl,bl_port               ; clear light

chk_something   jmp     chkbd

;; increment a by 1, rollover to 1 if max_call_memory exceeded
nxt_counter     inca
                cmp     #max_call_memory
                bls     ret_nxt_counter
                lda     #1
ret_nxt_counter rts

prev_counter    deca
                tsta
                bne     ret_prev_counter
                lda     #max_call_memory
ret_prev_counter rts


one_job_over    clr     mem_toe
                bclr    mem_toe_over,hw_status
                clr     dtmf_toe
                bclr    cid_rcvd,hw_status
                clr     byte_cnt
ret_home        lda     #3
                jsr     write_lcd_comm
                jmp     extra_delay              ; auto return

;; store call counter in location 00

upd_counter     lda     call_counter            ; store call counter in
                clrx
fill_counter    sta     buff_cid,x                ; 0th location
                incx
                cmpx    #8
                bne     fill_counter
                clra
                bra     save_in_memory          ; auto return

welcom_msg      bsr     ret_home
                lda     #amsg_wel\256t
                ldx     #amsg_wel%256t
com_msg         jsr     write_line1
                lda     #080h
                jmp     write_lcd_comm

amsg_erase      equ     *
msg_erase       db      "Erasing memory  "

amsg_wel        equ     *
msg_wel         db      "Have a nice day "

amsg_blank      equ     *
msg_blank       db      "                "
;; save first 8 bytes from cid_buff in memory
;; add is specifed by the call_counter
;; increment call counter after saving
;; last_call_counter is the address for current call
;; call_counter is the address for storing next call
;; last_call_counter may be changed by up/dn keys.

save_in_memory  bsr     cal_iicmem_add
save_in_mem1    clr     mem_counter
                jsr     gen_start
                lda     iic_add
                jsr     byte_iic
                bcs     save_in_mem1
                lda     e_add              ; mem add is call counter * 8
                jsr     byte_iic
                bcs     save_in_mem1

save_in_mem2    ldx     mem_counter
                lda     buff_cid,x
                jsr     byte_iic
                bcs     save_in_mem1

                inc     mem_counter
                ldx     mem_counter
                cmpx    #8
                bne     save_in_mem2
                jmp     gen_stop

;; calculate address field of iic slave address from e_add
;; a2 a1 a0 x x x x x   acc
;; x x x x x 0 0 0      e_add
;; 0 0 0 0 a2 a1 a0 0   iic_add
;;
cal_iicmem_add  sta     e_add
                lsl     e_add
                rolx
                lsl     e_add
                rolx
                lsl     e_add
                rolx
                rolx
                txa
                and     #0eh
                ora     #0a0h
                sta     iic_add
                rts




;; get data from memory 8 bytes -

get_from_memory  bsr     cal_iicmem_add
get_from_memory1 jsr    gen_start
                lda     iic_add
                jsr     byte_iic
                bcs     get_from_memory1
                lda     e_add
                jsr     byte_iic
                jsr     gen_start
                lda     iic_add                 ; iic add
                inca                            ; add 1 to it
                jsr     byte_iic
                clr     mem_counter
                bra     gfm1
gfm2            jsr     send_ack
gfm1:           jsr     read_iicbyte
                ldx     mem_counter
                sta     buff_cid,x
                inc     mem_counter
                ldx     mem_counter
                cmpx    #8
                bne     gfm2                    ; send ack and read next
                jsr     send_nack
                jmp     gen_stop

;; display on lcd screen
;; blank screen
;; get data from cid_buff, maximum 6 bytes
;; display on lcd nibble by nibble till all 6 bytes are over
;; or F is encountered
;; also display Ixx) for number

disp_from_memory lda     #88h                    ; set address counter to 8
                jsr     write_lcd_comm

                lda     #"I"
                jsr     write_lcd_data
                lda     last_call_counter       ; get last call counter
                clr     mem_counter
nxt_in          cmp     #0ah                    ; if number is 10 ore more
                blo     disp_msb                ; sub 10 from number
                sub     #0ah
                inc     mem_counter             ; increment msb
                bra     nxt_in                  ; repeat till number is < 10
disp_msb        tax                             ; save lsb in x
                lda     mem_counter             ; get msb
                stx     mem_counter             ; save lsb in mem_counter
                add     #30h                    ; display msb
                jsr     write_lcd_data
                lda     mem_counter             ; get lsb
                add     #30h
                jsr     write_lcd_data          ; display lsb

                lda     #")"
                jsr     write_lcd_data
                clr     mem_counter             ; reset pointer
disp_mem_lcd1   ldx     mem_counter
                lda     buff_cid,x              ; get a byte
                and     #0fh                    ; lower nibble
                jsr     con_ascii
                ldx     mem_counter
                lda     buff_cid,x              ; upper nibble
                lsra
                lsra
                lsra
                lsra
                jsr     con_ascii
                inc     mem_counter             ; next byte
                ldx     mem_counter
                cmpx    #2                      ; if 4 bytes/8 ascii
                bne     dml1                    ; converted
                lda     #0c8h                   ; nxt on nxt line
                jsr     write_lcd_comm
dml1            ldx     mem_counter
                cmpx    #6                      ; till all 6 are over
                bne     disp_mem_lcd1
disp_mem_lcd2   rts

                org     7f1h
                db      69h

                org     7f8h
                fdb     timint
                fdb     dummy
                fdb     dummy
                fdb     start
