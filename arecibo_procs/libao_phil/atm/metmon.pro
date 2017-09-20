;+
;NAME:
;metmon - monitor meteor data
;SYNTAX: img=metmon(fbase,num,lun=lun,toavg=toavg,numDisp=numDisp,$
;                   useCh=useCh,d=d,val=val,pixwin=pixwin,ilim=ilim,$
;                   dirhc=dirhc,hc=hc,invert=invert)
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
;  toavg: long   number of ipps to average together. The default is 5
;numDisp: long   The number of averaged ipps to display in the image. The
;                default is 900 averaged ipps.
;  useCh:        If set then start displaying the first data channel. This
;                is the carriage house in dual beam experiments. The default
;                for dual beam is the dome. You can change this from the
;                internal menu.
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
; dirhc : string directory to start hardcopy
; hc    : in     1 hardcopy on, 0 hardcopy off
; invert:        if set then reverse black, white in lut.
;RETURNS:
;   img[m,numDisp]:float    the last image displayed.
;   d[n]         if this keyword is provided then the data read
;                for the last image is returned here.
;DESCRIPTION:
;   metmon will make continuous images of meteor data. The mean is removed from
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
; h   0,1     hardcopy on,off
; hd  dirName  directory name for hardcopy
; l           list all files
; n           next file (or quit if 1 file)
; p  recnum   position to rec in file
; pr 0,1      display profiles  in image
; q           to quit
; r           rewind current file
; s  0        single step 0,1 (off,on)
; sc 6        rescale images to nsigmas
; cur         trac cursor
; d           debug. stop in metmon. .continue to continue

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
; p  recnum   position to rec in file. Rec num counts from 1
; pr 0,1      Use cursor to display profiles in image. 1 on, 0 off.
;
; q           quit the routine.
;
; r           rewind and start over in the current file.
;
; s  0,1      turn on,off single step mode.When it is on, the routine
;             will pause after every image waiting for the user to
;             enter return.
; d           debug. This will stop in the metmon routine.
;
; otherKey    any other key will cause the display to continue.
;             This allows you to pause the display to look at it for
;             a while.
;EXAMPLES:
;   An example of using this routine at AO:
;
; 1. slogin to either fusion00,01, or 02
; 2. idl
; 3. @phil
; 4. @atminit
; 5. xloadct   .. then click on bw linear for scale color table
;
; 6. setup the parameters for the call..
;    file='/share/aeron5/23Dec03T1748' .. this should be the path and
;                                         base filename for the files to use.
;    usech=1            .. set this to 0 if you want the dome output
;    num=272            .. first file number of your experiment to use.
; 7.start the program:
;       img=metmon(file,num,usech=usech)
;
; 8. Hit any key to bring up the keyboard menu.
;
; Possible problems:
;
; By default the lut (color lookup table) is scaled to 6 sigma of the
; first image displayed. If this image has a large meteor in it, the
; other plots may not have the correct contrast. You can fix this by:
; a. hit any key;
; b sc nsig    .. where nsig is the numbers of sigmas to scale the image.
;              .. it will the compute the new clipping values from the
;                 current image you are looking at.
;-
;history:
;   02mar06: on exit, reread previous image so user gets what was
;            displayed
;            included position keyword
;   28jul03: added single step option.
;          : remove mean from voltages before computing power
;          : if val not provided, scale to 6sigma on the first image
function metmon,fbase,num,lun=lun,toavg=toavg,numDisp=numDisp,$
                useCh=useCh,d=d,val=val,pixwin=pixwin,ilim=ilim,$
				dirhc=dirhc,invert=invert
				
    forward_function metmonkey
;
    a={    byteOff: 0D,$;    byte offset first record of file 
           rec1   : 1L$ ;  first record number of file (count from 1)
      }
	hcCnt=0L
    profile=0
    fileInfo=a 
    tmToExit=0
    curRec=1L
    yrdelta=[0.,0.]
    nsigCh=6                      ; to scale the lut if no val keyword
    nsigDome=6                      ; to scale the lut if no val keyword
    numLoc=num
    singleStep=0
    useLun=(n_elements(lun) gt 0)
    if n_elements(toavg) eq 0  then toavg=5l
    LnumDisp=900L
;   hardcopy
	dohc=keyword_set(hc)
;   get current directory
	cd,current=curdir
	cd ,curdir
	dirhcl=(n_elements(dirhc) gt 0)?dirhc:curdir
	if (strmid(dirhcl,0,1,/reverse_offset) ne "/") then dirhcl=dirhcl + "/"
	; gif files..
	hc_suf=".gif"

    if n_elements(numDisp) ne 0 then LnumDisp=numDisp
    if not keyword_set(useCh) then useCh=0
    img=''
    valch=[0.,0.]
    valDome=[0.,0.]
    if n_elements(val) eq 2 then  begin
        valch  =val
        valDome=val
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
;   make sure toavg,numipp are divisible
;
    firstTime=1
    done=0
    lastNumLoc=numLoc
    startOfFile=1
    key=checkkey()      ; flush any keys
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
'("fileNum:",i3," does not exist. Stay at eurrent fileNum:",i3)',$
                    numLoc,lastNumLoc)
                    print,lab
                endelse
                numLoc=lastNumLoc
                file=string(format='(a,".",i3.3)',fbasel,numLoc)
            endif
            openr,lun,file,/get_lun
            startOfFile=1
            curRec=1L
            i=strpos(file,'/',0,/reverse_off,/reverse_search)
            basename=(i eq -1)?file:$
                strmid(file,i+1)
        endif
;
;       first time first file, read a rec and get params. 
;       assume params are the same for the rest of the data
;
        if firstTime then begin
            istat=searchhdr(lun)
            point_lun,-lun,curpos
            istat=atmget(lun,d)
            if istat ne 1 then goto,ioerror
            point_lun,lun,curpos
            ippBuf=d[0].h.ri.ippsPerBuf
            spipp =d[0].h.ri.smppairipp
            gw    =d[0].h.ri.gw
            ipp   =d[0].h.ri.ipp
            fifo  =d[0].h.ri.fifonum
            txSmp =d[0].h.sps.smpintxpulse
            nrecs=(LnumDisp*toavg)/ippBuf
            if (lnumdisp*toavg) ne (nrecs*ippBuf) then begin
                lnumDisp= ((lnumDisp/ippBuf)+1)*ippBuf
                nrecs=(LnumDisp*toavg)/ippBuf
            endif
            bytesPerRec=d[0].h.std.reclen
            bytesPerImage=bytesPerRec*nrecs
            y1=d[0].h.sps.rcvwin[0].startUsec 
            y2=y1+ (d[0].h.sps.rcvwin[0].numsamples*d[0].h.sps.gw) 
            yrange=[y1,y2]*.15 
            yrange=(useCh)?yrange*cos(d[0].h.std.chttd*.0001*!dtor) $
                          :yrange*cos(d[0].h.std.grttd*.0001*!dtor)
            if n_elements(ilim) eq 2 then begin
                i1=ilim[0]
                i2=ilim[1]
;
;               fraction of entire range we are skipping, start,end
;               start is pos, end is neg
;
                skipFrac=[i1,-(spipp-1-i2)]/( 1.*spipp)
                yrdelta=skipFrac*(yrange[1]-yrange[0])
            endif else begin
                i1=0L
                i2=spipp-1
                yrdelta=[0.,0.]
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
                    recNumSave=curRec
				    nsig=(useCh)?nsigCh:nsigDome				
                    case metmonkey(lun,numLoc,fbasel,useCh,singleStep,nsig,$
					   dohc,dirhcl,$
                           curRec=curRec,recPerImg=nrecs,profile=profile)  of   
                        2: goto,newfile
                        3: goto,done
                        4: begin
                            curRec=(curRec lt 1)?1:curRec
                            jj=d[0].h.std.reclen*(curRec -1) + fileInfo.byteOff
                            if (jj + bytesPerImage) gt curSize then begin
                                print,'Requested recnum beyond end of file'
                                curRec=recnumsave
                            endif else begin
                                curpos=jj
                                point_lun,lun,curpos
                                goto, readLoop
                            endelse
                           end
                    5: begin
                        print,'In data avail loop: .continue to continue'
                        stop
                        end
                 	7: begin
;					    force rescale.
						val=[0.,0.]
                		if useCh then begin
                    		valCh=val
							nsigCh=nsig
                		endif else begin
                    		valDome=val
							nsigDome=nsig
                		endelse
                       end
                     else:
                   endcase
                endif
            endif
        end until dataAvail 
;
;       get the data
;
readLoop:   sec1=systime(/sec)  
            point_lun,-lun,curpos  &$
            istat=atmget(lun,d,nrecs=nrecs,/search)
            sec2=systime(/sec)  
            if istat ne 1 then goto,ioerror
            if startOfFile then begin
                point_lun,-lun,aa
                fileInfo.byteOff=aa-bytesPerImage
                fileInfo.rec1=1
                startOfFile=0
            endif
;
;       reform and then average
;
            if useCh then begin
     y1=(reform((d.d1),spipp,toavg,(nrecs*ippbuf)/toavg))[txSmp+i1:i2,*,*]
                val=valCh
            endif else begin
     y1=(reform((d.d2),spipp,toavg,(nrecs*ippbuf)/toavg))[txSmp+i1:i2,*,*]
                val=valDome
            endelse
            mn=meanrob(y1,sig=sig)
;           mn=mean(y1)
            mn=[float(mn),imaginary(mn)]
            img=transpose(total((float(y1)-mn[0])^2 + (imaginary(y1)-mn[1])^2,$
                    2))/toavg
            if tmToExit then goto,done
            if val[1] eq 0 then begin
                a=meanrob(img,sig=sig)
				nsig=(useCh)?nsigCh:nsigDome
                val=[0,sig*nsig]
                if useCh then begin
                    valCh=val
                endif else begin
                    valDome=val
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
                recnumsave=curRec
				nsig=(useCh)?nsigCh:nsigDome				
                case metmonkey(lun,numLoc,fbasel,useCh,singleStep,nsig,$
						   dohc,dirhcl,$
                           curRec=curRec,recPerImg=nrecs,profile=profile)of   
                 2: goto,newfile
;
;                  if exit , reread previous image.  
; 
                 3: begin 
                    tmToExit=1
                    curpos-=bytesPerImage; back to previous image
                    point_lun,lun,curpos
                    goto,readLoop
                    end
                 4: begin
                    curRec=(curRec lt 1)?1:curRec
                    jj=d[0].h.std.reclen*(curRec - 1) + fileInfo.byteOff
                    if (jj + bytesPerImage) gt curSize then begin
                        print,'Requested recnum beyond end of file'
                        curRec=recnumsave
                    endif else begin
                        curpos=jj
                        point_lun,lun,curpos
                        goto, readLoop
                    endelse
                    end
                 5: begin
                    print,'In read  loop: .continue to continue'
                    print,'.continue to continue'
                    stop
                    end
                 7: begin
;					recompute scale
					  a=meanrob(img,sig=sig)
                	  val=[0,sig*nsig]
                	  if useCh then begin
                    	valCh=val
					    nsigCh=nsig
                	  endif else begin
                        valDome=val
					    nsigDome=nsig
                	  endelse
                    end
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
;
;           start record of image we are about to display
;
            point_lun,-lun,aa
            curRec=long((aa*1D - fileInfo.byteoff - bytesPerImage)/$
                          d[0].h.std.reclen + .5) + 1L
            fdName=(useCh)?'ch':'dome'
            title=string(format=$
            '(A," tm:",A," Rec:",i6," file:",a," ProcTm",f5.2)',$
                    fdName,tmlab,curRec,basename,totTm)
            imgdisp,(img > (val[0]))<val[1],xrange=xrange,$
            yrange=yrange+yrdelta,$
            win=winToUse,ytitle='Altitude [km]',xtitle='tm [secs]',title=title,$
                charsize=cs,invert=invert
            sec3=systime(/sec)  
            totTm=sec3-sec1
;
;           if pixwin, copy to active window
;
            if wpixwin ne -1 then begin
                 wset,win
                 device,copy=[0,0,xdim,ydim,0,0,wpixwin]
;
;				 hardcopy?
;
				 if dohc then begin
				 	lant=(useCh)?"ch_":"gr_"
					hcbasenm=(hcCnt eq 0)?basename:hcbasenm
				 	hcFile=dirhcl +  lant +  hcbasenm + "." +$
								     string(format='(i05)',hcCnt) + $
									 hc_suf
				    write_gif,hcfile,tvrd()
					hcCnt++
				endif
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
            prof=(profile)
            if prof then begin
                px=!x.window*!d.x_vsize
                py=!y.window*!d.y_vsize
                sx=long(px[1] - px[0] + 1.5)
                sy=long(py[1] - py[0] + 1.5)
                profiles,img,sx=px[0],sy=py[0],wsize=.75
            endif
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
