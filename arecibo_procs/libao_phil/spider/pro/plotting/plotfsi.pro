pro plotfsi, path, indx, beamout_arr, a, ps=ps
;+
; PURPOSE: Generate plots of the Fourier coefficients of the sidelobe
;versus PA for Stokes I.  Separate plots of Fourier components nr 0 to
;3, both amplitude and PA versus ZA,AZ. 
;
; CALLING SEQUENCE: First call mueller2 to read a datafile and select the
;source; then .runplotfsi.idlprc. See mueller2_5.idl
;
;-

;READpolBEAMS.IDLPRC.. DISPLAY BEAM PARAMETERS
;FIRST READ IN A FILE AND SELECT A SOURCE USING MUELLER2

IF ( N_ELEMENTS( INDX) LT 2) THEN BEGIN
        print, 'SKIP PLOTFSI FOR THIS SOURCE--FEWER THAN TWO PATTERNS'
        GOTO, FINISHED
ENDIF

device, window=opnd
if ( opnd(9) eq 0) then window, 9, xs=400, ys=850
 
b2dcfs= beamout_arr.b2dfit
strp_cfs= beamout_arr.stripfit
fhgt=  beamout_arr.fhgt
fcen=  beamout_arr.fcen
fhpbw=  beamout_arr.fhpbw

pindx= where( b2dcfs[2,0,indx[*]] ne 0, count)
if (count eq 0) then goto, finished
pindx= indx[pindx]

fhgta= complexarr(8, n_elements(pindx))
;for nrc= 0,n_elements(pindx)-1 do begin
;;ft_sidelobes, strp_cfs[ *,0,*, pindx[nrc]], b2dcfs[*,*, pindx[nrc]], $
;;        fhgt, fcen, fhpbw
;ft_sidelobes_newcal, strp_cfs[ *,0,*, pindx[nrc]], b2dcfs[*,*, pindx[nrc]], $
;        fhgtp, fcenp, fhpbwp
;fhgta[*,nrc]= fhgtp
;endfor

fhgta= fhgt[ *, pindx]

for nfcomp=0, 7 do fhgta[ nfcomp,*]= fhgta[ nfcomp,*]/ b2dcfs[ 2, 0, pindx]
fhgta_ampl= sqrt(fhgta* conj(fhgta))
fhgta_angl= !radeg* atan(imaginary( fhgta), float(fhgta))

pltfilename, indx, a, 'fsi', '.ps', title, plotfilename

aza= b2dcfs[ 19,0, pindx[*]]
zaa= b2dcfs[19,1, pindx[*]]


!p.multi=[ 0,1,4]
;!p.multi= 0
!p.charsize=1.5

for nplt=0, 1 do begin

if ( (nplt eq 1) and (keyword_set( ps))) then openplotps, file= path+ plotfilename
plot, aza, fhgta_angl[ 0, *], psym=4, $
	xra=[-180,180], xsty=1, xtit='AZ', xmargin=[10,10], $
	yra=[-180,180],ysty=8, ytit='!4H!X!Dmax!N',  $
;	yra=[-180,180],ysty=8, ytit='POS ANGLE', $
	title= title, /nodata
;xyouts, 0, 180, 'ZEROTH FOURIER AMPL AND PA', align=.5, charsize=.9
for nambig=0,2 do oplot, aza, $
	(360.*(nambig-1)+ b2dcfs[9,0,pindx]), psym=6
oplot, [-200,200], [200,-200], lines=1
axis, yaxis=1, yra=[0, max(fhgta_ampl[0,*])], ytit='AMPLITUDE', /save
oplot, aza, fhgta_ampl[ 0, *], lines=0

graphtitle= ['AMPL * COS (PA-PA_0)', 'AMPL * COS 2(PA-PA_0)', $
	'AMPL * COS 3(PA-PA_0)'] 
FOR NFCOMP= 1,3 DO BEGIN
plot, aza, fhgta_angl[ 0, *], psym=4, $
	xra=[-180,180], xsty=1, xtit='AZ', xmargin=[10,10], $
	yra=[-180,180],ysty=8, ytit='!4H!X!Dmax!N',  $
;	yra=[-180,180],ysty=8, ytit='POS ANGLE', /nodata, $
	title= graphtitle[ nfcomp-1], /nodata
for nambig=0,2 do oplot, aza, $
	(360.*(nambig-1)+ fhgta_angl[ nfcomp, *])/nfcomp, psym=6
oplot, [-200,200], [200,-200], lines=1
;if (nfcomp eq 1) then xyouts, -160, 180, charsize=1, $
;	'DASHED IS ZROTH FOURIER COMPONENT'
axis, yaxis=1, yra=[0, max(fhgta_ampl[0,*])], ytit='AMPLITUDE', /save
oplot, aza, fhgta_ampl[ nfcomp, *];, psym=-4
;if (nfcomp eq 1) then oplot, aza, fhgta_ampl[ 0, *], lines=2
endfor

if ( (nplt eq 1) and (keyword_set( ps))) then closeps

endfor

FINISHED:

!p.multi=0
!p.charsize=0

end


