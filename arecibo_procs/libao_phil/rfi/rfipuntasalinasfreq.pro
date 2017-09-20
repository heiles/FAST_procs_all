;+
;NAME:
;rfipuntasalinasfreq - return punta salinas radar freq
;SYNTAX:rfipuntasalinasfreq,rinfo,old=old
;ARGS: none
;KEYWORDS:
; old :      if set then return the info prior to apr15
;
;
;RETURNS:
; rinfo[n]: struct array holding n channels
;                   each channel has 4/2  freq (!old/old)
;
;DESCRIPTION:
;   Return frequency info for the punta salinas radar
;rinfo[n] is an array with n channels. A channel is the set of 
;frequencies that can be transmitted in 1 ipp 
;
; rfinfo[0].channum  = channel number 1...n
; rfinfo[0].name     = " " or  'modeA', 'modeB','modeC' 
;                      "notx" if not allowed to xmit here
; rfinfo[0].cfr      =  freq center  xmit +/- 7.5 from here
; rfinfo[0].freq[m]  =  two xmit freq
; rfinfo[0].bwlist   = [.625,1.25] long,shortrange bandwidths
;
; 	prior to apr15 there were 20 2 freq chan
;   apr15 -> 100 2 freq channels.. mode A, b ,c changed
;
;Example
;1. flag the puntasalins freq in an corrlator plot:
;   @corinit  (or @wasinit)
;   @rfininit
;   .. input correlator data
;   rfipuntasalinasfreq,rdrinfo
;   fl=reform(rdrinfo.freq,2*20)
;   corplot,b,fl=fl,lnsfl=1
;2. flag each radar chan in a different color:
;   x=....
;   y=...
;   plot,x,y
;	nchan=20
;   for i=0,nchan-1 do flag,rdrinfo[i].freq,col=colph[(i mod 11) + 1],linest=2
;   
;-
pro rfipuntasalinasfreq,rinfo,old=old 

	a={ channum : 1,$
       	name    : " ",$
		cfr     : 0. ,$
       	freq    :fltarr(2),$
       	bwlist  :[.625,1.25]$
    }   
	nchan=(keyword_set(old))?20:100
	rinfo=replicate(a,nchan)
	rinfo.channum=lindgen(nchan)+1
	if (keyword_set(old)) then begin
		chanstep=8.96
		chan1=1222.32
		rinfo.cfr=findgen(nchan)*chanstep + chan1
		freqSpace=15.
		rinfo.freq[0]=cenAr - freqSpace/2.
		rinfo.freq[1]=cenAr + freqSpace/2.
		ii=[2,3]
		rinfo[ii].name='modeA'
		ii=[5,6]
		rinfo[ii].name='modeB'
		ii=[9,10]
		rinfo[ii].name='modeC'
		return
	endif else begin
	    rinfo.name='notx'
		rinfo[0:14].cfr =findgen(15) + 1223.
		rinfo[15:85].cfr=findgen(85-15+1)*2 + 1239
        rinfo[86:99].cfr=findgen(99-86+1)   + 1380.
        freqSpace=15.
        rinfo.freq[0]=rinfo.cfr  - freqSpace/2.
        rinfo.freq[1]=rinfo.cfr  + freqSpace/2.
;       ok to tx freq
		ii=14-1
        rinfo[ii].name=''
		ii=lindgen(54-40+1) + 39
        rinfo[ii].name=''
		ii=lindgen(87-78+1) + 77
        rinfo[ii].name=''
;
;		set mode A,B,C
		ii=14 - 1
        rinfo[ii].name='modeA modeB'
        ii=40 - 1
        rinfo[ii].name='modeA modeC'
        ii=54 - 1
        rinfo[ii].name='modeB'
        ii=52 - 1
        rinfo[ii].name='modeC'
        return
	endelse
end
