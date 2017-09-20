;+
;NAME:
;ristripch - stripchart recording of total power
;SYNTAX:   ristripch,lun,maxpnt=maxpnt,v1=v1,v2=v2,mean=mean,$
;                   scan=scan,rec=rec,rdDelay=rdDelay,pltDelay=pltDelay,$
;                   rdStep=rdStep,win=win
; ARGS:
;   lun:    int     to read power from
;KEYWORDS:
;   maxpnt: long    max number of points to display at once. default: 1000
;   v1[2] : float   min,max value for top plot
;   v2[2] : float   min,max value for bottom plot (polA-polB)
;   mean  : long    if set then remove mean from both plots.
;   scan : long     position to scan before starting. The
;                   default is the current position
;   rec   : long    record of scan to position to before starting.
;                   default: if scan present then:1 else current rec.
;rdDelay: float     number of seconds to wait between reads if no new
;                   data available.
;pltDelay: float    number of seconds to wait after each plot. Use this
;                   to slowly scan a file that already exists.
;   rdStep: long    max number of points to try and read at a time. Plot
;                   will increment by this amount when you read a file.
;   win   : long    window number to plot in. Default is 0
;DESCRIPTION:
;   The routine makes a stripchart recording of the total power and power
;difference polA-polB. It will step through the data file displaying
;up to MAXPNT pnts on the screen. When this value is reached, the plot will
;start scolling to the left. When the end of file is hit, the routine
;will wait rdDelay seconds (default of 1 second) and then try to read
;any new data in the file. This allows you to monitor data as it is 
;being taken. If you are scrolling through a file offline, use PLTDELAY
;to slow down the plotting rate (if it is too fast). At the end of the file
;hit any key and the enter q to quit (see below).
;
;   The top plot is the 0lag total power. The units are linear in power and the
;definition is measured/optimum power (for statistics of 3/9level sampling).
;You can change the vertical scale with the v1[min,max] keyword or from the
;menu displayed you hit any key. The line colors correspond to the 8 
;subcorrelators available on the interim correlator.
;
;   The bottom plot is the power difference PolA-PolB for each correlator
;board (NOTE: currently this only works if polA,polB are on the same board).
;The vertical scale can be changed with the v2=v2[min,max] keyword or from
;the menu displayed when you hit any key.
;
;   You can stop the plotting by touching any key on the keyboard.
;A menu will be presented that lets you modify some parameters and then
;continue. The menu is:
;
;command       function
;q             to quit
;r             rewind file
;v1  min max   new min,max for top    window 
;v2  min max   new min,max for bottom window 
;blank line ..continue 
;
;   You can quit, rewind the file and continue, change the vertical scale of
;the top plot with v1 min max, or change the vertical scale of the bottom
;plot. Any other inputline will let you continue from where you are
;(unlike cormonall, you have to enter return for the program to read the
;inputline.
;
;EXAMPLES:
;1. monitor the online datataking:
;   lun=coronl()
;   corstripch,lun
;
;2. set fewer points per plot for better resolution. Set the top vertical
;   scale to .8,2. and the bottom plot to -.4,.4.
;   corstripch,lun,maxpnt=600,v1=[.8,2],v2=[-.4,.4]
;
;3. If you want to restart from the begining of the file:
;   hit any character
;   r 
;   and it will rewind an continue
;
;4. If you want to monitor a file offline, with no wait between
;   updates, and 500 points plotted:
;   openr,lun,'/share/olcor/corfile.30apr03.x102.1',/get_lun
;   corstripch,lun,maxpnt=500,v1=[.5,3]
;
;5. Do the same thing but wait 1 second between plots and read 200 points at
;   a time:
;   corstripch,lun,maxpnt=500,v1=[.5,3],pltDelay=1,rdstep=200
;
;NOTE:
;   You can change the size of the plot by expanding or contracting the
;plot window. The plot will rescale itself.
;-
; history
; 21apr03 - added pixwin copy
; 21apr03 - double buffered space to 2*maxpnt. when we get to
;           2*maxpnt copy top half backto bottom half.
;           this way you cut down on the number of shifts you do when the
;           buf filled up.
; 30apr03 - added title. srcname, scan, ast time for rightmost point of plot
;         - added option to change setup, or wait by hitting any key..
; 09may03 - fixed index problem. check if nnkeep = 0lines 246..
;         
pro ristripch,lun,maxpnt=maxpnt,rdDelay=rdDelay,scan=scan,rec=rec,v1=v1,v2=v2,$
        rdstep=rdstep,pltDelay=pltDelay,mean=mean,win=win
    common colph,decomposedph,colph
;
;   
    forward_function checkkey
    !x.style=!x.style or 1
    !y.style=!y.style or 1
    xdimdef=640
    ydimdef=512
    wpixwintouse=4
    nlines=4L               ; plot all 4 strips
;
    if not keyword_set(mean) then mean=0
    if n_elements(rdstep) eq 0 then rdstep=100L
    if n_elements(maxpnt) eq 0 then maxpnt=1000L
    if n_elements(rddelay) eq 0 then rddelay=1
    if n_elements(scan) eq 0 then scan=0
    if n_elements(rec) eq 0  then rec=1
    if n_elements(pltDelay) eq 0 then pltDelay=0
    maxpntl=long(maxpnt)
    if (maxpntl mod rdstep) ne 0 then  begin
        n=long(maxpntl)/long(rdstep)
        maxpntl=(n + 1) * rdstep
    endif
    maxpntl2=maxpntl*2L
    if keyword_set(mean) then begin
      v1def=[-50,50]
      v2def=v1def
    endif else begin
      v1def=[0,2048]
      v2def=[-200,200]
    endelse
    if n_elements(v1)  ne  2 then v1=v1def
    if n_elements(v2)  ne  2 then v2=v2def
;
;   pixwin setup
;
    if n_elements(win) eq 0 then  begin
        win=0
        window,0,xsize=xdimdef,ysize=ydimdef
    endif else begin
        if win eq 4 then begin
            message,$
        'window 4 is use for the internal pixwin,pick another window...'
        endif
        wset,win
    endelse
    xdim=!d.x_size
    ydim=!d.y_size
    wpixwin=-1                  ; not allocated yet
;
    if scan ne 0 then begin
        istat=posscan(lun,scan,rec)
    endif
;
restart:
    npts=0
    d=fltarr(maxpntl2,nlines)
    !p.multi=[0,1,2]
    x=findgen(maxpntl2)
    i1=0L                   ; start of dataset index
    i2=0L                   ; end of dataset   index
    xinc1=.04
    xinc2=.03
    xp=.02
    ln2=17
    ln1=2
    n=rdstep
    labpol=['B ','A ']
    csn=1.2
    ch=checkkey()                   ; flush any chars here
    for i=0L,99999L-1L do begin &$
        staylooping=1
        istat=0L
        point_lun,-lun,startpos
        curpos=startpos
        n=0L
; 
;       keep reading till:
;       1. we've read at least  1 rec and then we need to block waiting for
;          a new rec  
;       2. or we've read rdstep recs
;
        while istat eq 0  do begin
            istat=waitnxtgrp(lun,0,bytesingrp=bytesingrp); check for next group
;                                         with 0 wait..
;           print,'wait istat:',istat
            if istat eq 0 then begin    ; found the grp
                curpos=curpos + bytesingrp  ; next read location
                point_lun,lun,curpos        ; position for next read.
                n=n+1L
                if n ge rdstep then istat=-1
            endif else begin
                istat=-1
            endelse
            ch=checkkey()
            if ch ne '' then begin
                print,'command       function'
                print,'q             to quit'
                print,'r             rewind file'
                print,'v1  min max   new min,max for top    window (no commas)'
                print,'v2  min max   new min,max for bottom window (no commas)'
                print,'blank line ..continue '
                inpstr=''
                read,inpstr
                cmd=strmid(inpstr,0,2)
                toks=strsplit(inpstr,' ,',/extract)
                case cmd of
                    'q': begin
                         print,'quitting...'
                         goto,done
                         end
                    'r': begin 
                            print,'rewinding file...'
                            rew,lun
                            print,'continuing...'
                            goto,restart
                         end
                    'v1': v1=float(toks[1:2])
                    'v2': v2=float(toks[1:2])
                    else: v1=v1
                endcase
                print,'continuing...'
             endif
        endwhile
;
;       n is the number of groups we've read
;
        if n eq 0L then begin
            wait,rddelay 
            goto,botloop
        endif 
        point_lun,lun,startpos
        recRd=riget(lun,b,numrecs=nrec) &$
        npnt=0
        if recRd eq 0 then goto,botloop
        a=size(b.d1)
        pntRec=a[2]
        npol=(n_tags(b) eq 3)?2:1
        npnt=pntRec*recRd
        if (i2 + npnt) ge (maxpntl2) then begin
            nnkeep=i2-i1 - npnt + 1
            if nnkeep gt 0 then begin
                d[0L:nnkeep-1L,*]=d[i2-nnkeep+1:i2,*]
                x=x+i2-nnkeep+1L
                i2=nnkeep-1L
            endif else begin
                x=x+i2-nnkeep+1L
                i2=0L
            endelse
            i1=0L
        endif
        if i2 eq 0 then begin
                d[i2:i2+npnt-1,0:1]= transpose(reform(b.d1,2,npnt,/overwrite))
                if npol eq 2 then $
                d[i2:i2+npnt-1,2:3]= transpose(reform(b.d2,2,npnt,/overwrite))
                i2=i2+npnt-1l
        endif else begin
                d[i2+1:i2+npnt,0:1]= transpose(reform(b.d1,2,npnt,/overwrite))
                if npol eq 2 then $
                 d[i2+1:i2+npnt,2:3]= transpose(reform(b.d2,2,npnt,/overwrite))
                i2= i2+npnt
        endelse
        if (i2 ge maxpntl) then i1=i2-maxpntl+1L
        if i2 gt 1 then begin &$
;
;           write into the pixwin        first
;
            if (!d.x_size ne xdim) or (!d.y_size ne ydim) or $
                    (wpixwin lt 0)  then begin
                    xdim=!d.x_size
                    ydim=!d.y_size
                    window,wpixwintouse,/pixmap,xsize=xdim,ysize=ydim
                    wpixwin=!d.window
            endif
            wset,wpixwin
;
            ver,v1[0],v1[1]
            if (keyword_set(mean)) then begin
                    mean4=total(d[i1:i2,*],1)/(i2-i1+1.)
;                   print,npnt,i1,i2,mean4
                    y=d[i1:i2,*]
                    for k=0,nlines-1 do y[*,k]=y[*,k]-mean4[k]
            endif else begin
                    y=d[i1:i2,*]
            endelse
            lab=string(format=$
                '("TOTAL POWER src:",a," scan:",i9," rec:",i5,"  timeAST:",a)',$
                    string(b[0].h.proc.srcname),b[0].h.std.scannumber,$
                    b[0].h.std.grpnum,fisecmidhms3(b[0].h.std.time))
                    
            plot,x[i1:i2],y[*,0],$
                    xtitle='sample',ytitle='power',$
                    title=lab
            for j=1,nlines-1 do oplot,x[i1:i2],y[*,j],col=colph[j+1]
            dif=y[*,[0,2]] -y[*,[1,2]]
            ver,v2[0],v2[1] 
            plot,x[i1:i2],dif[*,0],title='polA-polB'
            for j=1,nlines/2-1 do $
                    oplot,x[i1:i2],dif[*,j],col=colph[j+1]
            note,ln1,'sbc:',xp=xp
            for j=0,3 do begin
                    note,ln1,string(format='(i1,a2)',J/2+1,labpol[j mod 2]),$
                            color=colph[j+1],xp=.08+j*xinc1,charsize=csn
            endfor

            note,ln2,"sbcDif:",xp=xp,charsize=csn
            FOr  j=0,3 do begin
                    note,ln2,string(format='(i2)',J+1),color=colph[j+1],$
                            xp=.08+j*xinc2,charsize=csn
            endfor
;
;           pixwin copy     
;
            wset,win
            device,copy=[0,0,xdim,ydim,0,0,wpixwin]
            if pltDelay gt 0. then wait,pltDelay
        endif 
botloop:
    endfor
done: return
end
