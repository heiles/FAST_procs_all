;+
;NAME:
;pdevcmpstats - compute avg, rms for set of files
;SYNTAX: istat=pdevcmpstats(fnmIar,bavg,bavgN,bavgF,brms,brmsN,nrecsAr,descAr,$
;                           fractFl=fractFl,maxrecs=maxrecs)
;ARGS:
;   fnmIar[n]: {}   hold files to process (returned from pdevfilelist())
;
;KEYWORDS:
; fracFl: float fraction of bandpass to use for flattening average spectra.
;                the default is .1 .
; maxrecs long  max number of records in file to use. Use this to limit the
;               records that are read in for large files.
;RETURNS:
; istat: long    number of files processed (n)
; bavg[n] : {}  averaged data. 
; bavgN[n]: {}  averaged data normalized to median of each bandpass.
; bavgF[n]: {}  averaged bandpassed flattend by taking fracFl of the
;                   transformed bavg to create a bandpass correction.
; brms[n] : {}  rms by channel. Value is in average pdev counts.
; brmsN[n]: {}  rms by channel with each rms normalized by the
;                   channel mean value.
;nrecsAr[n]: lonarr number of records input for each file.
;descAr[n]: {}  descriptor for pdevopen for each file. Use this to
;                   generate the freq arrays.
;
;DESCRIPTION:
;   Compute the average and statistics for a number of files. 
;This routine was written to check the statistics as you change
;the level count at the digitizer.
;
;NOTES: 
;   The routine tries to read in the entire file so don't use in on
;very large files (or use the maxrecs keyword to limit recs to something that
;can be read into memory).
;   The routine returns the info as an array. Each file should have the
;same number of channels.
;   This routine will have trouble with data taken in stokes mode since the
;rms over the stokes channels may blowup..
;-
function pdevcmpstats,fnmIar,bavg,bavgN,bavgF,brms,brmsN,nrecsAr,descAr,$
                      fracFl=fracFl,maxrecs=maxrecs 
;
; 
    if n_elements(maxrecs) eq 0 then maxrecs=0
    if n_elements(fracfl) eq 0 then fractfl=.1
    nfiles=n_elements(fnmiar)
    nrecsAr=lonarr(nfiles)
    nfileTot=0L
    for i=0,nfiles-1 do begin &$
        istat=pdevopen(junk,desc,fnmI=fnmIar[i]) &$
        nrecs=desc.hdev.nblksdumped &$
        nrecs=(maxrecs ne 0)?(maxrecs < nrecs):nrecs
        istat=pdevgetm(desc,nrecs,b,rec=1) &$
        free_lun,desc.lun &$
        if istat ne 1 then begin
            print,'only ',n_elements(b),' recs for:',fnmIar[i].fname &$
        endif
        if istat eq 0 then continue
        nrecsAr[i]=n_elements(b)
        if i eq 0 then begin &$
            bavg=replicate(b[0],nfiles) &$
            bavgN=replicate(b[0],nfiles) &$
            bavgF=replicate(b[0],nfiles) &$
            brms =replicate(b[0],nfiles) &$
            brmsN=replicate(b[0],nfiles) &$
            descAr=replicate(desc,nfiles)
            nsbc  =bavg[0].nsbc
        endif &$
        bavg[i]=b[0] &$
        bavg[i].d=total(b.d,3)/nrecs &$
        bavgN[i]=bavg[i]
        bavgF[i]=bavg[i]
        brms[i] =bavg[i]
        brmsN[i] =bavg[i]
        descAr[i]=desc
        for isbc=0,nsbc-1 do begin
            med=median(bavg[i].d[*,isbc])
            bavgN[i].d[*,isbc]/=med
            bpc=smofrqdm_1d(bavg[i].d[*,isbc],fracsmo=fracsmo,ftype=3)
            bavgF[i].d[*,isbc]/=bpc
            brms[i].d[*,isbc]=rmsbychan(b.d[*,isbc],/nodiv)
            brmsN[i].d[*,isbc]=rmsbychan(b.d[*,isbc])
        endfor
        nfiletot++
    endfor
    return,nfileTot
end
