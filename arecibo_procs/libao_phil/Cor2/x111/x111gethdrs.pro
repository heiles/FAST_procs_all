;
; get header info for all headers in the directory.
;
function x111gethdrs,dir
;
;   on_ioerror,done
    cd,dir,current=odir
    hdrnames=findfile('*.hdr',count=numhdr)
    hdrlist=replicate({x111imghdr},numhdr)
    inp=' '
    numdone=0
    for i=0,numhdr-1 do begin
        openr,lun,hdrnames[i],/get_lun
        readf,lun,inp
        free_lun,lun
        a=strsplit(inp,/extract)
        hdrlist[i].name=a[0]
        hdrlist[i].cfr =float(a[1])
        hdrlist[i].bw  =float(a[2])
        hdrlist[i].nx  =  long(a[3])
        hdrlist[i].ny  =  long(a[4])
        hdrlist[i].fltnst=long(a[5])
        hdrlist[i].fltnnum=long(a[6])
        numdone=numdone+1
    endfor
done:
    cd,odir
    if numdone ne numhdr then begin
        if numdone eq 0 then return,''
        hdrlist=hdrlist[0:numdone]
    endif
    hdrlist=hdrlist[sort(hdrlist.cfr)]
    return,hdrlist
end
