; <04aug07> pasrc polsrc, switched to use values in muellerparams1
pro prtplot, nrps, windownr, indx, a, muellerparams1, $
        qpa, xpy, xmy, xy, yx, pacoeffs, ngoodpoints, $
	title=title, $
	path=path, plotfilename=plotfilename

;set nrps equal to 0 for screen plot, 1 for ps plot


IF (NRPS NE 1) THEN BEGIN
windownrr= windownr
device, window=opnd
if ( opnd(windownrr) eq 0) then window, windownrr, xs=400, ys=850
wset, windownrr
ENDIF

IF (NRPS EQ 1) THEN BEGIN
	if (n_elements(plotfilename) eq 0) then plotfilename='test'
	if (n_elements(path) eq 0) then path= './'
	openplotps, nbits=8, file= path + plotfilename
	print, 'writing plot onto ', path + plotfilename
	windownrr=-1
ENDIF

!p.multi=[0,1,2]
        
plot_stokespa, windownrr, indx, a, $
        qpa, xpy, xmy, xy, yx, $        
        pacoeffs, ps= nrps, title=title

xot = .1
yot = .5  
dyot = .02  
yot=yot-dyot
xyouts, xot, yot, 'DELTAG = '+ $
	string(muellerparams1.deltag, format='(f6.3)') + $
        ' +/- ' + string(muellerparams1.sigdeltag, format='(f6.3)'), /norm

yot=yot-dyot
xyouts, xot, yot, 'PSI = '+ $
string(modangle360(!radeg*muellerparams1.psi,/c180), format='(f6.1)') + $
        ' +/- ' + string(!radeg*muellerparams1.sigpsi, format='(f6.1)'), /norm

yot=yot-dyot
xyouts, xot, yot, 'ALPHA = '+ $ 
  string( modanglem(!radeg*muellerparams1.alpha), format='(f6.1)') + $
  ' +/- ' + string(!radeg*muellerparams1.sigalpha, format='(f6.1)'), /norm

yot=yot-dyot
xyouts, xot, yot, 'EPSILON = '+ $ 
	string(muellerparams1.epsilon, format='(f6.3)') + $
        ' +/- ' + string(muellerparams1.sigepsilon, format='(f6.3)'), /norm

yot=yot-dyot
xyouts, xot, yot, 'PHI = '+  $
	string(modangle360(!radeg*muellerparams1.phi,/c180), format='(f6.1)') + $
        ' +/- ' + string(!radeg*muellerparams1.sigphi, format='(f6.1)'), /norm

yot=yot-dyot
xyouts, xot, yot, 'QSRC = '+  $
	string(muellerparams1.qsrc, format='(f6.3)') + $
        ' +/- ' + string(muellerparams1.sigqsrc, format='(f6.3)'), /norm 

yot=yot-dyot
xyouts, xot, yot, 'USRC = '+ $
	string(muellerparams1.usrc, format='(f6.3)') + $
        ' +/- ' + string(muellerparams1.sigusrc, format='(f6.3)'), /norm

;polsrc1 = sqrt( muellerparams1.qsrc^2 + muellerparams1.usrc^2)
;pasrc1 = !radeg* 0.5*atan(muellerparams1.usrc, muellerparams1.qsrc)
;pasrc1= modanglem( pasrc1)

yot=yot-dyot
xyouts, xot, yot, 'POLSRC = '+ $
	 string(muellerparams1.polsrc, format='(f+6.3)') + $
        ' +/- ' + string(muellerparams1.sigpolsrc, format='(f6.3)'), /norm

yot=yot-dyot
xyouts, xot, yot, 'PASRC (**UNCORRECTED FOR M_ASTRO**) = '+ $
        strtrim(string(muellerparams1.pasrc, format='(f+9.2)'),2) + $
        ' +/- ' + strtrim(string(muellerparams1.sigpasrc, format='(f6.2)'),2), $
        /norm

yot=yot-dyot
xyouts, xot, yot, 'NR GOOD POINTS= ' + $
	string(ngoodpoints[1]) + $
        string(ngoodpoints[2]) + string(ngoodpoints[3]) + '/' + $
        string(ngoodpoints[0]), /norm

yot=yot-dyot
xyouts, xot, yot, 'SCAN '+ $
	trim(a[ indx[0]].scan), /norm

yot=yot-dyot
xyouts, xot, yot, '---------------------------------------------------', /norm

yot=yot-dyot
xyouts, xot, yot, 'MUELLER MATRIX:', /norm
        
if (nrps eq 1) then begin
print, ' '
print, '------------------MUELLER MATRIX-----------------------'
print, ' '
endif

yot=yot-dyot

FOR NR=0,3 DO BEGIN
yot=yot-dyot
line = string( muellerparams1.m_tot[*, nr], format= '(4f12.4)')
if (nrps eq 1) then print, line
xyouts, xot, yot, line, /norm
ENDFOR

if (nrps eq 1) then closeps

!p.multi=0

return
end
