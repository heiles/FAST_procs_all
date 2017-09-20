pro prtplot_fancy, nrps, windownr, coeffs_out, sigcoeffs_out, $
        qpa, xpy, xmy, xy, yx, pacoeffs, pacoeffs_out, ngoodpoints, $
	title=title, nloop, nproblem, $
	path=path, plotfilename=plotfilename

; THIS ROUTINE SETS UP THE PLOTTING WINDOW OR POSTSCRIPT FILE FOR OUR
; STANDARD SPIDER SCAN OUTPUT; A PLOT OF X-Y, XY AND YX AND THE BEST-FIT
; PARAMETERS FOR THE MUELLER COEFFICIENTS; AND FINALLY THE MUELLER MATRIX.

;set nrps equal to 0 for screen plot, 1 for ps plot

; PUT THE PS FILE WHERE IT BELONGS...
; SWAP /SAV/ FOR /PS/...
if (N_elements(PATH) gt 0) then begin
   pspath = strsplit(path,'/',/EXTRACT)
   pspath[where(strmatch(pspath,'sav'))] = 'ps'
   pspath = '/'+strjoin(pspath,'/')+'/'
endif

if n_elements( vsrc) eq 0 then vsrc=0
if n_elements( sigvsrc) eq 0 then sigvsrc=0

windownrr= windownr

PS = keyword_set(NRPS)

IF not keyword_set(PS) THEN BEGIN
   device, window=opnd
   if ( opnd[windownrr] eq 0) then window, windownrr, xs=400, ys=850
   wset, windownrr
ENDIF else begin
   if (n_elements(plotfilename) eq 0) then $
      plotfilename= coeffs_out.src + '__prtplot_fancy.ps'
   if (n_elements(pspath) eq 0) then pspath= './'
   psopen, pspath+plotfilename, /TIMES, /BOLD, /ISO, /color;, $
           ;XSIZE=8.0, YSIZE=9.0, /INCH
setcolors,/sys, /silent
   message, 'Writing plot to: '+pspath + plotfilename, /INFO
   windownrr=-1
ENDELSE

font = -1 + keyword_set(ps)
thick = 1 + keyword_set(ps)

!p.multi=[0,1,2]
        
plot_stokespa_fancy, windownrr, $
       qpa, xpy, xmy, xy, yx, $        
       pacoeffs, pacoeffs_out, ps=ps, title=title, $
       FONT=font, XTHICK=thick, YTHICK=thick, THICK=thick

pmstr = ' '+string(byte(177))+' '

xot = .1
yot = .5  
dyot = .02  
yot=yot-dyot
xyouts, xot, yot, 'SRC = '+ coeffs_out.src, /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, 'DELTAG = '+ $
	strtrim(string(coeffs_out.deltag, format='(f6.3)'),2) + $
        pmstr + strtrim(string(sigcoeffs_out.deltag, format='(f6.3)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, 'PSI = '+ $
        strtrim(string(modangle(!radeg*coeffs_out.psi,/NEGPOS), format='(f+6.1)'),2) + $
        pmstr + strtrim(string(!radeg*sigcoeffs_out.psi, format='(f6.1)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, 'ALPHA = '+ $ 
        strtrim(string( modangle(!radeg*coeffs_out.alpha,180.0,/NEGPOS), format='(f+6.1)'),2) + $
        pmstr + strtrim(string(!radeg*sigcoeffs_out.alpha, format='(f6.1)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, 'EPSILON = '+ $ 
        strtrim(string(coeffs_out.epsilon, format='(f+6.3)'),2) + $
        pmstr + strtrim(string(sigcoeffs_out.epsilon, format='(f6.3)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, 'PHI = '+  $
        strtrim(string(modangle(!radeg*coeffs_out.phi,/NEGPOS), format='(f+6.1)'),2) + $
        pmstr + strtrim(string(!radeg*sigcoeffs_out.phi, format='(f6.1)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, 'CHI = '+  $
        strtrim(string(modangle(!radeg*coeffs_out.chi,/NEGPOS), format='(f+6.1)'),2) + $
        pmstr + strtrim(string(!radeg*sigcoeffs_out.chi, format='(f6.1)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, (keyword_set(PS) ? 'Q!DSRC!N = ' : 'QSRC = ') +  $
        strtrim(string(coeffs_out.qsrc, format='(f+6.3)'),2) + $
        pmstr + strtrim(string(sigcoeffs_out.qsrc, format='(f6.3)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, (keyword_set(PS) ? 'U!DSRC!N = ' : 'USRC = ') + $
        strtrim(string(coeffs_out.usrc, format='(f+6.3)'),2) + $
        pmstr + strtrim(string(sigcoeffs_out.usrc, format='(f6.3)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, (keyword_set(PS) ? 'U!DSRC!N = ' : 'VSRC = ') + $
        strtrim(string(coeffs_out.vsrc, format='(f+6.3)'),2) + $
        pmstr + strtrim(string(sigcoeffs_out.vsrc, format='(f6.3)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, (keyword_set(PS) ? 'POL!DSRC!N = ' : 'LINPOLSRC = ') + $
	string(coeffs_out.polsrc, format='(f+6.3)') + $
        pmstr + string(sigcoeffs_out.polsrc, format='(f6.3)'), /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, $
        (keyword_set(PS) $
        ? 'PA!DSRC!N (**UNCORRECTED FOR M!DASTRO!N**) = ' $
        : 'LINPASRC (**UNCORRECTED FOR M_ASTRO**) = ') + $
        strtrim(string(coeffs_out.pasrc, format='(f+9.2)'),2) + $
        pmstr + strtrim(string(sigcoeffs_out.pasrc, format='(f6.2)'),2), $
        /norm, FONT=font
   
goto, skipgoodpoints
yot=yot-dyot
ngoodpoints= -99 + intarr(4)
xyouts, xot, yot, 'NR GOOD POINTS:' + $
	'   X-Y = ' + strtrim(ngoodpoints[1],2) + $
        '   XY = ' + strtrim(ngoodpoints[2],2) + $
        '   YX = ' + strtrim(ngoodpoints[3],2) + '  /  ' + $
        strtrim(ngoodpoints[0],2), /norm, FONT=font
skipgoodpoints:
;===== NOW PRINT OUT THE MUELLER MATRIX ======

yot=yot-dyot
xyouts, xot, yot, '---------------------------------------------------', /norm, FONT=font

yot=yot-dyot
if keyword_set(PS) $
   then xyouts, xot, yot, 'Mueller Matrix:', /norm, FONT=font $
   else xyouts, xot, yot, 'MUELLER MATRIX:', /norm, FONT=font
        
if keyword_set(PS) then begin
   print
   print, '------------------MUELLER MATRIX-----------------------'
   print
endif

yot=yot-dyot

;goto, skipmm
FOR NR=0,3 DO BEGIN
   yot=yot-dyot
   line = ''
   for NR2=0,3 do begin
      mmel = coeffs_out.m_tot[nr2, nr]
      if (mmel lt 0) $
         then line = line + string(mmel, FORMAT='(f11.4)') $
         else line = line + string(mmel, FORMAT='(f12.4)')
   endfor
   if keyword_set(PS) then print, line
   xyouts, xot, yot, line, /norm, FONT=font
ENDFOR

skipmm:
if keyword_set(PS) then psclose
;etcolors,/dev, /silent
setcolors,/sys, /silent
!p.multi=0

end
