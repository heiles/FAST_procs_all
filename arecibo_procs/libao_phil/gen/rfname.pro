;+
;NAME:
;rfname - given the rfnumber, return the standard receiver name
;SYNTAX : name=rfname(rfnum)
;ARGS   : 
;        rfnum: int 1-16..
;RETURNS:
;       name: string.. rfname.. sbn,sbw,lbn,lbw..etc..
; illegal or unimplented rfnumber will be return as the string
;  -number.. eg  rfnum 1 is not implented yet so it would return '-1'
;-
function rfname,rfnum
    rfnam=['-1','430','610','-4','lbw','lbn','sbw','-8','cband','-10','-11',$
        'sbn','-13','-14','-15','noisesrc']
    if ((rfnum lt 1) or (rfnum gt 16)) then begin
        return,string(-rfnum)
    endif
    return,rfnam[rfnum-1]
end
