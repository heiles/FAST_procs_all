;+
;NAME:
;mmplotazza - plot az,za coverage of dataset.
;SYNTAX: mmplotazza,mm,sym=sym,dx=dx,over=over,color=color,title=title,fig=fig
;ARGS:  
;   mm[npts]: {mueller} mueller info
;KEYWORDS:
;      sym: int symbol to plot at each position.Default is *.
;     over:     if set then overplot this data with what is there.
;       dx:     The step size in feet along the x,y axis. default is 10 feet.
;    color: int color index to use : 1..10 (see ldcolph)
;    title: string label for title of plot
;   fig   : int     figure number
;
;DESCRIPTION:
;   Plot the azimuth, za positions as a cartesian x,y plot. The axes are
;feet from the center of the dish (projected onto z=0). This routine can
;give an idea of how well a set of sources has covered the dish.
;
;EXAMPLE:
;   nrecs=mmgetarchive(020826,021015,mm,rcv=9)
;   mmplotazza,mm,title='cband coverage after focus change till 15oct02'
;-
pro mmplotazza,mm,sym=sym,dx=dx,over=over,_extra=e,fig=fig 
    on_error,1

    !x.style=!x.style or 1
    !y.style=!y.style or 1
    pltazzausage,mm.az,mm.za,sym=sym,over=over,_extra=e,dx=dx
    if n_elements(fig) ne 0 then fig=fignum(fig)
    return
end
