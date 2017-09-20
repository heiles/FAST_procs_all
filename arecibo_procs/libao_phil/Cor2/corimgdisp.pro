;+
;NAME:
;corimgdisp - display a set of correlator records as an image
;SYNTAX: img=corimgdisp(b,clip=clip,sbc=sbc,brdlist=brdlist,pol=pol,col=col,$
;                   median=median,bpc=bpc,ravg=ravg,nobpc=nobpc,$
;                   win=win,wxlen=wxlen,wylen=wylen,wxpos=wxpos,wypos=wypos,$
;                   samewin=samewin,zx=zx,zy=zy,$
;                   scan=scan,lun=lun,han=han,maxrecs=maxrecs,mytitle=mytitle,$
;                   hlind=hlind,hlval=hlval,hldash=hldash,hlvlines=hlvlines,$
;                   useind=useind,ln=ln,chn=chn)
;ARGS:
;   b[nrecs]: {corget} correlator data to make image of 
;RETURNS:
;   img[nchns,nrecs]: float image of last sbc displayed (before clipping).
;
;KEYWORDS:
;                  
;     clip[]: float  value to clip the normalized data to. Default is
;                    .02 (of Tsys). If clip has 1 value then 
;                    normalize to (img > (-clip)) < clip. If two value are
;                    provided, then they will the [min,max].
;        sbc: int 1-4. sub correlator to plot. default is all 4.
;    brdlist: long   A single number whose decimal digits specify the boards
;                    to display. eg brds 1,2,3,4 would be: brdlist=1234
;                    The boards are numbered 1 thru 8.
;        pol: int 1,2, (3,4 if stokes)  polarization to plot. default is 1:polA
;        win: int window number to plot in. default is 1.
;      wxlen: int xlen of window. default 700
;      wylen: int ylen of window. default 870
;      wxpos: int xpos of lower left edge of window.default 445
;      wypos: int ypos of lower left edge of window.default:35
;    samewin:     if set then use the current dimension for the image win.
;                 If you are calling corimgdisp in a loop then setting this
;                 (after the first call) lets the user dynamically adjust the
;                 window size,position.
;         zx: int ..-3,-2,2,3,4 zoom factor x dimension. Negative numbers 
;                   shrink the image positive numbers expand. Negative number 
;                   must divide evenly into the number of channels.
;         zy: int ..-3,-2,2,3,4 zoom factor y dimension (same format as zx)
;     col[2]: int .. x columns to use to flatten the image in the time
;                    direction. count 0..numberoflags-1. If multiple sbc 
;                    plotted then the same cols are used for all sbc. The
;                    default is no flattening in the time direction.
;        chn:        if set then plot vs channel number rather than freq
;        bpc:{corget} if supplied then this data will be used to do the
;                    bandpass correction. The default is to average over
;                    all of the nrecs.
;      nobpc:        if set then no bandpass correction is done.
;     median:        if set and bpc not provided, then bandpass correct using
;                    the median of the nrecs rather than the average.
;       ravg: long   bandpass correct with a running average of ravg spectra
;     scan  : long   if provided,then routine will input scans data into
;                    b[] before making image. In this case you must also
;                    supply the lun keyword to tell the routine where to
;                    read from.
;       lun : int    if scan keyword provided, then you must also supply
;                    this keyword. It should contain the lun for the 
;                    corfile that you have previously opened.
;       sl[]:{scanlist} This array can be used for direct access when the
;                     scan keyword is used. The sl[] (scanlist) array is
;                     returned from the sl=getsl(lun) routine. The routine
;                     scans the entire file recording where the scans start.
;       han:          if set and scan keyword set, then hanning smooth the
;                     data on input.
;   maxrecs: int      if lun used then the max records of a scan to input.
;                     default:300
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
;   Corimgdisp will display a set of correlator records (usually a scans
;worth) as an image. By default it will make a separate image for each
;subcorrelator (board). The sbc keyword lets you choose just 1 sbc to image.
;The data for the image is taken from polA  by default. Use the pol keyword 
;to make the image from the other polarization.
;   You can input the data outside of this routine (eg with corinpscan) or 
;use the scan,lun keywords to have corimgdisp input the data directly. 
;
;   By default, the image is bandpass normalized by the average of all the
;records (sbc/avg(sbc) - 1). If the median keyword is used then
; avg(sbc) is replaced by median(sbc). The bpc keyword allows you to input
;a separate correlator record to use as the normalization.
;   The col keyword lets you also flatten the image in the time (record)
;dimension by specifying the first/last columns to average and then divide 
;into all of the other columns (the columns are counted from 0). By default
;this is not done.
;
;   After bandpass correction and flattening in the record dimension, the
;image is clipped (by default) to +/- .02 (tsys) and then scaled
;from 0 to 256 for the image display. The clip  keyword lets you change the
;clipping value.
;
;   The zx,zy keywords let you scale the image in the x and y dimensions by
;integral amounts. Negative numbers will shrink it by that amount (Note:
;the negative numbers must divide evenly into the number of channels in
;each sbc). -1,0,1 do no scaling. This scaling is only applied for the single
;sbc displays. The multiple sbc displays are always scaled to fit 
;inside the window (700 by 870 pixels).
;
;   The scan keyword can be used to input the data directly from a file.
;In this case the scannumber is the scan keyword value and the lun keyword
;should be set the the logical unit number of the already open file. The
;sl keyword can be used to do direct access to the file. It's argument
;comes from a call to sl=getsl(lun) prior to calling this routine.
;
;   After displaying the image, use xloadct to manipulate the color table.
;
;   The routine returns the last image displayed (before clipping).
;
;EXAMPLES:
;   input a scans worth of data.
;   print,corinpscan(lun,b,/han)    .. input scan with hanning smoothing
;1. display the image of all 4 sbc.
;   img=corimgdisp(b)
;2. display only sbc 2, scale y by 2, and x by -2
;   img=corimgdisp(b,sbc=1,zx=-2,zy=2)
;3. display all 4, clip to .015 Tsys , display polB and median filter the
;   bandpass correction:
;   img=corimgdisp(b,pol=2,/median)
;4. assume scan 12730084 in an on position and 12730085 is the off position.
;   Suppose you want to display the on image normalized by the off.
;   scan=12730084L
;   print,corinpscan(lun,bon,scan=scan,/han)
;   print,corinpscan(lun,boff,scan=scan+1,/han)
;   bpc=coravgint(boff)             ; compute the average of the off.
;   img=corimgdisp(bon,bpc=bpc)
;5. Have the routine input and plot a scans worth of data:
;   openr,lun,'/share/olcor/corfile.27sep01.x101.1',/get_lun
;   scan=12730084L
;   img=corimgscan(b,lun=lun,scan=scan)
;6. Have the routine input and plot a scans worth of data, use the sl
;   keyword for direct access.
;   openr,lun,'/share/olcor/corfile.27sep01.x101.1',/get_lun
;   sl=getsl(lun)
;   scan=12730084L
;   img=corimgscan(b,lun=lun,scan=scan,sl=sl)
;
;This routine calls imgflat, and imgdisp for the image scaling and display.
;
;NOTE:
;   For stokes channels q,u,v the bandpass flattening is done by offseting
;the mean bp by 1. and dividing (should actually divide by sqrt(pola*polB)..:
;
;SEE ALSO:
;   Imgdisp,imgflat
;-
;29jan05 : if brdlist passed in make sure they don't request 
;          more brds than are available..
;11may05 : if pol 2,3,4  then use bpZero keyword to imgflat
;
function corimgdisp,b,clip=clip,sbc=sbc,brdlist=brdlist,pol=pol,col=col,$
                    median=median,$
                    bpc=bpc,nobpc=nobpc,zx=zx,zy=zy,scan=scan,lun=lun,sl=sl,$
                    han=han,maxrecs=maxrecs,mytitle=mytitle,$
                    win=win,wxpos=wxpos,wypos=wypos,wxlen=wxlen,wylen=wylen,$
                    hlind=hlind,hlval=hlval,hldash=hldash,hlvlines=hlvlines,$
                    useind=useind,ln=ln,chn=chn,_extra=e,ravg=ravg,$
                    samewin=samewin
;
;   
;    on_error,1
    defval=.02
    usebpc=0
    xsize=700
    ysize=870
    xpos=445
    ypos=35
    cs=1.8
    if n_elements(sbc) eq 0     then sbc=-1
    brdlistL=-1
    if n_elements(brdlist) ne 0 then brdListL=brdList
    if not keyword_set(pol)    then pol=1
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
    if n_elements(sl) eq 0      then sl=0
    if n_elements(scan) eq 0    then scan=-1L
    if n_elements(maxrecs) eq 0    then maxrecs=0L
    if n_elements(ravg) eq 0    then ravg=0
    if not keyword_set(chn)     then chn=0
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
    lpol=pol-1              ; 0..1
    lsbc=sbc-1
    if (scan ne -1L) then begin
       if n_elements(lun) eq 0 then $
        message,'You must use lun=lun with the scan keyword '
        istat=corinpscan(lun,b,scan=scan,sl=sl,han=han,maxrecs=maxrecs)
    endif
    if n_elements(mytitle) ne 0 then begin
        lab=mytitle
    endif else begin
    lab=string(format='("scan:",i9," src:",a," az:",f4.0," za:",f4.1)',$
            b[0].b1.h.std.scannumber,string(b[0].b1.h.proc.srcname),$
            b[0].b1.h.std.azttd*.0001,b[0].b1.h.std.grttd*.0001)
    endelse
;
;  if galfa then we need to pass the .hf header to corfrq..
;
    usegal=0
    if (strpos((tag_names(b[0].(0)))[1],'HF') eq 0 ) then begin
        usegal=size(b[0].b1.hf.(0),/type) eq 3   ; for was it's string not long
    endif
        
;
;   if single sbc 
;
    if sbc ne -1 then begin
        blab=string(format='(" Brd:",i1)',sbc)
        if n_elements(ln) eq 0    then ln=3
        !p.multi=0
        if usebpc then begin
            img=imgflat(b.(lsbc).d[*,lpol],0,col=col,$
                    bptouse=bpc.(lsbc).d[*,lpol],nobpc=nobpc)
        endif else begin
            if keyword_set(ravg) then begin
                img=imgflat(b.(lsbc).d[*,lpol],ravg,median=median,col=col,$
                    nobpc=nobpc,/ravg)
            endif else begin
                bpZero=((b[0].(lsbc).h.cor.numsbcout eq 4)  and (lpol gt 0))? $
                            1.:0 
                img=imgflat(b.(lsbc).d[*,lpol],0,median=median,col=col,$
                    nobpc=nobpc,bpzero=bpZero)
            endelse

        endelse
        if keyword_set(chn) then begin
            x=findgen(b[0].(lsbc).h.cor.lagsbcout)
            xlab='channel'
        endif else begin
            x=(usegal)?corfrq(b[0].(lsbc).hf) : corfrq(b[0].(lsbc).h)
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
        imgdisp,(img[i1:i2,*] > minval)<maxval,zx=zx,zy=zy,$
            xrange=[x[i1],x[i2]],win=win,xtitle=xlab+blab,$
                ytitle='record',_extra=e,samewin=samewin
        endif else begin
          imgdisp,(img > minval)<maxval,zx=zx,zy=zy,$
            xrange=[x[0],x(n_elements(x)-1)],win=win,xtitle=xlab+blab,$
                ytitle='record',_extra=e,samewin=samewin
        endelse
            note,ln,lab,charsize=cs
    endif else begin
        if n_elements(ln) eq 0 then ln=.5
;
;       they want a subset of the brds
;
        nbrds=b[0].b1.h.cor.numbrdsused 
        if brdlistL ne -1 then begin
            ibrdAr= -1
            itemp=long(brdlistL)
            while itemp gt 0 do begin
                ival=itemp mod 10
                if (ival gt 0) and (ival le nbrds) then begin
                    if ibrdAr[0] eq -1 then begin
                        ibrdAr= ival - 1
                    endif else begin
                        ibrdAr= [ibrdAr, ival - 1] ; store index for b.()
                    endelse
                endif
                itemp=itemp/10L
            endwhile
            ii=sort(ibrdAr)
            ibrdAr=ibrdAr[ii]
            nbrds=n_elements(ibrdAr)
        endif else begin
            ibrdAr=lindgen(nbrds)
        endelse
        if ((!d.flags and 1) eq 0) and (not keyword_set(samewin))  then begin
           window,win,xsize=xsize,ysize=ysize,xpos=xpos,ypos=ypos
        endif
        for lsbc=0,nbrds-1 do begin
            if lsbc eq 0 then begin
                !p.multi=[0,1,nbrds]
            endif else begin
                !p.multi=[nbrds-lsbc,1,nbrds]
            endelse
            ii=ibrdAr[lsbc]
            blab=string(format='(" Brd:",i1)',ii+1)
;           noBpcL=nobpc or ((b.(ii).h.cor.numsbcout eq 4) and (lpol gt 0))
            noBpcL=nobpc
            if usebpc then begin
                    img=imgflat(b.(ii).d[*,lpol],0,col=col,$
                           bptouse=bpc.(ii).d[*,lpol],nobpc=nobpcL)
            endif else begin
                bpZero=((b[0].(ii).h.cor.numsbcout eq 4)  and (lpol gt 0))? $
                            1.:0 
                img=imgflat(b.(ii).d[*,lpol],0,median=median,col=col,$
                            nobpc=nobpcL,bpZero=bpZero)
            endelse
            if keyword_set(chn) then begin
                x=findgen(b[0].(ii).h.cor.lagsbcout)
                xlab='channel'
            endif else begin
                x=(usegal)?corfrq(b[0].(ii).hf) : corfrq(b[0].(ii).h)
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
              imgdisp,(img[i1:i2,*] > minval)<maxval,zx=zx,zy=zy,charsize=cs,$
              xrange=[x[i1],x[i2]],win=win,xtitle=xlab+blab,$
              ytitle='record',_extra=e,samewin=samewin
            endif else begin
              imgdisp,(img > minval)<maxval,zx=zx,zy=zy,charsize=cs,$
              xrange=[x[0],x(n_elements(x)-1)],win=win,xtitle=xlab+blab,$
              ytitle='record',_extra=e,samewin=samewin
            endelse
        endfor
        note,ln,lab,charsize=cs
    endelse
;    !p.multi=0
    return,img
end
