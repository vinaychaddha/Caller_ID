;; check for off hook level
;;
chk_oh          brset   oh_in,oh_port,oh_active    ; high , oh found
oh_inactive     inc     oh_low                ; high  no oh , inc oh_low
                lda     oh_low                ; if oh_low is not yet valid
                cmp     #valid_oh_cnt         ; return
                blo     ret_oh_chk
                clr     oh_high               ; else clear high_oh
                brclr   oh_det,oh_status,ret_oh_chk ; if off hook to on hook
                bclr    oh_det,oh_status      ; clear oh_det
                bset    on_hook,oh_status     ; set on_hook
                bra     ret_oh_chk            ; and return

oh_active       inc     oh_high               ; increment oh_high
                lda     oh_high               ; if not yet valid return
                cmp     #valid_oh_cnt
                blo     ret_oh_chk
oh_active_v     clr     oh_low                ; clear low oh count

;;
;; if offhook confirmed
;;      offhook_toe = 4 secs
;;      if offhook_det = 0
;;              set offhook_det = 1
;;              first_ring = 1 and unknow_call = 1
;;                      unknown call = +1
;;              first_ring = 1 and unkonw call = 0
;;                      known call = +1
;;              first_ring = 0
;;                      clear display
;;                      byte_cnt = 0
;;
;;

oh_sense        bset    bl,bl_port
                brset   oh_det,oh_status,ret_oh_chk ; if already deteted
                bset    oh_det,oh_status      ; return else oh_sensed
oh_outgoing     jsr     one_job_over
ret_oh_chk
ret_oh_sensed   rts
