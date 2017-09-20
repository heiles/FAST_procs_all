;+
;NAME:
;mmbeammap - generate beam map from mm data structure.
;SYNTAX: mmbeammap,mm,beammap,show=show,mappixels=mappixels,$
;                  mbmap=mbmap,slmap=slmap,axisrange,$
;                  pntsperstrip=pntsperstrip, hpbw=hpbw,nterms=nterms
;ARGS:
; mm[0]: struct  returned from mmgetarchive() holds calibration 
;                fit info.
;KEYWORDS:
;show  : int     if true then display images of:
;                window 0: sidelobe map
;                window 1: main beam + sidelobe map
;                the map will be "mappixels square"
;                the maps are linear scales
;mappixels:int   the size of the image maps to return. The default is 200
;                (so bmmap is 200x200 pixels. The fit is evaluated on the 
;                 pntsperstripxpntsperstrip grid and this it is interpolated
;                 onto mappixels x mappixels using the idl routine congrid().
;
;Keywords not normally used:
;
;pntsperstrip: int  number of points per strip in original data.
;                The default is 60. This and hpbw deterimine the az,za grid
;                that is used to evaluate the fit on. Probably best to just
;                use the default of 60 (since that's what the datataking uses).
;hpbw: float     half power beamm width used (in arcminutes).
;                By default it uses what is in the mm structure fit info.
;nterms:int      number of coef's in the original fft fit to use when creating
;                the sidelobes. Fit has 8 terms and is hermetian. The default
;                value is 6. Whatever you enter it must be even and <=8.
;RETURNS:
;beammap[n,n]:float image of main beam and 1st sidelobes.
;                 n= mappixels which defaults to 200
;                 It is a linear scale with the peak value normalized to 1.
;mbmap[n,n]  :float  image of main beam by itself
;slmap[n,n]  :float  image of first sidelobe by itself.
;axisrange[n]:float  map angular offsets in arcminutes
;                    (eg beammap[*,0] is evaluated at axisrange[*])
;
;DESCRIPTION:
;   The spider scan calibration of carl heiles does a 2d fit to the main 
;beam and the first sidelobe for each spider scan taken (two crosses rotated
;by 45 degrees). This information is archived at AO and is accesssible 
;using the mmgetarchive() routine (in Cor2 lib). 
;
;   This routine will take the info from 1 pattern (mm) and compute an
;image of the main beam and first sidelobe using the original fit results.
;The fits are done in great circle az,za. beammap[az,za]. The  axisrange[n]
;keyword  returns the angular offsets where these points were evaluated.
;
;   The show=1 keyword will have the routine display the images before
;returning.
;
;   The maxpixels=N lets the user change the size of the output image.
;The fit is always evaluated on a 60x60 grid (the original size of the input
;data set). The routine then interpolates this onto the maxpixels x maxpixels
;grid. This defaults to 200.
;
;   There are a few  keywords that allow the user to do non standard
;processing: pntsperstrip,hpbw,nterms. You should normally let the routine
;use the default values.
;
;EXAMPLE:
;   - get cband data for 2010, sort by frequency, then build a beammap
;     for one of the patterns.
;     idl
;     @corinit
;     addpath,'spider/pro/mm0'     
;     .compile mmbeammap
;
;     yymmdd1=100101
;     yymmdd2=101231
;     istat=mmgetarchive(yymmdd,yymmdd2,mm,rcvnum=9)
;;    get the unique frequencies data measured at
;     ufrq=mm[uniq(mm.cfr,sort(mm.cfr))].cfr
;     print,ufrq
;4500.00   4860.00  5000.00  5400.00  5690.00  5900.0
;     
;;    get 4500 Mhz data
;     ii=where(mm.cfr eq ufrq[0],cnt)
;;    make beammap first of these
;    mmbeammap,mm[ii[0]],beammap,/show,mbmap=mbmap,slmap=slmap,$
;                        axisrange=axisrange
;
;;   display the main beam map
;    imgdisp,mbmap,zx=2,zy=2,nsigclip=3
;
;NOTE:
;   - This routine uses the ffteval() routine in spider/pro/mm0. Before calling
;     this routine you need to :
;     addpath,'spider/pro/mm0'  
;     so the routine can find it. You may have to then say
;     .compile ffteval if idl doesn't autocompile it. 
;   - You will have to run this routine at AO since the database that
;     mmgetarchive() accesses is only at ao.
;-
pro  mmbeammap,mm,beammap,show=show,pntsPerStrip=pntsPerStrip,$
        hpbw=hpbw,mbmap=mbmap,slmap=slmap,nterms=nterms ,mappixels=mappixels,$
        axisrange=axisrange
    forward_function ffteval

    hpbwUsed   =(keyword_set(hpbw))?hpbw:mm[0].bmwidscan
    ptsPerStrip=(keyword_set(pntsPerStrip))?pntsPerStrip: 60
    if not keyword_set(nterms) then nterms=6
    if not keyword_set(mapPixels) then mapPixels=200l
    hpbwToE=.6005612
;
; make az,za array
;
    azAr=fltarr(ptsPerStrip,ptsPerStrip) 
    zaAr=fltarr(ptsPerStrip,ptsPerStrip) 
    tsrc     =mm.fit.tsrc                 ; b2dfit[2,0]
    pixelsize=.1*hpbwUsed   ; this assumes 10 samples/beam or 6 beams in 60 secs
    totoffset_calc=pixelsize*(findgen(ptsperstrip) - .5*(ptsperstrip-1))
    axisrange=interpol(totoffset_calc,findgen(ptsperstrip)/(ptsperstrip-1.),$
                           findgen(mapPixels)/(mapPixels-1.))
    for i=0,ptsperstrip-1 do begin
        azAr[*,i]=totoffset_calc
        zaAr[i,*]=totoffset_calc
    endfor
    radiusSq=(azAr^2 + zaAr^2)
    radius  =sqrt(radiusSq)
    angle=atan(zaAr,azAr)
;
; sidelobe eval..
;
    hgt=ffteval(nterms,mm.fit.slhgtcoef,angle)
    cen=ffteval(nterms,mm.fit.slcencoef,angle)
;
;NOTE ON UNITS FOR THE WIDTH: The input width is in in units of HPBW. In
;the evaluation, we use 1/e widths, which is why we multiply by 0.6...
;
    wid=ffteval(nterms,mm.fit.slhpbwcoef,angle)*.6005612;
    sidelobe=hgt*exp( -((radius-cen)/wid)^2)
    sidelobe=reform(sidelobe,60,60)/tsrc
;
; sidelobe is probably in kelvins, so divide by Tsrc
;
;
; now the main beam
;
    mb_Wid0  =mm.fit.bmwidavg*hpbwToE   ; b2dfit[5,0] average hpbw (amin)
    mb_Wid2  =mm.fit.bmwiddelta*hpbwToE ; b2dfit[6,0] (max-min)/2. (amin)
    mb_Wid1  =mm.fit.bmwiddelta*hpbwToE ; b2dfit[8,0] coma ampl hpbw units
    mb_phi   =mm.fit.bmPhi*!dtor        ; b2dfit[7,0] PA of hpbw maj axis, deg
    phi_coma =mm.fit.comaPhi*!dtor      ; b2dfit[9,0] pa of coma lobe, deg
    bmwid    =mb_Wid0 + mb_Wid1*cos(angle - phi_coma) + $
                mb_Wid2*cos(2.*(angle - mb_phi))
    mainbeam = exp(- radiusSq/bmwid^2)
    slmap  =congrid(sidelobe,mapPixels,mapPixels,/interp,/minus_one)
    mbmap  =congrid(mainbeam,mapPixels,mapPixels,/interp,/minus_one)
    beammap= mbmap + slmap
;
    if keyword_set(show) then begin
        device, window=opnd
        for nwindow= 0,1 do begin
            if ( opnd(nwindow) eq 0) then begin
                window, nwindow, xs=mapPixels, ys=mapPixels
            endif else begin
                wset,nwindow
                if ( (!d.x_vsize ne mapPixels) or (!d.y_vsize ne mapPixels)) $
                then window, nwindow, xs=mapPixels, ys=mapPixels
            endelse
        endfor
        wset,0 & wshow
        tvscl, slmap
        plots, [0.5,0.5], [0,1], /norm, lines=1
        plots, [0,1], [0.5,0.5], /norm, lines=1

;DISPLAY BOTH TOGETHER...
        wset,1 & wshow
        tvscl, beammap
        plots, [0.5,0.5], [0,1], /norm, lines=1
        plots, [0,1], [0.5,0.5], /norm, lines=1

    ENDIF
    return
end
