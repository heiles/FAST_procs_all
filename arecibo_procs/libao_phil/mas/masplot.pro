;+
;NAME:
;masplot - plot mas spectra
;SYNTAX: masplot,b,freq=freq ,over=over,pollist=pollist,norm=normRange,median=median,$
;                  off=off,chn=chn,smo=smo,retvel=retvel,restFreq=restFreq,velCrdsys=velCrdSys,$
;				   mfreq=mfreq,colar=colar,edgefr=edgefr
;ARGS:
; b[n]: {b}   mas structure from masget to plot
;KEYWORDS:
;freq[n]: float  if provided then use this as the x axis
;   over:        if set then overplot spectra
;pollist: long   pols to plot: 12 = polA,B, -1--> all pols available
;norm[2]: float  normalize the spectra. If two element array then is is the range
;                of frequency bins to use for the mean (cnt from 0). If a single
;                element or /norm then use all the bins. If keyword median set then
;                use mean rather than mean
;median:         if set then use median rather than mean when normalizing
;    off: float  If multiple spectra then increment each spectra by off.   
;   chn :        if set then plot vs channel number (count from 0)
;   smo : int    smooth by this many channels
; ** to plot versus velocity
; retvel:        if set (/retvel) then plot versus velocity (see masfreq())
; restFreq: float Mhz. if /retvel then use restFreq as the restFreq when 
;                computing the velocity. The default is to use the hdr restFreq.
; velCrdSys:string If supplied then use this as the velocity coord system. The
;                default is to use what is in the header. The values are:
;                "T":topcentric,"G":geocentric,"B":Barycenter,"L",lsr
;
;mfreq  :        multiple frequencies.if set then the b[n] array has different
;                 freqs  (single pixel).
;                It we replot a new x axis each time. User needs to
;                setup the hor value ahead of time.
;                Note: if you also select /retvel, you'd better supply
;                      restFreq.
;colar[4]: int   color indices for pol1,2,3,4.1-black,2-red,3-green,4-blue
;                5-yell w..
;edgefr  : float if provided, the fraction of band on each edge to not plot
;DESCRIPTION:
;	Plot the various spectr in b. If b.accum > 0 the scale by one over this
;when plotting (but don't change the data).
;-
pro masplot,b,freq=freq,_extra=e,over=over,pollist=pollist,norm=norm,$
            chn=chn,off=pltoff,smo=smo,mfreq=mfreq,colar=colar,median=median,$
			retvel=retvel,restfreq=restfreq,velcrdsys=velcrdsys,edgefr=edgefr
;
        common colph,decomposedph,colph

	useMedian=keyword_set(median)
	colArL=(n_elements(colAr) gt 0)?colAr:[2,3,4,5]
	n=n_elements(colarL)
	colarL=[colarL,lonarr(3)+colarL[n-1]]
    if (keyword_set(norm)) then begin
        useNorm=1
        normRange=(n_elements(norm) eq 2)
    endif else begin
        useNorm=0 
    endelse
	dosmo=n_elements(smo) eq 1
	if dosmo then begin
		if smo gt 1 then begin
			tosmo=smo
		endif else begin
		    dosmo=0
		endelse
	endif
    if n_elements(pltoff) eq 0 then pltoff=0.
    nrow =n_elements(b)
    ndump=b[0].ndump
    nchan =b[0].nchan
    nsbc =b[0].npol
	if n_elements(edgefr) gt 0 then begin
		i0=long(nchan*edgefr[0] + .5)
		ii=lindgen(nchan - 2*i0) + i0
	endif else begin
		ii=lindgen(nchan)
	endelse
    pltsbc=intarr(nsbc)   ; 0--> no plot,1--> plot
    if (n_elements(pollist) ne 0) && (pollist ne -1)  then begin
       itemp=long(pollist)
       while itemp gt 0 do begin
           ival=itemp mod 10
           if ival gt 0 then pltsbc[ival-1]=1
           itemp=itemp/10L
       endwhile
    endif else begin
        for i=0,nsbc-1 do pltsbc[i]=1
    endelse
;
	usechn=keyword_set(chn)
	usefreq=n_elements(freq) gt 0
	usemfreq=keyword_set(mfreq)
    if (usechn) then begin
        x=findgen(nchan)
    endif else begin
        if (usefreq gt 0) then begin
            x=freq
        endif else begin
            x=masfreq(b[0].h,retvel=retvel,restfreq=restfreq,velcrdsys=velcrdsys)
        endelse
    endelse
    nx=n_elements(x)
    doover=keyword_set(over)
    autoscale=((!y.range[0] eq 0.) and (!y.range[1] eq 0.))
    if autoScale and (not doover) then begin
        if useNorm then begin
            ymin=0
            ymax=2.             ; too much trouble to figure it out..
        endif else begin
        ymin=min(b.d,max=ymax)
        endelse
        ver,ymin,ymax
    endif else begin
        ymin=!y.range[0]
        ymax=!y.range[1]
    endelse 

    if nrow*ndump eq 1 then begin
        if not doover then $
            plot,[x[0],x[nx-1]],[ymin,ymax],_extra=e,/nodata
        for isbc=0,nsbc-1 do begin
            if (pltsbc[isbc]) then begin
                ploffcum=0.
                if (useNorm) then begin
                    if nsbc gt 1 then begin
					    if useMedian then begin
                        	scale=normRange?median(b.d[norm[0]:norm[1],isbc]) : $
                                    median(b.d[*,isbc])
						endif else begin
                        	scale=normRange?mean(b.d[norm[0]:norm[1],isbc]) : $
                                    mean(b.d[*,isbc])
						endelse
						if dosmo then begin
                        oplot,x[ii],smooth(b.d[ii,isbc],tosmo)/scale ,$
                                col=colph[colarL[isbc]],_extra=e
						endif else begin
                        oplot,x[ii],b.d[ii,isbc]/scale ,$
                                col=colph[colarL[isbc]],_extra=e
						endelse
                    endif else begin
					    if useMedian then begin
                       		scale=normRange?median(b.d[norm[0]:norm[1]]) : $
                                    median(b.d)
						endif else begin
                        	scale=normRange?mean(b.d[norm[0]:norm[1]]) : $
                                    mean(b.d)
						endelse
						if dosmo then begin
                          oplot,x[ii],smooth(b.d[ii],tosmo)/scale ,col=colph[colarL[isbc]],_extra=e
						endif else begin
                          oplot,x[ii],b.d[ii]/scale ,col=colph[colarL[isbc]],_extra=e
						endelse
                    endelse
                endif else begin
					scale=(b.accum gt 0)?1./b.accum:1.	
                    if nsbc gt 1 then begin
						if dosmo then begin
                        	oplot,x[ii],smooth(b.d[ii,isbc],tosmo)*scale,col=colph[colarL[isbc]],_extra=e
					    endif else begin
                        	oplot,x[ii],b.d[ii,isbc]*scale,col=colph[colarL[isbc]],_extra=e
						endelse
                    endif else begin
						if dosmo then begin
                        	oplot,x[ii],smooth(b.d[ii],tosmo)*scale,col=colph[colarL[isbc]],_extra=e
						endif else begin
                        	oplot,x[ii],b.d[ii]*scale,col=colph[colarL[isbc]],_extra=e
						endelse
                    endelse
                endelse
            endif
        endfor  
;     nrow *ndump  > 1
    endif else begin
        if not doover then $
            plot,x[[0,nx-1]],[ymin,ymax],_extra=e,/nodata
			if usemfreq then begin
				xar=fltarr(nx,nrow)
				xar[*,0]=x
			endif
        for isbc=0,nsbc-1 do begin
            if (pltsbc[isbc]) then begin
               pltoffcum=0.
               for irec=0,nrow-1 do begin
				   if (usemfreq) then begin
						x=(xar[0,irec] ne 0.)?xar[*,irec]:masfreq(b[irec].h)
				   endif
                   if ndump eq 1 then begin
                     if (useNorm) then begin
                       if nsbc gt 1 then begin
							if useMedian then begin
                            	scale=normRange?median(b[irec].d[norm[0]:norm[1],isbc]):$
                                   median(b[irec].d[*,isbc])
							endif else begin
                            	scale=normRange?mean(b[irec].d[norm[0]:norm[1],isbc]):$
                                   mean(b[irec].d[*,isbc])
							endelse
                       endif else begin 
							if useMedian then begin
                            	scale=normRange?median(b[irec].d[norm[0]:norm[1]]):$
                                   median(b[irec].d)
							endif else begin
                            	scale=normRange?mean(b[irec].d[norm[0]:norm[1]]):$
                                   mean(b[irec].d)
							endelse
                       endelse
                       if pltoffcum ne 0. then begin
                            if nsbc gt 1 then begin
								if dosmo then begin
                                oplot,x[ii],smooth(b[irec].d[ii,isbc],tosmo)/scale + pltoffcum,$
                                col=colph[colarL[isbc]],_extra=e
								endif else begin
                                oplot,x[ii],b[irec].d[ii,isbc]/scale + pltoffcum,$
                                col=colph[colarL[isbc]],_extra=e
								endelse
                            endif else begin
								if dosmo then begin
                                oplot,x[ii],smooth(b[irec].d[ii],tosmo)/scale + pltoffcum,$
                                col=colph[colarL[isbc]],_extra=e
								endif else begin
                                oplot,x[ii],b[irec].d[ii]/scale + pltoffcum,$
                                col=colph[colarL[isbc]],_extra=e
								endelse
                            endelse
                       endif else begin
                            if (nsbc gt 1) then begin
								if dosmo then begin
                                oplot,x[ii],smooth(b[irec].d[ii,isbc],tosmo)/scale,$
                                col=colph[colarL[isbc]],_extra=e
 								endif else begin
                                oplot,x[ii],b[irec].d[ii,isbc]/scale,$
                                col=colph[colarL[isbc]],_extra=e
								endelse
                            endif else begin
								if dosmo then begin
                                oplot,x[ii],smooth(b[irec].d[ii],tosmo)/scale,col=colph[colarL[isbc]],_extra=e
								endif else begin
                                oplot,x[ii],b[irec].d[ii]/scale,col=colph[colarL[isbc]],_extra=e
								endelse
                            endelse
                       endelse
;                    not norm, 
                     endif else  begin
					   scale=(b[irec].accum gt 0)? 1./b[irec].accum:1.
                       if pltoffcum ne 0. then begin
                         if nsbc gt 1 then begin
							if dosmo then begin
                            oplot,x[ii],smooth(b[irec].d[ii,isbc],tosmo)*scale+pltoffcum,col=colph[colarL[isbc]],_extra=e
							endif else begin
                            oplot,x[ii],b[irec].d[ii,isbc]*scale+pltoffcum,col=colph[colarL[isbc]],_extra=e
							endelse
                         endif else begin
							if dosmo then begin
                            oplot,x[ii],smooth(b[irec].d[ii],tosmo)*scale+pltoffcum,col=colph[colarL[isbc]],_extra=e
							endif else begin
                            oplot,x[ii],b[irec].d[ii]*scale+pltoffcum,col=colph[colarL[isbc]],_extra=e
							endelse
                         endelse
                       endif else begin
                         if nsbc gt 1 then begin
							if dosmo then begin
                            oplot,x[ii],smooth(b[irec].d[ii,isbc],tosmo)*scale,col=colph[colarL[isbc]],_extra=e
							endif else begin
                            oplot,x[ii],b[irec].d[ii,isbc]*scale,col=colph[colarL[isbc]],_extra=e
							endelse
                         endif else begin
							if dosmo then begin
                            oplot,x[ii],smooth(b[irec].d[ii],tosmo)*scale,col=colph[colarL[isbc]],_extra=e
							endif else begin
                            oplot,x[ii],b[irec].d[ii]*scale,col=colph[colarL[isbc]],_extra=e
							endelse
                         endelse
                       endelse
                     endelse
                     pltoffcum+=pltoff
;                  ndump gt 1
                   endif else begin
				    scale=(b[irec].accum gt 0)? 1./b[irec].accum:1.
                    for idump=0,ndump-1 do begin
                        if (useNorm) then begin
                           if nsbc gt 1 then begin
							 if useMedian then begin
                             	scale=normRange?$
                               		median(b[irec].d[norm[0]:norm[1],isbc,idump]) : $
                                	median(b[irec].d[*,isbc,idump])
							 endif else begin
                             	scale=normRange?$
                               		mean(b[irec].d[norm[0]:norm[1],isbc,idump]) : $
                                	mean(b[irec].d[*,isbc,idump])
							 endelse
                              if pltoffcum ne 0. then begin
							    if dosmo then begin
                                oplot,x[ii],smooth(b[irec].d[ii,isbc,idump],tosmo)/scale+pltoffcum,$
                                    col=colph[colarL[isbc]],_extra=e
							    endif else begin
                                oplot,x[ii],b[irec].d[ii,isbc,idump]/scale+pltoffcum,$
                                    col=colph[colarL[isbc]],_extra=e
							    endelse
                              endif else begin
							    if dosmo then begin
                                oplot,x[ii],smooth(b[irec].d[ii,isbc,idump],tosmo)/scale,$
                                    col=colph[colarL[isbc]],_extra=e
							    endif else begin
                                oplot,x[ii],b[irec].d[ii,isbc,idump]/scale,$
                                    col=colph[colarL[isbc]],_extra=e
							    endelse
                              endelse
                           endif else begin
							 if useMedian then begin
                             	scale=normRange?$
                                	median(b[irec].d[norm[0]:norm[1],idump]) : $
                               		median(b[irec].d[*,idump])
							 endif else begin
                             	scale=normRange?$
                                	mean(b[irec].d[norm[0]:norm[1],idump]) : $
                               		mean(b[irec].d[*,idump])
							 endelse
                              if pltoffcum ne 0. then begin
							    if dosmo then begin
                                oplot,x[ii],smooth(b[irec].d[ii,idump],tosmo)/scale+pltoffcum,$
                                    col=colph[colarL[isbc]],_extra=e
							    endif else begin
                                oplot,x[ii],b[irec].d[ii,idump]/scale+pltoffcum,$
                                    col=colph[colarL[isbc]],_extra=e
							    endelse
                              endif else begin
							    if dosmo then begin
                                oplot,x[ii],smooth(b[irec].d[ii,idump],tosmo)/scale,$
                                    col=colph[colarL[isbc]],_extra=e
							    endif else begin
                                oplot,x[ii],b[irec].d[ii,idump]/scale,$
                                    col=colph[colarL[isbc]],_extra=e
							    endelse
                              endelse
                           endelse
                        endif else  begin
                            if nsbc gt 1 then begin
                              if pltoffcum ne 0. then begin
							    if dosmo then begin
                                oplot,x[ii],smooth(b[irec].d[ii,isbc,idump],tosmo)*scale+pltoffcum,$
                                        col=colph[colarL[isbc]],_extra=e
							    endif else begin
                                oplot,x[ii],b[irec].d[ii,isbc,idump]*scale+pltoffcum,$
                                        col=colph[colarL[isbc]],_extra=e
							    endelse
                              endif else begin
							    if dosmo then begin
                                oplot,x[ii],smooth(b[irec].d[ii,isbc,idump],tosmo)*scale,col=colph[colarL[isbc]],$
                                    _extra=e
							    endif else begin
                                oplot,x[ii],b[irec].d[ii,isbc,idump]*scale,col=colph[colarL[isbc]],$
                                    _extra=e
							    endelse
                              endelse
                            endif else begin
                              if pltoffcum ne 0. then begin
							    if dosmo then begin
                                oplot,x[ii],smooth(b[irec].d[ii,idump],tosmo)*scale+pltoffcum,$
                                        col=colph[colarL[isbc]],_extra=e
							    endif else begin
                                oplot,x[ii],b[irec].d[ii,idump]*scale+pltoffcum,$
                                        col=colph[colarL[isbc]],_extra=e
							    endelse
                              endif else begin
							    if dosmo then begin
                                oplot,x[ii],smooth(b[irec].d[ii,idump],tosmo)*scale,col=colph[colarL[isbc]],$
                                    _extra=e
							    endif else begin
                                oplot,x[ii],b[irec].d[ii,idump]*scale,col=colph[colarL[isbc]],$
                                    _extra=e
							    endelse
                              endelse
                            endelse
                        endelse
                        pltoffcum+=pltoff
                    endfor
                   endelse
            endfor
          endif 
        endfor
    end
    return
end
