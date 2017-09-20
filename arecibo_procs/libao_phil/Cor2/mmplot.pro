;+
;NAME:
;mmplot - x,y plot using different colors for each receiver
;SYNTAX: mmplot,x,y,mm,xtitle=xtitle,ytitle=ytitle,title=title,over=over
;ARGS:   x[npts]    : float xarray  to plot
;        y[npts]    : float yarray  to plot
;       mm[npts]    : {mueller} mueller info
;KEYWORDS:
;   xtitle  : string label for x axis
;   ytitle  : string label for y axis
;   title   : string label top of plot
;   sym     :     if set then use symbols rather than color
;DESCRIPTION:
;   mmplot will plot the x,y data with a different color 
;for each reciever.
;EXAMPLE:
;   mmplot,mm.za,mm.fit.tsys,mm,xtitle='za',ytitle='tsys[K]',title='tsys vs za'
;-
pro mmplot,x,y,mm,xtitle=xtitle,ytitle=ytitle,title=title,over=over,sym=sym
    on_error,1
    rcvnam=['610','lbw','lbn','cband','xband','sbn','430ch','430']
    rcvnum=[  3,   5   , 6   , 9     ,11,    12    ,100,2]
    col   =[  1,   2   , 3   , 4     ,8     ,7     , 9 ,6]
    symb  =[  1,   2   , 4   , 5     ,1     ,6     , 8 ,7]

    rcvnam=['610','lbw','lbn','sbw','sbh' ,'cband','xband','sbn','430ch','430']
    rcvnum=[  3,   5   , 6   , 7   , 8    ,  9    ,11     , 12  ,100,2]
    col   =[  1,   2   , 3   , 5   , 9    ,  4    ,8      , 7   , 9 ,6]
    symb  =[  1,   2   , 4   , 8   , 7    ,  5    ,1      , 6   , 8 ,7]
    usersym,[-.5,.5],[0.,0.]
    if keyword_set(sym) ne 0  then col=col*0 + 1
    print,keyword_set(sym)
    numrcv=n_elements(rcvnum)
    ln=3
    numplot=0
for i=0,numrcv-1 do begin  &$
    ind=where(mm.rcvnum eq rcvnum[i],count)
    if count gt 1 then begin
    if (numplot eq 0 ) and (not keyword_set(over)) then begin &$
        plot,x[ind],y[ind],color=1,psym=symb[i],xtitle=xtitle,$
            ytitle=ytitle,title=title,/nodata &$
    endif
    oplot,x[ind],y[ind],color=col[i],psym=symb[i] &$
    note,ln+i,'  ' + rcvnam[i],color=col[i],xp=.02,sym=symb[i] &$
    numplot=numplot+1
    endif
endfor
    return
end
