;+
;NAME:
;cormapbl   - baseline all the spectra in a map.
;
;SYNTAX: mbl=cormapbl(m,mask,polyDeg,gotmask=gotmask)
;
;ARGS:   
;   m[2,nsmps,nstrips]   - map array of structures.
;   mask[nfrqchn]: float - mask to use for baselining
;   polyDeg      : int   - degree of polynomial for baselining
;
;KEYWORDS:
;   gotmask      : if set then user supplies mask and polyDeg as input.
;
;RETURNS:
;       mask[nfrqchn]        : the mask array used.
;       polyDeg              : the degree of the polynomial used.
;       mbl[2,nsmps,nstrips] : baselined map info
;
;DESCRIPTION:
;   cormapbl will baseline all the spectra in a map. The user inputs
;the map array. The routine call bluser which allows the user to
;interactively define a mask and order for baselining. After the 
;mask and order is chosen, the routine will fit the requested order
;polynomial to every spectra using the mask.
;
;A copy of the map array is returned with the baseline removed from the
;data.
;
;bluser is called from within the routine with the average of all 
;spectra in pola. The users uses this as the reference to decide which
;polynomial and mask to use.
;
;EXAMPLE:
;   let m[2,31,21] be the map structure with 1024 frequency channels.
;   the call:
;   mbl=cormapbl(m,mask,polyDeg) will:
;   1. call bluser with average of polA over the map.
;      the output from bluser consists of:
;KEY  ARGS     FUNCTION
;m             .. define mask
;f       n     .. fit polynomial of order n
;h       h1 h2 .. change horizontal scale for plot to h1,h2
;v       v1 v2 .. change vertical  scale for plot to v1,v2
;c             .. print coefficients
;p             .. plot data - fit
;q             .. quit
;    You must first specify the mask with m.After than you can 
;fit various polynomials with the f deg .  Use p to plot the
;data - fit. Use v  1.1 1.5 or h 200 400 to change the vertical and
;horizontal display.
;When you are satisfied with the fit, enter q and the routine will
;then fit the polynomial to each spectra and return it in mbl.
;
;NOTE:
;   If you called: cormapinp, cormapsclk, and then this routine, the
;spectra still need to be bandpass corrected before the temperature
;scale is correct.
;-
; 01mar05 - fix for single strips
function cormapbl,m,mask,deg,gotmask=gotmask
;
;   
	a=size(m)
    nstrips =(a[0] eq 2)? 1:a[3]
    nsmp    =(size(m))[2]
    nchn    =(size(m[0,0,0].d))[1]
    nlags  =(size(m.d))[1]
;
;   compute the average over the whole map
;
    avgbpa=cmavgstrips(m,1)     ; avg pol a
    if not keyword_set(gotmask) then begin
      istat=bluser(findgen(nchn),avgbpa,coef,mask,yfit)
      deg=n_elements(coef)-1        ; get the degree they used
    endif
;
;    now baseline each strip 
;
    x=findgen(nchn)
    mb=m
    for i=0,nstrips-1 do begin
        for j=0,nsmp-1 do begin
            y=m[0,j,i].d
            a=polyfitw(x,y,mask,deg,yfit)
            mb[0,j,i].d=y-yfit
            y=m[1,j,i].d
            a=polyfitw(x,y,mask,deg,yfit)
            mb[1,j,i].d=y-yfit
        endfor
    endfor
    return,mb
end
