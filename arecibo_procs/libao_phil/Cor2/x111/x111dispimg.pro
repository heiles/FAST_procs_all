; 
;
function x111dispimg,img,imghdr,freq=freq,bw=bw,histeq=histeq,lab=lab,$
    xpix=xpix,ypix=ypix,win=win,prof=prof,wsize=wsize,flat=flat,$
    rdpix=rdpix
;
;   display the image with labels
;
    minHEq=-3.
    maxHEq=3.
    winxmax=1152
    winymax= 900
    doflat=0
    sz=size(img)
    if not keyword_set(xpix) then xpix=861
    if not keyword_set(ypix) then ypix=593
    if not keyword_set(histeq) then histeq=0
    if not keyword_set(lab) then lab=' '
    if not keyword_set(rdpix) then rdpix=0
    if not keyword_set(prof) then prof=0
;
    if n_params() eq 2 then begin
        freq=imghdr.cfr
          bw=imghdr.bw
          if imghdr.fltnnum gt 0 then begin
            flat=[imghdr.fltnst,imghdr.fltnst+imghdr.fltnnum-1]
            doflat=1
          endif 
    endif else begin
        if not keyword_set(bw)   then bw=25.
        if not keyword_set(freq) then freq=bw/2.
        if n_elements(flat) eq 2 then doflat=1
    endelse
    if not keyword_set(sbc) then sbc=1
    if not keyword_set(win) then win=3
    if not keyword_set(wsize) then wsize=.75
;
    xpos=winxmax-xpix
    ypos=winymax-ypix
    frqlist=[-bw/2.,bw/2.]+freq
    window,win,xsize=xpix,ysize=ypix,xpos=xpos,ypos=ypos
    plot,[frqlist[0],frqlist[1]],[0,sz[2]],/nodata,/xstyle,/ystyle,$
        xticklen=-.02,yticklen=-.02
    px=!x.window*!d.x_vsize
    py=!y.window*!d.y_vsize
    sx=long(px[1] - px[0] + 1.5)
    sy=long(py[1] - py[0] + 1.5)
    if (sx ne sz[1]) or (sy ne sz[2]) then  begin
        retimg=congrid(img,sx,sy,cubic=-.5)
    endif else begin
        retimg=img
    endelse
    if doflat  then begin
        flvec=temporary(total(retimg[flat[0]:flat[1],*],1)/(flat[1]-flat[0]+1.))
        retimg=transpose(mav(transpose(retimg),1./flvec))
    endif
    if (histeq ne 0) then begin
        tv,imghisteq(retimg,minv=minhEq,maxv=maxhEq),px[0],py[0]
    endif else begin
        tvscl,retimg,px[0],py[0]
    endelse
    if keyword_set(prof) then begin
        profiles,retimg,sx=px[0],sy=py[0],wsize=wsize
    endif else begin
        if keyword_set(rdpix) then begin
            rdpix,retimg,px[0],py[0]
        endif
    endelse
    return,retimg
end
