;
;+
;*DAY-----------------------
;imgfrq,{imday},frq,{imday}  - extract 1 freq subset from {imday}
;iminpday,yymmdd ,{imday}    - input the days worth of data
;imls                      - ls current im files online
;imopen  ,yymmdd ,lun      - open file, return lun in lun
;{imdrec}=imavg  ,{imday1frq} -return average rec for day. use imgfrq 1st
;*PLOTTING_-----------------
;implot  ,{imdrec}         - plot a an im data structure
;implloop,{imday} ,delay   - loop plotting imd with delay secs between each
;x[401]=immkfrq ,{imdrec}  - return x array holding the freq for the rec   
;immktm  ,{imday} ,y       - return y array holding the times(hour)for the rec 
;*PLOTTING SEQUENTIAL-------
;imfreq  ,{imday} ,freq    - freq to plot or -1 freq any freq
;imd     ,{imday} ,recnum  - plot recnumber
;imc     ,{imday}          - replot current rec
;imn     ,{imday}          - plot next rec of selected freq
;*MISC----------------------
;iminprec,lun,{imdrec}     - input the next record from the file
;imlin   ,{imday}          - convert data from db to linear scale
;imdb    ,{imday}          - convert data from linear to db
;tsys=imtsys,freq          - return tsys for this freq. 0 if not known
;davg=imavg(imday)         - compute average 1 freq, 1 day
;drms=imrms(imday)         - rms by channel 1 freq, 1 day
;
;*STRUCTURES----------------
;d:{imday}          - returned by iminpday
;d:yymmdd           - int
;d.nrecs            - how many records in day
;d.frql[int]        - list of frequencies for this day
;d.r[imdrec]        - array of data records. hdr and data
;d.crec             - current rec for plotting 1..nrecs
;d.cfrq             - current rec for plotting (or -1).
;d.r.d[12]          - data record 12, 401 points
;
;r:{imdrec}         - one integration in {imday}
;r.h                - {imhdr} header
;r.d                - [float 401]   data 
;
;h:{imhdr}          - header routine for each record
;h.hdrMarker        - bytarr(4)
;h.hdrlen           - 0L
;h.reclen           - 0L
;h.versionj         - bytarr(4)
;h.date             - yyyyddd
;h.secMid           - 0L
;h.cfrDataMhz       - float
;h.cfrAnaMhz        - float
;h.spanMhz          - float
;h.integTime        - long, seconds
;h.srcAzDeg:        -   0L
;-
;
pro imlib 
return
end
;
;---------------------------------------------------------------------------
;iminprec,lun,{imdrec} - input the next record from the file
;---------------------------------------------------------------------------
; lun - for file to read from
; s   - iminprec struct. return data here
pro iminprec, lun,r
;
; 
d={imirec}
r={imdrec}
readu,lun,d
if swap_endian(d.h.hdrlen) eq 44 then d=swap_endian(d)
r.h=d.h
r.d=(d.d*.01)
return
end
;---------------------------------------------------------------------------
;imls                   - ls filename in online directory
;---------------------------------------------------------------------------
pro imls
;
spawn,"ls /share/rfidat/data/IM*.dat", dat
print,dat
return
end
;---------------------------------------------------------------------------
;lun=imopen,yymmdd  - open file, return lun in lun
;---------------------------------------------------------------------------
function imopen,yymmdd,inpdir=inpdir
;
; return -1 if error
;
; convert to string and replace leading blanks with zeros.
;
	useInpDir=n_elements(inpdir) eq 1
	syymmdd=string(format='(i6.6)',yymmdd)
;
; first try online, then offline directories..
;
	name=(useInpDir)?inpdir + "/IM"  + syymmdd + '.dat' $
		            :'/share/rfidat/data/IM' + syymmdd + '.dat'
	openr,lun,name,/get_lun,error=ioerr
	if (ioerr ne 0) then begin
		if (useInpDir)then begin
     		printf,-2,!ERR_STRING;
     		lun=-1
			return,lun
		endif 
   		smm=strmid(syymmdd,2,2)
   		syy  = strmid(syymmdd,0,2)
  		name=string(format='("/share/rfi/data/y",A2,"/IM",A2,"/IM",a,".dat")',$
                syy,smm,syymmdd)
   		openr,lun,name,/get_lun,error=ioerr
   		if (ioerr ne 0) then begin
    		 printf,-2,!ERR_STRING;
     		lun=-1
   		endif
	endif
	return,lun
end
;---------------------------------------------------------------------------
;implot,{imdrec} - plot a an im data structure
;---------------------------------------------------------------------------
; s   - record to plot
pro implot,r
; 
stp=r.h.spanMhz/400.
x= (findgen(401) - 200.) * stp + r.h.cfrDataMhz
title=string(format='("cfr:",f5.0," Mhz  span:",f5.0," Mhz  tm:",i2,":",i2,":",i2)', $
 r.h.cfrDataMhz,r.h.spanMhz,r.h.secMid/3600, (r.h.secMid mod 3600)/60,  $
 r.h.secMid mod 60)

plot,x,r.d, xtitle="freq [Mhz]", ytitle="pwr [dbm]",title=title
return
end
;---------------------------------------------------------------------------
;iminpday,yymmdd,d[{iminprec}] - input full days worth of data
;---------------------------------------------------------------------------
pro iminpday,yymmdd,d,recsfound=recsfound,inpdir=inpdir
;
;  d.yymmdd
;  d.nrecs
;  d.frqlist[nfreq]
;  d.r[nrecs]
;  for plottinq
;  d.crec
;  d.cfrq
;
    numrec=0
    recsFound=0
    maxentry=1450   
    maxentry=2000	; for 1 month new mv162 was running too fast..
    maxfreq = 20
    frqlist=fltarr(maxfreq)
    frqlistLast=-1;
    lun=imopen(yymmdd,inpdir=inpdir)
    if (lun lt 0) then goto,done;
;
    inparr=replicate({imdrec},maxentry) 
    inprec={imirec};
;
;   loop till we hit eof
;
    on_ioerror,hiteof
    goodrecs=0L
    for numread=0,maxentry-1 do begin
        readu,lun,inprec
		if swap_endian(inprec.h.hdrlen) eq 44 then inprec=swap_endian(inprec) 
        if (string(inprec.h.hdrmarker) eq 'HDR_') and $
           (inprec.h.hdrlen    eq 44)    and $
           (inprec.h.reclen    eq 846)  then begin
            inparr[goodrecs].h=inprec.h
            inparr[goodrecs].d=inprec.d *.01 ; to db
            i=where(frqlist eq inprec.h.cfrDataMhz,count)
            if (count eq 0) then begin
                 frqlistlast=frqlistlast+1
                frqlist[frqlistlast]=inprec.h.cfrDataMhz;
            end
            goodrecs=goodrecs+1L
        endif
    end
hiteof:
    numrec=goodrecs
    if numrec eq 0 then goto,done 
    if ( not eof(lun) ) then begin 
        print,'rec:',numrec+1,' read err:',!err, !err_string
    end
;
;   sort frqlist, 
;
    frqlist=temporary(frqlist[sort(temporary(frqlist[0:frqlistlast]))])
;
;   now build structure to return
;
    if (numrec gt 0) then begin 
        d={yymmdd:yymmdd,nrecs:numrec,frql:frqlist, $
                r:temporary(inparr[0:numrec-1]),crec:0 ,cfrq:-1.}
    end
done:if lun ge 0  then free_lun,lun
    recsfound=numrec
    return
end
;---------------------------------------------------------------------------
;imgfrq,dall{imday},frq,dfrq{imday}  - return array with only frq
;---------------------------------------------------------------------------
pro imgfrq,dall,frq,dfrq,nfound=nfound
; dall {imday} all days info
; frq  float   to return
; dfrq {imday} holding just the frq of interest
;
    indlist=where(dall.r.h.cfrdataMhz eq frq,nfound)
    if (nfound le 0) then begin
        print,frq,' not found in daily data for ',dall.yymmdd
        return;
    end
     dfrq={yymmdd:dall.yymmdd,nrecs:nfound,frql:[frq],$
        r:temporary(dall.r[indlist]),crec:0     ,cfrq:frq}
     return
end
;---------------------------------------------------------------------------
;function imavg,d  - compute daily average. 
;---------------------------------------------------------------------------
function imavg,d
;
; {imdrec}=imavg {imday} - average recs in imd. call imgfrq first. 
;                          assumes data is linear
;
    s=size(d.r.d)
    davg={imdrec}
    davg.h=d.r[0].h
    davg.d= total(d.r.d,2)/(1.*s[2])
    return,davg
end
;---------------------------------------------------------------------------
;+
;imrms - compute rms for 1 frequency for a given day.
;SYNTAX: drms=imrms(d1)
;ARGS:
;   d1frq[] :   {imday} where you've extracted just 1 freq via imfrq()
;               and passed it thru imlin so it is a linear scale.
;   drms:        {imdrec} return rms here
;DESCRIPTION:
; compute rms/Mean by channel for a single frequency. d1 should contain
;a single frequency and be linear. You can do this via:
;iminpday,yymmdd,d
;imlin,d
;imgfrq,d,d.frql[i],d1
;drms=imrms(d1)
;
; You could then loop on i
;-
function imrms,d1
;
    npts=401
    drms={imdrec}
    drms.h=d1.r[0].h                 ; use first header
    for i=0,npts-1 do begin
        val=moment(d1.r.d[i],/double)
        drms.d[i]=sqrt(val[1])/val[0]
    endfor
    return,drms
end
;---------------------------------------------------------------------------
;implloop,d{imday},delaySecs  - loop plotting array with delay
;---------------------------------------------------------------------------
pro implloop,d,delay
; d     {imday} data to plot
; delay  secs   to wait
;
    for i=0,d.nrecs-1 do begin
        if ((d.cfrq eq -1.) or (d.cfrq eq d.r[i].h.cfrDataMhz)) then begin
            implot,d.r[i]
            if delay gt 0 then wait,delay
        endif
    endfor
    return
end
;---------------------------------------------------------------------------
;x=immkfrq,r{imdrec}      - return x array holding the freq for the rec   
;---------------------------------------------------------------------------
function immkfrq,r
; r     {imdrec} 1 record 
; returns float[401]  return freq here
;
    return,(findgen(401) - 200.) * r.h.spanMhz/400. + r.h.cfrDataMhz
end
;---------------------------------------------------------------------------
;immktm,d{imday},y       - return y array holding the times for the rec   
;---------------------------------------------------------------------------
pro immktm,d,y
;
; d     {imday} days data, extract the times
; tm    float[]  return the times .. hours
;
    y= d.r.h.secmid / 3600.
    return
end
;---------------------------------------------------------------------------
;  MISC 
;---------------------------------------------------------------------------
pro imlin , d
;---------------------------------------------------------------------------
;
; imlin,{imday}
; convert data from db to linear
;
    d.r.d=10.^(d.r.d*.1)
    return
end 
;---------------------------------------------------------------------------
pro imdb , d
;---------------------------------------------------------------------------
; imdb,{imday}
;  convert data from linear to db
;
    d.r.d=alog10(d.r.d)*10.
    return
end
;---------------------------------------------------------------------------
;  SEQUENTIAL PLOTTING
;---------------------------------------------------------------------------
;imd,d{imday},recnum  - display recnumber 1..n
;---------------------------------------------------------------------------
pro imd,d,recnum
    if ((recnum lt 1) or ( recnum gt d.nrecs)) then begin
        print,'err:recnum out of range:1 ..',d.nrecs
        retall
    end
    d.crec=recnum
    implot,d.r[recnum-1]
    return;
end
;---------------------------------------------------------------------------
;imc,d{imday}  - display current record number
;---------------------------------------------------------------------------
pro imc,d
    if (d.crec lt 1) then d.crec = 1 else $
    if (d.crec gt d.nrecs) then d.crec=d.nrecs
    implot,d.r[d.crec-1]
    return;
end
;---------------------------------------------------------------------------
;imn,d{imday}  - display next record number
;---------------------------------------------------------------------------
pro imn,d
    if (d.crec lt 1) then d.crec=1          ; in case we havent started yet
    i=d.crec+1                              ; next one
    if (d.cfrq gt 0) then begin             ; user specified freq
        for j=i,d.nrecs do begin            ; till end or hit new freq
            if (j gt d.nrecs) then goto,endloop     ; hit end
            if (d.r[j-1].h.cfrDataMhz eq d.cfrq) then goto,endloop
        end
endloop: i=j
    endif

    if (i gt d.nrecs) then begin
            print,'hit last record:',d.nrecs
            return
     endif
     d.crec=i;
     implot,d.r[d.crec-1]
    return;
end
;---------------------------------------------------------------------------
;imfreq,d{imday},frq  - set freq to display
;---------------------------------------------------------------------------
pro imfreq,d,freq
;
    if ( freq ge 0.) then begin
        i=where((d.frql eq freq),count)
        if (count eq 0) then begin
            print,'valid frequencies:',d.frql
            return
        end
    end
    d.cfrq=float(freq)
    return
end
;---------------------------------------------------------------------------
;imtsys,freq return tsys for this freq
;---------------------------------------------------------------------------
function imtsys,freq
;
    tsysArr= [15e3,15e3,15e3,3500.,0., 800.,800.,900.,1000.,1100.,1800.];
    frqArr = [ 70, 165 ,235, 330,430, 550,725,955,1075,1325,1400 ];
    ind=where( (freq eq frqArr),count)
    if (count eq 0) then return,0.
    return,tsysArr[ind[0]]
end
