;+ 
;NAME:
;masplotmb - plot mas multi beam data
;SYNTAX : masplotmb,b,brdlist=brdlist,vel=vel,rest=rest,off=ploff,pol=pol,
;                   over=over,nolab=nolab,extitle=extitle,newtitle=newtitle,
;                   col=col,sym=sym,chn=chn,$
;                   xtitle=xtitle,ytitle=ytitle,flag=flag,lnsflag=lnsflag
;ARGS:
;       b:  {corget} data to plot
;KEYWORDS:
; brdlist: int   number containing the boards to plot. To plot boards
;                1,3,5,7 use brdlist=1357.By default all boards are plotted.
;                This replaces the m= keyword.
;     vel:       if set, then plot versus velocity
;    rest:       if set, then plot versus rest frequency
;     off: float if plotting multiple integrations then this is the
;                offset to add between each plot of a single sbc. def 0.
;     pol: int   if set, then plot only one of the pol(1,2 ..3,4 for stokes)
;   norm :       if set then normalize the spectra for a given pol,beam before
;                plotting..
;    over:       if set then overplot with whatever was previously plotted.
;                This only works if you plot 1 sbc at a time (eg m=1).
;   nolab:       if set then don't plot the power level labels in the middle
;                of the plot for stokes data.
; extitle: string add to title line
;newtitle: string replace title line
;  xtitle: string title for x axis
;  ytitle: string title for y axis
;  col[4]: int   Change the order of the default colors. The 
;                order is PolA,polB,stokesU,stokesV colors.
;                values are:1=white(on black),2-red,3=green,4=blue,5=yellow
;     sym: int   symbol to plot at each point. The symbols are labeled
;                1 to 9. Positive numbers only plot the symbol (no 
;                connecting lines). Negative numbers (-1 to -9) plots the 
;                symbol and a connecting line. sym=10 will plot in 
;                histogram mode.
;     chn:       if set then plot vs channel
;   flag[]: float if present then flag each of these channels with a vertical
;                line. The units should be that of the x axis (Mhz,chan, or 
;                km/sec). 
;   lnsflag: int linestyle for flag. 0=solid 1-dashed,2=dashed,3=dots
;
;DESCRIPTION:
;   masplotmb will plot the mas spectra. The data should come from
;masavgmb(). If one dimension, then the dimension is over beams. If 
;two dimensions then b[nspc,nbeams].
;You can plot:
; - any combination of sbc using pol=pol and brdlist
; - by topocentric frequency (defaul), rest frequency, or by velocity
; - make a strip plot if b is an array by using off=ploff.
;EXAMPLES:
;   masavgmb(yymmdd,projid,filenum,b1,b2,...)
;   masplotmb,b1            plot all sbc
;   masplotmb,b,brd=1       plot first brd (beam 0)
;   masplotmb,b,brd=2       plot 2nd brd (beam 1)
;   masplotmb,b,brd=3,pol=2 plot 3rd brd (beam 2),polB only
;   masplotmb,b,brd=4,pol=1 plot 4th brd (beam 3) pola only
;   masplotmb,b,brd=13,/vel plot 1st and 3rd brds (beam 0,2 ) by velocity
;   masplotmb,b[1],brd=1,/over,col=[5,5]
;NOTE: 
;   use hor,ver to set the plotting scale.
;   oveplotting only works if you display 1 brd at a time.
;SEE ALSO:
;   masavgmb. hor,ver in the generic idl routines.
;- 
;modhistory:
;
pro masplotmb,b,vel=vel,rest=rest,off=pltoff,pol=pol,over=over,$
            nolab=nolab,extitle=extitle,newtitle=newtitle,col=col,sym=sym,$
            chn=chn,xtitle=xtitle,ytitle=ytitle,brdlist=brdlist,$
            flag=flag,lnsflag=lnsflag,norm=norm
;
; plot mas spectra
;
; setup the color table
; 1 - white
; 2 - red       pol A
; 3 - green     pol B
; 4 - bluen     stokes u
; 5 - yellow    stokes V
;
    forward_function isecmidhms3,corfrq
    common colph,decomposedph,colph
    on_error,1

	mjdtojd=2400000.5D
	if n_elements(lnsflag) eq 0 then lnsflag=2
    xptitle=.02
    lntitle=.8
    if ( n_elements(vel)  eq 0) then vel = 0
    if ( n_elements(rest) eq 0) then rest=0
    if not keyword_set(nolab) then nolab=0
    if n_elements(extitle) eq 0  then extitle=''
    if n_elements(sym) eq 0 then sym=0
    if n_elements(xtitle) eq 0 then xtitle=''
    if n_elements(ytitle) eq 0 then ytitle=''
	usenorm=keyword_set(norm)
    bychn=0
    if keyword_set(chn) then bychn=1
    ps= !d.flags and 1  
    colphLoc=colph[0:5]
    if ps eq 0 then begin
       tvlct,[0,1,1,0,0,1]*255,[0,1,0,1,0,1]*255,[0,1,0,0,1,0]*255
    endif else begin
       colphLoc=[0,1,2,3,4,5]       ; force pseudo col
    endelse
    k=[2,3,4,5]
    n=n_elements(col)
    if n gt 0 then begin
        for i=0,4 - 1 do begin 
            if i ge n then begin
                k[i]=col[n-1] 
            endif else begin
                k[i]=col[i] 
            endelse
        endfor
    endif
    white=1
;
;
	if n_elements(brdlist) ne 0 then begin
    	itemp=long(brdlist)
        plttmp=0L
        while itemp gt 0 do begin
        	ival=itemp mod 10
            if ival gt 0 then plttmp=plttmp or ( ishft(1,ival-1))
           	itemp=itemp/10L
        endwhile
    endif else begin
    	plttmp='ff'x
    endelse
    if (n_elements(pltoff) eq 0) then pltoff=0.
    if (n_elements(pol) eq 0) then pol=0
    if (not keyword_set(over) ) then over=0
    if (plttmp eq 0 ) then plttmp='ff'x
	a=size(b)
	ndim2=(a[0] eq 2)
    nbms=(ndim2)?a[2]:a[1]
	nspc=(ndim2)?a[1]:1
	npols=b[0].npol
    numplts=0
	nchan=b[0].nchan
    pltit=intarr(nbms)                 ; do we plot this boards output?
    bmNmAr=strarr(nbms)
    for i=0,nbms-1 do begin
		bmNum=(ndim2)?b[0,i].h.beam:b[i].h.beam
        bmNmAr[i]=string(format='("B",i1)',bmNum)
        pltit[i]= (plttmp and 1)
        numplts=numplts+pltit[i]
        plttmp=ishft(plttmp,-1)
    endfor
    if (numplts gt 2) then across=2 else across=1
    case 1 of
        numplts eq 1: down=1
        numplts eq 2: down=2
        else        : down=(numplts+1)/2
    endcase
    if not over then begin
        !p.multi=[0,across,down]
    endif else begin
        plotsleft=across*down
        !p.multi=[plotsleft,across,down]
    endelse
    cslab=1.
    if down gt 2 then csLab=1.6
;
; create the title for plot 1
;
	astFract=4./24d
	caldat,b[0].h.mjdxxobs -astFract + mjdtojd,mon,day,yr,hour,min,sec
    src=b[0].h.object
    proc=b[0].h.obsmode
    title=string(format='(A," ",I9," rec:",I4," tm:",i2,":",i2,":",i2," ",A)', $
      src,b[0].h.scan_id,b[0].h.recnum,hour,min,sec,proc)
    title=title+extitle
    if n_elements(newtitle) gt 0 then title=newtitle
    autoscale=0
	if (usenorm) then begin
    	if (!y.range[0] eq 0.) and (!y.range[1] eq 0.) then ver,0,2
	endif else begin
    	if (!y.range[0] eq 0.) and (!y.range[1] eq 0.) then autoscale=1
	endelse
;
; figure out size of char B in normalize coord for 
; writin B1
;
    xyouts,0,0,'B',width=bwidth,charsize=-1,/norm
    bxoff= bwidth*1. *cslab
    byoff= bwidth*1.5*cslab
;
;   loop plotting the data
;
    labcnt=0
	x=(bychn)?findgen(nchan):masfreq(b[0].h)
    for ibm=0 ,nbms - 1 do begin 
    	if pltit(ibm) then begin
            pltx=0                       ; no x scale yet
           	for ipol=0,npols-1 do begin 
        		pltoffcum=0.
                if (pol ne 0) and (ipol ne (pol-1)) then continue
               	if  pltx eq 0 then begin
;
;          figure out y scaling 
;
                   	if  over then begin
                    	!p.multi=[plotsleft,across,down]
                    endif 
                    if autoscale then begin
                    	if (pol eq 0) then begin
                        	ymin=(ndim2)?min(b[*,ibm].d,max=ymax)$
                                        :min(b[ibm].d,max=ymax) 
                        endif else begin
                            ymin=(ndim2)?min(b[*,ibm].d[*,ipol],max=ymax)$
                                        :min(b[ibm].d[*,ipol],max=ymax) 
                        endelse
;                       if not finite, skip board
                        ind=where(finite([ymin,ymax]) eq 0,count)
                        if count gt 0 then begin
                        	print,'skip board:',i+1,' data not finite'
                            goto,donebrd
                        endif
                    endif else begin
                    	ymin=!y.range[0]
                        ymax=!y.range[1]
                    endelse
;                   print,ymin,ymax,' autoscl:',autoscale,pol
;                   print,x[0],xmax 
                    plot, x,[ymin,ymax],color=colphLoc[white],/xstyle,$
                          /ystyle,/nodata,psym=sym,ytitle=ytitle,$
                            xtitle=xtitle,charsize=cslab
                    if title ne "" then begin
                         xx=!x.window[0] + bxoff
                         yy=!y.window[1] 
                         xyouts,xx,yy+bwidth,title,/norm,charsize=1.25
                    endif
                    xx=!x.window[0] + bxoff
                    yy=!y.window[1] - byoff
                    xyouts,xx,yy,bmNmAr[ibm],/norm
                    title=""
                    pltx=1
                endif
				yscale=1.
            	for ispc=0,nspc - 1 do begin ; if array loop over whole array
					if (ispc eq 0) and (usenorm) then begin
						yscale=(ndim2)? 1./median(b[*,ibm].d[*,ipol]) $
						              : 1./median(b[ibm].d[*,ipol])  
;						print,"ibm:",ibm," ipol:",ipol," yscale:",yscale
					endif
                   	if pltoff ne 0. then begin
				    	if (ndim2) then begin
                  			oplot,x,b[ispc,ibm].d[*,ipol]*yscale+pltoffcum,$
                        	 	color=colphLoc[k[ipol]],psym=sym
			   			endif else begin
                       		oplot,x,b[ibm].d[*,ipol]*yscale+pltoffcum,$
                         	 		color=colphLoc[k[ipol]],psym=sym
					   	endelse
             		    pltoffcum=pltoffcum+pltoff
                    endif else begin
						if (ndim2) then begin
                       		oplot,x,b[ispc,ibm].d[*,ipol]*yscale,$
                       	 		color=colphLoc[k[ipol]],psym=sym
					   	endif else begin
                       		oplot,x,b[ibm].d[*,ipol]*yscale,$
                       	 		color=colphLoc[k[ipol]],psym=sym
					   	endelse
                    endelse
             	endfor  ; end loop over array this pol
           endfor   ; end loop over pols
        if over then plotsleft=plotsleft-1
           if n_elements(flag) gt 0 then flag,flag,linestyle=lnsflag
    endif       ; endif plot this board
donebrd:
    endfor      ; end loop over brds
    return
end
