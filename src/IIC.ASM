;; 28.4.98
;; to maintain compatibility with old programs
;; and to add access to 24c04
;; following routines are added
;; get_eeprom_info1 and set_eeprom_info1
;; they will act as get_eeprom_info and set_eeprom_info
;; except that address will be 256+e_add
;; old programs do not need change - however checksum and program size may
;; change

;; 28.2.98
iic subroutine consist of following small programs

$include        "tx_4094.asm"
$include        "iicsub.asm"
$include        "iictxrx.asm"
$include        "iicmem.asm"
$include        "iic5511.asm"           ; if TSA5511 used ie UV916E

;; add following lines in stdmain

e_dat                db      00,00,??,??
e_add                db      00
iic_buff             db      00,00,00,??,??
max_iic_bytes        db      00
iic_counter          db      00
dat_counter          db      00
max_mem_bytes        equ     ??

div_ratio            db      00,00              ; reqd for TSA5511 only
ba_byte              db      00                 ; reqd for TSA5511 only


mem_status           db      00
mem_busy             equ     ??

;; add following lines in initmain

scl                  equ
sda                  equ
iicport              equ                data port of scl and sda
iicont               equ                direction port of scl and sda


;; to write data in memory
;;      set e_add to mem location
;;      set data to be written in e_dat
;;      ensure that max_mem_bytes is equal to no of bytes to be written
;;      call set_eeprom_info


;; to read data from memory
;;      set e_add to mem location
;;      ensure that max_mem_bytes is equal to no of bytes to be read
;;      call get_eeprom_info
;;      data is read into buffer starting from e_dat

;; 23.7.98
;; added mem_busy flag in mem_status
;; before writing/reading set this flag and clear before returning
;;