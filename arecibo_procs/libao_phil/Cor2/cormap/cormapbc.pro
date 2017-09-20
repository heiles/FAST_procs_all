;+
;NAME:
;cormapbc   - band pass correct a map 1 strip at a time
; 
;SYNTAX: mbpc=cormapbc(m,numbpedg,pol=pol,edge=edge,$
;             m3sections=m3sections,m3type=m3type,$
;             tsys=tsys,degfit=degfit,cumfilter=cumfilter,$
;             mask=mask,fractmask=fractmask,coef0=coef0,coef1=coef1 
;
;ARGS:
;
; m[2,pntstrip,numstrips] : {}  input map array.
;
;numBpEdg : int.  This determins the type of bandpass correction to use:
;           ge 0. numBpEdg is the number of bandpasses on each edge of 
;                 a strip to average together and use for the bandpass
;                 correction (0 is the same as 1). 
;                 The edge keyword can choose just the left or right edge.
;              -1 The bandpass correction is computed for each strip by 
;                 doing a linear fit for each channel over the samples of
;                 a strip. Outliers are thrown out. The keyword edge will 
;                 be ignored.
;              -2 Use the entire strip to compute the bandpass by averaging
;                 over the strip.
;              -3 Use the entire strip to compute the bandpass by computing
;                 the median by freq chn along the strip. The m3sections 
;                 (Minus 3) and m3type can be used to modify how the
;                 median is computed.
;              
;KEYWORDS:
;
;pol       :  int  1 or 2. if provided, then only process this pol
;
;edge[]    :  int  If numBpEdg is ge 0 then edge can be used to determine 
;                  which side of the strips the bandpass correction comes from 
;                  (by default numBpEdg bandpasses from both edges are used).
;				   The coding for edge is:
;                  -1  use numbpedg on the starting edge of each strip
;                      for the bandpass correction.
;                   1  use numbpedg on the ending edge of each strip
;                      for the bandpass correction.
;                   0  use numbpedge from both edges.
;				   If edge is a single number (not an array) then the specified
;			       side of the strip will be used for all strips of the map.
;				   If edge is an array then it must be dimensioned to be the
;				   same length as the number of strips in the map. Each 
;				   element of edge[] then determines the side to use for
;                  that strip. The number of bandpasses used is still 
;				   determined by numbpedg.
;
;m3sections: int   When numbpedg is set to -3, the bandpass correction is
;                  computed using the median by channel. Normally this
;                  is done over the entire strip. The m3sections keyword
;				   allows you to break the strip up into m3sections and then 
;				   compute the median over each of these sections separately.
;				   By default the minimum (for each channel) of each of these 
;				   sections is then used for the bandpass correction.
;				   m3type lets you change how the bandpass value is selected 
;				   from the m3 sections.
;
;m3type    : int   The keyword m3sections creates m3sections bandpasses. By
;                  default the minimum (by channel) of the m3sections bandpasses
;                  is returned as the bandpass correction. m3type lets you 
;                  change this to:
;                  0 - The bandpass is the minimum of the m3section bandpasses.
;                  1 - The bandpass is the maximum of the m3section bandpasses.
;                  2 - The bandpass is the average of the m3section bandpasses.
;                  3 - The bandpass is the median  of the m3section bandpasses.
;
;      tsys: int   This keyword determines how to remove the system temperature
;                  from each spectra. The values are:
;                  0 -(default) compute tsys from bpc spectra. 
;                      linearly interpolate between each edge if two edges.
;                      if a single edge, use that for the entire strip
;                  1 - linearly interpolate the total power using all of the 
;                      spectra of the strip. If numbpedg = -1 then
;                      the average of the linear fits by channel is used.
;                  2 - compute the mean Tsys for each spectra of the strip and 
;                      remove it.
;                  3 - do not remove tsys
;                  4 - compute the median Tsys for each spectra of the strip
;                      and remove it.
;                  5 - compute Tsys with a robust average over each spectra and
;                      then remove it.
;
;				   The mask= or edgefract= keyword can limit the number of 
;			  	   chnannels used to compute tsys. 
;
;degfit    : int   if tsys eq 1 then this is the deg of the polynomial fit to
;                  use. The default is 1.
;
;cumfilter :       If tsys eq 1 (and bpnumedg != -1) and this keyword is
;                  set, then  a cumfilter is run on the Tsys values before
;                  doing the linear fit. This will normally exlude
;                  the continuum sources from the fit. see cumfilter (under
;                  general software)
;
;mask[nchn]: int   mask to use for removing Tsys. If provided then it 
;                  should have the same number of channels as m[0,0].d
;                  It will use the non-zero channels to compute and remove
;                  Tsys (depending on keyword tsys). The routine will
;                  always use all of the channels when doing the bandpass
;                  correction (since the cal was averaged over all 
;                  channels). Note.. to use this polA and polB must
;                  have the same number of channels.
;
;fractmask : float fraction of channels on each side of spectra to ignore
;                  when computing tsys for tsys removal. Use this instead
;                  of mask= keyword. If you have 1024 channels then
;                  fractmask=.05 would ignore 51 channels from each side.
; 
;RETURNS:
;     mbpc[2,pntstrip,numstrips] : map after bandpass correction
;     coef0[nlags,nstrips]: float bandpass fit by channel for each strip.
;                           This is the constant.
;     coef1[nlags,nstrips]: float bandpass fit by channel for each strip.
;                           This is the linear term (-nsmp/2,nsmp/2)
;
;DESCRIPTION:
;
;   The routine will bandpass correct a map 1 strip at a time and then 
;subtract off the system temperature.
;
;BANDPASS CORRECTION:
;
;   The bandpass correction is determined by the numbpedge parameter. Its
;values are:
;
;numbpedge ge 0. 
;
;   use a set of bandpasses from 1 or both edges of each strip for the
;   bandpass correction. numbpedge specifies the number of bandpasses to
;   average. By default numbpedge spectra from each edge are used. If the
;   edge keyword  is -1 or +1 then only the left or right edge is used for
;   the entire map.
;   If edge[nstrips] is an array then you can choose a different edge
;   for each strip. 
;
;numbpedge=-1
;
;   The bandpass correction is computed by doing a linear fit to each channel
;   (over the samples in a strip). The fitting iterates throwing out any 
;   outliers over 2 sigma. The x value for the fit is symmetric about 0 so
;   the constant term of the fit is used for the bandpass corretion value
;   at each channel.
;
;numbpedge = -2
;
;   The average bandpass over each strip is used for the bandpass correction.
;    
;numbpedge = -3
;
;   The median bandpass over each strip is used for the bandpass correction.
;       The m3section keyword lets you break the strip up into m3sections. The
;   median for each section is computed and then the minimum (by default) of
;   the m3sections bandpasses is used for the bandpass correction.
;       The m3type keyword lets you change how the value from the m3sections
;   bandpasses is selected for each channel. It can be max,min,average, or
;   median.
;
;SYSTEM TEMPERATURE REMOVAL:
;
;       The removal of the system temperature is determined by the TSYS
;   keyword. The keywords MASK= and FRACTMASK= can be used to limit
;   the channels that are used to compute tsys (in case there is
;   interference). The values for TSYS are:
;
;TSYS=0
;   For each strip compute Tsys from the spectra used for the bandpass 
;   correction. If bandpasses from both edges are used then linearly
;   interpolate the tsys from the 2 sides across the entire strip.
;
;TSYS=1
;   Compute tsys for each spectra by taking the average of each spectra. Then
;   do a linear fit of these values along the strip (the degfit keyword
;   lets you change the order of the fit). From each spectra remove the fitted
;   value.
;		If numbpedge was set to -1 then the linear fits by channel have already 
;   been done. In this case, the average (across the channels) of the fits is
;   used. 
;
;TSYS=2
;   Compute Tsys for each spectra and remove it from each spectra. This is
;   handy if you want to get rid of the continuum sources.
;
;TSYS=4
;   Same as Tsys=2 but use the median rather than the mean.
;
;TSYS=5
;   Same as Tsys=2 but use a robust average. All points 3 sigma away from
;   the mean are excluded, and then the mean is recomputed. Continue looping
;   till no points are thrown out.
;
;TSYS=3
;   Do not remove Tsys.
;
;Take a look at: <A HREF="http://www.naic.edu/~phil/obstechniques/cormapbc_tsysremoval.html">Comparing mean,median,robustAvg</A> for a comparison of tsys=2,4,5.
;
;For each strip the routine will:
;  1. Average the bandpasses for the bandpass correction.
;  2. For the i'th spectra in each strip compute:
;      spectra[i]=(spectra[i]/normalized(avgBP) -Tsys[i]
;      where normalized(avbBp) is the normalized average bandpass computed
;      in step 1. Tsys[i] is the system temperature computed from  the
;      keywords tsys= etc..If mask= or fracmask= is set then avgBP and
;      Tsys are computed over the specified channels.
;
;EXAMPLES:
;
;1. Bandpass correct using 3 channels on each side of the map. Remove tsys
;   using all spectral channels interpolating between the 3 averaged bandpasses
;   on each edge.
;   m=cormapbc(m,3)
;
;2. Bandpass correct using only the starting edge. When computing Tsys
;   ignore 5% of the channels on each edge.
;   m=cormapbc(m,3,edge=-1,fractmask=.05)
;
;3. Suppose you want to make a continuum map..
;
;   Bandpass correct linearly interpolating along each channel. Remove
;   tsys by using the average (along channels) of these channel fits.
;   Do not use 5% of the channels on each edge of the spectra. 
;   m=cormapbc(m,-1,fractmask=.05,tsys=1)
;
;4. You want to remove the continuum sources (ie. you are looking for galaxies).
;   Use the linear fit by channel to compute the bandpass correction.
;   Remove Tsys by substracting the median of each spectrum. Ignore 5%
;   of the channels on each edge of the spectra when computing tsys.
;
;   m=cormapbc(m,-1,fractmask=.05,tsys=4)
;
;5. Same as 4, but you get a negative image of some galaxies in your strip.
;   This is probably because continuum sources in the bandpass correction
;   are cutting down on the number of unbiased samples for the median. Try
;   breaking the strip up into 3 sections, computing the median of each
;		Then try removing Tsys using a robust average over each spectra
;   (ignoring 5% of the channels on each edge).
;
;   m=cormapbc(m,-3,fractmask=.05,tsys=5,m3sections=3)
;
;
;RECENT HISTORY:
;   21nov04 - added m3sections,m3type keywords.
;   07jul04 - added tsys=5. use avgrobbychan for tsys removal.
;   06jul04 - added tsys=4. uses median rather than mean for Tsys removal.
;   07feb04 - bandpass by channel, after fit, recheck all the 
;             residuals for being with nsig, not just the current good ones.
;             Bug in the residual compare, was not using abs().
;   14jan04 - allstrip -> numbpedg=-2
;   07jan04 - added bcbychan option. does a linear fit by chan along
;             each strip to determine the bandpass.
;   03sep03 - if mask supplied (or edge fract) then the normalizatino
;             of the bandpass for bandpass correction should be
;             over the mask, and not the entire bandpass. Before it was
;             normalizing over the entire bandpass, dividing, and then
;             using the mask to compute the tsys subtraction.
;   27jan03 - added cumfilter keyword
;   27jan03 - for tsys removal if tsys=1 then allow option to 
;             iterate throwing out pnts above 3sigma
;-
;   26jan03 - added tsys=3 option to not remove tsys (for testing)
;   ???     - added tsys=2 option to remove tsys by spectra
;   09dec01 - Routine now removes average system temperature.
;             Allow edge keyword to be an array.
;             Removed /normal keyword..
;   01nov01.. fixed bug in bpavgI computation if > 1 bandpass on edge
; (thanks to bon-chul koo for pointing it out).
; from:
; bpavgI=(total(m[polI,0:numbpedg-1,i].d,3) + $
;               total(m[polI,nsmp-numbpedg:nsmp-1,i].d,2)/(numbpedg*2.))
; to:
; bpavgI=(total(m[polI,0:numbpedg-1,i].d,3) + $
;               total(m[polI,nsmp-numbpedg:nsmp-1,i].d,3))/(numbpedg*2.)
;
; The bandpass correction would have been
; numbpedge*spectraLeft + spectraRight/(numbpedge*2)
; so the band pass would have been too large by a factor of about numbpedge.
;
;
function cormapbc,m,numbpedg,pol=pol,edge=edge,tsys=tsys,degfit=degfit,$
                  mask=mask,fractmask=fractmask,allstrip=allstrip,$
                 cumfilter=cumfilter,coef0=coef0,coef1=coef1,bcbychan=bcbychan,$
                 m3sections=m3sections,m3type=m3type 
;
; coding: .. this should really be straightened out....
;   numbpedg = -1  bp correct by channel
;                  bcbychan=1
;   numbpedg = -2  bp correct by average
;                  allstrip=1
;                  edgeLoc=-1
;                  numbpEdgeL=nsmp
;                  edge1=-1
;   numbpedg = -3  bp correct by median
;                  allstrip=1
;                  usemedian=1
;                  edgeLoc=-1
;                  numbpEdgeL=nsmp
;                  edge1=-1
; 
    numbpedgL=numbpedg
    bcbychan=numbpedgL eq -1
    if keyword_set(allstrip) then begin
        numbpedgL=-2
    endif else begin
        allstrip=numbpedgL eq -2
    endelse
    usemedian=0
    if numbpedgL eq -3 then begin
        numbpedgL=-2
        usemedian=1
        allstrip=1
    endif
    a       =size(m)
    nstrips =(a[0] eq 2)? 1 : a[3]
    nsmp    =a[2]
    nlagsPol=lonarr(2)
    nlagsPol[0]=n_elements(m[0].d)
    nlagsPol[1]=n_elements(m[1].d)
    polISt =0
    polIEnd=1
    if keyword_set(pol) then begin
        polISt =pol-1
        polIEnd=pol-1
    endif
    if keyword_set(bcbychan) then begin
            coef0=fltarr(max(nlagsPol),nstrips)
            coef1=coef0
    endif
;
;   see if the want a mask for tsys
;
    usemask=0
    if n_elements(mask) gt 0 then begin
        usemask=1
    endif 
    if keyword_set(fractmask) then begin
        if fractmask ge .5 then message,'The fractmask must be < .5'
        nlags=nlagsPol[polISt]
        mask= intarr(nlags)
        i1=((long(fractmask*nlags+.5)) > 0) < (nlags/2-1)
        i2=nlags-i1-1
        mask[i1:i2]=1
        usemask=1
    endif
    if usemask then begin
        if nlagsPol[polIst] ne nlagsPol[polIend] then $
            messages,'when using mask, the # of  polA chan must eq polB chan'
        mind=where(mask ne 0,count)
        if count eq 0 then  message,'mask is all zeros..'
        if count eq nlagspol[polISt] then usemask=0
        mcount=count*1.
    endif
        
    if not keyword_set(tsys) then tsys=0
    case 1 of
        n_elements(edge) eq 0: edgeLoc=intarr(nstrips)
        n_elements(edge) eq 1: edgeLoc=intarr(nstrips) + edge
        n_elements(edge) eq nstrips: edgeLoc=edge
        else                :$
        message,'edge keyword must have 1 or nstrips entries'
    endcase
;
;   see if they want to use the entire strip
;
    ind=where(edgeLoc lt 0,count)
    if count gt 0 then edgeLoc[ind]=-1
    ind=where(edgeLoc gt 0,count)
    if count gt 0 then edgeLoc[ind]=1
;
    nfrqchn =(size(m[0,0,0].d))[1]
    if allstrip then begin
        numbpedgL=nsmp              ; use entire strip
        edgeLoc=edgeLoc*0   -1
    endif else begin
        if numbpedgL gt nsmp/2 then begin
            print,'number of  spectra on edge for bandpass > numspectra/2'
            return,''
        endif
    endelse
;
;    allocate the bandpass array
;
    maxfitloop=10
    sigclip   =2.
    ml=m
    if tsys eq 1 then begin
        x=findgen(nsmp)             ; used for polyfit if tsys=1
        if n_elements(degfit) eq 0 then degfit=1
    endif
    for i=0,nstrips-1 do begin
;
;       compute inverse of bandpass correction so we can multiply by it
;
        edge1=edgeLoc[i]
        for polI=polIst,polIend do begin

;-------------------------------------------------------
        case 1 of
;
;============================================================
;    try bandpass correcting each strip channel by channel
;
        keyword_set(bcbychan): begin
            nlag=nlagspol[polI]
            bpcorN=fltarr(nlag,/nozero)
            indall=indgen(nsmp)
            xx=findgen(nsmp)-nsmp/2.
            fmin=999
            fmax=0
            favg=0.
;
;           loop over each spectral channel
;
            for ilag=0,nlag-1 do begin
                indgd=indall
                curCnt=nsmp
;
;               loop finding all points in channel whose fit
;               residuals are nsig*sigma
;
                for j=0,maxfitloop-1 do begin
                    coef=poly_fit(xx[indgd],m[polI,indgd,i].d[ilag],1,$
                                  yerror=sigma)
                    yfit=poly(xx,coef)
                    ii=where(abs(m[polI,*,i].d[ilag]-yfit) lt $
                            (sigclip*sigma),count)
                    if count eq  curCnt then goto,efitloop ; no change
                    indgd=ii
                    curCnt=count
                endfor
efitloop:       bpcorN[ilag]=coef[0]
                coef0[ilag,i]=coef[0]
                coef1[ilag,i]=coef[1]
                fmin=(fmin < (j+1))
                fmax=(fmax > (j+1))
                favg=favg+(j+1)
            endfor
            favg=favg/(nlag*1.)
            lab=string(format=$
        '("strip:",i2,"_",i1,"  min/max/avgl:",i2,i3,f4.1)',$
            i,polI,fmin,fmax,favg)
            print,lab
            if usemask then begin
                meanbp=mean(bpcorN[mind])
            endif else begin
                meanbp=mean(bpcorN)
            endelse
            bpcorN= bpcorN/meanBp
            if (usemask) then begin
                mc0=mean(coef0[mind,i]/bpcorN[mind])
                mc1=mean(coef1[mind,i]/bpcorN[mind])
                avgpwrL=mc0 + mc1*xx[0]
                avgpwrR=mc0 + mc1*xx[nsmp-1]
            endif else begin
                mc0=mean(coef0[*,i]/bpcorN)
                mc1=mean(coef1[*,i]/bpcorN)
                avgpwrL=mc0 + mc1*xx[0]
                avgpwrR=mc0 + mc1*xx[nsmp-1]
            endelse
            tsysCmpByChn=mc0+mc1*xx
        end     ;case (bpcbychan)

;============================================================
;        
        numbpedgL gt 1: begin
            case edge1 of
;============================================================
;       edge1=0 use numbpedgL both edges,
                0:begin
                    bpsumL=total(m[polI,0:numbpedgL-1        ,i].d,3)
                    bpsumR=total(m[polI,nsmp-numbpedgL:nsmp-1,i].d,3)
                    if (usemask) then begin
                        avgPwrL=mean(bpsumL[mind])/numbpedgL
                        avgPwrR=mean(bpsumR[mind])/numbpedgL
                    endif else begin
                        avgpwrL=mean(bpsumL)/numbpedgL
                        avgpwrR=mean(bpsumR)/numbpedgL
                    endelse
                    bpcorN=(bpSumL+bpSumR)/(numbpedgL*(avgpwrL+avgPwrR))
                 end
;============================================================
;       edge1=-1 use numbpedgL left edge only (or whole strip)
               -1:begin
                    if usemedian then begin
                        bpsumL=medianbychan(reform(m[polI,0:numbpedgL-1,i].d,$
                              nlagsPol[polI],nsmp),nsec=m3sections,$
                              retsec=m3type)
                    endif else begin
                        bpsumL=total(m[polI,0:numbpedgL-1        ,i].d,3)
                    endelse
                    if (usemask) then begin
                        avgPwrL=mean(bpsumL[mind])/numbpedgL
                        avgPwrR=avgPwrL
                    endif else begin
                        avgpwrL=mean(bpsumL)/numbpedgL
                        avgpwrR=avgPwrL
                    endelse
                    bpcorN=(bpSumL)/(numbpedgL*(avgpwrL))
                  end
;============================================================
;       edge1=1 use numbpedgL right edge only 
                1:begin
                    bpsumR=total(m[polI,nsmp-numbpedgL:nsmp-1,i].d,3)
                    if (usemask) then begin
                        avgPwrR=mean(bpsumR[mind])/numbpedgL
                        avgPwrL=avgPwrR
                    endif else begin
                        avgpwrR=mean(bpsumR)/numbpedgL
                        avgpwrL=avgPwrR
                    endelse
                    bpcorN=(bpSumR)/(numbpedgL*(avgpwrR))
                  end
            endcase
        end
;============================================================
;         single sample left,right or both edges

        else: begin
            case edge1 of
                0: begin
                    if (usemask) then begin
                        avgPwrL=mean(bpsumL[mind])
                        avgPwrR=mean(bpsumR[mind])
                    endif else begin
                        avgpwrL=mean(m[polI,0     ,i].d)
                        avgpwrR=mean(m[polI,nsmp-1,i].d)
                    endelse
                    bpcorN=((m[polI,0,i].d + m[polI,nsmp-1,i].d)/$
                            (avgpwrL+avgpwrR))
                   end
               -1: begin
                    if (usemask) then begin
                        avgPwrL=mean(bpsumL[mind])
                        avgPwrR=avgPwrL
                    endif else begin
                        avgpwrL=mean(m[polI,0,i].d)
                        avgpwrR=avgpwrL
                    endelse
                    bpcorN=m[polI,0,i].d/(avgpwrL)
                   end
                1: begin
                    if (usemask) then begin
                        avgPwrR=mean(bpsumR[mind])
                        avgPwrL=avgPwrR
                    endif else begin
                        avgpwrR=mean(m[polI,nsmp-1,i].d)
                        avgpwrL=avgpwrR
                    endelse
                    bpcorN=m[polI,nsmp-1,i].d/(avgpwrR)
                   end
            endcase
           end
        endcase 
;
        if tsys eq 0 then begin
;
;           this is the average Tsys to remove for each spectra.
;           if bandpass edges where used on both sides then we
;           linearly interpolated between the two sides.
;
            TsysCmp=findgen(nsmp)/(nsmp-1.) * (avgpwrR-avgpwrL) + avgpwrL
            for j=0,nsmp-1 do begin 
                ml[polI,j,i].d=(m[polI,j,i].d / bpcorN) - TsysCmp[j]
            endfor
        endif else begin 
            for j=0,nsmp-1 do begin
                ml[polI,j,i].d=(m[polI,j,i].d / bpcorN) 
            endfor
            if tsys ne 3 then begin 
                if usemask then begin
                    case tsys of
                         4: tsysCmp= medianbychan(transpose($
                                    reform(ml[polI,*,i].d[mind],mcount,nsmp)))
                         5: tsysCmp= avgrobbychan(transpose($
                                   reform(ml[polI,*,i].d[mind],mcount,nsmp)))
                      else: tsysCmp=reform(total(ml[polI,*,i].d[mind],1))/mcount
                    endcase
                endif else begin
                    case tsys of
                         4: tsysCmp= medianbychan(transpose($
                                    reform(ml[polI,*,i].d,nlagsPol[polI],nsmp)))
                         5: tsysCmp= avgrobbychan(transpose($
                                    reform(ml[polI,*,i].d,nlagsPol[polI],nsmp)))
                      else: tsysCmp=reform(total(ml[polI,*,i].d,1))/nlagsPol[polI]
                    endcase
                endelse
;
;           lineary interpolate using total power from each spectra
;
                if tsys eq 1 then begin
                   if keyword_set(bcbychan) then begin
                       tsysCmp=tsysCmpByChn
                   endif else begin
                       if keyword_set(cumfilter) then begin
                          cumfilter,tsysCmp,nsmp/4,3.,indxgood
                          coef=poly_fit(x[indxgood],tsysCmp[indxgood],degfit)
                       endif else begin
                          coef=poly_fit(x,tsysCmp,degfit)
                       endelse
                       tsysCmp=poly(x,coef)
                   endelse
                endif
                for j=0,nsmp-1 do begin
                    ml[polI,j,i].d=ml[polI,j,i].d - tsysCmp[j]
                endfor
            endif
        endelse
    endfor      ; pol loop
    endfor      ; strip loop
    return,ml
end
