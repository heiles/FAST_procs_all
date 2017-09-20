;+
;NAME:
;sefdInpData - input sefd data for rcvr.
;
;SYNTAX:
;     istat=sefdInpData(rcvNum,sefdData,fname=fname,date=date)  
;
;ARGS:
;     rcvNum:  1 thru 16.  receiver to use (same as hdr.iflo.stat1.rfnum).
;KEYWORDS:
;      fname: to specify an alternate data file with sefd values.
;            The default file is aodefdir() + 'data/sefd.datR{rcvNum}
;      date : [year,daynum]  .. if specified the data when you want the
;                              sefd for..default is most recent.
;
;RETURNS:
;      istat: 1 ok, -1 bad file/rcvnum,data probably no fit data available.
;    sefdData[n]:{sefdData} return fit info. 1 structure for each frequency
;DESCRIPTION: 
;  Input the sefd fit data for all the frequncies of a particular receiver
; (rcvNum). The rcvNum can be extracted from the headers with iflohrfnum().
;
;  The default datafile is aodefdir() + 'data/sefd.datR{rcvNum} (aodefdir() is
;  a function that returns the root of the aoroutines). The keyword
;  fname allows you to specify an alternate file. The file format is:
;  -  col 1 ; is a column, 
;  -  col 1 !yyyy dayno   starts a date section. yyyy dayno is the
;                        year daynumber for the start of this data set.
;  -  data is free format , column oriented
;  freq fitType c0 c1 c2 ....   cN  pol calVala calvalB
;  
;   c0..cN are the fit coefficients, pol is I or A or B, CalValA,B are the
;   cal values used for this fit.
;
;The structure format for {sefddata} is:
; sefdData.rcvNum       receiver number
; sefdData.numFreq      number of frequencies found
; sefdData.startYr      for the fit
; sefdData.startDaynum  for the fit
; sefdData.endYr        for the fit
; sefdData.endDaynum    for the fit
; sefdData.fitI[numFreq] {azzafit} structure holding the coef and other
;                          info for each fit
; sefdData.calVal[2,numFreq] cal values used when each fit was made.
; See azzafit for a description of the {azzafit} structure.
;
;This routine is called automatically by corhsefdval and sefdget().
;
;How the different cal routines vary:
;sefdinpdata() inputs the data from disc. You must specify the rcvrnum.
;             It defaults to the current date. It loads a table in common
;             holding the fit info for all of the frequencies measured.
;sefdget()    Pass in the frequency and the rcvrnum. It will input the
;             data using sefdinpdata if necessary, do the interpolation
;             and return the sefd.
;corhsefdval() You specify the correlator sbc header (eg b.b1.h). It will
;             compute the frequency and then call sefdgetl(). It returns the
;             sefd value.
;
;SEE ALSO: corhsefdval, sefdget ,azzafit, azzafiteval,azzafitpr
;- 
;history:
;10jul06 .. copied from gainInpdata
;
function sefdInpData,rcvNum,sefdData,fname=fname,date=date
;
    on_error,1
    on_ioerror,endio
    lun=-1
    if (n_elements(fname) eq 0) then begin
        fname=string(format='(a,"data/sefd.datR",i0)',aodefdir(),rcvNum)
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
        else: message,'sefdinpdata illegal date request.. [year,daynum]'
    endcase
    openr,lun,fname,/get_lun,error=err
    if  err ne 0 then begin
        print,"couldn't open file",fname
        return,-1
    endif
;
;    file format is:
;  d1Ah d1Al d1Bh d1Bl d2Ah d2Al d2Bh d2Bl
; ; col 1 is comment
; !yyyy ddd is first valid date for data that follows..
;
    fitI=replicate({azzafit},10)    ; max 10 freq at each receiver..
    calVal=fltarr(2,10)                    ; read in 8 numbers on the line 
    freqLine=0.
    inpl=" "
    i=0
    gotDate=reqYr eq 0
    startYr=0L & startDay=0L
    endYr=0L   & endDay=0L
    while (1) do begin
        readf,lun,inpl
        if (strmid(inpl,0,1) ne ';') then begin
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
                    line=''
                    line2=''
                    reads,inpl,freqLine,fittype,line
                    fitI.numCoef=10
                    case fittype of
                        1: begin
                            fitI.zaSet=14.
                            var=fltarr(11)
                            reads,line,var,line2
                           end
                        2: begin
                            fitI.zaSet=10.
                            var=fltarr(11)
                            reads,line,var,line2
                           end
                        3: begin
                            fitI.zaSet=10.
                            var=fltarr(11)
                            reads,line,var,line2
                           end
                        4: begin
                            fitI.zaSet=14.
                            fitI.numCoef=4
                            var=fltarr(5)
                            reads,line,var,line2
                           end
                        6: begin
                            fitI.zaSet=10.
                            fitI.numCoef=4
                            var=fltarr(5)
                            reads,line,var,line2
                           end
                    else: begin
                           ln='file:'+fname+'  freq:'+string(freqLine) $
                                + ' fittype:'+ string(fittype) + ' illegal'
                           message,ln
                          end
                    endcase
; 
                    fitI[i].freq=freqLine
                    fitI[i].rfNum =rcvNum
                    fitI[i].type  ='sefd'
                    fitI[i].coef  =var[0:fitI[i].numCoef-1]
                    fitI[i].sigma =var[fitI[i].numCoef]
                    fitI[i].fittype =fittype
                    line2=strtrim(line2,1)
                    fitI[i].pol   =strmid(line2,0,1)
                    cal2=fltarr(2)
                    reads,strmid(line2,1),cal2
                    calval[*,i]=cal2
                    i=i+1
                endif
           endelse
        endif
    endwhile
endio:
    retstat=1
    if ((not eof(lun)) and  (strmid(inpl,0,1) ne '!') ) or (i eq 0) then begin
        retstat=-1
    endif else begin
        if (endYr eq 0) then begin
            endYr=3000L
            endDay=366L
        endif
        sefdData={ rcvNum    :rcvNum,$
                  numFreq    :i, $
                  startYr    : startYr,$
                  startDaynum: startDay,$
                  endYr      : endYr,$
                  endDaynum  : endDay,$
                  fitI       : fitI[0:i-1],$
                  calval     :calVal[*,0:i-1]}
    endelse
    if (lun gt -1) then free_lun,lun
    return,retstat
end
