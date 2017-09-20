;+
;NAME:
;blmask - interactively create a mask for baseline fit
;
;SYNTAX: istat=blmask(x,y,maskArr,y2=y2)
;
;ARGS:   
;       x[npts]:    xaxis array 
;       y[npts]:    yaxis array
;KEYWORDS:
;       y2[npts]:   overplot second array
;
;RETURNS:
; maskArr[npts]:   returned mask array with valuse  0,1
;         istat:   1: created mask, 0: no mask specified by user
;
;DESCRIPTION:
;   Let the user interactively define a mask to use for fitting. The
;x,y data is plotted and then the user is prompted to interactively
;build the mask using the mouse. The user is prompted to position the
;the mouse to the start and end of each segment that is to be filled
;with ones in the mask. The left mouse button is used to specify the
;point. The right mouse button will get you out of this loop. The
;returned mask will have the value 1 for all the specified segments.
;All other values will be set to 0.
;
;   If the y2 keyword is provided, then the data in y2 will be over
;plotted in red. You might use this when you are trying to create
;1 mask for 2 polarizations of data.
;
;EXAMPLE:
;   istat=blmask(x,y,maskArr)
;buttons used: left mark, right quit 
;  1--P1?--     -47.2958
;  1--P2?--      9.64367     first section of mask done
;  2--P1?--      19.4657
;  2--P2?--      22.8821     2nd section of mask done
;  3--P1?--      25.1597     right button clicked so it returns.
;
;NOTE:
;   It is the users responsibility to set the horizontal and vertical scale
;prior to calling this routine. The normal interface to this routine is 
;from the bluser() routine.
;
;SEE ALSO: bluser, cursorsubset.
;-
function blmask,x,y,maskArr,y2=y2,_extra=e
; 
    common colph,decomposedph,colph 
    npts=(size(x))[1]
    maskArr=fltarr(npts)
    plot,x,y,_extra=e,/ystyle,/xstyle
    if n_elements(y2) gt 0 then oplot,x,y2,_extra=e,color=colph[2]
    nsets=cursorsubset(x,indarr)
    if nsets eq 0 then return,0
    print,indarr
    for i=0,nsets-1 do maskArr[indArr[0,i]:indArr[1,i]]=1.
    return,1
end

