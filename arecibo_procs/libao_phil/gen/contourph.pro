;+
;NAME:
;contourph - phil's interface to idl contour routine.
;
;SYNTAX: contourph,d,numcontours,dbstep,maxval,levels,axes=axes,$
;        fill=fill,_extra=e
;ARGS:
;   d[nx,ny] : float    data to contour.    
; numcontours: int      number of contours to plot. 
;      dbstep: float    db step between contour levels.
;RETURNS:
;      maxval: float    db scaling is relative to this value.
;levels[numcontours]: float the contour levels in dbs relative to maxval.
;         
;KEYWORDS:
;     axes[4]: float    axes label values: [minx,maxx,miny,maxy]. If not 
;                       supplied then 0:nx-1,0:ny-1 are used.
;        fill: int      if set then fill the contours with colors.
;           e:          extra keywords sent to the contour routine.
;DESCRIPTION:
;   contourph interfaces to the idl contour routine. It will scale
;a dataset to dbs relative to the maximum value. The number of levels and
;db step size is input by the user. Annotation can be entered via the
;_extra=e keyword.
;
;EXAMPLE:
;   let bmmap[120,50] be a baselined beammap dataset of 20 arcminutes in az and
;15 arcminutes in za. To contour the data with 12;contours at 2db steps:
;
;   axes=[-10.,10.,-7.5,7.5]
; contourph,bmmap,12,2,maxval,levels,axes=axes,xtitle='az [amins]',$
;   ytitle='za [amins]'
;-
pro contourph,d,ncont,dbstep,maxval,levels,axes=axes,fill=fill,_extra=e
;
    common colph,decomposedph,colph

    a=size(d)
    if a[0] ne 2 then begin
        print, 'data must be 2d array'
        return
    endif
    nx=a[1]
    ny=a[2]
    if (n_elements(axes) ne 4) then begin
        x=findgen(nx)
        y=findgen(ny)
    endif else begin
        x=findgen(nx)/(nx-1.) *(axes[1]-axes[0]) + axes[0]
        y=findgen(ny)/(ny-1.) *(axes[3]-axes[2]) + axes[2]
    endelse
    levels=condblevels(reform(d,nx*ny),ncont,dbstep,maxval)
    levels=levels[sort(levels)]
    colind=reverse(indgen(ncont)+1)
    if keyword_set(fill) then  begin
        contour,d,x,y,levels=levels,_extra=e,/fill,c_color=colph[colind],$
                /xstyle,/ystyle
    endif else begin
        contour,d,x,y,levels=levels,_extra=e,/xstyle,/ystyle
    endelse
    return
end
