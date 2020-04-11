if ring
        set ring_toe
if first ring
        clear display and byte_cnt
if second ring detected
        if byte_cnt is less than 6
                display and set unknown call

when ring_toe over and unit still on hook
        display welcom message
        inc missed calls

when unit goes off hook and first_ring is set
        clear first_ring,ring_det,ring_stopped,ring_toe
        increment known calls or unknown call (depending upon flag)


when unit goes off hook and first_ring is clear
        clear display


when unit goes on hook
        display welcom message




power on

initilase ports
initilase lcd
display signon message
wait for 2 secs
set byte_cnt = 0
set timeout = 0
clear hw_status (incoming_call)
                (first ring detect)
                (tone_detect)

if ring_stopped
        clear first ring detect
        save in memory


if ring detect
        set ring_toe =  4 secs
        if first ring = 0
                set first ring detect
                set byte_cnt = 0
                clear display
        if first ring = 1 and cid_rcvd = 0
                if byte_cnt < 6
                        display "Unknown Source"
                set cid_rcvd = 1
                clear byte_cnt



if onhook to offhook sensed and not incoming call
        set outgoing call
        set byte_cnt = 0
        clear display

if onhook to offhook sensed and incoming call
        store number in incoming memory

timint
        if dtmf_toe # 0
                decrement dtmf_toe
                if dtmf_toe = 0
                        set cid_rcvd flag in hw_status
        if ring_toe # 0
                decremnt ring_toe
                if ring_toe = 0
                        set ring_stopped in hw_status


if tone detected from dtmf sensor and tone sensed flag is inactive
        set tone sensed flag
        read data
        if byte_cnt < max_num_length
                store in buff+byte_cnt
                if byte_cnt = 0
                        clear display
                transfer to display
                increment byte cnt
        set dtmf_toe to 4 secs


