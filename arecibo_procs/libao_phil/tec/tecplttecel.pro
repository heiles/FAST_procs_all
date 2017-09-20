;+
;NAME:
;tecplttecel - plot tec and elevation vs hour
;SYNTAX: tecplttecel,tecAr,tecv=tecv,lsat=lsat,ldate=ldate,title=title,
;                    cs=cs
;ARGS:
; tecAr[n]: {}  array of tec strucutures from tecget();
;KEYWORDS:
;   tecv:   if set then call tecver() to convert to "vertical" tec..
; lsat  :   if set then include satellite name in the title
; ldate :   if set then include the AST start time in the title
; title : string   title to include in first plot of each page.
;   cs  : float   characiter size for the labels (as passed to plot).
;
;DESCRIPTION:
;   Plot tec vs hour and overplot elevation vs hour for each pass in the
;array tecAr. The elevation is overplotted in red with the elevation axis
;plotted on the right side of each plot. 
;   You can add the satellite name and date/time for start of the pass with
;the keywords /lsat and /ldate (all times are AST). 
;   The horizontal scale should be set to autoscaling (use hor). The vertical
;scale can be left to autoscale or you could set a fixed value for the
;tec plots using ver (the elevation scale is always 0 to 90). 
;   You can place multiple plots on the page using !p.multi= system 
;variable.
;
;EXAMPLE:
;   plot all of the passes between 23mar07 and 25mar07. Place two plots
;per page.
;   yymmdd1=070323
;   yymmdd2=070325
;   npnts=tecget(yymmdd1,yymmdd2,tar)
;;   throw out  bad elevations..
;   ngood=tecchk(tar,indgood)
;   tar=tar[indgood]
;   !p.multi=[0,1,2]            ; 1 column, 2 rows per page
;   cs=1.                       ; default scale for labels
;   ver,0,20                    ; limit tec range to 0,20
;;  make the plots
;   tecplttecel,tar,/lsat,/ldate,title='23-25mar07',cs=cs
;-
pro tecplttecel,tar,tecv=tecv,lsat=lsat,ldate=ldate,title=title,$
            cs=cs
    common colph,decomposedph,colph

    astOff=4/24D
    if n_elements(title) eq 0 then title=''
    upass=tar[uniq(tar.passnum,sort(tar.passnum))].passnum
    npass=n_elements(upass)
    hrAr=tecasthr(tar)
    xtit='Ast Hr'
    ytit1 =(keyword_set(tecv))? 'vertTec':'slant tec'
    ytit2 = 'el deg'
    xmargin=[8,6]
    yrel=[0,90]
    if n_elements(cs) eq 0 then cs=1.6
    ncol=!p.multi[1]
    nrow=!p.multi[2]
    nstep=nrow*ncol
    if nrow*ncol gt 0 then !p.multi=[0,ncol,nrow]

    satlist=tecsatlist()
    if (nstep eq 0 ) then nstep=1
    for i=0,npass,nstep do begin &$
        first=1
        for j=i,i+nstep-1 do begin &$
            if j lt npass then begin &$
                ii=where(tar.passnum eq upass[j],cnt) &$
                el=tar[ii].el &$
                tec=(keyword_set(tecv))?tecver(tar[ii],/freg):tar[ii].tec &$
                hr=hrAr[ii] &$
                llsat=keyword_set(lsat)?satlist[tar[ii[0]].sat-1]:''
                lldate=''
                if keyword_set(ldate) then begin
                    caldat,tar[ii[0]].jd-astOff,mon1,day1,yr1,hr1,min1
                    lldate=string(format='(i02,i02,i02,"_",i02,":",i02)',$
                            yr1 mod 100,mon1,day1,hr1,min1)
                endif
                tit=''
                if first then tit=title + ' '
                if llsat ne '' then tit=tit + llsat + ' ' 
                if lldate ne '' then tit=tit +lldate
                plot,hr,tec,xmargin=xmargin,charsize=cs,$
                    xtitle=xtit,ytit=ytit1,yrange=yrtecv,$
                    ystyle=9,title=tit  &$
                axis,yaxis=1,ystyle=1,color=colph[2],ytit=ytit2,yrange=yrel,$
                    /save,charsize=cs &$
                oplot,hr,el,col=colph[2] &$
                first=0
            endif &$
        endfor &$
    endfor
    return
end
