;+
;NAME:
;pdevtpfile - compute total power for file.
;SYNTAX: istat=pdevtpfile(fname,tp,hdr=hdr,hI=hI,fnmI=fnmI,ind=ind,bavg=bavg)
;ARGS:
; fname: string name of file to process (unless fnmI keyword is supplied)
;KEYWORDS:
;   fnmI:{} if supplied, then take filename from here. This structure is
;           returned by bpdevfilelist().
;   ind[]: long if supplied, then these are the indices in the data
;               array to be used for the total power computation. The
;               indices are relative to the channels stored in the 
;               file (not the fftlen in case these two are different).
;RETURNS:
;   istat:   long   number of total power points returned (n)
;                   0--> no points
;                  -1    trouble opening file.
;   tp[n,2]: float  total power. n = number of points. 2=pola,polb
;   hdr    : {]     primary header. reg and sp.
;                   hdr.h1 (general hdr0< hdr.h2 (sp header)
;   hI[n]  : {}     record header for each record. contains sequence
;                   number, calon/off and overflow info
;     bavg : {pdevget} if this keyword is supplied then the program will
;                   first compute the spectral average of the entire
;                   file and then use this average to bandpass correct
;                   every spectra before computing the total power.
;                   the average spectra is then returned here.
;-
function pdevtpfile,fname,tp,hdr=hdr,hI=hI,fnmI=fnmI,ind=ind,bavg=bavg
;
;
;   
    fnamel=(n_elements(fnmI) gt 0) $
            ? fnmI.dir + fnmI.fname $
            : fname
    istat=pdevopen(fnameL,desc)
    if istat ne 0 then return,-1
    nrecs=desc.hdev.nblksdumped
;
; get the average spectra
;
    useBavg=arg_present(bavg)
    if useBavg then begin
        istat=pdevavg(desc,nrecs,bavg,rec=1)
        if istat eq 0 then return,-1
    endif
;
;   compute power
;
    if useBavg then begin
        istat=pdevpwr(desc,nrecs,tp,rec=1,bpc=bavg.d,hI=hI,ind=ind)
    endif else begin
        istat=pdevpwr(desc,nrecs,tp,rec=1,hI=hI,ind=ind)
    endelse
    free_lun,desc.lun
    if arg_present(hdr) then begin
        hdr={h1:desc.hdev, h2:desc.hsp}
    endif
    return,n_elements(tp[*,0]) 
end
