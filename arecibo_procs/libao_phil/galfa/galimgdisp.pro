;+
;NAME:
;galimgdisp - display a set of correlator records as an image
;SYNTAX: img=galimgdisp(b,clip=clip,brdlist=brdlist,pol=pol,col=col,$
;                   median=median,bpc=bpc,ravg=ravg,nobpc=nobpc,$
;                   win=win,wxlen=wxlen,wylen=wylen,wxpos=wxpos,wypos=wypos,$
;                   samewin=samewin,zx=zx,zy=zy,$
;                   mytitle=mytitle,$
;                   hlind=hlind,hlval=hlval,hldash=hldash,hlvlines=hlvlines,$
;                   useind=useind,ln=ln,chn=chn)
;ARGS:
;   b[nrecs]: {corget} correlator data to make image of 
;RETURNS:
;   img[nchns,nrecs]: float image of last brd displayed (before clipping).
;
;KEYWORDS:
;                  
;         wb:        if set then take the data from the wide band.
;     clip[]: float  value to clip the normalized data to. Default is
;                    .1 of Tsys (3 sigma for 1 sec integratio for nb).
;                    If clip has 1 value then 
;                    normalize to (img > (-clip)) < clip. If two value are
;                    provided, then they will the [min,max].
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
;                 If you are calling galimgdisp in a loop then setting this
;                 (after the first call) lets the user dynamically adjust the
;                 window size,position.
;         zx: int ..-3,-2,2,3,4 zoom factor x dimension. Negative numbers 
;                   shrink the image positive numbers expand. Negative number 
;                   must divide evenly into the number of channels.
;         zy: int ..-3,-2,2,3,4 zoom factor y dimension (same format as zx)
;     col[2]: int .. x columns to use to flatten the image in the time
;                    direction. count 0..numberoflags-1. If multiple boards 
;                    plotted then the same cols are used for all boards. The
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
;   galimgdisp will display a set of correlator records (usually a scans
;worth) as an image. By default it will make a separate image for each
;subcorrelator (board). The brdlist  keyword lets you choose just 1 brd to
; image. The data for the image is taken from polA  by default. 
;Use the pol keyword to make the image from the other polarization. 
;If you use the /wb keyword then the wide band data will be used.
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
;image is clipped (by default) to +/- .1 (tsys) and then scaled
;from 0 to 256 for the image display. The clip  keyword lets you change the
;clipping value.
;
;   The zx,zy keywords let you scale the image in the x and y dimensions by
;integral amounts. Negative numbers will shrink it by that amount (Note:
;the negative numbers must divide evenly into the number of channels in
;each brd). -1,0,1 do no scaling. This scaling is only applied for the single
;brd displays. The multiple brd displays are always scaled to fit 
;inside the window (700 by 870 pixels).
;
;   After displaying the image, use xloadct to manipulate the color table.
;
;   The routine returns the last image displayed (before clipping).
;
;EXAMPLES:
;   input a scans worth of data.
;   print,corgetm(desc,600,b,/han)    .. input scan with hanning smoothing
;1. display the image of all 7 brds.
;   img=galimgdisp(b)
;   img=galimgdisp(b,/wb) display the wide band data.
;2. display only brd 2, scale y by 2, and x by -2
;   img=galimgdisp(b,brdlist=1,zx=-2,zy=2)
;3. display all 7, clip to .015 Tsys , display polB and median filter the
;   bandpass correction:
;   img=galimgdisp(b,pol=2,/median)
;4. display all brds 1,2,3,4 , clip to .015 Tsys , 
;   display polB and median filter the bandpass correction:
;
;   img=galimgdisp(b,brdlist=1234,pol=2,/median)
;
;This routine calls imgflat, and imgdisp for the image scaling and display.
;
;NOTE:
;   When displaying only 1 brd and using zx fopr shrinking the image,
; zx must divide into the number of channels. For the narrow only zx=-7
; works since 7679/7=1097 and 1097 is prime.
;
;SEE ALSO:
;   imgdisp,imgflat
;-
;29jan05 : if brdlist passed in make sure they don't request 
;          more brds than are available..
;11may05 : if pol 2,3,4  then use bpZero keyword to imgflat
;
function galimgdisp,b,wb=wb,clip=clip,brdlist=brdlist,pol=pol,col=col,$
                    median=median,$
                    bpc=bpc,nobpc=nobpc,zx=zx,zy=zy,scan=scan,lun=lun,sl=sl,$
                    han=han,maxrecs=maxrecs,mytitle=mytitle,$
                    win=win,wxpos=wxpos,wypos=wypos,wxlen=wxlen,wylen=wylen,$
                    hlind=hlind,hlval=hlval,hldash=hldash,hlvlines=hlvlines,$
                    useind=useind,ln=ln,chn=chn,_extra=e,ravg=ravg,$
                    samewin=samewin
;
;   
    on_error,1
    usebpc=0
    xsize=700
    ysize=870
    xpos=445
    ypos=35
    cs=1.8
    if n_elements(brdlist) eq 0 then brdlist=-1
    usewb=keyword_set(wb)
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
    if n_elements(ravg) eq 0    then ravg=0
    if not keyword_set(chn)     then chn=0
    maxchn=(usewb) ? 512 : 7679
    if n_elements(col) eq 2 then begin
      if (col[0] lt 0 ) or (col[1] ge maxchn) then begin
         print,' Col keyword must be between 0 511 for wb and 0 7679 for nb'
         return,''
      endif
    endif
    defval=(usewb)?.01:.1
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
    ipol=pol-1              ; 0..1
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
    usegal=1
;
;   if single sbc 
;
    if (brdlist ne -1) and (brdlist lt 8) then begin
        ibrd=brdlist-1
        blab=string(format='(" Brd:",i1)',brdlist)
        if n_elements(ln) eq 0    then ln=3
        !p.multi=0
        img=(usewb)?(b.(ibrd).hf.g_wide[*,ipol]) $
                   :(b.(ibrd).d[*,ipol])
        if usebpc then begin
           bp=(usewb)?bpc.(ibrd).hf[*,ipol] $
                     :bpc.(ibrd).d[*,ipol]
           img=imgflat(img,0,col=col,$
                    bptouse=bp,nobpc=nobpc)
        endif else begin
            if keyword_set(ravg) then begin
                img=imgflat(img,ravg,median=median,col=col,$
                    nobpc=nobpc,/ravg)
            endif else begin
                img=imgflat(img,0,median=median,col=col,$
                    nobpc=nobpc)
            endelse
        endelse
        if keyword_set(chn) then begin
            nn=(usewb)?n_elements(b[0].b1.hf.g_wide[*,0]) $
                      :b[0].(ibrd).h.cor.lagsbcout
            x=findgen(nn)
            xlab='channel'
        endif else begin
            x=corfrq(b[0].(ibrd).hf,wb=usewb)
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
                ytitle='record',_extra=e
        endif else begin
          imgdisp,(img > minval)<maxval,zx=zx,zy=zy,$
            xrange=[x[0],x(n_elements(x)-1)],win=win,xtitle=xlab+blab,$
                ytitle='record',_extra=e
        endelse
            note,ln,lab,charsize=cs
    endif else begin
        if n_elements(ln) eq 0 then ln=.5
;
;       they want a subset of the brds
;
        nbrds=b[0].b1.h.cor.numbrdsused 
        if brdlist ne -1 then begin
            ibrdAr= -1
            itemp=long(brdlist)
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
        for ibrd=0,nbrds-1 do begin
            if ibrd eq 0 then begin
                !p.multi=[0,1,nbrds]
            endif else begin
                !p.multi=[nbrds-ibrd,1,nbrds]
            endelse
            ii=ibrdAr[ibrd]
            blab=string(format='(" Brd:",i1)',ii+1)
            noBpcL=nobpc
            img=(usewb)?(b.(ii).hf.g_wide[*,ipol]) $
                       :(b.(ii).d[*,ipol])
            if usebpc then begin
                     bp=(usewb)?bpc.(ii).hf[*,ipol] $
                               :bpc.(ii).d[*,ipol]
                    img=imgflat(img,0,col=col,$
                           bptouse=bp,nobpc=nobpcL)
            endif else begin
                img=imgflat(img,0,median=median,col=col,nobpc=nobpcL)
            endelse
            if keyword_set(chn) then begin
                 nn=(usewb)?n_elements(b[0].b1.hf.g_wide[*,0]) $
                           :b[0].(ii).h.cor.lagsbcout
                x=findgen(nn)
                xlab='channel'
            endif else begin
                x=corfrq(b[0].(ii).hf,wb=usewb) 
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
              ytitle='record',_extra=e
            endif else begin
              imgdisp,(img > minval)<maxval,zx=zx,zy=zy,charsize=cs,$
              xrange=[x[0],x(n_elements(x)-1)],win=win,xtitle=xlab+blab,$
              ytitle='record',_extra=e
            endelse
        endfor
        note,ln,lab,charsize=cs
    endelse
;    !p.multi=0
    return,img
end
