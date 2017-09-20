;+
;NAME:
;alfachkday - check a days set of files
;SYNTAX: nfiles=alfachkday(projid,yymmdd,savI,imglist=imglist,pol=pol,$
;                 bychn=bychn,$
;                 savDat=savDat,usecurs=usecurs,nopltrms=nopltrms,$
;                 rmslist=rmslist,vrms=vrms,nolut=nolut,dir=dir)
;ARGS:
;   projid: string project id to use eg 'a2010';
;   yymmdd: long   day (ast) to search for
;   
;KEYWORDS:
;imglist: long   sbc of boards to display in image. To display sbc 1,2,3,4
;                set imglist=1234  (The sbc numbers are 1 based). def=1
;    pol: long   the pol to display in image 1=polA, 2=polB. Default=1
;  bychn:        if set then display rms,image by channel number. The default
;                is by frequency.
; savDat:        if set then save the rms's  and savI in a save file
;                called yymmdd.sav in the current directory.
;useCurs:        if set then stop after every image wait for the
;                user to click on the cursor position. This time, freq
;                will be stored in the savI for this image.
;nopltrms:       if set then don't bother to plot the rms's for each
;                scan. 
;rmslist :long   the sbc to display in the rms plots. To display sbc
;                3,4,5 use rmslist=345 (the sbc are 1 based).
;vrms    :float  vertical scan max for rms plot (min is 0). Units are
;                 rms/mean by channel.
;nolut   :       if set then don't load the grey scale lookup table before
;                starting. by default a linear ramp is installed.
;dir     :       use this directory rather than /proj/projid/ This may be
;                needed if the files have not been moved to proj/projid yet. 
;
;RETURNS:
;     nfiles: long number of files we processed.
;savI[nfile]: {} struture holding info on each scan
;               CURSFRQ  FLOAT           1420.59    ; from cursor
;               CURSJD   DOUBLE           2453454.7 ; from cursor
;               SCAN     LONG         508400209     
;               FNAME    STRING    '/proj/a2010/wapp.20050325.a2010.0000.fits'
;               NOTES    STRING    ''               ; user entered
;
;If savdat set :  save,savI,brmsAr[],file='050326.sav' if yymmdd=050326
;               this data will be saved in the current directory.
;
;DESCRIPTION:
;   alfachkday will scan for all of the fits files for a particualr day 
;with the specified project id. It will then input the first scan of each
;file, compute the rms/mean by channel and display it. It will then
;compute an image of the specified sbc/pol and display it. If /usecurs
;is set then:
;   1.the program will wait for the user to click the cursor on a position
;     in the image. It will record the frequency, time of this position.
;   2.it will then prompt the user for a single line of notes for this
;     image.
;It then proceeds to the next file.
;If /savDat is specified then the rms/mean for all of the scans as well
;as the savI structure is stored to disc as yymmdd.sav
;
;-
function alfachkday,projid,yymmdd,savI,imglist=imglist,pol=pol,bychn=bychn,$
                savDat=savDat,usecurs=usecurs,nopltrms=nopltrms,$
                rmslist=rmslist,vrms=vrms,nolut=nolut,dir=dir

    xs=644
    ys=861
    xp=0
    yp=35
    mjdtojd=2400000.5D
    if n_elements(pol) eq 0 then pol=1 &$
    if (pol ne 1) and (pol ne 2) then begin
        print,'Pol is 1 or 2 for polA,polb'
        return,0
    endif
    if n_elements(bychn) eq 0 then bychn=0
    if n_elements(savDat) eq 0 then savDat=0
    if n_elements(usecurs) eq 0 then usecurs=0
    pltrms=not keyword_set(noplotrms)
    if n_elements(rmslist) eq 0 then rmsbrd=1234567
    if n_elements(vrms)   eq 0 then vrms=.05
    if n_elements(imglist)   eq 0 then imglist=1
    if not keyword_set(nolut) then loadct,0
;
    minfile=100e6
    savNm=string(format='(i6.6,".sav")',yymmdd)
    nfiles=wasprojfiles(projId,fI,yymmdd1=yymmdd,yymmdd2=yymmdd,dir=dir)
    if nfiles gt 0 then ind=where(fi.size gt minfile,nfiles)
    if nfiles eq 0 then begin
        print,'no files found'
        return,0
    endif
    fI=fI[ind]
    print,'found ',nfiles,' files'
;
    aa={    cursfrq: 0. ,$; birdie freq center of two
            cursjd : 0D ,$; jd bfrq measured
            scan: 0L    ,$; scan number
            fname: ''   ,$; filename
            notes: ''    $; what they types in at prompt
    }
    needrms=pltrms or savDat
    if pltrms then window,0,xsize=xs,ysize=ys,xpos=xp,ypos=yp
    savI=replicate(aa,nfiles)
    zx=-4 &$
    chn=0 &$
    x=0 
    y=0
    notes=''
    for ifile=0,nfiles-1 do begin &$
        fname=fi[ifile].fname &$
        wasclose,/all &$
        print,'start:',fname
        istat=wasopen(fname,desc) &$
        print,corinpscan(desc,b)   &$

        if needrms then brms=corrms(b) &$
        if pltrms then begin
            hor &$
            wset,0 &$
            ver,0,vrms &$
            corplot,brms,brdlist=rmslist  &$
        endif

;
    len=b[0].b1.hf.numchan
    zx=-round(len/1024.)
    img=corimgdisp(b,brdlist=imglist,pol=pol,zx=zx,/imgmed) &$
    if usecurs then begin
        print,"waiting cursorpos"
        cp ,x=x,y=y&$
        print,"comments??" &$
        notes='' &$
        read,notes &$
    endif
    savI[ifile].cursfrq =x &$
    savI[ifile].cursjd  = (y)/(3600.*24) + b[0].b1.hf.mjd_obs +mjdtojd &$
    savI[ifile].scan = b[0].b1.h.std.scannumber &$
    savI[ifile].fname= fname &$
    savI[ifile].notes= notes &$
    if (ifile eq 0) and savDat  then brmsAr=replicate(brms,nfiles) &$
    if savDat then brmsAr[ifile]=brms &$
endfor
;
if savDat then begin
    save,savI,brmsAr,file=savnm
    print,'info saved to:',savnm
endif
    return,nfiles
end
