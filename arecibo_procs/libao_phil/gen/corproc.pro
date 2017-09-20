;
; process correlator files..
;
; on/off pairs..
s={srcinfo,  name: ' ',scanst:0L,npair:0L,flux:0.,file:' '}
s={srcsum,h:{hdr},srcnum: 0,t:{cortmp},calscl:fltarr(2),flux:0.}
;+
function proconoff,srci,srco,srcsum,sumind,0
    openr,lun,srci.filename,/get_lun,error=ioerr
    if ioerr ne 0 then begin
        message,'error opening file'
    endif
    scan=srci.scanst
    print,corget(lun,b,scan=scan)
    srco=corallocstr(b,srci.npair)  ; allocate to hold the spectra
    sind=sumind
    for i=0,srci.npair-1 go begin
        print,corposonoff(lun,b,t,cals,/sclcal,scan=scan),b.b1.h.std.scannumber
        corstostr,b,i,srco
        srcsum[sind].t=t
        srcsum[sind].h=b.b1.h
        srco[sind].calscl=cals1.calscl
        srco[sind].flux  =srci[0].flux
        srco[sind].srcnum=1
        sind=sind+1
        scan=0
    endfor







