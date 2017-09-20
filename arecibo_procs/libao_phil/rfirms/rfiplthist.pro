;+
;NAME:
;rfiplthist - plot histograms of rfi rms data
;SYNTAX : rfiplthist,histar,histinfo,ln=ln,title=title,over=over,xp=xp,$
;                   sclln=sclln
;ARGS   :  
;   histAr[nchn,3] : long hold totalcnts,rfi, rejected histograms
;   histInfo       :{rfihistinfo} hold histinfo.
;KEYWORDS:
;  title: string if supplied then title for plot
;  over :        if set then overplot on last plot.
;   ln  : int    if supplied then line number for labels (colors, sigma,etc).
;   xp  : float  0 to 1. xoffset for labels
;   sclln:float  to space label lines (default 1.)
;   cs   :float  character size scale for label. default:1.
;   
;-
pro rfiplthist,histar,hinfo,ln=ln,title=title,over=over,sclln=sclln,xp=xp,$
               cs=cs
;
    common colph,decomposedph,colph
    csn=1
    coltot=colph[4]
    colrej=colph[2]
    if n_elements(over) eq 0 then over=0
    if n_elements(xp) eq 0 then xp=.08
    if n_elements(sclln) eq 0 then sclln=1.
    if n_elements(cs) eq 0 then cs=1.
    if n_elements(title) eq 0 then title=''
    frq=findgen(hinfo.totchn)*hinfo.frqstp+hinfo.frqst
    maxchn=max(histAr[*,0])
;
    titlel=title+'!c '
    if over eq 0 then begin
        plot,frq,histAr[*,1]/float(histAr[*,0]>1.),xtitle='frq [Mhz]',$
    ytitle='rfi fractional occurrence',charsize=cs,title=titlel,ticklen=-.02,$
        ystyle=5,/nodata
        axis,yaxis=1,yrange=[0,maxchn],ystyle=1,ytitle='total counts in a bin',$
            color=coltot,yticklen=-.02
        axis,yaxis=0,yrange=[0,1.],ystyle=1,ytitle='rfi fractional occurrence',$
            yticklen=-.02,charsize=cs,ticklen=-.02
    endif
    oplot,frq,histAr[*,1]/float(histAr[*,0]>1.)
;
    oplot,frq,histAr[*,0]/float(maxchn),color=coltot
    oplot,frq,histAr[*,2]/float((histAr[*,0]+histAr[*,2])>1.),color=colrej
;
    if n_elements(ln) gt 0 then begin
        lin=string(format='("rms >",f4.1," sigma-->rfi")',$
                    hinfo.sigmatoclip)
        note,ln,lin   ,xp=xp,charsize=csn
        lin=string(format='("bandRejected if rfiFract>",f4.2)',$
            hinfo.rejectfrac)
        note,ln+1*sclln,lin,xp=xp,charsize=csn,color=colrej
        lin=string(format='("binWidth = ",f4.2,"Mhz")',hinfo.frqstp)
        note,ln+2*sclln,lin,xp=xp,charsize=csn
    endif
;   
    return
end
