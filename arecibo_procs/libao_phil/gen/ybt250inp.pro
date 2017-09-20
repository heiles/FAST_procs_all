;+
;NAME:
;ybt250inp - input ybt250 spectrum from save file
;SYNTAX: ntrace=ybt250inp(lun,spc1,frq1,spc2,frq2,info=info,/print)
;ARGS:
;   lun:    open to xxx.txt file.. form export trace .txt mode (tabs)
;  print:   if set the print out the ascii info header as it is read in.
;RETURNS:
;   ntrace: 0  trouble reading file
;           1  1 trace found ..returned in spc1,frq1
;           2  2 trace found ..returned in spc1,frq1 and spc2,frq2
;   frq1[501]: freq of trace 1 in mhz
;   spc1[501]: spectra trace 1 in dbm
;   frq2[501]: freq of trace 2 in mhz
;   spc2[501]: spectra trace 2 in dbm
;   info[29] : string return the 29 ascii info lines read from the file.
;
;DESCRIPTION:
;   The textronix ybt250 portable spectrum analyzer can save its
;trace data in a text file. This routine will input the text file and
;return the spectra and frequency.
;   The steps in getting at trace from the ybt250 to idl is:
;1. save the trace:
;   On the ybt250 use:
;   -->file
;      --> save trace as
;        select tab separated  .txt as the save option
;        You can change the name using the keyboard button.
;2. Copy the saved file to the floppy on the ybt250:
;   From outside of ybt250 program (in windows)
;    - insert floppy
;    --> start programs button
;       -- start floppy
;    --> netTek icon
;      --> builtindisc
;         --> ybt250
;           ?? may have left out a directory here..
;             -->appresults 
;             copy the file you want (edit, copy)
;   --> back to top level of netTek
;       --> click on floppdisc
;       --> edit , copy
;
;3. copy the file to unix/linux.. find a floppy that works ..
;   on solaris try volcheck (does not work on lots of machines).
;4. in idl 
;   @phil
;   openr,lun,filename,/get_lun
;   ntrace=ybt250inp(lun,spc1,frq1,spc2,frq2,info=info,/print)
;-
function ybt250inp,lun,spc1,frq1,spc2,frq2,info=inpar,print=print
;
; read in the 
    rew,lun
    inpar=strarr(29)
    readf,lun,inpar
    for i=0,n_elements(inpar)-1 do begin
        inpar[i]=strtrim(strjoin(strsplit(inpar[i],string(9b),/extract),' ')) 
        if keyword_set(print) then print,inpar[i]
    endfor
;
;   check that the data read in ok:
;
    if ((strmid(inpar[0],0,4) ne 'Name') or $
        (strmid(inpar[28],0,5) ne 'Trace')) then begin
        print,'first, last text line mismatch'
        print,'Expected: Name    Trace'
        print,'found   :',strmid(inpar[0],0,4),'    ',strmid(inpar[28],0,5)
        return,0
    endif
    istat=stregex(inpar[21],'Trace 2 On.*True')
    ntrace=(istat ne -1)?2:1
;
; get the frequency scale
;
    a=stregex(inpar[14],'Trace 1 Start Freq .Hz. ([0-9]+)',/extract,/subexpr)
    b=stregex(inpar[15],'Trace 1 Stop Freq .Hz. ([0-9]+)',/extract,/subexpr)
    frq1=double([a[1],b[1]])*1d-6
    if ntrace eq 2 then begin
        a=stregex(inpar[16],'Trace 2 Start Freq .Hz. ([0-9]+)',/extract,/subexpr)
        b=stregex(inpar[17],'Trace 2 Stop Freq .Hz. ([0-9]+)',/extract,/subexpr)
        frq2=double([a[1],b[1]])*1d-6
    endif
    npts=(530-30) + 1
    spc=(ntrace eq 2)?fltarr(2,npts):fltarr(npts)
    readf,lun,spc
    if ntrace eq 1 then begin
        spc1=spc
        spc2=''
    endif else begin
        spc1=reform(spc[0,*])
        spc2=reform(spc[1,*])
    endelse
    frq1=findgen(npts)*(frq1[1]-frq1[0])/(npts-1.) + frq1[0]
    if ntrace eq 2 then $ 
        frq2=findgen(npts)*(frq2[1]-frq2[0])/(npts-1.) + frq2[0]
    return,ntrace
end
