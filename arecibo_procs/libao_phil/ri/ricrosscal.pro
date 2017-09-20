;+
;NAME:
;ricrosscal - compute the cal scaling factor for ri cross patterns
;SYNTAX: ncal=ricrosscal(bcal,bscale,calval)
;ARGS:   bcal[n]:  {cross} cal scans input from ricrossinp.
;RETURNS:
;      bscale[2,n]:float  scale factor to convert counts to kelvins
;      calval[2,n]:float  cal value used (pola,polB)used
;      ncal       : int   number of cal records processed
;
;DESCRIPTION:
;   The ricrossinp routine returns the data and cal records for a cross
;pattern. This routine will compute the conversion factor from a/d counts
;to Kelvins using the cal record and the cal value (in kelvins).
;
;   The input data structure returned from ricrossinp is:
;
;        bcal.h[nrecs]     {hdr} header from each rec of strip
;        bcal.don[npts,2]  float cal On samples 
;        bcal.doff[npts,2] float cal off samples
;        b.d[npts,2]  - the data polA,b
;
;   Normally then second index is polA, or polB (since the ricrossinp
;routine uses detected data).
;
;   The routine will lookup the cal value using calget().
;the conversion factor from kelevins
;-
function ricrosscal,bcal,bscale,calval
;
    ncal=n_elements(bcal)
    bscale=fltarr(2,ncal)
    calval=fltarr(2,ncal)
    npts=(size(bcal[0].don))[1]
    skip=npts/4
    use=npts-skip
    for i=0,ncal-1 do begin
        istat=calget(bcal[i].h,bcal[i].h.iflo.if1.rffrq*1e-6,cal2)
        if istat ne 1 then message,'error reading calvalue'
        calval[0,i]=cal2[0]
        calval[1,i]=cal2[1]
        bscale[0,i]=calval[0,i]/(mean(bcal[i].don[skip:npts-1,0])- $
                    mean(bcal[i].doff[skip:npts-1,0]))
        bscale[1,i]=calval[1,i]/(mean(bcal[i].don[skip:npts-1,1])- $
                    mean(bcal[i].doff[skip:npts-1,1]))
    endfor
    return,ncal
end
