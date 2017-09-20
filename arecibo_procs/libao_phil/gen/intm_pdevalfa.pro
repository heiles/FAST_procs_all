;+
;NAME: 
;intm_pdevalfa - compute alfa/pdev mixer intermods
;SYNTAX:intm_pdevalfa,skycfr,rdrFrqAr,retI,code=code,lo2=lo2,$
;					  maxorder=maxorder,minmaxfrq=minmaxfrq,all=all,$
;ARGS:
; skycfr: float	Mhz sky cfr for alfa band. The first lo will be 
;               250 Mhz above this value.
; rdrFrqAr[n]: float Mhz freq of each radar to check.
;
;KEYWORDS:
;	code: 	int	  0 default compute intermods for the 1st mixer
;                 1 compute intermods for the 2nd mixer
;                    using the lower pdev band (lo1=175 1450 band)
;                 2 compute intermods for the 2nd mixer using the
;                   2nd pdev band (lo1=325 1300 band)
;    lo2:  float  Mhz if supplied then this is the lo2 to use.
;                 It will override the code 1,2 selection.
; maxorder: int   maximum harmonic order to contemplate. Default is
;                 10
;minmaxfrq[2]: float Mhz. min,maximum frequency output from the mixer
;                 to keep.
;                 The default values are:
;                 code
;                   0   100 to 400 since:
;                        the filters in if1 are 0..250 and 0-400.
;                        The bbandFilters are +/= 75 Mhz.
;                   1    -/+ 86 ... since thats the output band
;                   2    -/+ 86 ... since thats the output band
;html        :   if set then output html code to make a table.
;RETURNS:
;retI[n]   : {}  array of structures holding intermod info
;DESCRIPTION:
;	Compute mixer intermods for alfa and pdev. The user specifies:
;1. skycfr sky center frequency used for the alfa band. Normally this is
;   lo1-250. 
;2. rdrFrqAr[n] - array of radar frequencies to test for intermods
; 	By default it computes the intermods in the first mixer. The keyword
; code=1,2 will compute intermods in the 2nd mixers (1=175,2=325).
;
;EXAMPLE:
;	skycfr=1375
;   rdrFrqAr=[1330,1350.]
;   intm_pdevalfa,skycfr,rdrFrqAr,retI
;;  use intm_pdevalfa_pr to print out the results
;   intm_pdevalfa_pr,retI
;-
pro intm_pdevalfa,skycfr,rdrFrqAr,retI,code=code,lo1=lo1,lo2=lo2,$
			maxorder=maxorder,all=all
;
;   some params for intermods
;
;   struct for intermods in first mixer
;
	aIf1={ nlo : 0  ,$ ; order of lo
           nrfi: 0  ,$ ; order of rfi used
           if1V: 0. ,$ ; IF1 location of intermod
		   skyF: 0.  $ ; sky freq for this intermod
		  }
;   struct for intermods in 2nd mixer
	aIf2={ nlo : 0  ,$ ; order of lo
           nrfi: 0  ,$ ; order of rfi used
           if1V: 0. ,$ ; IF1 location of rfi
        baseBnd: 0. ,$ ; baseband value of intermod
		   skyF: fltarr(2)$ ; sky freq for this intermod, +/-
		  }
	maxnum=10
	a={ mixerUsed:   1,$; 1=mixer 1 , 2=mixer2
        rdrSky: 0.  ,$ ; radar sky frequency
		lo1     : 0.,$ ; lo1 used
		if1     : 0.,$ ; if1 freq used for band center 
		lo2     : 0.,$ ; lo2 used
		maxOrder:0  ,$ ; max order used
		numEntry: 0 ,$ ; how many 
		mix1  : replicate(aIf1,maxnum),$
		mix2  : replicate(aIf2,maxnum)}

	if n_elements(all) eq 0 then all=1
	maxorder=(n_elements(maxorder) gt 0)?maxorder:10
	nrdr=n_elements(rdrFrqAr)
	if1=250.
	lo1L=skycfr + if1
	lo2L= 175.					; default 
	codeL=0
	codeL=(n_elements(code) gt 0)?code: codeL
	if codeL gt 0 then begin
		lo2L=(code eq 1)?175.:325.
		lo2L=(n_elements(lo2) gt 0)?lo2:lo2L
	endif
	mixUsed=1
	if codeL eq 0 then begin
	    neg=0
		minFreq=100.
		maxFreq=400.
		lo=lo1L
		mixUsed=1
	    rdrL=rdrFrqAr
	endif else begin
		neg=1
		minFreq=-86.
		maxFreq=86.
		mixUsed=2
		lo2L=(code eq 1)?175.:325.
		lo2L=(n_elements(lo2) gt 0)?lo2:lo2L
		lo=lo2L
;
;		freq of the radar in the first IF
;       This assumes hi side lo1
;
		rdrL=(skyCfr - rdrFrqAr ) + if1
	endelse
	a.mixerused=mixused
	a.lo1      = lo1L
	a.lo2      = lo2L
	a.if1      = if1 
	a.maxOrder =maxorder
	retI=replicate(a,nrdr)
;
; loop processing each radar
;
	for ifrq=0,nrdr-1 do begin
		n=intermods(lo,rdrL[ifrq],minfreq,maxfreq,maxorder,out,nf1,nf2,$
					neg=neg,all=all)
		retI[ifrq].rdrSky=rdrFrqAr[ifrq]
		retI[ifrq].numEntry=0
		j=0
		if mixUsed eq 1 then begin
			lab=string(format='(f7.2,1x,i2)',rdrFrqAr[ifrq],n) 
 			print,lab 
			for i=0,n-1 do begin &$
;				print,i,nf1[i],nf2[i]
;				ignore 1,1 since thats the normal mixing freq
				if (nf2[i] ne 1)  or (nf1[i] ne 1) then begin
					retI[ifrq].mix1[j].nlo=nf1[i]
					retI[ifrq].mix1[j].nrfi=nf2[i]
					retI[ifrq].mix1[j].if1V=out[i]
					retI[ifrq].mix1[j].skyF=skyCfr + (if1-out[i])
    			lab=string(format='(i2,1x,i2,1x,f5.1,1x,f6.1)',$
        			nf1[i],nf2[i],out[i],skyCfr + (if1-out[i]))
                print,'---> ',lab &$
					j++
				endif
  			 endfor &$
		endif else begin
			   lab=string(format='(f6.1,1x,f6.1,1x,f6.1)',$
					lo,rdrL[ifrq],rdrFrqAr[ifrq])
            print,lab 
            for i=0,n-1 do begin &$
				if (nf2[i] ne 1)  or (nf1[i] ne 1) then begin
				  skycfrBand=skyCfr + (if1 - lo)
				  retI[ifrq].mix2[j].nlo=nf1[i]
				  retI[ifrq].mix2[j].nrfi=nf2[i]
				  retI[ifrq].mix2[j].if1V=-(retI[ifrq].rdrSky - retI[ifrq].lo1)
				  retI[ifrq].mix2[j].baseBnd=out[i]
				  retI[ifrq].mix2[j].skyF= [skycfrBand-out[i],skycfrBand+out[i]]
                  lab=string(format='(i2,1x,i2,1x,f5.1,1x,f6.1,1x,f6.1)',$
                    nf1[i],nf2[i],out[i],skycfrBand-out[i],skycfrBand+out[i])
                print,'---> ',lab 
				j++
				endif
             endfor 
		endelse
		retI[ifrq].numentry=j
	endfor
	return
end
