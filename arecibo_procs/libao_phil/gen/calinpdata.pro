;+
;NAME:
;calInpData - input cal data for rcvr/calType.
;
;SYNTAX:
;     istat=calInpData(rcvNum,calNum,calData,fname=fname,date=date)  
;
;ARGS:
;     rcvNum:  1 thru 16.  receiver to use (same as hdr.iflo.stat1.rfnum).
;     calNum:  0 thru  7.  cal Type to use (same as hdr.iflo.stat2.calType). 
;               the values are:0-lcorcal,1-hcorcal,2-lxcal,3-hxcal,
;                              4-luncorcal,5-huncorcal,6-l90cal,7-h90cal
;KEYWORDS:
;      fname: to specify an alternate data file with cal values.
;            The default file is aodefdir() + 'data/cal.dat{rcvNum}
;      date : [year,daynum]  .. if specified the data when you want the
;                              cals for..default is most recent.
;
;RETURNS:
;      istat: 1 ok, -1 bad file/rcvnum,data , -2 bad calnum
;    calData: return data in structure:
;            calData.calNum   - calNum 
;            calData.numFreq  - number of freq entries
;            calData.freq[numFreq] - for each cal value (in Mhz)
;            calData.calA[numFreq] - polA cal value in Kelvins
;            calData.calB[numFreq] - polB cal value in Kelvins
;DESCRIPTION: 
;  Input the cal data for all the frequncies of a particular receiver (rcvNum)
;  and cal type (calNum). The calNum and rcvNum can be extracted from the
;  headers with iflohrfnum() and iflohcaltype (). 
;
;  The default datafile is aodefdir() + 'data/cal.dat{rcvNum} (aodefdir() is
;  a function that returns the root of the aoroutines). The keyword
;  fname allows you to specify an alternate file. The file format is:
;  -  col 1 # is a column
;  -  data is free format , column oriented
;  -  nd1 is noise diode 1, nd2 is noise diode2, H-highcal,L-lowcal,
;  -  A is polA, B id polB, ndxx-->A/B  implies that diode N feeds pol X 
;
;    freq nd1H->A nd1L->A nd1H->B nd1L->B nd2H->A nd2L->A nd2H->B nd2L->B
;  
;  The mapping of cal type to diodes used is:
;  corCal     diode 1-> polA, diode 1-> polB
;  uncorCal   diode 1-> polA, diode 2-> polB
;  xCal       diode 1-> polB, diode 2-> polA
;  90cal      diode 2-> polA (with 90deg phase shift), diode 2-> polB
;
;This routine is called automatically by corhcalval and calget().
;
;How the different cal routines vary:
;calinpdata() inputs the data from disc. You must specify the rcvrnum,calnum.
;             It defaults to the current date. It loads a table in common
;             but it does not interpolate or compute a calvalue.
;calval()     Pass in the frequency and the caldata array input via
;             calinpdata(). It will interpolate the frequency and compute the
;             cal value.
;calget()     You supply a header and a frequency. The routine figures out the
;             caltype,rcvrNum, and date from the header and calls calinpdata()
;             and calval(). It returns the cal values.
;corhcalval() You specify the correlator sbc header (eg b.b1.h). It will
;             compute the frequency and then call calget(). It returns the
;             cal values.
;
;NOTE:
;  The following receivers will always return a single calNum independent
;of what is requested (since they only have 1 single cal).
;  rcvnum  nam    calnumreturned
;    3     610     0  low cor cal
;    6     lbn     0  low cor cal
;  100     ch      5  h uncorcal
;
;  sbn now has hcorcal,lcorcal.
;   12     sbn     0  low cor cal,hcorcal
;
;SEE ALSO: corhcalval, calget
;- 
;history:
;19jan01 .. added date option.
;27apr04 .. added check for rcv 17 alfa..
;
function calInpData,rcvNum,calNum,calData,fname=fname,date=date
;
	calNumL=calNum
    maxEntry=120
    useAlfa=rcvNum eq 17
    on_error,1
    on_ioerror,endio
    lun=-1
    if (n_elements(fname) eq 0) then begin
        fname=string(format='(a,"data/cal.datR",i0)',aodefdir(),rcvNum)
    endif
;   print,'calinpdata ',fname
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
        else: message,'calinpdata illegal date request.. [year,daynum]'
    endcase
    openr,lun,fname,/get_lun,error=err
    if  err ne 0 then begin
        print,"couldn't open file",fname
        return,-1
    endif
    if  (rcvnum eq 6) then calNumL=0
    if (rcvNum eq 12) then begin
;       old rcv only had lcorcal, so always force lcorcal
;       new rcv had hcorcal,lcorcal
;       date for switch is 28oct12 =dayno 302
;
		if (reqYr ne 0)	and (reqYr le 2012) and $
		   (reqDay lt 302) then  begin
			calNumL=0
		endif else begin
;		even number --> lcorcal, odd --> hcorcal
			calNumL=(calNum mod 2)?1: 0 
		endelse
	endif
    if (rcvNum eq 1) or (rcvNum eq 3) then calNumL=1  
    if (rcvNum eq 100) then calNumL=5  
    if (useAlfa) then calNumL=17
;
;    file format is:
;  d1Ah d1Al d1Bh d1Bl d2Ah d2Al d2Bh d2Bl
; # col 1 is comment
; !yyyy ddd is first valid date for data that follows..
    ;
    case calNumL of
        0: begin & indA=1 & indB=3 & end ; lcorcal d1 -> a,b
        1: begin & indA=0 & indB=2 & end ; hcorcal d1 -> a,b
        2: begin & indA=5 & indB=3 & end ; lxcal   d1 -> b,d2->a
        3: begin & indA=4 & indB=2 & end ; hxcal   d1 -> b,d2->a
        4: begin & indA=1 & indB=7 & end ; luncor  d1 -> a,d2->b
        5: begin & indA=0 & indB=6 & end ; huncor  d1 -> a,d2->b
        6: begin & indA=5 & indB=7 & end ; l90cal  d2 ->a,d2->b
        7: begin & indA=4 & indB=6 & end ; h90cal  d2 ->a,d2->b
        17:begin & indA=[0,2,4,6,8,10,12] & indB=[1,3,5,7,9,11,13] & end ;alfa..
     else: begin 
            print,calNum," is illegal,calNumbers are 0..7"
            return,-2
           end
     endcase
    freqLine=0.
    freq=fltarr(maxEntry)
    if useAlfa then begin
        calA=fltarr(maxEntry,7)
        calB=fltarr(maxEntry,7)
        calVal=fltarr(14)                    ; read in 14 numbers on the line 
    endif else begin
        calA=fltarr(maxEntry)
        calB=fltarr(maxEntry)
        calVal=fltarr(8)                    ; read in 8 numbers on the line 
    endelse
    inpl=" "
    i=0
    gotDate=reqYr eq 0
    startYr=0 & startDay=0
    endYr=0   & endDay=0
    while (1) do begin
        readf,lun,inpl
        if (strmid(inpl,0,1) ne '#') then begin
           if (strmid(inpl,0,1) eq '!') then begin
              if not gotDate then begin
                 startYr=0 & startDay=0
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
           endif else begin
                if gotDate then begin
                    reads,inpl,freqLine,calval
                    freq[i]=freqLine
                    if useAlfa then begin
                        calA[i,*]=calVal[indA]
                        calB[i,*]=calVal[indB]
                    endif else begin
                        calA[i]=calVal[indA]
                        calB[i]=calVal[indB]
                    endelse
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
            endYr=3000
            endDay=366
        endif
        if useAlfa then begin
            calData={ rcvNum:rcvNum,$
                  calNum:calNumL,$
                  numFreq:i, $
                  startYr    : startYr,$
                  startDaynum: startDay,$
                  endYr      : endYr,$
                  endDaynum  : endDay,$
                  freq:freq[0:i-1],$
                  calA:calA[0:i-1,*],$
                  calB:calB[0:i-1,*]}
        endif else begin
            calData={ rcvNum:rcvNum,$
                  calNum:calNumL,$
                 numFreq:i, $
                  startYr    : startYr,$
                  startDaynum: startDay,$
                  endYr      : endYr,$
                  endDaynum  : endDay,$
                  freq:freq[0:i-1],$
                  calA:calA[0:i-1],$
                  calB:calB[0:i-1]}
        endelse
                    
    endelse
    if (lun gt -1) then free_lun,lun
    return,retstat
end
