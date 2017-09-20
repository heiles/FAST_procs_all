;+
;NAME:
;galripple - look at ripple in galfa bandpass
;SYNTAX: galripple,b,hard=hard,bfit=bfit,win=win,mytitle=mytitle,$
;				   spcar=spcar,deg=deg,fsin=fsin,nospc=nospc,tosmo=tosmo
;ARGS:
;	b: {corget}	bandpass to use. Normally you would input a file, average
;				it, and then pass the averaged spectra in.
;KEYWORDS:
;   hard:  	if set then user wants hardcopy. This will not plot the
;		    baseline fits.
;   bfit:{corget} This is the fit from corblauto(). If it is passed in as 
;				  a corget structure then it will be used rather than calling
;			      corblauto(). This speed things up if you call the routine
;				  multiple times with the same bandpass. 
;	win : string  Window function to use when computing the transform of the
;				  spectrum. Values are:
;					  'cos4'  cos^4 window
;				      'han'   hanning smoothing.
;				  The default is no windowing.
;  mytitle: string If supplied then it will be plotted at the top of the
;				  page.
;	deg   : int	  The deg for the polynomial portion of the fit done by
;				  corblauto().
;	fsin  : int	  The order of the harmonic fit done by corblauto()
;  nospc  :       If set, then don't plot the smoothed bandpass corrected
;				  spectra.
;RETURNS:
;	bfit: {corget} If supplied and the input is not a {corget} then the
;				   corblauto() fit is returned here.
;spcar[nchn,2,nbeams]: float	this is the transform of the bandpass. 
;
;DESCRIPTION:
;	galripple was used to look at the 174 Khz rippled caused by reflections
;in the fiber optics cable. It  takes an galfa bandpass as input. 
;It will then :
;
;1. fit the bandpass with corblauto(). The default is a linear polynomial
;	and a 7th order harmonic. This gets rid of ripples with a spacing up 
;   to 1 Mhz. You can change the order using deg= and fsin=
;2. Divide the bandpass by the fit in 1.
;3. Smooth the spectra from 2 by tosmo. The default is 19 channels. 
;4. if the keyword /nospc is not set then plot the bandpasses from 3. Pol
;   A and polB are on separate pages.
;5. compute the transform of the spectra in 4:
;	spc=abs(fft(spc3))*2.
;   The 174 Khz rippled should show up in channel 39 or 40.
;   Then plot this spc for each pixel. Black in polA, red is polB
;
;EXAMPLES:
;	istat=corgetm(desc,600,b)
;   bavg=coravg(b)
;	galripple,bavg
;-
;
pro  galripple,bavg,hard=hard,bfit=bfit,win=win,mytitle=mytitle,$
		   spcar=spcar,deg=deg,fsin=fsin,nospc=nospc,tosmo=tosmo
	    common colph,decomposedph,colph


if n_elements(deg) eq 0 then deg=1
if n_elements(fsin) eq 0 then fsin=7
if n_elements(hard) eq 0 then hard=0
if n_elements(win) eq 0 then win=''
if n_elements(mytitle) eq 0 then mytitle=''
if n_elements(tosmo) eq 0 then tosmo=19
xs=640
ys=850
verb=(hard)?0:-1
if keyword_set(nospc) then verb=0
dofit=(n_elements(bfit) eq 0) or ((size(bfit))[2] ne 8)
if dofit then begin
	hor
	ver
	istat=corblauto(bavg,bfit,deg=deg,fsin=fsin,verb=verb)
endif
bf=cormath(bavg,bfit,/div)
bf=cormath(bf,ssub=1.0)
corsmo,bf,bsmo,smo=tosmo
	if n_elements(h) eq 2 then begin
		hor,h[0],h[1]
	endif else begin
		hor
	endelse
	ver,-.01,.01
	if not keyword_set(noSpc) then begin
	if not hard then window,0,xsize=xs,ysize=ys,xpos=10
	corplot,bsmo,pol=1,newtitle=mytitle+ ' pol A'
    if not hard then window,1,xsize=xs,ysize=ys,xpos=15
	corplot,bsmo,pol=2,newtitle=mytitle+ ' pol B'
	endif
;
!p.multi=[0,2,4]
cs=1.6
hor,0,100
ver,0,.005
nlags=7679
minval=-.01
maxval=-minval
if ((not hard) and (not keyword_set(nospc)) ) then window,2,xsize=xs,ysize=ys,xpos=500
spcAr=fltarr(nlags,2,7)
for ibrd=0,6 do begin &$
    ltit=(ibrd eq 0) ?mytitle:''
for ipol=0,1 do begin &$
 	y=(bf.(ibrd).d[*,ipol] > minval) < maxval  &$
	case win of
		'cos4': y=y*wincos4(nlags) &$
		'han': y=y*windowfunc(nlags,type='han') &$
		else : y=y
	endcase
	spc=abs(fft(y))*2. &$
	spcAr[*,ipol,ibrd]=spc
	if not keyword_set(nospc) then begin
	if ipol eq 0 then  begin &$
		plot,spc,charsize=cs,title=ltit + string(format='(" beam:",i1)',ibrd),$
				/nodata,xtitle='cycles in spc'
		oplot,spc,color=colph[2]
	endif else begin &$
		oplot,spc ,color=colph[3]&$
	endelse &$
	endif
endfor &$
xp=.2
xinc=.2
ln=2
if not keyword_set(nospc) then begin
note,ln,'polA',color=colph[2],xp=xp
note,ln,'polB',color=colph[3],xp=xp+xinc
endif
endfor
return
end
