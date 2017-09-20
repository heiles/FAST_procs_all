;+
;NAME:
;pfrmsinpfiles - compute rms/mean for all files in filelist
;SYNTAX: numscans=pfrmsinpfiles(fname,outputdir,rembase=rembase,doplot=doplot)
;ARGS:
;       fname:  string . file containing list of filenames to process
;    ouputdir:  string . directory name for output files.
;
;KEYWORDS:   
;   rembase : int   if set then remove baseline before rms computed
;   minrecs : int   minimum number of recs in scan need to process a scan.
;                   defaults to 5.
;   doplot  : int   if set then plot each rms as it is computed
;   logfile : string if provided then log ascii status to logfile.
;                    if not provided then log to default log file
;
;DESCRIPTION:
;   Call pfrms for all filesname in the file fnames.
;fnames is a file that holds 1 filename perline with.
;Process each of these files by calling pfrms. Use outputdir/basename
;as the output filename.
;This routine will automatically hanning smooth, set zerorate true,
;and excluce the patterns corcrossch
;-
;history:
;
function pfrmsinpfiles,fname,outputdir,rembase=rembase,minrecs=minrecs,$
                       logfile=logfile,doplot=doplot,rateok=rateok
 
    deflog='/share/megs/rfi/rms/files/logfile.dat'
    lunLog=-1
    excludepat=strarr(2)
    excludepat[0]='corcrossch'
    excludepat[1]='SMARTF'
    zerorate=1
	if keyword_set(rateok) then zerorate=0 
    han=1

    if not keyword_set(rembase) then rembase=0
    if not keyword_set(logfile)     then logfile=deflog
    if not keyword_set(doplot)      then doplot=0
    if not keyword_set(minrecs) then minrecs=5
    if keyword_set(logfile) then begin
        openw,lunLog,logfile,/append,error=err,/get_lun
        if err ne 0 then begin
            print,'err opening logfile:',logfile,!err_string
            lunLog=-1
        endif
        lab="start " + fname + " on " +systime()
        printf,lunLog,lab
    endif
    openr,lunin,fname,error=openerr,/get_lun
    if openerr ne 0 then begin
        printf,-2,!err_string
        return,0
    endif
    outdir=outputdir
    if (strmid(outdir,0,/reverse_offset) ne '/') then outdir=outdir+'/'
    on_ioerror,ioerr
    filesdone=0L
    finput=' '
    for i=0L,9999 do begin
        readf,lunin,finput
        finput=strtrim(finput,2)
        if strpos(finput,';') ne 0 then begin
            i=strpos(finput,'/',/reverse_search)
            if i eq -1 then begin
                basename=finput
            endif else begin
                basename=strmid(finput,i+1)
            endelse
            foutput=outdir + basename
            if ( foutput eq finput) then  begin
                print,'input,ouput files the same.. no processing',foutput
                if lunLog ne -1 then printf,lunLog,$
                    'input,ouput files the same.. no processing',foutput
            endif else begin
                lab='process ' + finput + ' --> ' + foutput
                print,lab
                if lunLog ne -1 then printf,lunLog,lab
                numscans=pfrms(finput,foutput,rembase=rembase,minrecs=minrecs,$
                        han=han,lunLog=lunLog,excludepat=excludepat,$
                        zerorate=zerorate,doplot=doplot)
                print,foutput,' with ',numscans,' processed'
                if lunLog ne -1 then printf,lunLog,$
                        foutput,' with ',numscans,' processed'
                filesdone=filesdone+1
            endelse
        endif
    endfor
ioerr: 
;   print,'io err',!error_state.msg
    free_lun,lunin
    if lunLog ne -1 then begin
        printf,lunLog,"endrun run on ",fname," at ",systime()
        free_lun,lunLog
    endif
    return,filesdone
end
