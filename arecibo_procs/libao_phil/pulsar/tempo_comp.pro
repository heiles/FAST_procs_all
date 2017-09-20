;+
;NAME:
;tempocomp - compute pulse phase and freq from polyco.dat
;SYNTAX: istat=tempocomp(mjd,polyI,retI)
;ARGS:
; Mjd: double   time of interest
; polyI: {}     polyco.dat info from tempoget
;RETURNS:
;istat:	 int   status of computation
;              0 ok
;              < 0  error
;              -1 requested tmmjd comes before polyI times
;              -2 requested tmmjd comes after end of polyI times
;retI: {}      strucuture holding return info
;
;-
function tempo_comp,mjd,polyI,retI

;
; 	find the entry that comes before the requested time
;
	retI={ ind:0  ,$; index into in polyI to used
           dt :0D ,$; req - polyI time in minutes
        phase :0D ,$; computed (cycles??)
        freq  :0D }; computed (hz)
	npolyI=n_elements(polyI)

	ii=where(abs(mjd-polyI.mjd)*1440D le polyI[0].dspan/2D,n) 
;   see if requested time if before start of polyco
	if n eq 0 then return,-1
	i0=ii[0]
;
	dt=(mjd - polyI[i0].mjd)*1440D

	xp=1D
	nc=polyI[I0].ncoef
;;	phase=polyI[i0].rphase + dt * 60D * polyI[i0].rrotfreq
	phase=polyI[i0].coef[nc-1]
	frq=0D
	for i=nc-1,1,-1 do begin
		phase = dt*phase + polyI[i0].coef[i-1]
		frq= frq*dt + i*polyI[i0].coef[i]
	endfor
	phase+=polyI[i0].rphase + dt * 60D * polyI[i0].rrotfreq 
	frq=polyI[i0].rrotfreq + frq/60D
	retI.ind=i0
	retI.dt =dt
	retI.phase =phase
	retI.freq  =frq
	return,0
end
