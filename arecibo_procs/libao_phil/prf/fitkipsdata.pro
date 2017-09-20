;
; fit kips to az,za,tiedown position, temp or height
;
; use march, apr, part of may.. (all the td info currently on disc
;
; 7mar: daynum 67 first day of lr data on disc
; 59 days thru 4may00
;
; input the laser ranging info from file
;
;@lrinit
;@tdinit
	common fitkips,fitkipsdat,tdind
	dayNum=67L				; first daynumber. corresponds to 0307
	numdays=59L
	lrdatinp,dayNum,numdays,lrd
;
; now loop inputting the tiedown data.
;
	tdA=replicate({tdlr},1440L*numdays)
	ist=0
	for i=307L,331L do begin
		tdinpday,i,td
;
;	 select on each minute
;
		ind=where((td.secm mod 60L) eq 0) 
		npts=(size(ind))[1]
		iend=ist+npts-1
		tdA[ist:iend].day  =td[ind].secM/86400.D +  dayNum
		tdA[ist:iend].az   =td[ind].az
		tdA[ist:iend].gr   =td[ind].gr
		tdA[ist:iend].ch   =td[ind].ch
		tdA[ist:iend].pos  =td[ind].pos
		tdA[ist:iend].kips =td[ind].kips
		tdA[ist:iend].kipst =td[ind].kipst
;
; 	spline interpolate hght and temp
;   first find indices for this day
;
		ind1  = where(long(lrd.day) eq dayNum)
		day   =lrd[ind1].day
		temp =lrd[ind1].temp
		hght =lrd[ind1].hght
		y2    =spl_init(day,temp)
		tdA[ist:iend].temp=spl_interp(day,temp,y2,tdA[ist:iend].day)
		y2    =spl_init(day,hght)
		tdA[ist:iend].hght=spl_interp(day,hght,y2,tdA[ist:iend].day)
		ist=ist+npts
		print,"day,dayNum,pnts:",i,dayNum,npts,ist
		dayNum=dayNum+1
	endfor
   for i=401L,430L do begin
        tdinpday,i,td
;
;    select on each minute
;
        ind=where((td.secm mod 60L) eq 0)
        npts=(size(ind))[1]
        iend=ist+npts-1
        tdA[ist:iend].day  =td[ind].secM/86400.D +  dayNum
        tdA[ist:iend].az   =td[ind].az
        tdA[ist:iend].gr   =td[ind].gr
        tdA[ist:iend].ch   =td[ind].ch
        tdA[ist:iend].pos  =td[ind].pos
        tdA[ist:iend].kips =td[ind].kips
        tdA[ist:iend].kipst =td[ind].kipst
;
;   spline interpolate hght and temp
;   first find indices for this day
;
        ind1  = where(long(lrd.day) eq dayNum)
        day   =lrd[ind1].day
        temp =lrd[ind1].temp
        hght =lrd[ind1].hght
        y2    =spl_init(day,temp)
        tdA[ist:iend].temp=spl_interp(day,temp,y2,tdA[ist:iend].day)
        y2    =spl_init(day,hght)
        tdA[ist:iend].hght=spl_interp(day,hght,y2,tdA[ist:iend].day)
        ist=ist+npts
        print,"day",i," done. pnts",npts,ist
		print,"day,dayNum,pnts:",i,dayNum,npts,ist
		dayNum=dayNum+1
    endfor

   for i=501L,504L do begin
        tdinpday,i,td
;
;    select on each minute
;
        ind=where((td.secm mod 60L) eq 0)
        npts=(size(ind))[1]
        iend=ist+npts-1
        tdA[ist:iend].day  =td[ind].secM/86400.D +  dayNum
        tdA[ist:iend].az   =td[ind].az
        tdA[ist:iend].gr   =td[ind].gr
        tdA[ist:iend].ch   =td[ind].ch
        tdA[ist:iend].pos  =td[ind].pos
        tdA[ist:iend].kips =td[ind].kips
        tdA[ist:iend].kipst =td[ind].kipst
;
;   spline interpolate hght and temp
;   first find indices for this day
;
        ind1  = where(long(lrd.day) eq dayNum)
        day   =lrd[ind1].day
        temp =lrd[ind1].temp
        hght =lrd[ind1].hght
        y2    =spl_init(day,temp)
        tdA[ist:iend].temp=spl_interp(day,temp,y2,tdA[ist:iend].day)
        y2    =spl_init(day,hght)
        tdA[ist:iend].hght=spl_interp(day,hght,y2,tdA[ist:iend].day)
        ist=ist+npts
        print,"day",i," done. pnts",npts,ist
		print,"day,dayNum,pnts:",i,dayNum,npts,ist
		dayNum=dayNum+1
    endfor
;
;	select out good data points..
;	1. ch at stow
;   2. at leat 3 kips in each load cell
;   3. height within 1 foot of 1256.5
;   5. temp withing 25 deg of 80 deg F
;
	 tdA=temporary(tdA[0:ist-1])
	diff1=tdA.hght-shift(tdA.hght,1)
	diff2=tdA.hght-shift(tdA.hght,-1)
	diff3=tdA.temp-shift(tdA.temp,-1)
	diff4=tdA.temp-shift(tdA.temp, 1)
    mink=3.
	maxkipsdif=5.
    ind1=where( (abs(tdA.ch - 8.834) lt .1) and $
        (tdA.kips[0,0] ge mink) and $
        (tdA.kips[1,0] ge mink) and $
        (tdA.kips[0,1] ge mink) and $
        (tdA.kips[1,1] ge mink) and $
        (tdA.kips[0,2] ge mink) and $
        (tdA.kips[1,2] ge mink) and $
        (abs(diff1) lt .1)      and $
        (abs(diff2) lt .1)      and $
        (abs(diff3) lt 2.)      and $
        (abs(diff4) lt 2.)      and $
		(abs(tdA.kips[0,0]-tdA.kips[1,0]) lt maxkipsdif) and $
		(abs(tdA.kips[0,1]-tdA.kips[1,1]) lt maxkipsdif) and $
		(abs(tdA.kips[0,2]-tdA.kips[1,2]) lt maxkipsdif) and $
        (  tdA.hght  lt 1256.7) and $
        (  tdA.hght  gt 1256.1) and $
		(abs(tdA.temp-80.) lt 25.))
    fitkipsdat=temporary(tdA[ind1])
;
; fix ldcell 1 td 4
;
	ind1=where(abs(fitkipsdat.kips[0,1]-fitkipsdat.kips[1,1]) gt 1) 
	fitkipsdat[ind1].kips[0,1]=fitkipsdat[ind1].kips[1,1]
;
;	recompute total kips
;
	fitkipsdat.kipst=total(total(fitkipsdat.kips,1),1)
;
;	store in file
;
	print,"outputing data to:/share/megs/prf/fitkips.dat"
	openw,lun,"/share/megs/prf/fitkips.dat",/get_lun
	writeu,lun,fitkipsdat
	free_lun,lun
;
end
