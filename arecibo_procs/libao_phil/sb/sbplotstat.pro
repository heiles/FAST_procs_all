;+
;NAME:
;sbplotstat - plot the status bits versus time
;SYNTAX: sbplotstat,d,stI,utit=utit,wait=wait,gap=gap,laboff=laboff 
;ARGS:
;      d[n]:{}  sband long info read from disc via sblogget()
;stI:  {}       statInfo input from file via sbinpstatinfo()
;               determines which bytes and in what order to 
;               output the data
;KEYWORDS:
;utit: string  	user title to add to each page
;wait:          if set then wait for return after each page.
;gap  : float    number of units of X that specify a gap in the
;               data. If provided then an extra trace will appear
;               at the top of each page showing when there was 
;               valid data.
;laboff: float  fraction of screen distance to move the labels to the
;               left. For hardcopy .2 is ok. for interactive display
;               .1 is probably better.
;
;DESCRIPTION:
;	Make a plot of sband status bits vs x (normally dayno).
;The stI struct info is read from a file via sbinpstatinfo().
;It contains the number of "groups" to output. Each group is
;output starting on a new page. The order of the groups as
;well as the bits within each group is also contained in stI.
;	To generate a different plot:
;1. copy sbStatInfoAll.dat to a new file.
;2. edit the new file removing bits that aren't needed
;3. assign different bits to different groups and arrange
;   the order of output in each group to what you want.
;4. use sbinpstatinfo() to read this file and pass it to
;   this routine.
;-
pro sbplotstat,d,stI,gap=gap,utit=utit,wait=wait,laboff=laboff
;
;   figure out date for first dayno
;
    year=d[0].year
    dm=daynotodm(fix(d[0].dayno),year)
    yymmdd=string(format='(i02,i02,i02)',year mod 100L,dm[1],dm[0])
    xtitle=string(format='("DayNumber AST (",i3,"=",a,")")',$
            fix(d[0].dayno),yymmddtodmy(yymmdd))
;
; 	compute bit index into lab array
;

	if n_elements(utit) eq 0 then utit=''		; user title
	maxBitsPage=32
	laboffL=.2
	if (n_elements(laboff) gt 0) then begin
		if (labOff ge 0 ) then laboffL=labOff
	endif
	x=d.dayno
	grpsToOutput=n_elements(stI.grpOrder)
	for ii=0,grpsToOutput-1 do begin
		igrp=where(stI.grpOrder[ii] eq stI.grpI.grpnum,cnt)		; next grp to output
		if cnt eq 0 then begin
			print,"grouporder contains group req with no grpI entry",sti.grpOrder[ii]
			return
		endif
		nbitsGrp=stI.grpI[igrp].nbits
;
;		figure out the number of pages (32bits/page) we need.
;       if not a multiple of 32, round to get number/page needed
    	npages=nbitsGrp/maxBitsPage
    	if npages eq 0 then begin
        	bitsPerPage=nbitsGrp
    	endif else begin
        	if npages*maxBitsPage ne nbitsGrp then begin
            	npages+=1
          		bitsPerPage=nbitsGrp/npages
          		if bitsPerPage*npages lt nbitsGrp then bitsPerPage+=1
        	endif
    	endelse

;		loop for bits in this group..
	    ustat=0UL
		ishift=0;
		title=utit + ' ' + stI.grpI[igrp].grpname
		for ib=0,nbitsGrp-1 do begin
			mask=ishft(1,stI.grpI[igrp].bitAr[ib])
			val=  ulong((reform(d.stat[stI.grpI[igrp].wdAr[ib],*]) and mask) ne 0)   ; value 0,1
        	ustat= ustat or (ishft(val,ishift))
        	ishift++;
        	if (((ib mod bitsPerPage) eq (bitsPerPage -1)) or (ib eq (nbitsGrp-1))) then begin
            	nbits= (ib mod bitsPerPage) + 1
            	mask=2ul^nbits - 1
				hor&ver
				!p.multi=0
            	pltbits,x,ustat,mask,maxbits=nbits,loff=laboffL,$
            	lab=reform(sti.grpI[igrp].labAr[ib-nbits+1:ib]),gap=gap,title=title,$
				xtitle=xtitle
            	ishift=0
            	ustat=0uL
				if keyword_set(wait) then key=checkkey(/wait)
        	endif
    	endfor
	endfor
	return
end
