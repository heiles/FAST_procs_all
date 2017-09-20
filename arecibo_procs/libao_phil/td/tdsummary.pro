;+
;NAME:
;tdsummary - create td summary info for a date range
;SYNTAX: istat=tdsummary(yymmdd1,yymmdd2,tdsum)
;ARGS:
;   yymmdd1: long   first day to include (usually start of month)
;   yymmdd2: long   last day to get (usually last day of month)
;
;RETURNS:
;   npts:    long   number of points created
;   tdsum[npts]:{tdsumI} Interpolated data 
;
;DESCRIPTION:
;   Read through the daily archives files for the tiedown and the laser 
;rangers for the specified date range. The tiedowns are sampled once a 
;second while the laser rangers are sampled every 2 minutes. This routine
;return a array of structure containing the tiedown and laser ranger data 
;after interpolating to 1 minute resolution. It exclude bad data points.
;   The returned structure (interpolated to 1 minute) contains:
;
;** Structure TDLR, 9 tags, length=68, data length=68:
;DAY             DOUBLE   1.6951389  ; daynumber of year (count from 1)
;AZ              FLOAT  315.157      ; azimuth (gregorian side)
;GR              FLOAT   11.4503     ; gregorian za
;CH              FLOAT    8.83490    ; ch za
;POS             FLOAT  Array[3]     ; td jack positions inches (td12,td4,td8)
;KIPS            FLOAT  Array[2, 3]  ; td kips [2cables,td12/td4/td8]
;KIPST           FLOAT   112.920     ; total tension kips
;TEMP            FLOAT    76.2484    ; platform temp deg F
;HGHT            FLOAT  1256.35      ; platform average hgt feet above sealevel
;
;   This routine is normally run at the end of the month to create the
;tiedown/laser ranger monthly summary files. These are stored by 
;month in /share/megs/phil/x101/td/tds_yymm.sav'. This data can then
;be accessed with the tdgetsum(yymmdd1,yymmdd2,td) idl routine.
;
;   To run this routine you must first call @tdinit,@lrinit to setup the
;paths.
;-
function tdsummary,yymmdd1,yymmdd2,tdsum
    forward_function lrpcinp
    year1=yymmdd1/10000L
    mon1 =yymmdd1/100 mod 100
    day1 =yymmdd1 mod  100
;
    year2=yymmdd2/10000L
    mon2 =yymmdd2/100 mod 100
    day2 =yymmdd2 mod 100
; 
    case year1 gt 50 of
        1: year1l=year1+1900
        0: year1l=year1+2000
    endcase 
    case year2 gt 50 of
        1: year2l=year2+1900
        0: year2l=year2+2000
    endcase 
    julday1=julday(mon1,day1,year1l,0,0,10)
    julday2=julday(mon2,day2,year2l,0,0,10)
    numdays=julday2-julday1+1
    tdSumMaxrec=numdays*1440L+10
    tdSum=replicate({tdlr},tdSumMaxRec)
    lrtemp =dblarr(numdays*740*2+10)
    lrhght =dblarr(numdays*740*2+10)
    lrday  =dblarr(numdays*740*2+10)

    ii=0L               ; start index current day td
    il=0L               ; start indexlr by day
    ile=0L              ; end ind lr array
;
;   make bad value large enough to that even after interpolation between
;  many missing points,the  interpolated values will still be unreasonable..
;
    badtempval=-1e5
    badhghtval=-1e3

    for juld=julday1,julday2 do begin &$
        caldat,juld,mon,day,year &$
        yymmdd=(year mod 100) * 10000L+mon*100L+day
        dayNum=dmtodayno(day,mon,year)
;
;   get laser ranging data
        nptslr=lrpcinp(yymmdd,lrd)
        if nptslr gt 0 then begin
;
;           get rid of any bad dates,0 bad heights or temps
;
            ind=where((lrd.date ge daynum-.1) and $
                      (lrd.date le daynum+1+.1),count)
            if count gt 0 then begin
                ile=il+count-1
                lrday[il:ile]=lrd[ind].date
                temp=lrd[ind].tempPl
                avgh=lrd[ind].avgh
                ind=where((temp lt 50) or (temp gt 100),count)
                if count gt 0 then temp[ind]=badtempval
;15oct02 changed    ind=where((avgh lt 125 ) or (avgh gt 1258),count)
                ind=where((avgh lt 1255) or (avgh gt 1258),count)
                if count gt 0 then avgh[ind]=badhghtval
                lrtemp[il:ile]=temp
                lrhght[il:ile]=avgh
                il=ile+1
            endif
      endif
;
;   get tiedown data
;
       npts=0
       tdpnts=tdinpday(yymmdd,td)
       if tdpnts eq 0 then goto,botloop
;
;     throw out points with bad tm
;
    ind=where((td.secm ge 0L ) and (td.secm le 86400L),count)
    if count lt tdpnts then begin
        tdpnts=count
        if tdpnts eq 0 then goto,botloop
        td=td[ind]
    endif
;
;    select on each minute
;
        ind=where((td.secm mod 60L) eq 0,count) 
		if count eq 0 then goto,botloop
        npts=(size(ind))[1]
        iie=ii+npts-1
;       tdmin=td[ind].secM/60L
        if (iie+1 ge  tdsummaxrec) then begin
            aa= (iie - tdsummaxrec + 1  + 100)
            tdsum=[tdsum,replicate(tdsum[0],aa)]
            tdsummaxrec+=aa
        endif
        tdSum[ii:iie].day   =td[ind].secM/86400.D +  dayNum 
        tdSum[ii:iie].az    =td[ind].az
        tdSum[ii:iie].gr    =td[ind].gr
        tdSum[ii:iie].ch    =td[ind].ch
        tdSum[ii:iie].pos   =td[ind].pos
        tdSum[ii:iie].kips  =td[ind].kips
        tdSum[ii:iie].kipst =td[ind].kipst
        ii=ii+npts
botloop:
        print,"yymmdd,pnts:",yymmdd,npts
    endfor
;
;   now interpolate the temps,hghts of lr to tiedown times
;
    if iie eq 0 then begin
        tdsum=''
        npts=0L
        return,0
    endif 
    npts=iie+1
    tdsum=temporary(tdsum[0:npts-1])
    lrday=lrday[0:ile]
    lrtemp=lrtemp[0:ile]
    lrhght=lrhght[0:ile]
;
;   find all of the jumps in the lr data > 10 minutes,
;   indj: where jumps > 10 min occur .indices are at the end of the jump
;   ii is next to move
    indj=where((lrday-shift(lrday,1))*1440 gt 10.,count)
    if count gt 0 then begin
        tempn=fltarr(ile+1+count+1)
        hghtn=fltarr(ile+1+count+1)
         dayn=fltarr(ile+1+count+1)
        in1=0
        io0=0
        for i=0,count-1 do begin &$
            if i eq 0 then begin    ; stuff bad point at beginning
             tempn[in1]=badtempval
             hghtn[in1]=badhghtval
             dayn[in1]=lrday[0]- 2./1440.
             in1=in1+1
            endif
            io1=indj[i]-1 &$
;
;           all the good points up to the jump
;
            n=io1-io0+1 &$
            tempn[in1:in1+n-1]=lrtemp[io0:io1] &$
            hghtn[in1:in1+n-1]=lrhght[io0:io1] &$
            dayn[in1:in1+n-1]=lrday[io0:io1] &$
;
;       at the jump place a bad temp,hght value. 
;       set time to 5 minutes after last good point
            io0=indj[i] &$  ; this is the jump index.
            in1=in1+n &$
            tempn[in1]=badtempval &$
            hghtn[in1]=badhghtval &$
            dayn[in1] =lrday[io1]+5./1440. &$
            in1=in1+1 &$
         endfor
;
;        fill in last good points
;
         if ((indj[count-1]+1) lt (ile+1)) then begin &$
            ii=indj[count-1] &$
            tempn[in1:*]=lrtemp[ii:*] &$
            hghtn[in1:*]=lrhght[ii:*] &$
            dayn[in1:*] =lrday[ii:*] &$
        endif
;
;       now interpolate to tiedown minutes
;
        temp=interpol(tempn,dayn,tdsum.day)
        hght=interpol(hghtn,dayn,tdsum.day)
    endif else begin
        temp=interpol(lrtemp,lrday,tdsum.day)
        hght=interpol(lrhght,lrday,tdsum.day)
    endelse
;
;   not mark all bad temps, heights with value 0.
;
    ind=where((temp lt 50) or (temp gt 100),count)
    if count gt 0 then temp[ind]=0.
    ind=where((hght lt 1255) or (hght gt 1258),count)
    if count gt 0 then hght[ind]=0.
    tdsum.hght=hght
    tdsum.temp=temp
    return,npts
end
