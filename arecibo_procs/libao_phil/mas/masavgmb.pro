;+
;NAME:
;masavgmb - read and average spectra for multi beams
;SYNTAX:navgspcR=masavgmb(yymmdd,projid,filenum,b1,b2,$
;                   toavg=toavg,navgspc=navgspc,row=row)
;ARGS:
;  yymmdd: long  date to process
;  projid: char  string on first part of filename.
; filenum: long  the filenumber to process
;KEYWORDS: 
;   toavg: long  number of spectra to avg. Default is the entire file
; navgspc: long  Number of avg spectra to return. Only used if toavg=
;                is specified. By default return all the averaged spectra
;                from the file. If requested number of averaged spectra
;                is greater than the number available, just return
;                the number we could avg.
;     row: long  row to position to before reading (cnt from 1). Default
;                is start of file.
;RETURNS:
;navgspcR: long The number of average spc returned for each beam,band
;        : 0 did not find any files matching request
;        : -1 error accessing a file. no data returned
;
;b1[navgspcR,nbeams]: {}  array of structs holding the averaged data
;             for the lower 170 Mhz band in the first IF. This is usually
;             the higher 170 Mhz at RF since a high side lo flips the band.
;b2[navgspcR,nbeams]: {}  array of structs holding the averaged data
;             for the higher 170 Mhz band in the first IF. 
;-
function masavgmb,yymmdd,projid,num,b1,b2,row=row,toavg=toavg,navgspc=navgspc,$
                    fnmi1=fnmi1,fnmi2=fnmi2
;
;   optionally position to start of row
;
    rowl=n_elements(row) eq 0 ? 1:row
    if rowl eq 0 then rowl=1
;
;  get the files to process
;
    dirB=''
    nfiles=masfilelist(dirb,fnmiar,yymmdd=yymmdd,/appbm,num=num,projid=projid)
    if nfiles eq 0 then return,0
    if nfiles gt 14 then begin
        print,"found:",nfiles," max should be 14"
        return,-1
    endif
    iibnd1=where(fnmiar.band eq 0,nibnd1)
    iibnd2=where(fnmiar.band eq 1,nibnd2)
    if nibnd1 gt 0 then fnmi1=fnmiar[iibnd1]
    if nibnd2 gt 0 then fnmi2=fnmiar[iibnd2]
;
;   loop over band1, band2
;
    desc=''
    start=1
    b1=''
    b2=''
    for ibnd=0,1 do begin
        nibnd=(ibnd eq 0)?nibnd1:nibnd2
        iibnd=(ibnd eq 0)?iibnd1:iibnd2
        for ibm=0,nibnd-1 do begin
            ii=iibnd[ibm]
            istat=masopen(junk,desc,fnmI=fnmiar[ii])
            if istat ne 0 then begin
                print,"Could no open ",fnmiar[ii].fname
                goto,errout
            endif
            if (start) then begin
                if rowl gt desc.totrows then begin
                    print,"Requested row:",rowl," beyond end of file"
                    goto,errout
                endif
                istat=masget(desc,hdr1,row=rowl,/hdronly)
                istat=masget(desc,hdrL,row=desc.totrows,/hdronly)
                spcInFile=hdr1.ndump*(desc.totrows-rowl) + hdrL.ndump
                if (n_elements(toavg) eq 0) || (toavg eq 0) then begin
                    toavgL=spcInFile
                    navgspcL=1
                endif else begin
                    toavgL=toavg
                    if (toavgL gt spcInFile) then begin
                    print,"Requested spc to avg:",toavgL," > number spc in file"
                        goto,errout 
                    endif
                    if n_elements(navgspc) eq 0 then begin
                        navgspcL=spcInfile/toAvgL
                    endif else begin
                        navgspcL=((spcInFile/toavgL) < navgspc);smaller of the 2
                    endelse
                endelse
            endif
            istat=masavg(desc,navgspcL,bb,row=rowL,toavg=toavgL)
            if istat ne 1 then begin    
                print,"masavg error:",istat," file:",desc.filename
                goto,errout
            endif
            if start eq 1 then begin
                if navgspcL eq 1 then begin
                    b1=replicate(bb[0],nibnd1)
                    b2=replicate(bb[0],nibnd2)
                endif else begin
                    b1=replicate(bb[0],navgspcL,nibnd1)
                    b2=replicate(bb[0],navgspcL,nibnd2)
                endelse
            endif
            if (navgspcL eq 1) then begin
                if ibnd eq 0 then begin
                   b1[ibm]=bb
                endif else begin
                   b2[ibm]=bb
                endelse
            endif else begin
                if ibnd eq 0 then begin
                   b1[*,ibm]=bb
                endif else begin
                   b2[*,ibm]=bb
                endelse
            endelse
            bb=''
            start=0     
            masclose,desc
            desc=''
        endfor
    endfor
    return,1
errout:
    if desc ne '' then masclose,desc
    b1=''
    b2=''
    return,-1
end
