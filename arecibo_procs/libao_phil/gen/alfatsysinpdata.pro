;+
;NAME:
;alfatsysinpData - input alfa tsys fits.
;
;SYNTAX:
;     istat=alfatsysinpdata(tsysfitI,fname=fname,date=date)  
;
;ARGS:
;KEYWORDS:
;      fname: to specify an alternate data file with fit values.
;            The default file is aodefdir() + 'data/tsys.datR17
;      date : [year,daynum]  .. if specified the data when you want the
;                              tsys for.. the default is most recent.
;
;RETURNS:
;      istat: 1 ok, -1 bad filename or data in file.
;tsysfitI[14]:{alfatsysFitI} return fit info. 1 structure for each
;                      pol/pix.
;DESCRIPTION: 
;  Input the alfa tsys fit data. The default datafile is aodefdir() + 
;'data/tsys.datR17 (aodefdir() is a function that returns the root of the ;
; aoroutines). The keyword  fname allows you to specify an alternate file.
;The file format is:
;  -  col 1 ; or # is a column
;  -  col 1 !yyyy dayno   starts a date section. yyyy dayno is the
;                        year daynumber for the start of this data set.
;  -  data is free format , column oriented
;
;The structure format for {alfaTsystFitI} is:
; fitI.pol            0,1   ; polA or polB
; fitI.pix            0..6  ; pixel number
; fitI.fitType        1     ; code for type of fit used
; fitI.pntsused       1     ; number of points used to compute the fit
; fitI.ncoef          11    ; number of coef in the fit
; fitI.sigmafit        0.    ; hold the fit sigma (in deg K)
; fitI.numCoef          fltarr(ncoef); hold the fit coefs.
; fitI.sigmacoef     fltarr(ncoef); hold the fit coef errors.
; fitI.startYr       for the fit
; fitI.startDaynum        for the fit
;
;
;How the different cal routines vary:
;alfatsysinpdata() inputs the data from disc. 
;             It defaults to the current date. It loads a table in common
;             holding the fit info for all of the pixels/pols
;alfatsysget()    Pass in the az,za,freq,rotAr. It will input the
;             data using alfatsysinpdata if necessary, do the computation
;             and return the tsys for the reqeusted values.
;
;SEE ALSO: alfatsysget
;- 
;history:
;18aug05 .. started
function alfatsysinpData,fitI,fname=fname,date=date
;
    on_error,1
    on_ioerror,endio
    lun=-1
    if (n_elements(fname) eq 0) then begin
        fname=string(format='(a,"data/tsys.datR17")',aodefdir())
    endif
    case n_elements(date) of
        0   : begin
                reqYr =0
                reqDay=0
              end
        1   : begin
                reqYr =date[0]
                reqDay=0            
              end
        2   : begin
                reqYr =date[0]
                reqDay=date[1]
              end
        else: message,'alfatsysinpdata illegal date request.. [year,daynum]'
    endcase
    openr,lun,fname,/get_lun,error=err
    if  err ne 0 then begin
        print,"couldn't open file",fname
        return,-1
    endif
;
;    file format is:
; ; col 1 is comment
; !yyyy ddd is first valid date for data that follows..
;  pix pol fittype ncoefs npntsused fitsig
;  0   0    1       11     3500     .45
;        coefs[ncoefs]
;        coeferrs[ncoefs]
;
    fitI=replicate({alfatsysfitI},14)    ; 14 pol/pixels
    inpl=" "
    inpl1=" "
    inpl2=" "
    i=0
    gotDate=reqYr eq 0
    startYr=0L & startDay=0L
    endYr=0L   & endDay=0L
;
;   find the starting date
;
    pix=0 
    pol=0
    fittype=0
    ncoefs =0
    npntsused=0L
    fitsig=0.D
    while (1) do begin
        readf,lun,inpl
        c1=strmid(inpl,0,1)
        if ( (c1  ne ';') and (c1 ne '#'))  then begin
           if (strmid(inpl,0,1) eq '!') then begin
              if not gotDate then begin
                 startYr=0L & startDay=0l
                 reads,strmid(inpl,1,strlen(inpl)-1),startYr,startDay
                 if (startYr lt reqYr) or $
                    ((startYr eq reqYr) and (startDay le reqDay)) then begin
                        gotDate=1
                 endif else begin
                    endYr = startYr
                    endDay= startDay
                 endelse
              endif else begin
                 if i gt 0 then goto,endio
              endelse
              if (startYr eq 0 ) and (startDay eq 0) then begin
                   reads,strmid(inpl,1,strlen(inpl)-1),startYr,startDay
              endif
           endif else begin
                if gotDate then begin
                ;  pix pol fittype ncoefs npntsused fitsig
                ;  0   0    1       11     3500     .45

                    reads,inpl,pix,pol,fittype,ncoefs,npntsused,fitsig
                    fitI[i].numCoef=ncoefs
                    fitI[i].fitType=fittype
                    fitI[i].pol    =pol
                    fitI[i].pix    =pix
                    fitI[i].pntsUsed=npntsused
                    fitI[i].sigmafit  =fitsig
                    fitI[i].startYr   =startYr
                    fitI[i].startDayNum=startDay
;
;   now get the fit coef and the errors
;
                    gotit=0
                    while not gotit do begin
                        readf,lun,inpl1
                        c1=strmid(inpl1,0,1)
                        if (c1 eq '!') then goto,endio      ; premature ! 
                        gotit=((c1 ne ';') and (c1 ne '#'))
                    endwhile
                    gotit=0
                    while not gotit do begin
                        readf,lun,inpl2
                        c1=strmid(inpl2,0,1)
                        if (c1 eq '!') then goto,endio      ; premature ! 
                        gotit=((c1 ne ';') and (c1 ne '#'))
                    endwhile
                    var=dblarr(ncoefs)
                    reads,inpl1,var
                    fitI[i].coef=var
                    reads,inpl2,var
                    fitI[i].sigmacoef=var
                    i=i+1
                endif
           endelse
        endif
    endwhile
endio:
    retstat=(i ne 14) ? -1 : 1
    if retstat eq 1 then begin
        fitI.endDaynum=366
        fitI.endYr =3000
    endif
    if (lun gt -1) then free_lun,lun
    return,retstat
end
