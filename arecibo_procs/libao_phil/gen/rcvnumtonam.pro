;+
;NAME:
;rcvnumtonam - convert receiver number to receiver name.
;SYNTAX: stat=rcvnumtonam(rcvnum,rcvnam,/num)
;ARGS:
;   rcvnum : int    receiver number 1..16
;KEYWORDS:
;   num    : if set then user inputs the rcvnam and we return the rcvnum
;RETURNS:
;   rcvnam: string  receiver name
;   stat  :  int    1 value receiver num, 0 invalid receivernumber
;DESCRIPTION
;   Convert a receiver number to receiver name. Return the receiver name
;in the string rcvnam. Return the status :1 ok, 0 no receiver with this
;num in stat.
;-
function rcvnumtonam,rcvnum,rcvnam,num=num
    rcvlist=[$
    '327','430','800','none','LBW','none','SBW','SBH','CB','CBH','XB','SBN',$
        'none','none','none','CH430','ALFA']
    rcvnuma=[ $
      1  , 2   ,  3,     4,     5,    6  ,  7    ,8   ,9    ,10,    11,  12,$
         13,     14,    15,100,17]

    if keyword_set(num) then begin
        nrcv=n_elements(rcvnam)
        for i=0,nrcv-1 do begin
            if rcvnam[i] ne 'none' then begin
                ind=where(rcvnam[i] eq rcvlist,count)
                if nrcv eq 1 then begin
                    if count eq 0 then return,0
                    rcvnum=rcvnuma[ind]
                    return,1
                endif
                if  i eq 0 then rcvnum=lonarr(nrcv) 
                if count eq 0 then return,0
                rcvnum[i]=rcvnuma[ind]
            endif
        endfor
    endif else begin
        nrcv=n_elements(rcvnum)
        for i=0,nrcv-1 do begin
            ind=where(rcvnum[i] eq rcvnuma,count)
            if nrcv eq 1 then begin
                if count eq 0 then return,0
                rcvnam=rcvlist[ind]
                return,1
            endif
            if  i eq 0 then rcvnam=strarr(nrcv) 
            if count eq 0 then return,0
            rcvnam[i]=rcvlist[ind]
        endfor
    endelse
    return,1
end
