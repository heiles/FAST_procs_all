;+ 
;NAME:
;masget - input next mas rowfrom disc
;
;SYNTAX: istat=masget(des,b,row=row,hdronly=hdronly)
;
;ARGS:
;    desc:{descmas}  from masopen();
;
;RETURNS:
;     b: structure holding the hdr and data input
; istat: 1 ok
;      : 0 hiteof
;      :-1 i/o error..bad hdr, etc..
;
;KEYWORDS:
;     row     : if set then position to row before reading (count from 1)
;               if row=0 then ignore row keyword
;     hdronly : if set then just return the row header. no status or data.
;
;DESCRIPTION:
;
;   Read the next row from a mas fits datafile pointed to by desc.
;  If keyword row is present, position to row  before reading.
;-
; Note: eof() doesn't work on the rows because the heap follows the last row
function masget, desc,b,row=row,hdronly=hdronly
;
;
;
;;    on_error,2
    on_ioerror,ioerr
;
;   see if we position before start
;
    curRowStart=desc.currow
    if keyword_set(row) then begin
        if (row gt desc.totrows) or (row lt 1) then begin
            lab=string(format=$
            '("illegal row requested:",i," valid is 1 to",i)',row,desc.totrows);
            print,lab
            return,-1
        endif
        point_lun,desc.lun,desc.bytesRow*(row-1) + desc.byteoffrec1
        desc.currow=row-1
    endif 
    if (desc.currow ge desc.totrows) then begin
            lab=string(format=$
            '("hit last row of fits file:",i)',desc.totrows);
;            print,lab
            return,-1
    endif
;
;   debug.. get the two descriptors
;
;;    point_lun,desc.lun,desc.currow*desc.bytesRow + $
;;              desc.byteoffrec1 
;;  ll=lonarr(4)
;;  readu,desc.lun,ll
;;  ll=swap_endian(ll)
;;  print,"descriptors:",ll
    hdrB={masfhdrb}
    hdr={masfhdr}
;
;   read the header skipping the array descriptor
;
    point_lun,desc.lun,desc.currow*desc.bytesRow + $
                desc.byteoffrec1 + desc.descBYTES
    readu,desc.lun,hdrB
    if desc.needswap then hdrB=swap_endian(hdrB)    
    struct_assign,hdrB,hdr
;
;   fix up the strings
;
    n=n_elements(desc.strInd)
    for i=0,n-1 do hdr.(desc.strInd[i])=string(hdrb.(desc.strInd[i]))
    tdim1=fix(fxbtdim(string(hdrb.tdim1)))
    nchan=tdim1[0]*1L
    npol =tdim1[3]*1L
    ndump=tdim1[4]*1L
;
;   get the data then the status
;
    if (keyword_set(hdronly)) then begin
         b={ h : hdr ,$
            nchan:nchan,$
             npol:npol,$
            ndump :ndump,$
            pol  :hdr.pol} 
        desc.currow++;
        return,1
    endif
    errmsg=''
    fxbread,desc.lun,data,1,desc.curRow+1,errmsg=errmsg
    if errmsg ne '' then begin
        print,"data read error:" + errmsg
        goto,ioerr
    endif
    errmsg=''
    fxbread,desc.lun,statSh,2,desc.curRow+1,errmsg=errmsg
    if errmsg ne '' then begin
        print,"stat read error:" + errmsg
        goto,ioerr
    endif
;
;   move stat shorts to struct
;
    n=n_elements(data)
    if n ne nchan*npol*ndump then begin
        data=data[0:nchan*npol*ndump-1]
        statSh=statSh[0L:10L*ndump-1]
    endif
    statSh=reform(statSh,10,ndump)
    stat=replicate({pdev_hdrdump},ndump)
    for i=0,9 do stat.(i)=reform(statSh[i,*])
;
;   return the struct
;
    case 1 of
     ((npol eq 1) and (ndump eq 1)): $
            b={ h : hdr ,$
            nchan:nchan,$
             npol:npol,$
            ndump :ndump,$
            pol  :hdr.pol,$
            st   :stat,$
		    accum: 0D,$
            d : reform(temporary(data),nchan)}
     ((npol gt 1) and (ndump eq 1)): $
            b={ h : hdr ,$
            nchan:nchan,$
             npol:npol,$
            ndump :ndump,$
            pol  :hdr.pol,$
            st:  stat,$
		    accum: 0D,$
            d : reform(temporary(data),nchan,npol)}
     ((npol eq 1) and (ndump gt 1)): $
            b={ h : hdr ,$
            nchan:nchan,$
             npol:npol,$
            ndump :ndump,$
            pol  :hdr.pol,$
            st: stat,$
            d : reform(temporary(data),nchan,ndump)}
        else: $
            b={ h : hdr ,$
            nchan:nchan,$
             npol:npol,$
            ndump :ndump,$
            pol  :hdr.pol,$
            st: stat,$
		    accum: 0D,$
            d : reform(temporary(data),nchan,npol,ndump)}
    endcase
    desc.currow++;
    return,1
;
; testing..
ioerr: ; seems that we need a null line or the jump screws up
    on_ioerror,NULL
    hiteof=eof(desc.lun)
    desc.currow=curRowStart;
    if ( not hiteof ) then begin
            print, !ERROR_STATE.MSG
            return,-1
    endif else  return,0
end
