;+
;NAME:
;wappmonimg - monitor wapp file via images
;
;SYNTAX: img=wappmonimg(lun,hdr,projid=projid,logfile=logfile,wapptouse=wapptouse,
;                     posrec=posrec,nrec=nrec,pol=pol,han=han,lvlcor=lvlcor,
;                     clip=clip,nsigclip=nsigclip,zx=zx,zy=zy,col=col,hist=hist,
;                     flipforce=flipforce,noldlut=noldlut,han=han)
;TERMINOLOGY:
;   file set:   the wapp will concurrenlty write 1 to 4 files (depending
;               on the number of wapps selected). These 1 to 4 files
;               are called a file set.
;    logfile:   the online gui writes a logfile of the datataking to 
;               /share/obs4/usr/pulsar/projid/projid.cimalog. This file
;               can be used to locate all of the wapp files taken for this
;               project (that are currently on disc). See the logfile
;               keyword and the l,f menu options.
;   
;ARGS:
;   lun:    long      logical unit number for file to read
;   hdr:    {wapphdr} wapp header user passes in (see wappgethdr)
;NOTE:      In logfile mode, lun and hdr are ignored. just pass in dummies.
;
;KEYWORDS:
;  projid:    string  create logfile name for projid. Comments for logfile below
;                     also apply.
;  logfile:   string  if provided, then ignore lun, and get the files to
;                     monitor from the logfile
;wapptouse:   int     if logfile included, then start with this wapp 1..4.
;                     default is first available board.
;
;   posrec:   long    position to record posrec before starting (count from 1).
;                     Use the p menu option to position while running.
;     nrec:   long    number of spectra to plot per image. The default is 700.
;      pol:   int     polization to plot:
;                     1  - first pol (if more than 1)
;                     2  - 2nd   pol (if more than 1)
;                     12 - both pols (side by side if more than 1)
;      han:           if set then hanning smooth the data
;   lvlcor:           if set then level correct the data (currently only
;                     works for 3 level data).
;
; nsigclip:   float   if supplied then clip the images to nsigmaclip sigmas.
;                     This is computed for the first image displayed.
;  clip[2]:   float   fraction of tsys to clip image (min,max)
;                     The default is to use the full range of each image.
;       zx:   int     zoom in the x (freq) direction using pixel replication.
;                     numbers gt 1 make it bigger
;                     numbers lt -1 make it smaller
;                     Note that any negative zoom factors must divide 
;                     evenly into the dimension.
;       zy:   int     zoom in the y (time) direction using pixel replication.
;                     same constraints as zx.
;    col[]:   int     cols (channels) to use to flatten image in time direction
;                     (count from 0). default is no flattening.
;     hist:           if set, then histogram equalize the image
;flipforce:   intarr[4]if set then force the freq band to be flipped.
;  noldlut:           If set then do not load a linear ramp into the 
;                     lookup table. This allows you to adjust the lookup
;                     table (via xloadct) and then use that setting. The
;                     default is to load a linear ramp into the color
;                     lkup table.
;newdir[4]:   string  string of alternate directory names to use
;                     incase the files have been moved (1 for each wapp).
;
;RETURNS:
;       img[] float   the last image displayed
;
;DESCRIPTION:
;   Input data from a wappfileset and display an image of the data. The image
;will be nrec samples long. The routine will continue reading the file set
;creating new images until eof is hit. 
;   The processing for each image is:
;   1. Input the acf's, remove bias, normalize, compute spectra, scale
;      to power. no level correction is done. (see wappget()).
;   2. scale the image to the mean image and then subtract 1.
;      img[nchn]= img[nchn]/mean(img[nchn]) - 1 ..we are now in tsys units.
;   3. scale the lut (look up table) so that clip[0] clip[1] is 0 to 255.
;On exit from wappmonimg() the last image (before scaling to 0 to 255)
;is returned.
;
;   The routine can be run in two modes: 
;1. no logfile supplied. This will scan lun from the current position
;   making images till eof is hit. The routine will then return.
;   Only one board is available (the one that lun points at).
;2. supply a logfile from the observation. In this case the 
;   program will scan the logfile, finding all of the file sets that
;   were created (see wappgetfileInfo()). It will then start at the
;   first fileset creating images of nrecs per image till the end of the
;   fileset. At the end of the file the user can use the menu (hit any key)
;   to move to the next (or another) fileset.
;
;   While processing the images, the user can hit any key to pause
;processing and display a selection menu. The menu includes:
;
; command       function
;curFile dir/adleo_calon.wapp3.52803.013 startTm:15:57:33(AST) fileInd:  1
;b             board (1..4)
;f  fileInd    move to fileset fileInd (1 to  maxfileset)
;l             list all filesets
;n             next fileset (or quit if 1 file)
;p sec         position to second SEC in file
;q             to quit
;s 0 1         step mode 1-on,0-off (currently:off)
;
;Further command description.
;b          display a different wapp board. Choices are 1 to 4
;f  fileInd If you are using a logfile, then you can skip to another 
;           fileset by inputting the fileInd to jump to. Use the
;           l command to list the filesets with their file indices.
;l          If in logfile mode, list all of the filesets with there 
;           file indices.
;n          Move to the next file set.
;p  sec     Move to a new position within the current fileset. Start the
;           image at sec seconds from the start of the file.
;s  0,1     single step mode. This will stop after each image is displayed.
;           1 starts single step, 0 stops it.
;
;Hitting return will exit the menu and return to processing. 
;
;EXAMPLES:
;   1. use logfile mode. display both polarizations and zoom in the 
;      x direction by 2.
;
;   logfile='/share/obs4/usr/pulsar/a1730/a1730.cimalog'        
;   zx=2            ; zoom by 2 in x direction
;   xloadct         ; adjust the lookup table for a grey scale ramp.
;   img=wappmonimg(lun,hdr,logfile=logfile,zx=zx,pol=12)
;
;   2. just scan a single file. Position to first rec on startup
;
;   file='/share/wapp25/adleo.wapp2.52802.036'
;   openr,lun,file,/get_lun
;   istat=wappgethdr(lun,hdr)
;   xloadct         ; adjust the lookup table for a grey scale ramp.
;   img=wappmonimg(lun,hdr,zx=2,pol=12,posrec=1)
;
;NOTES:
;1. The routine will only display complete images of nrec samples.
;   Any leftover points at the end of the file are not displayed.
;2. When using logfile mode, the first key you hit just brings up
;   the menu. You need to enter a 2nd key (followed by return) for the
;   menu command.
;
;SEE ALSO:
;   wappgethdr,wappgetfileinfo,wappget
;-
;15jun03 - include folding mode with spectra output.
;08aug03 - fix pos rec, add noldlut to not automatically load lut.
;31jan04 - if short file, use the length of file
;24jul04 - if next file requested, set posrec to 1
;
function  wappmonimg,lun,hdr,projid=projid,logfile=logfile,wapptouse=wapptouse,$
                      posrec=posrec,nrec=nrec,pol=pol,noldlut=noldlut,han=han,$
                col=col,zx=zx,zy=zy,hist=hist,flipforce=flipforce,clip=clip,$
                newdir=newdir,nsigclip=nsigclip,lvlcor=lvlcor
;     
;
    modeLab=['Search ','folding','SpcTotP','Unknown']
    img=''
    lunAr=[-1,-1,-1,-1]
    if n_elements(posrec) eq 0 then posrec=0L
    if n_elements(nrec)   eq 0 then nrec=700L
    if n_elements(pol)    eq 0 then pol=1
    if n_elements(zx)     eq 0 then zx=1
    if n_elements(zy)     eq 0 then zy=1
    if n_elements(hist)   eq 0 then hist=0
    if n_elements(wapptouse)   eq 0 then wapptouse=1
    if not keyword_set(noldlut) then loadct,0
    useClip=0
    if n_elements(clip)   gt 0 then begin
        useclip=1
        if n_elements(clip) eq 1 then begin
           clipLoc=[-abs(clip),abs(clip)]   
        endif else begin
           cliploc=clip
        endelse
    endif
    if not keyword_set(nsigclip) then nsigclip=0.
    firstNsigclip=1                         ;first time we need to compute
    stepmode=0
    lastSize=[-1,-1]
;
;   if logfile, get all the files
;
    if (n_elements(logfile) eq 1) or (n_elements(projid) eq 1)  then begin
        nwappfile=wappgetfileInfo(lunlog,wappFileI,logfile=logfile,projid=projid,$
                newdir=newdir)
        useLogFile=1
        iwapp=wapptouse-1
        if nwappfile eq 0 then begin
            print,'no wapp files found in :',logfile
        endif
    endif else begin
        nwappfile=1
        useLogFile=0
        iwapp=0
        lunAr[0]=lun
    endelse
;
;
;    index for polarization to use
;
    ifile=0
    while (ifile lt nwappfile) do begin
;
; if they jump to a new board
;
newbrd:
        newNsigclip=1
        if useLogFile then begin
            for i=0,3 do begin
                if lunAr[i] ne -1 then begin
                    free_lun,lunar[i]
                    lunAr[i]=-1
                endif
            endfor
            if wappFileI[ifile].wappused[iwapp] eq 0 then begin 
                ind=where(wappfileI[ifile].wappused eq 1,count)
                if count eq 0 then begin
                    print,'skipping fileInd:', ifile+1,' no wapps used'
                    goto,donefile
                endif
                print,'brd:',iwapp+1,' missing. Switch to',ind[0]+1
                iwapp=ind[0]
            endif
            on_ioerror,open1err
            openok=0
            fname=wappFileI[ifile].wapp[iwapp].dir + $
                        wappFileI[ifile].wapp[iwapp].fname
            openr,lun,fname,/get_lun
            openok=1

open1err:   on_ioerror,NULL 
            if openOk eq 0 then begin
                print,'skip find:',find,' ..missing file:',fname
                goto,donefile
            endif
            lunAr[iwapp]=lun
            hdr=wappFileI[ifile].wapp[iwapp].hdr
            point_lun,lunAr[iwapp],(hdr.byteOffData) ; skiphdr
            if (lunAr[iwapp] eq -1) then begin
                print,'wapp ',iwapp+1,' missing. skipping fileInd', ifile+1
                goto,donefile
            endif else begin
                fstart=string(format=$
                '(a," startTm:",a,"(AST)")',fname,fisecmidhms3(hdr.start_ast))
                print,fstart
            endelse
        endif
;
;   
;
    ipol=0
    numplots=1
    nbrds=(hdr.isalfa)?2:1
    nifsbrds=(hdr.nifs eq 4)?2*nbrds:hdr.nifs*nbrds; we donot return crosspol
    if (nifsbrds gt 1) then begin
        case pol of
            1 : ipol=0
            2 : ipol=1
            3 : if (nifsbrds gt 2) then  ipol=2
            4 : if (nifsbrds gt 3) then  ipol=3
           12 : begin 
                    ipol=[0,1]
                    numplots=2
                end
           34 : begin 
                    if nifsbrds gt 3 then begin
                        ipol=[2,3]
                        numplots=2
                    endif
                end
          else: ipol=0
         endcase

    endif
    nlags=hdr.num_lags
    nifs =hdr.nifs
;
;   check that there are nrec recs in the file, if not,
;   use what is there..
;
     case hdr.lagformat of
        0: bytelen=2UL
        1: bytelen=4UL
        2: bytelen=4UL
        3: bytelen=4Ul
     else: message,'Unknown lagformat in hdr:'+string(hdr.lagformat)
    endcase
    bytesPerRec=bytelen*nlags*nifs*nbrds
 
;   point_lun,lun,(hdr.byteOffData + bytesPerRec*nrec)-1L
;    on_ioerror,checkNrecU
;   idat=0B
;   inpOk=0
;   readu,lun,idat
;   inpOk=1
;checkNrecU: on_ioerror,NULL
;
;    x,y axis scale for image
;
    flip=(hdr.freqinversion) ? -1.:1.    ; of digitaldown conversion
    flip=(hdr.iflo_flip[0]) ? -flip:flip ; of iflo 
    if keyword_set(flipforce) then flip=-1
    frq=hdr.cent_freq + [-hdr.bandwidth,hdr.bandwidth] $
                *.5*flip
    secPerRec=hdr.samp_time*1e-6
;
;   folding mode, time get modified.
;
    if hdr.obs_type_code eq 2 then begin
;
;      dumptime secs for nbins of data
;
        secPerRec=hdr.dumptime/hdr.nbins
    endif
    secPerImg=secPerRec*nrec
    delay=1.                        ; for checking file

    xslop=50*numplots               ; for the borders
    yslop=70
;
;   get pixel dimensions
;
    xlen=(zx lt 0) ? long(nlags/zx):nlags*zx
    xlen=abs(xlen)*numplots + xslop
    ylen=(zy lt 0) ? long(nrec/zy) :nrec*zy
    ylen=abs(ylen) + yslop
; 
;   if it's changes or first time
;
    if (lastsize[0] ne xlen) or (lastsize[1] ne ylen) then begin
        winimg=3
        winpix=4
        window,winimg,xsize=xlen,ysize=ylen
        window,winpix,xsize=xlen,ysize=ylen,/pixmap
        device,set_graphics=3
        lastsize=[xlen,ylen]
    endif
;
;    position if file if they want ..
;

restart:

    if posrec gt 0L then begin
       point_lun,lunAr[iwapp],(hdr.byteOffData + (posrec-1L)*bytesPerRec)
    endif
    currec=(posrec eq 0L)? 0L: posrec-1L
;
;   loop plotting the images
;
    bytesPerImage=bytesPerRec*nrec
    done=0
    key=checkkey()
    while not done do begin
;
;       wait for the data to become available
;
        repeat begin
            bytesLeft=bytesleftfile(lunAr[iwapp])
            dataAvail=(bytesLeft ge bytesPerImage) 
            if not dataAvail then wait,delay
;
;           Cmd CurVal   Function
;            b  n        board to use (1..4)
;            d  -        debug.. just stop in routine
;            f  n        file to skip to (1..max)
;            l  -        list all files
;            n  -        next file
;            p  xxxx.xx  pos curfile to second
;            q  -        quit
;            s  n        stepMode s 1 on,s 0 off
            key=checkkey()
            if (key ne '') or (stepmode) then begin
                if useLogFile then print,'curFile: '+fstart
                print,'Cmd CurVal    function'
                if useLogFile then begin
                  lab=string(format=$
'(" b  ",i4,"     board to use (1..4)")',iwapp+1)
                  print,lab
                  lab=string(format=$
'(" f  ",i4,"     file to use (1 to ",i3,")")',ifile+1,nwappfile)

                  print,lab
                  print,' l           list all files'
                  print,' n           next file (or quit if 1 file)'
                endif
                lab=string(format=$
'(" p  ",f7.2,      "  position to Sec in curFile")',$
                        ((currec-nrec)>0)*secPerRec)
                  print,lab
                  print,' q           to quit'
                lab=string(format=$
'(" s  ",i4,"     step mode. 1-on,0-off")',stepmode)
                  print,lab
                  print,' d           debug stop in procedure'
                  print,'otherKeys    continue'
                inpstr=''
                read,inpstr
                toks=strsplit(inpstr,' ,',/extract)
                cmd=toks[0]
                case cmd of
                   'b': begin
                        ind=(n_elements(toks) lt 2) ? -1 : toks[1]-1
                        if (ind lt 0 ) or (ind gt 3) then begin
                            print,'Enter b wappnum   1..4'
                        endif else begin
                            cpuok=0
                            if useLogFile then begin
                              if wappFileI[ifile].wappused[ind] eq 1 then begin
                                print,'switching to wapp',ind+1
                                iwapp=ind
                                posrec=currec
                                goto,newbrd
                              endif else begin
                                print,'wappnum:',ind+1,' not available'
                              endelse
                            endif
                        endelse
                        end
                   'd': begin
                        stop                ;debug stop
                        end
                   'f': begin
                        ind=(n_elements(toks) lt 2) ? -1 : toks[1]-1
                        if (ind lt 0 ) or (ind ge nwappfile) then begin
                            print,'Enter f fileInd  (1..maxfiles)'
                        endif else begin
                            if useLogFile then begin
                                print,'switching to fileind:',ind+1
                                ifile=ind
                                posrec=0L
                                goto,newbrd
                            endif
                        endelse
                        end
                    'l': begin
                        if useLogFile then begin
                            openr,lunLog,logfile,/get_lun
                             nwappfile=wappgetfileInfo(lunlog,wappFileI,$
                                        newdir=newdir)
                             free_lun,lunLog
                             lab=string(format=$
'("fInd wappUsed  StartAST Mode    fNameForBrd:",i1)',iwapp+1)
                          print,lab
                         for ii=0,nwappfile-1 do begin
                            imode=wappfileI[ii].wapp[iwapp].hdr.obs_type_code
                            if imode eq 0 then imode=4
                 lab=string(format='(i3," ",4i2,"   ",a," ",a," ",a)',$
                   ii+1,wappfileI[ii].wappused,$
                   fisecmidhms3(wappfileI[ii].astSec),modeLab[imode-1],$
                  wappfileI[ii].wapp[iwapp].fname)
                            print,lab
                         endfor
                         endif
                         end 
                    'p': begin
                            if n_elements(toks) lt 2 then begin
                                print,'Enter p secs .. to position to secs'
                            endif else begin
                                sec=double(toks[1])
                                junk=bytesleftfile(lunAr[iwapp],cursize=cursize)
                                lastRec=(((long(cursize - hdr.byteOffData)/$
                                             bytesPerRec) - nrec) > 1)
                                posrec=(lastRec < ulong(sec/secPerRec)) > 1L 
                                goto,restart
                            endelse
                        end
                   'q': begin
                        print,'quitting...'
                        goto,done
                        end
                   'n': begin
                        print,'next file..'
                        posrec=1L
                        goto,donefile
                        end
                   's': begin
                            if n_elements(toks) lt 2 then begin
                            print,'Enter s 0 or 1 .. turn off,on step mode'
                            endif else begin
                                stepmode=(toks[1] eq 0) ? 0 : 1
                            endelse
                        end
                   else: 
                endcase
                print,'continuing...'
            endif
        end until dataAvail
;
;       read the data
;
        istat=wappget(lunAr[iwapp],hdr,d,nrec=nrec,han=han,lvlcor=lvlcor)
        if istat ne nrec then begin
            print,'wappget: expected:',nrec,' recs. got:',istat
            break
        end
;
        !p.multi=(numplots eq 2) ?[0,2,1]:[0,1,1]
        if keyword_set(han) then begin
        endif
        for ii=0,numplots-1 do begin
            if nifs*nbrds gt 1 then begin
                img=imgflat(reform(d[*,ipol[ii],*],nlags,nrec),col=col)
            endif else begin
                img=imgflat(reform(d,nlags,nrec),col=col)
            endelse
            wset,winpix
            tmAr=[0.,secPerImg]+secPerRec*currec
            if useClip or nsigclip then begin
               if nsigclip and firstnsigclip then begin
                    aa=meanrob(img,sig=sig)
                    clipLoc=[-sig*nsigclip,sig*nsigclip]
                    firstnsigclip=0
               endif    
        imgdisp,(img > clipLoc[0])<clipLoc[1],zx=zx,zy=zy,win=winpix,hist=hist,$
                xrange=frq,yrange=tmAr,ytitle='secs'
            endif else begin
        imgdisp,img,zx=zx,zy=zy,win=winpix,hist=hist,$
                xrange=frq,yrange=tmAr,ytitle='secs'
            endelse
        endfor
        wset,winimg
        device,copy=[0,0,xlen,ylen,0,0,winpix]
        currec=currec+nrec
    endwhile
    if useLogFile then begin
        print,'finished with file:',wappFileI[ifile].wapp[iwapp].fname
    endif
donefile:
    ifile=ifile+1L
    endwhile
done:
    if useLogfile then begin
        for i=0,3 do begin 
            if lunAr[i] ne -1 then free_lun,lunAr[i]
            lunAr[i]=-1
        endfor
    endif
    return,img
end
