;; to be defined in initmain
;; sda                  equ
;; scl                  equ
;; iicport              equ
;; iicont               equ

;; byte_iic
;; input : data to be trnamitted in A reg
;; output : carry as per acknowledge. clear if ACK , high of NACk
;; function :    transfer 8 bits to iic bus and sense acknowledge
;;

;; input in a register
;; 1104(if ack)/1107(if no ack)
byte_iic:       bsr             tx_8bits        ; serial transfer of 8 bits 987(6)
                bclr            sda,iicont      ; leave sda high by making it input 5
                bsr             pulse_scl       ; 101/104
                bclr            sda,iicport     ; 5
                rts                             ; leave with sda as input 6

;; read_iicbyte
;; input : nil
;; output : data read from iic bus in A register
;;

read_iicbyte:   ldx             #8
                bclr            sda,iicont              ; set sda as input
read_iicbit:    bsr             pulse_scl
read_iic        rola
                decx
                bne             read_iicbit
                rts

send_ack        bclr            sda,iicport             ; send ack
send_acknack    nop
                bset            sda,iicont
                bsr             pulse_scl               ; sda as output
                bclr            sda,iicport             ; and low
                rts

send_nack       bset            sda,iicport             ; send no ack
                bra             send_acknack

;; generate stop condition
;; sda is set as output and low
;; fisrt sda is cleared  the scl is set high
;; then make sda high keeping scl high
;; on return scl is high and sda is also high
;; cycle used by gen_stop=73
;; cycle used by gen_start=103

gen_stop:       bclr            sda,iicport       ;5
                bset            sda,iicont        ;5     ; set sda as output
                jsr             delay_small       ;23(5)
                bset            scl,iicport       ;5
                bsr             delay_small       ;24(6)
                bset            sda,iicport       ;5     ; leave with sda and
                rts                               ;6     ; scl high and output


gen_start:      bset            sda,iicont        ;5      ; sda as o/p
                bset            sda,iicport       ;5      ; and high
                bsr             delay_small       ;24(6)
                bset            scl,iicport       ;5      ; scl also high
                bsr             delay_small       ;24(6)
                bclr            sda,iicport       ;5
                bsr             delay_small       ;24(6)
                bclr            scl,iicport       ;5
                rts                               ;6
