;+
;NAME:
;rimonimg - monitor ri data
;SYNTAX: img=rimonimg(fbase,num,lun=lun,tmtoavg=tmtoavg,
;                   numx=numx,numy=numy,usefifo2=usefifo2,d=d,val=val,
;                   pixwin=pixwin,ilim=ilim)
;ARGS:
;  fbase: string Base filename to read from (eg '/share/aeron5/24jul03').
;                Do not include the . or file number.
;   num : int    file number of file to start on. 
;
;KEYWORDS:
;   lun : int    If provided, then process this file from the current 
;                position. When done with the file return. In this case
;                fbase and num are ignored. You also can not jump to other 
;                files from the internal menu.
;ipptoavg:long   number of ipps to average together. The default is none
;tmtoavg: long   number of time points to average. default is none
;numDisp: long   The number of averaged ipps to display in the image. The
;                default is 900 averaged ipps.
;usefifo2:       If set then use fifo 2. The default is fifo 1.
; val[2]: float  Clip the  power (a/d levels squared) to [min,max] and
;                then scale to the full range of the display device (
;                0 to 255). The default is to clip the power at 6 sigma
;                (as measured from the first image).
;
; pixwin:        if set then use a pixwin when drawing a new image. This
;                cuts down on the flashing. It is useful when you are
;                averaging only 1 or 2 ipps.
; ilim  : long   if supplied then limit image to these indices of the 
;                data rec (0 based).
;RETURNS:
;   img[m,numDisp]:float    the last image displayed.
;   d[n]         if this keyword is provided then the data read
;                for the last image is returned here.
;DESCRIPTION:
;   rimonimg will make continuous images of meteor data. The mean is removed from
;the voltages, power is computed, and then toavg ipps are averaged together.
;numDisp averaged ipps are then displayed as height versus time. When 
;the end of file is hit, the routine will advance to the next filenumber.
;If no data is available, the routine will wait until it becomes available.
;   The user can modify things by hitting any key and bringing up an
;internal menu:
;
;Cmd CurVal   function
; a dome      antenna ch, dome
; f   70      move to new fileNum
; l           list all files
; n           next file (or quit if 1 file)
; q           to quit
; r           rewind current file
; s  0        single step 0,1 (off,on)
; otherkey    continue
;
;The commands are:
;
; a  dome/ch  This lets you switch between dome and carriage house display
;
; f  filenum  You can start displaying at the start of a different 
;             filenumber. If the new filenumber is illegal then no 
;             change is made.
;
; l           This will list all of the available files starting with
;             fbase. The last file will also contain its size.
;
; n           move to the next file number.
;
; q           quit the routine.
;
; r           rewind and start over in the current file.
;
; s  0,1      turn on,off single step mode.When it is on, the routine
;             will pause after every image waiting for the user to
;             enter return.
;
; otherKey    any other key will cause the display to continue.
;             This allows you to pause the display to look at it for
;             a while.
;-
;history:
;   28jul03: added single step option.
;          : remove mean from voltages before computing power
;          : if val not provided, scale to 6sigma on the first image
function rimonimg,fbase,num,lun=lun,tmtoavg=tmtoavg,ipptoavg=ipptoavg,$
                  numX=numX,numy=numy,usefifo2=usefifo2,d=d,val=val,$
                pixwin=pixwin,$
                ilim=ilim
    forward_function rimonimgkey
;
    nsig=6                      ; to scale the lut if no val keyword
    numLoc=num
    maxreclen=2L^18
    singleStep=0
    useLun=(n_elements(lun) gt 0)
    if n_elements(tmtoavg)  eq 0  then tmtoavg=1l
    if n_elements(numx) eq 0 then numx=800
    LnumY=900L
    if n_elements(numY) ne 0 then LnumY=numY
    if not keyword_set(usefifo2) then useFifo2=0
    img=''
    valfifo1=[0.,0.]
    valfifo2=[0.,0.]
    if n_elements(val) eq 2 then  begin
        valfifo1  =val
        valfifo2  =val
    endif
    wpixwinToUse=4
    wpixwin     =-1
    win=1
    tmlab=''
    title=''
    totTm=0.
    on_ioerror,ioerror
    cs=1.4
    noDataDelay=1.                      ; wait 1 sec if no data
    maxSize=2L^31- 1024L
    if keyword_set(lun) then begin
        fbasel=''
    endif else begin
        len=strlen(fbase)
        fbasel=fbase
        if strmid(fbase,len-1,1) eq '.' then fbasel=strmid(fbase,0,len-1)
    endelse
    if not useLun then lun=-1
;
;   make sure tmtoavg,numipp are divisible
;
    firstTime=1
    done=0
    lastNumLoc=numLoc
    while (1) do begin
;
;       need a new file??
;
newFile:    if not useLun then begin
            file=string(format='(a,".",i3.3)',fbasel,numLoc)
            if lun ne -1 then begin
                free_lun,lun
                lun=-1
            endif
            if file_exists(file) eq 0 then begin
                if firstTime then begin
                    print,'file:',file,' does not exist.. returning..'
                    return,img
                endif else begin
                    lab=string(format=$
'("fileNum:",i3," does not exist. Stay at current fileNum:",i3)',$
                    numLoc,lastNumLoc)
                    print,lab
                endelse
                numLoc=lastNumLoc
                file=string(format='(a,".",i3.3)',fbasel,numLoc)
            endif
            openr,lun,file,/get_lun
            i=strpos(file,'/',0,/reverse_off,/reverse_search)
            basename=(i eq -1)?file:$
                strmid(file,i+1)
        endif
;
;       first time first file, read a rec and get params. 
;       assume params are the same for the rest of the data
;
        if firstTime then begin
            istat=searchhdr(lun,maxlen=maxreclen)
            point_lun,-lun,curpos
            istat=riget(lun,d,/search,/complex)
            if istat ne 1 then goto,ioerror
            point_lun,lun,curpos
            ippBuf=d[0].h.ri.ippsPerBuf
            spipp =d[0].h.ri.smppairipp
            gw    =d[0].h.ri.gw
            ipp   =d[0].h.ri.ipp
            fifo  =d[0].h.ri.fifonum
            nrecs=(numx*tmtoavg*numy)/(spipp*ippBuf)
            if (numx*tmtoavg*numy) ne (spipp*nrecs*ippBuf) then begin
                nrecs=nrecs+1
            endif
            bytesPerRec=d[0].h.std.reclen
            bytesPerImage=bytesPerRec*nrecs
            if n_elements(ilim) eq 2 then begin
                i1=ilim[0]
                i2=ilim[1]
            endif else begin
                i1=0L
                i2=spipp-1
            endelse
         endif
;
;       loop reading the file
;
         while (1) do begin
;
;       wait for the data to become available
;
        repeat begin
            bytesLeft=bytesleftfile(lun,cursize=cursize)
            dataAvail=(bytesLeft ge bytesPerImage)
            if not dataAvail then begin
;
;           next file exists??
;
                if (maxSize-curSize) lt bytesPerImage then begin
                    fileL=string(format='(a,".",i3.3)',fbasel,numLoc+1)
                    if file_exists(fileL) then begin
                        numLoc=numLoc+1
                        goto,newfile
                    endif
                endif
                wait,noDataDelay
                key=checkkey()
                if key ne '' then begin
                   case rimonimgkey(lun,numLoc,fbasel,usefifo2,singleStep) of   
                        2: goto,newfile
                        3: goto,done
                        4: stop
                     else:
                   endcase
                endif
            endif
        end until dataAvail 
;
;       get the data
;
            sec1=systime(/sec)  
            point_lun,-lun,curpos  &$
            istat=riget(lun,d,numrecs=nrecs,/complex,/search)
            sec2=systime(/sec)  
            if istat ne nrecs then goto,ioerror
;
;       reform and then average
;
            if useFifo2 then begin
      y1=reform((d.d2),tmtoavg,numx,numy)
                val=valfifo2
            endif else begin
      y1=reform((d.d1),tmtoavg,numx,numy)
                val=valfifo1
            endelse
            mn=mean(y1)
            mn=[float(mn),imaginary(mn)]
            img=total((float(y1)-mn[0])^2 + (imaginary(y1)-mn[1])^2,1)/tmtoavg
            if val[1] eq 0 then begin 
                a=rms(img,/quiet)
                val=[a[0]-a[1]*nsig/2, a[0]+a[1]*nsig/2]
                if useFifo2 then begin
                    valfifo2=val
                endif else begin
                    valfifo1=val
                endelse
            endif
            x1=d[0].h.std.time
            x2=nrecs*(ippBuf*ipp*1e-6) 
            xrange=[0.,x2] 
            if firstTime then begin 
                !p.multi=0 
            endif else begin 
                !p.multi=[0,1,1]
            endelse 
            tmlab=fisecmidhms3(x1,h,m,sec) 
;
;           see if they hit a key.. do this before the display
;           so they can stop on the current image
;
            key=checkkey()
            if (key ne '') or (singleStep ne 0)  then begin
                case rimonimgkey(lun,numLoc,fbasel,useFifo2,singleStep) of   
                 2: goto,newfile
                 3: goto,done
                 4: stop
                else:
                endcase
            endif
;
;           write image .. into screen or pixwin
;
            if wpixwin ne -1 then begin
                wset,wpixwin
                wintouse=wpixwin
            endif else begin
                wintouse=win
            endelse
            fifoName=(usefifo2)?'chan 2':'chan 1'
            title=string(format=$
            '(A," tm:",A," FPos:",i10," file:",a," ProcTm",f5.2)',$
                    fifoName,tmlab,curpos,basename,totTm)
            imgdisp,(img > (val[0]))<val[1],xrange=xrange,yrange=yrange,$
              win=winToUse,ytitle='hght [km]',xtitle='tm [secs]',title=title,$
                charsize=cs
            sec3=systime(/sec)  
            totTm=sec3-sec1
;
;           if pixwin, copy to active window
;
            if wpixwin ne -1 then begin
                 wset,win
                 device,copy=[0,0,xdim,ydim,0,0,wpixwin]
            endif
;
;           first time, get dimensions of window for pixwin. 
;           start pixwin write on 2nd iteration
;
            if firstTime and keyword_set(pixwin)  then begin
               xdim=!d.x_size
               ydim=!d.y_size
               window,wpixwintouse,/pixmap,xsize=xdim,ysize=ydim
               wpixwin=!d.window
            endif
            firstTime=0 
            sec1=systime(/sec) 
        endwhile   ; loop reading 1 file

ioerror:
        if useLun then goto,done
        numLoc=numLoc+1L
        if lun ne -1 then  begin
            free_lun,lun
            lun=-1
        endif
    endwhile
done:
    if (not useLun) and (lun ne -1) then free_lun,lun
    if wpixwin ne -1 then wdelete,wpixwin
    return,img
end
