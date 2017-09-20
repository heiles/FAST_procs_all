;+
;NAME:
;agcplttqavg - avg then plot the torques
;SYNTAX: agcplttqavg,b,nbinsVel,axis=axis,minV=minV,maxV=maxV,velbin=velbin,$
;                      cntbin=cntbin,tqavg=tqavg,vtq=vtq,usespd=usespd,fl=fl)
;ARGS:
;    b[npnt]:  {cbfb} struct returned from agcinpday
;     nbinsVel:  long number of velocity bins to use.
;
;KEYWORDS:
; minV   : float min value for the histogram (default is find min)
; maxV   : float max value for the histogram (default is find max)
; axis   : int   1=az,2=gr,3=ch
; vtq[2] : float if specified, then the vertical scale for the torque
;usespd  :       if set use motor speed readout rather than 
;                encoder to compute the velocity.
;fl      : []    flag  these locations in plots
;
;RETURNS:
; tqavg[nbins,nmot]: float averaged data
; velbin[nbin]: float array holding the velocity bins.
; cntbin[nbin]: float number of counts we had in each velocity bin
;
;DESCRIPTION:
;   Compute the velocity from the encoder positions and then make
;a histogram of the velocity. For each motor find all the points that fall
;in each velocity bin and average them. Return a binned avg of the torques
;for each motor. plot the data and return the results.
;EXAMPLE: ;
;
; average the azimuth torques.
; npnts=agcinpday(yymmmdd,b)
;
; agcplttqavg(b,51,minV=-.5,maxV=.5,axis=1,tqavg=tqavg,velbin=velbin,$
;                 cntbin=cntbin)
;-
;
pro agcplttqavg,b,nbinsVel,axis=axis,minV=minV,maxV=maxV,velbin=velbin,$
                cntbin=cntbin,tqavg=tqavg,title=title,vtq=vtq,usespd=usespd,$
				fl=fl
	    common colph,decomposedph,colph
	
	if n_elements(axis) eq 0 then axis=1
	tqAvg=agctqavg(B,nbinsVel,minv=minV,maxv=maxV,axis=axis,velbin=velbin,$
				   cntbin=cntbin,usespd=usespd)
;
	if n_elements(title) eq 0 then title=''
	usefl=n_elements(fl) gt 0

	if axis eq 3 then begin
		!p.multi=[0,1,2]
	endif else begin
		!p.multi=[0,1,4]
	endelse
    iaxis=axis-1
	cs=1.8
	if n_elements(vtq) eq 2 then begin
		ver,vtq[0],vtq[1]
	endif else begin
		ver,0,max(tqAvg)*1.02
	endelse
	hor,minV,maxV
	sym=10
	colar=lindgen(8)+1
	labaxis=['az','gr','ch']
	ls=2
	colfl=2

	stripsxy,velbin,tqAvg,0,0,/step,psym=sym,charsize=cs,col=colar,$
		xtitle='Vel deg/sec',ytitle='tq [Ft-lbs]',$
	    title=title + $
     ' avg torque ' + labaxis[iaxis] + ' vs velocity (all motors)'
	agclabmot,labaxis[iaxis],ln=1.5
	if usefl then flag,fl,linestyle=ls,col=colph[colfl]
	if axis ne 4 then begin
		stripsxy,velbin,tqAvg[*,0:3],0,0,/step,psym=sym,col=colar[0:3],$
			charsize=cs,xtitle='Vel deg/sec',ytitle='tq [Ft-lbs]',$
	    	title= ' avg torques vs velocity (group 1)'
		agclabmot,labaxis[iaxis],grp=1,ln=9,xpos1=.12
		if usefl then flag,fl,linestyle=ls,col=colph[colfl]
		plot,velbin,tqAvg[*,4],/nodat,charsize=cs,$$
			xtitle='Vel deg/sec',ytitle='tq [Ft-lbs]',$
	    	title= ' avg torques vs velocity (group 2)'

		stripsxy,velbin,tqAvg[*,4:*],0,0,/step,psym=sym,col=colar[4:*],/over
		agclabmot,labaxis[iaxis],grp=2,ln=15,xpos1=.12
		if usefl then flag,fl,linestyle=ls,col=colph[colfl]
	endif
	ver,1,max(cntbin)*2. 
	plot,velbin,cntbin,psym=sym,charsize=cs,/ylog,$
		xtitle='Vel deg/sec',ytitle='counts per bin',$
	    title= 'Histogram of velocity'
	if usefl then flag,fl,linestyle=ls,col=colph[colfl]

	return
end
