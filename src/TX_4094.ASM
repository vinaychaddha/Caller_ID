;; tx_4094
;; input : data to be serially transmitted in A register
;; function : transfer 8 bits from acc (MSB first) to sda and scl
;; uses : A and X register
;; comments : set sda as output port, leaves with scl low, sda undefined
;;
;; totol cycles = 986 (tx_4094)
;; total_cycle = 981 (tx_8bits)


tx_8bits        bset            sda,iicont      ; set sda as output port 5
                ldx             #0
                stx             copr
                ldx             #8              ; count of 8 bits 2

;; total cycles = 3+3+(5+3)/(5)+101/104+3+3
;;              = 6 + 8/5 + 101/104 + 6
;               = 121

bit_iic:        rola                            ; shift msb to carry 3
                bcc             sda_low         ; if no carry(msb low) 3
sda_high:       bset            sda,iicport     ; carry set msb high 5
                bra             sda_hl          ; 3
sda_low:        bclr            sda,iicport     ; 5
sda_hl:         bsr             pulse_scl       ; 101/104 (6)
                decx                            ; is count over 3
                bne             bit_iic         ; no next bit 3


                rts                             ; 6

;; pulse_scl
;; input : Nil
;; output : carry as per sda value
;; function : pulse scl to high and then low
;;            read value of sda and copy it to carry
;; uses     : nil

;;              95(if 0)/98(if 1)

pulse_scl:      bsr             delay_small     ; delay  24 (6)
                bset            scl,iicport     ; set scl high 5
                bsr             delay_small     ; 24 (6)
                brset           sda,iicport,iic_1       ; read data bit 5
iic_0           clc                             ; 2
                bra             scl_0           ; 3
iic_1           sec                             ; 2
scl_0           bclr            scl,iicport     ; then scl is set low   5
                bsr             delay_small     ; 24 (6)
                rts                             ; 6

; total cycles - 18

delay_small:
$if     debug
                rts
$endif
                nop             ;2
                nop             ;2
                nop             ;2
                nop             ;2
                nop             ;2
                nop             ;2
                rts             ;6
