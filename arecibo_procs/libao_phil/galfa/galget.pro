;+
;NAME:
;galget - read a group  of galfa data records.
;
;SYNTAX: istat=galget(desc,b,rec=rec,han=han)
;
;ARGS: 
;   desc:{galdesc} gal descriptor returned from galopen()
;
;RETURNS:
;   istat: int  1 ok, 0 eof, -1 error.
;       b: {galget}  data structure holdin data.
;
;DESCRIPTION:
;   This is the lowlevel routine that reads the data from the fits file.
;This routine in normally not called by users. The user interface to the
;data in the file is via corget(). corget() will call this routine 
;automatically when it is passed a galDescriptor rather than a
;logical unit number(lun).
;
;18jan04 - added h.dop. set it so that it is doppler update 
;          each sbc even if it is not being done. We will load the
;          correct frequency, velocity into the header so that this
;          will be true.
;19jan04 - force returned data to always be in increasing freq order.
;          for now key off of flipped keyword (until cdelta1 is fixed).
;02feb04 - switch to use galftochdr() to get/convert the header.
;14jul04 - if pol data then acf's, do not flip data
;20aug04 - added iscan call to galftochdr.
;          use indar to return the data arrays independant of the order
;          they are stored on disc.
;-
function galget,desc,b,scan=scan,han=han
;
;   map the curpos row ptr (0 based) in the scan, grp we are about to read
;
    errmsg=''
    if n_elements(rec) gt 0 then begin
        if rec gt desc.totrecs then begin 
            print,"error positioning to rec:",rec
            return,-1
        endif
    endif
;
;   get the headers
;
    curposStart=desc.curpos
    istat=galftochdr(desc,h,hf=hf,irec=irec)
    if istat ne 1 then begin
        if istat eq 0 then goto,hiteof
        goto,hdrreaderr;
    endif
;
; allocate the data structure
;
   nlags=desc.nbchan
   nsbc=2
   pol=[1,2]
   b={b1:{  h:h[0],$;
           hf:hf[0],$
           accum: 0d,$
           p:pol ,$
           d:fltarr(nlags,nsbc,/nozero)},$
     b2:{  h:h[1],$;
           hf:hf[1],$
           accum: 0d,$
           p:pol ,$
           d:fltarr(nlags,nsbc,/nozero)},$
     b3:{  h:h[2],$;
          hf:hf[2],$
           accum: 0d,$
           p:pol ,$
         d:fltarr(nlags,nsbc,/nozero)},$
     b4:{ h:h[3],$;
         hf: hf[3],$
           accum: 0d,$
           p:pol ,$
         d:fltarr(nlags,nsbc,/nozero)},$
     b5:{ h:h[4],$;
         hf: hf[4],$
           accum: 0d,$
           p:pol ,$
         d:fltarr(nlags,nsbc,/nozero)},$
     b6:{ h:h[5],$;
         hf: hf[5],$
           accum: 0d,$
           p:pol ,$
         d:fltarr(nlags,nsbc,/nozero)},$
     b7:{ h:h[6],$;
         hf: hf[6],$
           accum: 0d,$
           p:pol ,$
         d:fltarr(nlags,nsbc,/nozero)}}

    errmsg=''
    colData=fxbcolnum(desc.lun,'data',errmsg=errmsg);
    if errmsg ne '' then goto , nodatacol
;
    nread=0
    nbrds=7
    j=0
    for ibrd=0,nbrds-1 do begin
        for isbc=0,1 do begin
            fxbread,desc.lun,d,colData,desc.curpos+1+j,errmsg=errmsg
            nread=nread+1
            if errmsg ne '' then goto,datareaderr
            b.(ibrd).d[*,isbc]=d
            j=j+1
        endfor
    endfor
    desc.curpos=desc.curpos + nread 
    if keyword_set(han) then corhan,b
    return,1

hiteof:
    return,0
nodatacol:
    print,'fits file has no data col in header'
    desc.curpos=curposStart
    return,-1
datareaderr:
    desc.curpos=curposStart
    print,'Error reading data array:'+ errmsg
    return,-1
hdrreaderr:
    desc.curpos=curposStart
    print,'Error reading hdr data:'
    return,-1
end
