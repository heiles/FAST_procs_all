;+
; pfcmpstgc - compute sefd,Tsys,gain,and cal stability
;
;SYNTAX: pfcmpstgc,srcinp,srcout,sefd,tsys,gain,gainavg,fracpol,calscl,az,za
;ARGS:
;		srcinp[]:	{pfsrcinfo} hold source info
;		srcout[]:	{pfsrcout}  results by src
;RETURNS:
;		tsys[2,4,npnts] - float holds tsys.. Kelvins
;		gain[2,4,npnts] - float holds tsys.. K/Jy
;		gainAvg[2,4,npts]- float (gaina+gainb)*.5.. store in polA ind 0
;		fracPol[2,4,npts]- float (gaina-gainb)/(gaina+gainb)store in polA
;						    not meaningful for circular recievers..
;	  calscl[2,4,npnts] - float holds tsys.. K/Jy
;            az[npts]   - azimuth positino
;            za[npts]   - azimuth positino
;
;	In the arrays returns, 2 is for the two pol, 4 is up to 4 sbc
;and npts are the number of points measured. Sbc/pol data is valid when
;srcout.t.p[2,4] is non zero
;-
pro pfcmpstgc,srcinp,srcout,sefd,tsys,gain,gainavg,fracpol,calscl,az,za
;
	tsys=srcout.t.off
	sefd=tsys
	gain=srcout.t.src
	fracpol=gain
	for i=0,3 do begin &$
    	tmp1=srcout.flux[i]
    	ind = where(srcout.flux[i] le 0,count)
    	if count gt 0 then begin
        	tmp1[ind]=1.
    	endif
    	gain[0,i,*]=gain[0,i,*]/tmp1 &$
    	gain[1,i,*]=gain[1,i,*]/tmp1 &$
    	if (count gt 0 ) then begin
       	 	gain[0,i,ind]=0.
        	gain[1,i,ind]=0.
    	endif
    	tmp1=reform(gain[0,i,*])
    	tmp2=reform(gain[1,i,*])
    	ind1= where(tmp1 le 0.,count1)
    	ind2= where(tmp2 le 0.,count2)
    	if count1 gt 0 then tmp1[ind1]=.1
    	if count2 gt 0 then tmp2[ind2]=.1
    	sefd[0,i,*]=tsys[0,i,*]/tmp1
    	sefd[1,i,*]=tsys[1,i,*]/tmp2
		fracpol[0,i,*]=(gain[0,i,*]-gain[1,i,*])/(tmp1+tmp2)
    	if count1 gt 0 then begin
				sefd[0,i,ind1]=0.
				fracpol[0,i,ind1]=0.
		endif
    	if count2 gt 0 then begin
				sefd[1,i,ind2]=0.
				fracpol[0,i,ind2]=0.	;if either pol,or polb is gain 0
		endif
		fracpol[1,i,*]=fracpol[0,i,*]
	endfor
	gainavg=gain
	gainavg[0,*,*]=(gain[0,*,*]+gain[1,*,*])*.5
	gainavg[1,*,*]=gainavg[0,*,*]
	calscl=srcout.t.calscl
	za=srcout.h.std.grttd*.0001
	az=srcout.h.std.azttd*.0001
	return
end
