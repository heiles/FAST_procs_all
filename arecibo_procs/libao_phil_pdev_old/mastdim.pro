;+
;NAME:
;mastdim - decode fits tdim1 keyword
;SYNTAX: mastdim,h,nchan=nchan,nra=nra,ndec=ndec,npol=npol,nspc=nspc 
;ARGS:
;   h{} : struct        fits header (b.h)
;RETURNS:
;   istat: 0 ok
;          -1 could not parse tdim1
;   nchan: long number of frequency channels
;     nra: long number of ra points
;    ndec: long number of dec points
;    npol: long number of pols 1,2,4
;    nspc: long number of specra
;-
pro mastdim,h,nchan=nchan,nra=nra,ndec=ndec,npol=npol,nspc=nspc 
;
    a=strsplit(h[0].tdim1,"(,)",/extract)
    nchan=long(a[0])
    nra=float(a[1])
    ndec=float(a[2])
    npol=long(a[3])
    nspc=long(a[4])
    return
end
