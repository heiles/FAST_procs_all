; 
;NAME: tdsummary
; input summary info for a month this is the 
; position,kips at each minute of a day as well as the temp and avg platfheight
;
;@lrinit
;@tdinit
function tdsummary1,yymmdd1,yymmdd2,tdsum
    forward_function lrpcinp

    stdhght=1256.35
    stdtemp=75.
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
;
;   convert to julian days. 
;
    julday1=julday(mon1,day1,year1l,0,0,10)
    julday2=julday(mon2,day2,year2l,0,0,10)
    numdays=julday2-julday1+1
    maxlr=numdays*740L+10L
    maxtd=numdays*1440L+10L
    tdsum=replicate({tdlr},numdays*1440+10)
    lrt    =dblarr(maxlr)
    lrh    =dblarr(maxlr)
    lrday  =dblarr(maxlr)
;--------------------------------------------------------------------------
;   input all of the laser ranging data first. the
;   the end of 1 day can be in the start of the file for the next day.
;
    ii=0
    for juld=julday1,julday2 do begin &$
        caldat,juld,mon,day,year &$
        yymmdd=(year mod 100) * 10000L+mon*100L+day
        dayNum=dmtodayno(day,mon,year)
        nptslr=lrpcinp(yymmdd,lrd)
        if nptslr gt 0 then begin
;
;       get rid of any bad dates
;
          ind=where((lrd.date ge daynum-.1) and $
                      (lrd.date le daynum+1+.1),count)
          if count gt 0 then begin
              iie=ii+count-1
              lrday[ii:iie]=lrd[ind].date
              lrt[ii:iie]=lrd[ind].tempPl
              lrh[ii:iie]=lrd[ind].avgh
              ii=ii+count
          endif
      endif
    endfor
    if (ii lt maxlr) then begin
        lrt =lrt[0:ii-1]
        lrh  =lrh[0:ii-1]
        lrday=lrday[0:ii-1]
    endif
;--------------------------------------------------------------------------
;   loop through inputing the tiedown data and computing the hght,temp for
;   that day.
;
    ii=0
    tempflag=intarr(1441)
    hghtflag=intarr(1441)
    for juld=julday1,julday2 do begin &$
        caldat,juld,mon,day,year &$
        yymmdd=(year mod 100) * 10000L+mon*100L+day
        dayNum=dmtodayno(day,mon,year)
        npts=tdinpday(yymmdd,td)
        if npts gt 0 then begin 
            ind=where((td.secm mod 60L) eq 0,npts)
        endif
        if npts gt 0 then begin
;
;           move the td data
;
            iie=ii+npts-1
            tdSum[ii:iie].day   =td[ind].secM/86400.D +  dayNum 
            tdSum[ii:iie].az    =td[ind].az
            tdSum[ii:iie].gr    =td[ind].gr
            tdSum[ii:iie].ch    =td[ind].ch
            tdSum[ii:iie].pos   =td[ind].pos
            tdSum[ii:iie].kips  =td[ind].kips
            tdSum[ii:iie].kipst =td[ind].kipst
;
;           now do the lr hght /temp[
;
            tdmin=td[ind].secM/60L
            indlr=where((lrday ge dayNum) and (lrday lt (dayNum+1.D)),count)
            if count gt 0 then begin    
;
;               get this days worth of lr data
;
                tdday1=tdSum[ii:iie].day
                lrday1=lrday[indlr]
                lrt1  =lrt[indlr]
                lrh1  =lrh[indlr]
;
;           Use flag array of 1440 entries (1 per minute).
;           hghtflag[1440] holds  1 if we have lrght data for this minute
;                          and it is ok. 
                hghtflag=hghtflag*0
                tempflag=tempflag*0
                lrmin=long((lrday1 mod 1.D)*1440.)
                hghtflag[lrmin]=1           ; have data
                hghtflag[lrmin+1]=1         ; for next minute too.
                tempflag[lrmin]=1           ; have data
                tempflag[lrmin+1]=1         ; for next minute too.
;
;               get any bad heights
;
                ind=where((lrh1 lt 1255.5) or (lrh1 gt 1257),count)
                if count gt 0 then begin
                    hghtflag[lrmin[ind]]=0      ; 0 flag
                    hghtflag[lrmin[ind]+1]=0    ; 0 flag next minute
                    lrh1[ind]=stdhght           ; so we don't ruin adjacent pts
                endif
                htd1=interpol(lrh1,lrday1,tdday1)
                ind=where(hghtflag[tdmin] eq 0,count)
                if count gt 0 then htd1[ind]=0.
                tdSum[ii:iie].hght=htd1
;
;               get any bad temps
;
                ind=where((lrt1 lt 50.) or (lrt1 gt 105.),count)
                if count gt 0 then begin
                    tempflag[lrmin[ind]]=0      ; 0 flag
                    tempflag[lrmin[ind]+1]=0    ; 0 flag next minute
                    lrt1[ind]=stdtemp           ; so we don't ruin adjacent pts
                endif
                ttd1=interpol(lrt1,lrday1,tdday1)
                ind=where(tempflag[tdmin] eq 0,count)
                if count gt 0 then ttd1[ind]=0.
                tdSum[ii:iie].hght=htd1
             endif
        ii=ii+npts
        endif
        print,"yymmdd,pnts:",yymmdd,npts
    endfor
    npts=ii
    if npts lt maxtd then tdsum=tdsum[0:npts-1]
    return,npts
end
