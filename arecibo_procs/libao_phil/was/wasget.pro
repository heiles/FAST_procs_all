;+
;NAME:
;wasget - read a group  of was data records.
;
;SYNTAX: istat=wasget(desc,b,scan=scan,han=han)
;
;ARGS: 
;   desc:{wasdesc} was descriptor returned from wasopen()
;
;RETURNS:
;   istat: int  1 ok, 0 eof, -1 error.
;       b: {wasget}  data structure holdin data.
;
;DESCRIPTION:
;   This is the lowlevel routine that reads the data from the fits file.
;This routine in normally not called by users. The user interface to the
;data in the file is via corget(). corget() will call this routine 
;automatically when it is passed a wasDescriptor rather than a
;logical unit number(lun).
;
;18jan04 - added h.dop. set it so that it is doppler update 
;          each sbc even if it is not being done. We will load the
;          correct frequency, velocity into the header so that this
;          will be true.
;19jan04 - force returned data to always be in increasing freq order.
;          for now key off of flipped keyword (until cdelta1 is fixed).
;02feb04 - switch to use wasftochdr() to get/convert the header.
;-
function wasget,desc,b,scan=scan,han=han
;
;   map the curpos row ptr (0 based) in the scan, grp we are about to read
;
    errmsg=''
    if n_elements(scan) gt 0 then begin
    if waspos(desc,scan) ne 1 then begin
            print,"error positioning to scan:",scan
            return,-1
        endif
    endif
;
;   get the headers
;
	curposStart=desc.curpos
    istat=wasftochdr(desc,h,hf=hf,pol=pol)
    if istat ne 1 then begin
        if istat eq 0 then goto,hiteof
        goto,hdrreaderr;
    endif
;
; allocate the data structure
;
     case h[0].cor.numbrdsused of
        1: begin 
            b={b1: {h:h,$
                    hf: hf,$
                    p:pol[*,0],$
                accum: 0.D,$
                    d:fltarr(h[0].cor.lagsbcout,$
                             h[0].cor.numSbcout,/nozero)}}
            end
        2: begin
           b={b1:{ h:  h[0],$
                  hf: hf[1],$
                   p:pol[*,0],$
              accum: 0.D,$
                  d:fltarr(h[0].cor.lagsbcout,$
                           h[0].cor.numSbcout,/nozero)},$
              b2:{ h:  h[1],$
                  hf: fh[1],$
                   p:pol[*,1],$
               accum: 0.D,$
                   d:fltarr(h[1].cor.lagsbcout,$
                           h[1].cor.numSbcout,/nozero)}}
            end
        3: begin
           b={b1:{ h: h[0],$
                  hf:hf[0],$
                  p:pol[*,0],$
              accum: 0.D,$
                  d:fltarr(h[0].cor.lagsbcout,$
                           h[0].cor.numSbcout,/nozero)},$
              b2:{ h: h[1],$
                  hf:hf[1],$
                   p:pol[*,1],$
               accum: 0.D,$
                   d:fltarr(h[1].cor.lagsbcout,$
                           h[1].cor.numSbcout,/nozero)},$
               b3:{h:  h[2],$
                  hf: hf[2],$
                   p:pol[*,2],$
                 accum: 0.D,$
                  d:fltarr(h[2].cor.lagsbcout,$
                           h[2].cor.numSbcout,/nozero)}}
            end
        4: begin
           b={b1:{ h: h[0],$
                  hf:hf[0],$
                  p:pol[*,0],$
              accum: 0.D,$
                  d:fltarr(h[0].cor.lagsbcout,$
                           h[0].cor.numSbcout,/nozero)},$
              b2:{ h: h[1],$
                  hf:hf[1],$
                  p:pol[*,1],$
              accum: 0.D,$
                  d:fltarr(h[1].cor.lagsbcout,$
                           h[1].cor.numSbcout,/nozero)},$
               b3:{h: h[2],$
                  hf:hf[2],$
                  p:pol[*,2],$
                 accum: 0.D,$
                  d:fltarr(h[2].cor.lagsbcout,$
                           h[2].cor.numSbcout,/nozero)},$
               b4:{h:  h[3],$
                  hf: hf[3],$
                   p:pol[*,3],$
                 accum: 0.D,$
                  d:fltarr(h[3].cor.lagsbcout,$
                           h[3].cor.numSbcout,/nozero)}}
            end
    endcase
    colData=fxbcolnum(desc.lun,'data',errmsg=errmsg);
    if errmsg ne '' then goto , nodatacol
;
    for ibrd=0,h[0].cor.numbrdsused-1 do begin
        flipped=(h[ibrd].cor.state and '0x00100000'XUL) ne 0
        for isbc=0,h[ibrd].cor.numSbcOut-1 do begin
            fxbread,desc.lun,d,colData,desc.curpos+1,errmsg=errmsg
            if errmsg ne '' then goto,datareaderr
            desc.curpos=desc.curpos+1 
            b.(ibrd).d[*,isbc]=(flipped)?reverse(d):d
        endfor
    endfor
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
