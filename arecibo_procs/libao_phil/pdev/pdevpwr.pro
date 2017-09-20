;+
;NAME:
;pdevpwr -  read,compute total power
;SYNTAX: istat=pdevpwr(desc,nrecs,tp,rec=rec,ind=ind,bpc=bpc,hI=hI)
;ARGS:
;    desc: {} returned by pdevopen
;   nrecs: long number of records to process
;KEYWORDS: 
;     rec: long record to position to before reading (cnt from 1)
;  ind[n]: long if supplied then compute total power over the indices in
;               this array (should b 0.. nchan-1)
;bpc[nchn,nsbc]: long if supplied then divided each spectra by this bandpass
;                     before computing total power.
;                     nsbc should be 1 or 2. if stokes u,v are present they
;                     should be ignored.
;RETURNS:
;     istat: number of records averaged.
;          : 0 returned no records
;          : -1 returned some but not all of the recs
;   tp[nrecs,nsbc]: float if supplied then return the total power at each sample
;                         nsbc will be 1 or 2. If stokes u,v present, they are ignored.
;  hI[nrecs]: {}    record header from each record. Contains sequence number (mod
;                   64k, calon,off and overflow info.
;DESCRIPTIION:
;   Read the requeseted number of records and compute the total power for each
;sample.  If the file has stokes info, the last two spectra (u,v) are ignored.
;   If the bpc keyword is supplied, then divide each spectra by the
;band pass (1 bandpass for each pol) before computing the total power. 
;   If the ind= keyword is supplied then compute the total power over the indices
;provided in the ind array. The same indices are used for both pols. The indices
;are over the returned channels (not the fftlen).
;
;   The total power is returned in the array tp[nchan,sbc]. If the keyword
;hi= is provided then the record header from each record is also returned.
; the structure contains:
;
;IDL> help,hI,/st
;** Structure PDEV_HDRDUMP, 10 tags, length=20, data length=20:
;   SEQNUM          UINT             0
;   FFTACCUM        UINT           191
;   CALON           INT              0
;   ADCOVERFLOW     INT              0
;   PFBOVERFLOW     INT              0
;   SATCNTVSHIFT    INT              0
;   SATCNTACCS2S3   INT              0
;   SATCNTACCS0S1   INT              0
;   SATCNTASHFTS2S3 INT              0
;   SATCNTASHFTS0S1 INT              0
;-
function pdevpwr,desc,nrecs,tp,rec=rec ,bpc=bpc,ind=ind,hI=hI,verb=verb
;
;   optionally position to start of rec
;
    lrec=n_elements(rec) eq 0 ? 0L:rec
    useHi=arg_present(hi)
    useBpc=n_elements(bpc) gt 0
    useInd=n_elements(ind) gt 0
;
;
;   loop reading the data
;
    nsbc=desc.nsbc < 2
    nchan=desc.nchan
    if (useBpc) then begin
        a=size(bpc)
        if a[0] ne nsbc then begin
            print,'bpc must have same number of sbc as data:',nsbc
            return,-1
        endif
        if a[1] ne nchan then begin
            print,'bpc must have same number of channels as data:',nchan
            return,-1
        endif
        if nsbc eq 1  then begin
            bpcM=1./bpc[*,0]
        endif else begin
            bpcM=reform([1./bpc[*,0], 1./bpc[*,1]],nchan,nsbc)
        endelse
        if useind then bpcM=bpcM[ind,*] ; same as the mask
    endif
    toprint=100L
    nrecTot=0L
    nchanUsed=(useInd)?n_elements(ind):nchan
    tp=fltarr(nrecs,nsbc)
    for irec=0L,nrecs-1 do begin
        istat=pdevget(desc,b,rec=lrec)
        if istat ne 1 then break
        if keyword_set(verb) and ((irec mod toprint) eq 0L) then $
            print,nrecTot
        lrec=0L
        if (irec eq 0) &&  (useHi) then  hI=replicate(b.h,nrecs)
;
;       do the average depending on the options
;
        case 1 of
            ((~useBpc)  && (~useInd)): tp[irec,*]=total( b.d             ,1)
            (  useBpc  &&   useInd)  : tp[irec,*]=total((b.d[ind,*]*bpcM),1)
            ((~useBpc) && ( useInd)) : tp[irec,*]=total( b.d[ind,*]      ,1)
            ((useBpc)  && (~useInd)) : tp[irec,*]=total( b.d       *bpcM ,1)
         endcase
         if useHi then hI[irec]=b.h
         nrecTot++
    endfor
    tp/=nchanUsed
    return,nrecTot
end
