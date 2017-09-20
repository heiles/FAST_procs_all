pro prtplot, nrps, windownr, indx, a, muellerparams1, $
        qpa, xpy, xmy, xy, yx, pacoeffs, ngoodpoints, $
	title=title, $
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

windownrr= windownr

PS = keyword_set(NRPS)

IF not keyword_set(PS) THEN BEGIN
   device, window=opnd
   if ( opnd[windownrr] eq 0) then window, windownrr, xs=400, ys=850
   wset, windownrr
ENDIF else begin
   if (n_elements(plotfilename) eq 0) then plotfilename='test'
   if (n_elements(pspath) eq 0) then pspath= './'
   ;openplotps, nbits=8, file= path + plotfilename
   psopen, pspath+plotfilename, /TIMES, /BOLD, /ISO;, $
           ;XSIZE=8.0, YSIZE=9.0, /INCH
   message, 'Writing plot to: '+pspath + plotfilename, /INFO
   windownrr=-1
ENDELSE

font = -1 + keyword_set(ps)
thick = 1 + keyword_set(ps)

!p.multi=[0,1,2]
        
plot_stokespa, windownrr, indx, a, $
               qpa, xpy, xmy, xy, yx, $        
               pacoeffs, ps=ps, title=title, $
               FONT=font, XTHICK=thick, YTHICK=thick, THICK=thick

pmstr = ' '+string(byte(177))+' '
;pmstr = ' +/- '

xot = .1
yot = .5  
dyot = .02  
yot=yot-dyot
xyouts, xot, yot, 'DELTAG = '+ $
	strtrim(string(muellerparams1.deltag, format='(f6.3)'),2) + $
        pmstr + strtrim(string(muellerparams1.sigdeltag, format='(f6.3)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, 'PSI = '+ $
        ;strtrim(string(modangle360(!radeg*muellerparams1.psi,/c180), format='(f6.1)'),2) + $
        strtrim(string(modangle(!radeg*muellerparams1.psi,/NEGPOS), format='(f+6.1)'),2) + $
        pmstr + strtrim(string(!radeg*muellerparams1.sigpsi, format='(f6.1)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, 'ALPHA = '+ $ 
        ;strtrim(string( modanglem(!radeg*muellerparams1.alpha), format='(f6.1)'),2) + $
        strtrim(string( modangle(!radeg*muellerparams1.alpha,180.0,/NEGPOS), format='(f+6.1)'),2) + $
        pmstr + strtrim(string(!radeg*muellerparams1.sigalpha, format='(f6.1)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, 'EPSILON = '+ $ 
        strtrim(string(muellerparams1.epsilon, format='(f+6.3)'),2) + $
        pmstr + strtrim(string(muellerparams1.sigepsilon, format='(f6.3)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, 'PHI = '+  $
        ;strtrim(string(modangle360(!radeg*muellerparams1.phi,/c180), format='(f6.1)'),2) + $
        strtrim(string(modangle(!radeg*muellerparams1.phi,/NEGPOS), format='(f+6.1)'),2) + $
        pmstr + strtrim(string(!radeg*muellerparams1.sigphi, format='(f6.1)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, (keyword_set(PS) ? 'Q!DSRC!N = ' : 'QSRC = ') +  $
        strtrim(string(muellerparams1.qsrc, format='(f+6.3)'),2) + $
        pmstr + strtrim(string(muellerparams1.sigqsrc, format='(f6.3)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, (keyword_set(PS) ? 'U!DSRC!N = ' : 'USRC = ') + $
        strtrim(string(muellerparams1.usrc, format='(f+6.3)'),2) + $
        pmstr + strtrim(string(muellerparams1.sigusrc, format='(f6.3)'),2), $
        /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, (keyword_set(PS) ? 'POL!DSRC!N = ' : 'POLSRC = ') + $
	string(muellerparams1.polsrc, format='(f+6.3)') + $
        ;pmstr + string(0., format='(f6.3)'), /norm, FONT=font
        pmstr + string(muellerparams1.sigpolsrc, format='(f6.3)'), /norm, FONT=font

yot=yot-dyot
xyouts, xot, yot, $
        (keyword_set(PS) $
        ? 'PA!DSRC!N (**UNCORRECTED FOR M!DASTRO!N**) = ' $
        : 'PASRC (**UNCORRECTED FOR M_ASTRO**) = ') + $
        strtrim(string(muellerparams1.pasrc, format='(f+9.2)'),2) + $
        ;pmstr + strtrim(string(0., format='(f6.1)'),2), $
        pmstr + strtrim(string(muellerparams1.sigpasrc, format='(f6.2)'),2), $
        /norm, FONT=font
   
yot=yot-dyot
xyouts, xot, yot, 'NR GOOD POINTS:' + $
	'   X-Y = ' + strtrim(ngoodpoints[1],2) + $
        '   XY = ' + strtrim(ngoodpoints[2],2) + $
        '   YX = ' + strtrim(ngoodpoints[3],2) + '  /  ' + $
        strtrim(ngoodpoints[0],2), /norm, FONT=font

; CARL AND TIM AGREE THIS IS KIND OF USELESS...
;yot=yot-dyot
;xyouts, xot, yot, 'SCAN '+ $
;	strtrim(a[ indx[0]].scan,2), /norm, FONT=font


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

FOR NR=0,3 DO BEGIN
   yot=yot-dyot
   line = ''
   for NR2=0,3 do begin
      mmel = muellerparams1.m_tot[nr2, nr]
      if (mmel lt 0) $
         then line = line + string(mmel, FORMAT='(f11.4)') $
         else line = line + string(mmel, FORMAT='(f12.4)')
   endfor
   if keyword_set(PS) then print, line
   xyouts, xot, yot, line, /norm, FONT=font
ENDFOR

if keyword_set(PS) then psclose

!p.multi=0

end
