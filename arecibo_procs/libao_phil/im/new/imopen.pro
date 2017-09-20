;---------------------------------------------------------------------------
;lun=imopen,yymmdd  - open file, return lun in lun
;---------------------------------------------------------------------------
function imopen,yymmdd
;
; return -1 if error
;
; convert to string and replace leading blanks with zeros.
;
syymmdd=string(format='(i6.6)',yymmdd)
;
; first try online, then offline directories..
;
name='/share/rfidat/data/IM' + syymmdd + '.dat'
openr,lun,name,/get_lun,error=ioerr
if (ioerr ne 0) then begin
   smm=strmid(syymmdd,2,2)
   syy  = strmid(syymmdd,0,2)
   name=string(format='("/share/rfi/data/y",A2,"/IM",A2,"/IM",a,".dat")',$
                syy,smm,syymmdd)
   openr,lun,name,/get_lun,error=ioerr
   if (ioerr ne 0) then begin
     printf,-2,!ERR_STRING;
     lun=-1
   end
end
return,lun
end
