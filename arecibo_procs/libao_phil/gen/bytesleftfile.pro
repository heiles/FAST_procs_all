;+
;NAME:
;bytesleftfile - return the unread bytes left in a file
;SYNTAX: bytesLeft=bytesleftfile(lun,bytereq=bytereq,chktime=chktime,$
;                               maxloop=maxloop,cursize=cursize)
;ARGS:
;         lun: int  lun to already open file that we should check.
;KEYOWRDS:
; bytereq: long Wait until at least this number of bytes is available.
;               use the chktime keyword to determine how often to check
;chktime : float number of seconds to delay between file size checks. This
;                is used if bytereq is specified. The default is 1 second.
;maxloop : long  max number of times to loop if bytereq option used.
;                The default is 999999
;RETURNS:
;   bytesLeft: LONG returns the unread bytes in the file
;   cursize  : LONG current number of bytes in file
;
;DESCRIPTION:
;   The routine will return the number of unread bytes in a file. 
;It takes 5 to 10 milliseconds to check the file size. 
;   The bytereq option will wait until at least bytereq bytes are available 
;in the file. The chktime option specifies how often to check the file size.
;The maxloop option tells how many times to check the file before quitting.
;EXAMPLE:
;   openr,lun,'/share/olcor/corfile.15jun02.x101.1',/get_lun
;   nbytes=bytesleftfile(lun)
;   Wait till there are at least 5k bytes. Check every 10 secs and loop
;   a maximum of 60 times:
;   nbytes=bytesleftfile(lun,bytereq=5000,chktime=10,maxloop=60)
;   
;-
function bytesleftfile,lun,bytereq=bytereq,chktime=chktime,maxloop=maxloop,$
                        cursize=cursize
        
    if n_elements(bytereq) eq 0 then bytereq=0
    if n_elements(chktime) eq 0 then chktime=1.
    if n_elements(maxloop) eq 0 then maxloop=999999L
    if bytereq eq 0 then maxloop=0
    if maxloop le 0L then maxloop=1L
    fstd=fstat(lun)
    for i=0L,maxloop-1 do begin
        openr,lun1,fstd.name,/get_lun
        fst1d=fstat(lun1)
        free_lun,lun1
        bytesLeft=fst1d.size - fstd.cur_ptr
        cursize=fst1d.size
        if (bytesLeft ge bytereq) then goto,done
        if (maxloop gt 1) and (chktime gt 0.) then wait,chktime
    endfor
done:
    return,bytesLeft
end
