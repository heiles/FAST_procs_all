;+
;NAME:
;rmconfig - return config info for rcvr monitoring
;SYNTAX: istat=rmconfig(rcvnum,temps=temps,amps=amps,rcvnam=rcvnam)
;ARGS:   
;   rcvnum:   int    rcvr number to return info. 1 to 12
;
;RETURNS:
;   istat   : int    1 if this is a valid receiver with some monitoring info.
;                    0 invalid rcvr num or no monitoring package available
;KEYWORDS:
;   temps[3]: int    0..2 is T16k,T70K,Tomt. A 1 is returned if this stage
;                    exists for this receiver, a Zero is returned if this
;                    monitoring stage does not exist.
;   amps[3] : int    0..2 is stage 1,2,3 amps in dewar. A 1 is returned if
;                    this stage exists in the receiver, a 0 is returned if it
;                    does not exist.
;   rcvnam  : string return the name of this receiver.
;   
;
;DESCRIPTION:
;   Return info on the receiver monitoring configuration. The user enters
;the receiver number (1..12). The info is returned in the keywords.
;The temps array has a 1 if this temperature monitoring stage exists for 
;this receiver. The amps array has a 1 for each amplifier stage in the
;reciever (max of 3). 
;
;EXAMPLES:
;   get info on rcv number 2 (430) 
;   istat=rmconfig(2,temps=temps,amps=amps,rcvnam=rcvnam)
;   print,istat     
;   1
;   print,temps
;   1 1 0               ; only 16K and 70K monitoring, no omt.
;   print,amps 
;   1 1 0               ; only 2 amps to monitor
;   print,rcvnam
;   430
;-
;history:
; 04feb13 - 327 has amps monitoring 0,1 had been left out
;
function rmconfig,rcvnum,temps=temps,amps=amps,rcvnam=rcvnam
;
;   monitoring stages 16k,70k,omt   
;
    tempar=[[0,0,0],    $; 0 no rcvr
            [1,1,0],    $; 1 327 
            [1,1,0],    $; 2 430
            [1,0,0],    $; 3 800 only temp 1
            [0,0,0],    $; 4 no monitoring
            [1,1,1],    $; 5 lbw
            [1,1,1],    $; 6 lbn
            [1,1,1],    $; 7 sbw
            [1,1,1],    $; 8 sbh
            [1,1,1],    $; 9 cb 
            [1,1,1],    $; 10 cbh
            [1,1,1],    $; 11 xb
            [1,0,0]]     ; 12 sbn
     ampar=[[1,1,0],    $; 0 no rcvr
            [1,1,0],    $; 1 327
            [1,1,0],    $; 2 430
            [0,0,0],    $; 3 800 no monitoring
            [0,0,0],    $; 4 no monitoring
            [1,1,1],    $; 5 lbw
            [0,0,0],    $; 6 lbn
            [1,1,1],    $; 7 sbw
            [1,1,1],    $; 8 sbh
            [1,1,1],    $; 9 cb 
            [1,0,0],    $; 10 cbh
            [1,0,0],    $; 11 xb
            [1,1,0]]     ; 12 sbn
    stat=rcvnumtonam(rcvnum,rcvnam)
    if stat eq 0 then return,stat
    if rcvnam[0] eq 'none' then return,0
    amps=ampar[*,rcvnum]
    temps=tempar[*,rcvnum]
    ind=where(amps  ne 0,counta)
    ind=where(temps ne 0,countt)
    if (counta eq 0) and (countt eq 0) then return,0
    return,1
end
