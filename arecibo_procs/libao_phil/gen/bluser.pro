;+
;NAME:
;bluser - interactively baseline a function.
; 
;SYNTAX: istat=bluser(x,y,coef,mask,yfit,maskst=maskst,xfit=xfit)
;
;ARGS:   
;       x[npts]:    xaxis array 
;       y[npts]:    yaxis array
;
;KEYWORDS:
;   maskst[npts]:  if provided, then use this mask to start with.
;
;RETURNS:
;     coef[]   :   coefficients from fit.. you should use xfit=xfit 
;                  as the xvalues for the fit;
;                   yy=poly(xfit,coef)
;    mask[npts]:   mask used for fit that was defined by the user.
;    xfit[npts]:   x values used for fitting [0,1) or [0,-1] . these are 
;                  the values you should used when evaluating coef
;    yfit[npts]:   fit evaluatuted at the data points
;         istat:   1: fit ok, 0 no fit
;
;DESCRIPTION:
;   bluser lets the user interactively baseline a function. The user passes
;in the x,y arrays of data. The routine will pass back the coef's from the
;fit, the mask used, and the fit evaluated at the data points. On entry
;the main menu is displayed:
;
; KEY  ARGS     FUNCTION
; m             .. define mask
; f       n     .. fit polynomial of order n
; h       h1 h2 .. change horizontal scale for plot to h1,h2
; v       v1 v2 .. change vertical  scale for plot to v1,v2
; c             .. print coefficients
; p             .. plot data - fit
; q             .. quit
;
;The user should first adjust the horizontal and vertical scale with
;h h1 h2 and v v1 v2. Each time one of these is entered the plot will
;be redisplayed with the new limits (do not use commas here..).
;
;When the plot shows the correct limits, enter m to define the mask. The
;leftmost mouse button is used to define the starting and ending portions 
;of the data that will be used for the fit. You can have as many of these
;sections as you want. When you are done with the mask, click the right
;mouse button.
;
;After defining the mask, you can fit any order polynomial you want.
;
; f 4 
;
;would fit a fourth order polynomial and overplot the fit. 
;
; p  .. plots data - fit. (use v v1 v2 to reset the vertical scale). 
;
;You can go back and redefine a new mask if you want and the redo the fits.
;
; q  is how you exit the routine.
;
;SEE ALSO: blmask
;-
;history:
;21jan02.. switched from y.range, to y.crange
;31may06.. switched mask to use indices rather than errors  to keep
;          barbara happy...
function bluser,x,y,coef,mask,yfit,maskst=maskst,_extra=e,xfit=xfit
; 
    common colph,decomposedph,colph
    ldcolph                     ; load the color map
    colfit=3
    colmask=5
    lnstyle=2
    npts=(size(x))[1]
    bigErr=1e5                  ; measure error for mask.. vs 1.
    gotmask=0
    if n_elements(maskst) gt 0 then begin
        gotmask=1
        maskLoc=maskst
    endif
	xfit=(1D*x - x[0])/(x[npts-1]-x[0])
    donefit=0
    maskHght=.25
    fitorder=0
    lastReq=' '
    plot,x,y,_extra=e,/ystyle,/xstyle
    while 1 do begin
        print,' '
        print,'KEY  ARGS     FUNCTION'
        print,'m          .. define mask'
        print,'f    n     .. fit polynomial of order n'
        print,'h    h1 h2 .. change horizontal scale for plot to h1,h2'
        print,'v    v1 v2 .. change vertical  scale for plot to v1,v2'
        print,'c          .. print coefficients'
        print,'p          .. plot data - fit'
        print,'q          .. quit'
        line='...(no commas between arguments!!) '
        read,'?',line
        line=strtrim(strlowcase(line),1)
        itemp=strpos(line,' ')
        len=strlen(line)
        if (itemp ne -1) and ((itemp+1) le len) then begin
            lineargs=strmid(line,itemp+1,len-(itemp))
        endif else begin
            lineargs=''
        endelse
        print,line,' len',len,' itemp',itemp,' args:',lineargs
;
        replot=1
        case strmid(line,0,1) of
            'q': goto,done
            'm': begin
                 print,'use cursor to specify baseline to use'
                 if blmask(x,y,maskLoc,_extra=e) eq 1 then begin
                    gotmask=1
                    mask=maskLoc
                 endif
                 lastreq='m'
                 donefit=0
                 end
            'f': begin
                 if gotmask eq 0 then begin
                     print,'--> You need to specify the mask first'
                     goto,botloop
                 endif
                 key=' '
                 reads,lineargs,order
                 mask=maskLoc
                 if (!version.release) le '5.3' then begin
                    coef=polyfitw(x*1.D,y*1.D,mask,order,yfit,yband,coefsigma)
                 endif else begin
                    ind=where(mask ne 0,nn)
                   coef=poly_fit(xfit[ind],y[ind],order,yfit=yfit,yband=yband,$
                          sigma=coefsigma,measure_errors=measure_errors,/double)
					
                    yfit=poly(xfit,coef)
;
;			fix up coef
;
                 endelse
                 donefit=1
                 lastReq='f'
                 end
            'h': begin
                  if lineargs ne '' then begin
                    reads,lineargs,h1,h2
                     hor,h1,h2
                 endif else begin
                     hor
                 endelse
                 end
            'v': begin
                  if lineargs ne '' then begin
                    reads,lineargs,v1,v2
                     ver,v1,v2
                 endif else begin
                     ver
                 endelse
                 end
            'c': begin
                 if donefit then begin
                    print,'       N     coef'
                    for i=0,(size(coef))[2]-1 do begin
                        print,i,':',coef[i]
                    endfor
                  endif else begin
                    print,'--> need to do the fit first'
                  endelse
                  replot=0
                end
            'p': begin
                 if donefit then begin
                    lastReq='p'
                  endif else begin
                    print,'--> need to do the fit first'
                    replot=0
                  endelse
                end
            else:print,'bad input.. enter:m,f,h,v, or q'
        endcase
botloop:
        if replot then begin
;
;           plot difference
;
            case lastreq of 
               'p': begin
                    plot,x,y-yfit,/xstyle,/ystyle,_extra=e,title='data - fit'
                    end
               'f': begin
                    plot,x,y,_extra=e,/ystyle,/xstyle
                    oplot,x,yfit,linestyle=lnstyle,color=colph[colfit]
                    end
              else: begin
                    plot,x,y,_extra=e,/ystyle,/xstyle
                    end
            endcase
            if gotmask then begin
                  oplot,x,maskLoc*(!y.crange[1]-!y.crange[0])*maskHght + $
                        !y.crange[0],_extra=e,color=colph[colmask],linestyle=2
            endif
        endif
    endwhile
done:
    return,donefit
end
