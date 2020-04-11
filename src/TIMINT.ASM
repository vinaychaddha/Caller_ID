;; clear flags
;; set one_tick_over in hw_status
;; if offhook_toe # 0
;;      decrement offhook_toe
;;      if offhook_toe
;;              set on_hook
;; if ring_toe # 0
;;      decrement ring-toe
;;      if ring_toe = 0
;;              set ring_stopped
;; if dtmf_toe # 0
;;      decrement dtmf_toe
;;      if dtmf_toe = 0
;;              set cid_rcvd flag
;;

timint          lda     #def_tscr
                sta     tscr
                bset    one_tick_over,hw_status

chk_mem_toe     tst     mem_toe
                beq     chk_offhook_toe
                dec     mem_toe
                bne     chk_offhook_toe
                bset    mem_toe_over,hw_status

chk_offhook_toe
chk_dtmf_toe    tst     dtmf_toe
                beq     timint_over
                dec     dtmf_toe
                bne     timint_over
                bset    cid_rcvd,hw_status
dummy
timint_over     rti
