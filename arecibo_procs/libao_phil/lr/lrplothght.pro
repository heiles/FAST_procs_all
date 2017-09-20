;+ 
;NAME:
;lrplothght - plot the platform height versus time
;
; SYNTAX: lrplothght,b,defhght=defhght,sym=sym,year=year
;   ARGS:
;b[npts]: {lrdat} laser ranging data input via lrpcinp.
;
;KEYWORDS:
; defhght: float    value to print out as default height (1256.35)
;     sym: int      symbol to use for each point (-1 to -8). def: no symbol
;    year: long     4 digit year to use. Default is current year
;
;DESCRIPTION:
;   Make a plot of platform height versus hour of day. The data in b[] must
;first be read in using the routine lrpcinp. The output is in feet above
;sea level and includes:
; white: the average platform height 
;   red: tower 12 height
; green: tower  4 height
;yellow: tower  8 height
;
;The date at the middle of the plot and the time,temp, and average height at 
;the last point of the plot are printed (note that the last point is usually
;from the start of the next day).
;The plots show that the tiedowns are trying to keep the average height of
;the platform fixed while the corners move depending on the unbalanced load 
;(which is a function of the dome/carriage house positions).
;
;Example:
;istat=lrpcinp(010505,b)
;ver,1256,1257
;hor,0,24
;lrplothght,b
;-
pro lrplothght,b,defhght=defhght,sym=sym,cs=cs,_extra=_ex,nonotes=nonotes,$
            lnnotes=lnnotes,year=year
;
    common colph,decomposedph,colph

    syml=0
    if keyword_set(sym) then syml=-2
    if not keyword_set(defhght) then defhght=1256.22
    npts=n_elements(b)
	ii = where(b.date ne 0.,cnt)
	if cnt gt 0 then begin
    	daynum=median(floor(b[ii].date))
    endif else begin
    	daynum=median(floor(b.date))
	endelse
    ind=where(abs(b.date-daynum) le 1.1,count)
    blast=b[npts-1]
    col12=2
    col4 =3
    col8 =5
    if not keyword_set(cs) then cs=1.5
;    print,cs
    hour  =(b[ind].date-daynum)*24.
    a=bin_date()
	if n_elements(year) eq 0 then year=a[0]
    a=daynotodm(daynum,year)
    day=a[0]
    month=a[1]
;
; fix any bad time points or 24  wrap arounds
;
    plot,hour,b[ind].avgh,xtitle='hour',ytitle='feet above sea level',$
  title='platform corner and average height versus hour',charsize=cs,psym=syml,$
        _extra=_ex
    oplot,hour,b[ind].cornerh[0],color=colph[col12],psym=syml,$
        _extra=_ex
    oplot,hour,b[ind].cornerh[1],color=colph[col4],psym=syml,$
        _extra=_ex
    oplot,hour,b[ind].cornerh[2],color=colph[col8],psym=syml,$
        _extra=_ex
    if (blast.dok eq 1) then begin
        lab=string(format='("average height:",f8.3," ft")',blast.avgh)
    endif else begin
        lab="distomat errs :"
        for i=0,5 do begin
            if ((blast.dist[i] lt 163.) or (blast.dist[i] gt 166.))$
                then begin
               lab=lab+" "+string(format='("d",i1)',i+1)
            endif
        endfor
    endelse
    xp=.02
    if (n_elements(lnnotes) ne 0) then begin
        ln=lnnotes
    endif else begin
        ln=3
    endelse
    note,ln  ,'average   height',xp=xp,charsize=cs,_extra=_ex
    note,ln+1,'corner 12 height',xp=xp,color=colph[col12],charsize=cs,$
        _extra=_ex
    note,ln+2,'corner  4 height',xp=xp,color=colph[col4],charsize=cs,$
        _extra=_ex
    note,ln+3,'corner  8 height',xp=xp,color=colph[col8],charsize=cs,$
            _extra=_ex

    if not keyword_set(nonotes) then begin
    ln=3
    xp=.5
    note,ln  ,"date (m/d/y) "+string(format='(i2,"/",i2,"/",i4)',$
                    month,day,year),charsize=cs,xp=xp,_extra=_ex
    note,ln+1,"time last pnt   "+$
            fisecmidhms3((blast.date-floor(blast.date))*86400.),$
                charsize=cs,xp=xp,_extra=_ex
    note,ln+2,"platform temp:"+string(format='(f8.2,"  F")',blast.temppl),$
               charsize=cs,xp=xp,_extra=_ex
    note,ln+3,lab,charsize=cs,xp=xp,_extra=_ex
    lab=string(format='("Default  height:",f8.3," ft")',defhght)
    note,ln+4,lab,charsize=cs,xp=xp,_extra=_ex
    endif
    return
end
