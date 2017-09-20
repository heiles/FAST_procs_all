;+
;NAME:
;agctqavg - avg the torques using vel histogram
;SYNTAX: tqavg=agctqavg(b,nbinsVel,axis=axis,minV=minV,maxV=maxV,velbin=velbin,$
;                      cntbin=cntbin)
;ARGS:
;    b[npnt]:  {cbfb} struct returned from agcinpday
;     nbinsVel:  long number of velocity bins to use.
;
;KEYWORDS:
; minV   : float min value for the histogram (default is find min)
; maxV   : float max value for the histogram (default is find max)
; axis   : int   1=az,2=gr,3=ch
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
;for each motor.
;EXAMPLE: ; 
;
; average the azimuth torques.
; npnts=agcinpday(yymmmdd,b)
; 
; tqAvg=agctqavg(b,51,minV=-.5,maxV=.5,axis=1)
;history:
;01feb08 - switched axis 1,2,4 to 1,2,3
;11feb08 - added usespd option
;          computed velenc correctly (needed to add days so interp worked)
;          switch mean to median for histbin averaging to get rid of
;          outliers.
;-
function  agctqavg,b,nbins,minV=minV,maxV=maxV,axis=axis,velbin=velbin,$
			cntbin=cntbin,usespd=usespd
;
	npnts=n_elements(b)
;
;   compute the velocity at the torque  timestamps.
;
	if n_elements(axis) eq 0 then axis=1
	case  (axis) of
	  1: begin
		 tq=transpose(b.fb.tqaz)
	     maxVelA=.5
		 end
	  2: begin
		 tq=transpose(b.fb.tqgr)
	     maxVelA=.05			;; ignore velocities outside of this
		 end
	  3: begin
		 tq=transpose(b.fb.tqch)
	     maxVelA=.05
		 end
	else: message,'axis must be 1 (az), 2 (gr), or 3 (ch)'
	endcase
	iaxis=axis-1 
;
;  compute velocity at torque timestamps
;
	pos1=b.cb.pos[iaxis]
	dpos=pos1 - shift(pos1,1)
	dpos[0]=dpos[1]
	if (keyword_set(usespd)) then begin
		velTq=b.cb.vel[iaxis]
	endif else begin
		tm1=b.cb.time*1D
    	tmTq=b.fb.time*1d
    	tm1[0]=tm1[1]-1.
    	tmTq[0]=tmTq[1]-1.
    	dtm=tm1-shift(tm1,1)
    	dtm[0]=dtm[1]
    	ii=where(dtm lt -1000,cnt)
    	for i=0,cnt-1 do begin &$
        	tm1[ii[i]:*]+=86400D &$
        	tmTq[ii[i]:*]+=86400D &$
    	endfor
    	velEnc=dpos/dtm
    	velTq=interpol(velEnc,tm1+dtm/2.,tmTq)
	endelse
	ii=where(abs(velTq) le maxVelA,cnt)
	if cnt ne n_elements(velTq) then begin
		velTq=velTq[ii]
		tq=tq[ii,*]
	endif
;
;  now bin velTq
;
	if n_elements(minV) eq 0 then minV=min(velTq)
	if n_elements(maxV) eq 0 then maxV=max(velTq)
	binSize=(maxV-minV)/(nbins-1)
	histV=histogram(velTq,nbins=nbins,max=maxV,min=minV,locat=velbin,$
					reverse_ind=revInd)
;
; now average the binned torques
;
	nmot=n_elements(tq[0,*])
	cntbin=fltarr(nbins)
    tqAvg=fltarr(nbins,nmot)
	for ibin=0,nbins-1 do begin
		i1=revInd[ibin] 
    	i2=revInd[ibin+1] 
        cntbin[ibin]=i2-i1 
    	if cntbin[ibin] gt 0 then begin 
        	ii=revInd[i1:i2-1] 
        	for imot=0,nmot-1 do begin 
            	tqAvg[ibin,imot]=median(tq[ii,imot])
    		endfor
    	endif 
	endfor
	return,tqAvg
end
