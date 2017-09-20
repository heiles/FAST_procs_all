;+
;NAME: 
;wstbindata - bin data to the requested time step
;
;SYNTAX: nbins=wstbindata(yinp,xinp,Davg,Dpk,Dx,binsize=binsize,$
;                 hrdat=hrdat,degdat=degdat,jddat=jddat,hist=hist)
;ARGS:
; yinp[n]: float/double data to process
; xinp[n]: double   x value for each y sample
;KEYWORDS:
; binsize : double  for histogram (see defaults below
; jddat   :         if set then assumme xdat is jd dates.
;                   round to full ast days. this is the default
;                   if hrdat,degdat is not supplied
;                   Def binsize=15/1440. (15 minutes)
; hrdat   :         if set then xdat is in hours
;                   def binsize is .1 hours
; degdat  :         if set then xdat is in degrees.
;                   def binsize=1 deg.
;              
;RETURNS:
;  nbins: long   number of bins in returned datahistogram
;Davg[nbins]:double average the points in each bin
;Dpk[nbins] :double take peak value from each bin
;Djd[nbins] :double xvalue value for center of each bin
;hist[nbins]   :double return the histogram
;               
;DESCRIPTION:
;   bin the input data using the xinp array. The default
;binwidth is:
; jd data : 15/1440 (15 minutes5 minutes).
; hr data : .1 hours
; degdata:  1 deg
; You can change the binwidth with the binsize=keyword.
;width with the tmStep= keyword.
;	The prgoram returns the following binned data:
; Bavg[nbins]: averag data in each bin
; Bpk [nbins]: peak data in each bin
; Bx[nbins]  : x values for center of each bin
;-
function wstbindata,ydat,xdat,Bavg,Bpk,Bx,binsize=binsize,$
			noround=noround,minval=minval,maxval=maxval,$
			jdDat=jddat,hrdat=hrdat,degdat=degdat,hist=h
	
	defHrStep=.25d
	defDegStep=1d
	defJdStep=15d/1440d
	npnts=n_elements(xdat)
	XMax=(n_elements(maxval) eq 1)?maxval:max(xdat)
	astToUtc=4d/24d
	case 1 of 
		keyword_set(hrdat): begin
			; xdata is in hours
			binsize=keyword_set(binstep)?binstep:defHrStep
			nbins=long(24./ binsize + .5)
			; we return
			bX=dindgen(nbins) *binsize + binsize/2.
			x0=0d
			iigd=lindgen(npnts)
			end
		keyword_set(degdat): begin
			; xdata is in deg
			binsize=keyword_set(binstep)?binstep:defDegStep
			nbins=long(360./ binsize + .5)
			; we return
			bX=dindgen(nbins) *binsize  + binsize/2.
			x0=0d
			iigd=lindgen(npnts)
			end
	    else:begin
			; xdata is in days
			binsize=keyword_set(binstep)?binstep:defJdStep
			caldat,xdat[0] - astToUtc,mon,day,yr,hr,min,sec
			yymmdd=yr*10000L + mon*100L + day
			jdSt=yymmddtojulday(yymmdd) + astToUtc
			ndays=long(Xmax - jdSt)
			if (jdSt + ndays) lt xMax then ndays++
			nbins=long(ndays/binsize + .5)
			;keep only times after the start
			iigd=where((xdat - xdat[0]) ge 0.,cnt)
			; we return
			x0=jdSt
			bX=dindgen(nbins) *binsize + binsize/2.  +  jdSt
			; for jd bin in minutes
			end
	endcase
	; in case bad dates..
    h=histogram(xdat[iigd]-X0,min=0d,nbins=nbins,binsize=binsize,revers=r)
    bavg=fltarr(nbins)
    bpk=fltarr(nbins)
	yuse=ydat[iigd]
    for i=0L,nbins-1 do begin &$
        if (h[i] ge 1) then begin &$
		   if (h[i] eq 1) then begin
           		bavg[i]=yuse[r[r[i]:r[i+1]-1]] &$
          		 bpk[i]=bavg[i]
		   endif else begin
           		bavg[i]=mean(yuse[r[r[i]:r[i+1]-1]]) &$
           		bpk[i]=max(yuse[r[r[i]:r[i+1]-1]]) &$
		   endelse
        endif &$
    endfor
	return,nbins
end
