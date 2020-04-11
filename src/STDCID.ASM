                org     0c0h

max_num_length  equ     10h
blank_buff      equ     20h

buff_cid        db      0,1,2,3,4,5,6,7
get_byte        db      00,00,00,00     ; used by write_line1 only


e_add           db      00
iic_add         db      00
lcd_data        db      00
lcd_temp        db      00

oh_status
hw_status       db      00
tone_detect     equ     7
cid_rcvd        equ     6
one_tick_over   equ     5
unknown_call    equ     4
oh_det          equ     3
on_hook         equ     2
new_key_found   equ     1
mem_toe_over    equ     0

byte_cnt        db      00
dtmf_toe        db      00
def_dtmf_outoe  equ     240t            ; outgoing toe of 240 ints
def_dtmf_intoe  equ     20t             ; incoming toe of 20 ints

def_tscr        equ     15h             ; rti after every 16 msec
cnt_onesec      equ     60t
cnt_halfsec     equ     30t

oh_toe          db      00
def_oh_toe      equ     240t

oh_low          db      00
oh_high         db      00
valid_oh_cnt    equ     20t

cid_low         db      00
cid_high        db      00
def_cid_len     equ     2


call_counter    db      00
last_call_counter db    00

same_key        db      00
last_key        db      00
kbd_pos         db      00

key_byte_cnt    db      00

mem_counter     db      00

max_call_memory equ     99t            ; 99t/63t/31t

def_mem_toe     equ     240t
mem_toe         db      00

test_pattern    db      00
test_pattern1   db      00
