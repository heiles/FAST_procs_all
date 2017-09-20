;+
;NAME:
;masupdfsize - update fits filesize for online file
;SYNTAX: istat=masupdfsize(desc,naxis2=naxis2)
;ARGS:
;desc :  {}   from masopen()
;RETURNS:
; istat:         1 naxis2 keyword in fits file was updated
;                0 no change to naxis2  keyword. file hasn't grown.
;naxis2: long    current value of naxis2
;
;DESCRIPTION:
;   The idl fits routines assume that the fits files are static.
;The size of the file is checked when the file is openned and that's it.
;When monitoring online files, the size of the file can grow after the
;initial masopen(). This routine will check if the file has grown 
;and updated the naxis2 value in the idl common block. Hopefully
;this will allow us to continue reading the file without having to
;close and then reopen it..
;
function masupdfsize,desc,naxis2=curnaxis2
;
; need the common block for the fits idl common block.
@fxbintable
;
; point in file for naxis2 location
point_lun,desc.lun,desc.byteoffnaxis2 
line1  =''
; read it
readf,desc.lun,line1,format='(a32)'
; convert string to long
curnaxis2=long(strmid(line1,10,20))
;
; find where this lun is in fits common
;
    istat=0
    ind=where(lun eq desc.lun,count)
    if count ne 0 then begin
      if (naxis2[ind] ne curnaxis2) then begin
        naxis2[ind]=curnaxis2
        desc.totrows=curnaxis2
        istat=1
      endif
    endif else begin
      istat=-1
    endelse
    return,istat
end
