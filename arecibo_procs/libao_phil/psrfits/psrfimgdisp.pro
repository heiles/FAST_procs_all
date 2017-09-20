;+
;NAME:
;psrfimgdisp - display a set of psrfits records as an image
;SYNTAX: img=psrfimgdisp(desc,b,nsigclip=nsigclip,clip=clip,pollist=pollist,col=col,$
;                  toavg=toavg,median=median,bpc=bpc,ravg=ravg,nobpc=nobpc,$
;                  win=win,wxlen=wxlen,wylen=wylen,wxpos=wxpos,wypos=wypos,$
;                  samewin=samewin,zx=zx,zy=zy,$
;                        rddesc=rddesc,maxrecs=maxrecs,mytitle=mytitle,$
;                   hlind=hlind,hlval=hlval,hldash=hldash,hlvlines=hlvlines,$
;                   useind=useind,ln=ln,chn=chn,cs=cs)
;ARGS:
;     desc : {}     from psrfopen open
;   b[nrecs]: {corget} correlator data to make image of 
;RETURNS:
;   img[nchns,nrecs]: float image of last sbc displayed (before clipping).
;
;KEYWORDS:
;                  
;    nsigClip:float if suppled then clip data to [-sig,sig]*nsigClip
;                   This is done after any averaging for -zx,-zy.
;                   If this is supplied, then clip= is ignored.
;     clip[]: float  value to clip the normalized data to. Default is
;                    .02 (of Tsys). If clip has 1 value then 
;                    normalize to (img > (-clip)) < clip. If two value are
;                    provided, then they will the [min,max].
;    pollist: long   A single number whose decimal digits specify the pols  
;                    to display. eg 1,12,1234 .. pols,3,4 are stokes u,v
;                    The default is pola,polb.
;        win: int window number to plot in. default is 1.
;      wxlen: int xlen of window. default 700
;      wylen: int ylen of window. default 870
;      wxpos: int xpos of lower left edge of window.default 445
;      wypos: int ypos of lower left edge of window.default:35
;    samewin:     if set then use the current dimension for the image win.
;                 If you are calling psrfimgdisp in a loop then setting this
;                 (after the first call) lets the user dynamically adjust the
;                 window size,position.
;         zx: int ..-3,-2,2,3,4 zoom factor x dimension. Negative numbers 
;                   shrink the image positive numbers expand. Negative number 
;                   must divide evenly into the number of channels.
;         zy: int ..-3,-2,2,3,4 zoom factor y dimension (same format as zx)
;     rddesc:       if true then read data using descrtipor. returns
;                   data read in in b.
;     col[2]: int .. x columns to use to flatten the image in the time
;                    direction. count 0..numberoflags-1. If multiple sbc 
;                    plotted then the same cols are used for all sbc. The
;                    default is no flattening in the time direction.
;        chn:        if set then plot vs channel number rather than freq
;        bpc:{masget} if supplied then this data will be used to do the
;                    bandpass correction. The default is to average over
;                    all of the nrecs.
;      nobpc:        if set then no bandpass correction is done.
;     median:        if set and bpc not provided, then bandpass correct using
;                    the median of the nrecs rather than the average.
;       ravg: long   bandpass correct with a running average of ravg spectra
;                    for polB). You can change this with the numspc keyword 
;      numspc: int   number of spectra to display from b (or to read from the
;                    file. The default if b is provided is the entire array.
;                    If reading from the file then we will use about 600 spc.
;                    This will be the count prior to any averaging (see toavg)
;      toavg: long   average this many spectra together before making image.
;                     (zy will to the averaged array).
;   mytitle:string    user supplied tittle instead of scan,srcname,az,za
;                     az,za at top of the plot.
;   hlind[]: ind      index into img array (2nd dimension) to draw
;                     horizontal lines.
;   hlval  : float    value to use for horizontal lines (in img units)
;                     default is clip value.
;   hldash : int      The dash lengths to used for the horizontal lines.
;                     2*ldash must divide into x dimension.default is 4
;   hlvlines:int      Number of engths to used for the horizontal lines.
;                     default=1
;   useind[2]:int     if provided then use these indices from data array
;                     0 .. lengthsbc -1
;                     default=1
;   ln       :int     linenumber for title..0..33 def:3
;   extra_=e          this allows you to input keywords that will be
;                     passed to the plotting routine. eg title=title..
;  
;DESCRIPTION:
;   psrfimgdisp will display a set of psrf spectra as an image.
;By default it will make a separate image for each polA and polB.
;The polList keyword lets you specify polA or polB (and someday maybe
;stokes U,V.
;   You can input the data outside of this routine (eg with psrfget)  by
;setting the keyword rddesc=1 (by default the user passes the data in
; in b.
;
;   By default, the image is bandpass normalized by the average of all the
;records (sbc/avg(pol) - 1). If the median keyword is used then
; avg(sbc) is replaced by median(pol). The bpc keyword allows you to input
;a separate mas record to use as the normalization.
;   The col keyword lets you also flatten the image in the time 
;dimension by specifying the first/last columns to average and then divide 
;into all of the other columns (the columns are counted from 0). By default
;this is not done.
;
;   After bandpass correction and flattening in the time dimension, the
;image is clipped (by default) to +/- .02 (tsys) and then scaled
;from 0 to 256 for the image display. The clip  keyword lets you change the
;clipping value.
;
;   The zx,zy keywords let you scale the image in the x and y dimensions by
;integral amounts. Negative numbers will shrink it by that amount (Note:
;the negative numbers must divide evenly into the number of channels in
;each sbc). -1,0,1 do no scaling. This scaling is only applied for the single
;pol displays. The multiple pol displays are always scaled to fit 
;inside the window (700 by 870 pixels).
;
;   The desc and numspc keywords can be used to input the data directly from
;a file. In this case the desc comes from the psrfopen() routine and numspc
;is the number of spectra to put in the image.
;
;   After displaying the image, use xloadct to manipulate the color table.
;
;   The routine returns the last image displayed (before clipping).
;
;EXAMPLES:
;   input data and make an image
;   istat=masgetm(desc,30,b,/han0  .. input 30 rows with hanning smoothing
;                                  .. assume there are 10 spec/row
;1. display the image of pola and polB
;   img=psrfimgdisp(b)
;2. display only polB, scale y by 2, and x by -2
;   img=psrfimgdisp(b,pol=0,zx=-2,zy=2)
;3. display pola,polB, clip to .015 Tsys , median filter the
;   bandpass correction:
;   img=psrfimgdisp(b,/median,clip=[.015])
;This routine calls imgflat, and imgdisp for the image scaling and display.
;
;NOTE:
;
;SEE ALSO:
;   imgdisp,imgflat
;-
;
function psrfimgdisp,desc,b,clip=clip,pollist=pollist,$
					col=col,$
                    median=median,toavg=toavg,$
                    bpc=bpc,nobpc=nobpc,zx=zx,zy=zy,numspc=numspc,$
                    rddesc=rddesc,mytitle=mytitle,$
                    win=win,wxpos=wxpos,wypos=wypos,wxlen=wxlen,wylen=wylen,$
                    hlind=hlind,hlval=hlval,hldash=hldash,hlvlines=hlvlines,$
                    useind=useind,ln=ln,chn=chn,_extra=e,ravg=ravg,$
                    samewin=samewin,cs=cs
;
;   
;    on_error,1
    defval=.02
    usebpc=0
    xsize=900
    ysize=870
    xpos=445
    ypos=35
    cs=(n_elements(cs) eq 0)?1.8:cs
    if n_elements(pollist) eq 0 then pollist=-1 
    if n_elements(median) eq 0 then median=0
    if n_elements(bpc) ne 0     then usebpc=1
    if n_elements(nobpc) eq 0   then nobpc=0
    if n_elements(zx) eq 0      then zx=1
    if n_elements(zy) eq 0      then zy=1
    if n_elements(win) eq 0     then win=1
    if n_elements(wxlen) ne 0   then xsize=wxlen
    if n_elements(wylen) ne 0   then ysize=wylen
    if n_elements(wxpos) ne 0   then xpos=wxpos
    if n_elements(wypos) ne 0   then ypos=wypos
    if n_elements(col) eq 0     then col=0
	rdDescL=0
    if keyword_set(rdDesc)      then rdDescL=1
    if n_elements(numspc) eq 0  then numspc=400L
    if n_elements(ravg) eq 0    then ravg=0
    if not keyword_set(chn)     then chn=0
    toavgL=(n_elements(toavg) eq 0)?1:toavg
    case  n_elements(clip)  of
        1 : begin
             if clip[0] ne 0 then begin
                minval=-clip
                maxval= clip
            endif else begin
                minval=-defval
                maxval= defval
            endelse
            end
        2 : begin
            minval=clip[0]
            maxval=clip[1]
            end
      else: begin
            minval=-defval
            maxval= defval
            end
    endcase
    clipL=[minval,maxval]
    if (rdDescL) then begin
        istat=psrfget(desc,b)
    endif
    if n_elements(mytitle) ne 0 then begin
        lab=mytitle
    endif else begin
	bsg=stregex(desc.filename,".*b([0-9])s([0-1])g[0-1].*",/extract,/sub)
	beam=fix(bsg[1])
	subband=fix(bsg[2])
    lab=string(format=$
'("Bm",i1,"S",i1," scan:",i9," startSpc:",i5," src:",a," az:",f4.0," za:",f4.1)',$
            beam,subband,$
            desc.haogen.scan_id,(desc.currow-1)*desc.hsubint.nsblk,$
		    desc.hpri.src_name, b[0].tel_az,b[0].tel_zen)
    endelse
;
;   see which pol to plot
;
	npol=desc.hsubint.npol
	if pollist eq -1 then begin
		ipolAr=lindgen(npol)
	endif else begin
        itemp=long(pollist)
		ipolAr=-1
        while itemp gt 0 do begin
        	ival=itemp mod 10
            if (ival gt 0) and (ival le npol) then begin
            	if ipolAr[0] eq -1 then begin
               		ipolAr= ival - 1
                endif else begin
                    ipolAr= [ipolAr, ival - 1] ; 
                endelse
            endif
            itemp=itemp/10L
         endwhile
         ii=sort(ipolAr)
         ipolAr=ipolAr[ii]
	endelse
;
; make sure npolUse and spc row are correct
;
	npolUse=n_elements(ipolAr)
	spcrow=desc.hsubint.nsblk
	nspc  =n_elements(b)*spcrow 	; for 1 pol
	yr1= b[0].offs_sub - b[0].tsubint/2.  ; first spc of this row
	yr2=yr1 + nspc*desc.hsubint.tbin
	yr=[yr1,yr2]
	nchan =desc.hsubint.nchan
    if toavgL gt 1 then begin
		nspc1=(nspc/toavgL)*toavgL
		iend=nspc1-1
	endif
	
;   if single pol
;
    if npolUse eq 1 then begin
		ipol=ipolAr[0]
        blab=string(format='(" pol:",i1)',ipol+1)
        if n_elements(ln) eq 0    then ln=3
        if (zx lt -1) or (zy lt -1) then begin
			!p.multi=0
		endif else begin
			!p.multi=[0,1,1]
		endelse
	    if (spcRow gt 1) then begin
			d=(npol gt 1)?reform(b.data[*,ipol,*],nchan,nspc)$
						 :reform(b.data,nchan,nspc)
		endif else begin
			d=(npol gt 1)?reform(b.data[*,ipol],nchan,nspc)$
						 :b.d
		endelse
        if toAvgL gt 1 then begin
			d=(nspc1 ne nspc)?reform(total(reform(d[*,0:iend],nchan,toavg,nspc1/toavg),2),nchan,nspc1/toavg)$
			                 :reform(total(reform(d,nchan,toavg,nspc1/toavg),2),nchan,nspc1/toavg) 
		endif
							 
				
        if usebpc then begin
            img=imgflat(d,0,col=col,bptouse=bpc.data[*,ipol],nobpc=nobpc)
        endif else begin
            if keyword_set(ravg) then begin
                img=imgflat(d,ravg,median=median,col=col,$
                    nobpc=nobpc,/ravg)
            endif else begin
                if ipol gt 1 then begin
                	img=imgflat(d,0,median=median,col=col,$
                    nobpc=nobpc,bpzero=1.)
				endif else begin
                	img=imgflat(d,0,median=median,col=col,$
                    nobpc=nobpc)
				endelse
            endelse
        endelse
        if keyword_set(chn) then begin
            x=findgen(desc.hsubint.nchan)
            xlab='channel'
        endif else begin
            x=b[0].dat_freq 
            xlab='freq'
        endelse
        if n_elements(hlind) gt 0 then begin
            if n_elements(hldash) eq 0 then hldash=4
            if n_elements(hlvlines) eq 0 then hlvlines=1
            if n_elements(hlval) eq 0 then hlval=maxval
            imghline,img,hlind,hldash,hlvlines,hlval
        endif
        if n_elements(useind) eq 2 then begin
              i1=useind[0]
              i2=useind[1]
              xr=[x[i1],x[i2]]
        imgdisp,img[i1:i2,*],clip=clipL,nsigclip=nsigclip,zx=zx,zy=zy,$
            xrange=xr,win=win,xtitle=xlab+blab,$
                ytitle='time [secs]',_extra=e,samewin=samewin,yr=yr
        endif else begin
              xr=[x[0],x(n_elements(x)-1)]

          imgdisp,img,clip=clipL,nsigclip=nsigclip,zx=zx,zy=zy,$
            xrange=xr,win=win,xtitle=xlab+blab,$
                ytitle='time [secs]',_extra=e,samewin=samewin,yr=yr
        endelse
	    xx=(xr[1]-xr[0])*.01+xr[0]
        yy=(yr[1]-yr[0])*.01 + yr[1]
        xyouts,xx,yy,lab,charsize=cs
;       note,ln,lab,charsize=cs
    endif else begin
        if n_elements(ln) eq 0 then ln=.5
;
;       they want multiple pols
;
        if ((!d.flags and 1) eq 0) and (not keyword_set(samewin))  then begin
           window,win,xsize=xsize,ysize=ysize,xpos=xpos,ypos=ypos
        endif
        for i=0,npolUse-1 do begin
			ipol=ipolAr[i]
            if i eq 0 then begin
                !p.multi=[0,1,npolUse]
            endif else begin
                !p.multi=[npolUse-i,1,npolUse]
            endelse
            blab=string(format='(" pol:",i1)',ipol+1)
            noBpcL=nobpc
			d=(spcRow gt 1)?reform(b.data[*,ipol,*],nchan,nspc)$
                         :reform(b.data[*,ipol],nchan,nspc)
            if toAvgL gt 1 then begin
			   d=(nspc1 ne nspc)?reform(total(reform(d[*,0:iend],nchan,toavg,nspc1/toavg),2),nchan,nspc1/toavg)$
			                    :reform(total(reform(d,nchan,toavg,nspc1/toavg),2),nchan,nspc1/toavg) 
		    endif
            if usebpc then begin
                    img=imgflat(d,0,col=col,$
                           bptouse=bpc.data[*,ipol],nobpc=nobpcL)
            endif else begin
                    img=(ipol gt 1)$
					?imgflat(d,0,median=median,col=col,nobpc=nobpc,bpzero=1.)$
					:imgflat(d,0,median=median,col=col,nobpc=nobpc) 
            endelse
            if keyword_set(chn) then begin
                x=findgen(desc.hsubint.nchan)
                xlab='channel'
            endif else begin
                x=b[0].dat_freq
                xlab='freq'
            endelse
            if n_elements(hlind) gt 0 then begin
                if n_elements(hldash) eq 0 then hldash=4
                if n_elements(hlvlines) eq 0 then hlvlines=1
                if n_elements(hlval) eq 0 then hlval=maxval
                imghline,img,hlind,hldash,hlvlines,hlval
            endif
            if n_elements(useind) eq 2 then begin
              i1=useind[0]
              i2=useind[1]
              xr=[x[i1],x[i2]]
              imgdisp,(img[i1:i2,*] > minval)<maxval,zx=zx,zy=zy,charsize=cs,$
              xrange=xr,win=win,xtitle=xlab+blab,yr=yr,$
              ytitle='time [secs]',_extra=e,samewin=samewin
            endif else begin
              xr=[x[0],x(n_elements(x)-1)]
              imgdisp,(img > minval)<maxval,zx=zx,zy=zy,charsize=cs,$
              xrange=xr,win=win,xtitle=xlab+blab,$
              ytitle='time [secs]',_extra=e,samewin=samewin,yr=yr
            endelse
        endfor
		xx=(xr[1]-xr[0])*.01+xr[0]
        yy=(yr[1]-yr[0])*.01 + yr[1]
        xyouts,xx,yy,lab,charsize=cs
;        note,ln,lab,charsize=cs
    endelse
;    !p.multi=0
    return,img
end
