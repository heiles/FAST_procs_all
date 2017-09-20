;+
;NAME:
;masstripch - stripchart recording of total power
;SYNTAX:   masstripch,desc,maxpnt=maxpnt,v1=v1,v2=v2,sub=sub,$
;                   rec=rec,rdDelay=rdDelay,pltDelay=pltDelay,$
;                   rdStep=rdStep,win=win,median=median,maskar=maskar
; ARGS:
;  desc:    {}      from masopen()
;KEYWORDS:
;   polList:int     pols to use. 1,12,-1 (all pols a,b def)
;   maxpnt: long    max number of points to display at once. default: 1000
;   v1[2] : float   min,max value for top plot
;   v2[2] : float   min,max value for bottom plot (polA-polB)
;   sub   :         if set then subtract running mean
;   scan : long     position to scan before starting. The
;                   default is the current position
;   rec   : long    record of file to position to before starting.
;                   cnt from 1..def: 1
;rdDelay: float     number of seconds to wait between reads if no new
;                   data available.
;pltDelay: float    number of seconds to wait after each plot. Use this
;                   to slowly scan a file that already exists.
;   rdStep: long    max number of points to try and read at a time. Plot
;                   will increment by this amount when you read a file.
;   win   : long    window number to plot in. Default is 0
;median   :         if set, use the median to compute the power
;maskar[nchn]:int   if provided then use to mask off chan
;                   with rfi. use chan where maskAr[] > 0
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
;   istat=masopen(file,desc)
;   masstripch,desc
;
;2. set fewer points per plot for better resolution. Set the top vertical
;   scale to .8,2. and the bottom plot to -.4,.4.
;   masstripch,desc,maxpnt=600,v1=[.8,2],v2=[-.4,.4]
;
;3. If you want to restart from the begining of the file:
;   hit any character
;   r 
;   and it will rewind an continue
;
;4. If you want to monitor a file offline, with no wait between
;   updates, and 500 points plotted:
;   istat=masopen(file,desc)
;   masstripch,desc,maxpnt=500,v1=[.5,3]
;
;5. Do the same thing but wait 1 second between plots and read 200 points at
;   a time:
;   masstripch,lun,maxpnt=500,v1=[.5,3],pltDelay=1,rdstep=200
;
;NOTE:
;   You can change the size of the plot by expanding or contracting the
;plot window. The plot will rescale itself.
;-
; history
; -----------------------------------------------------------------
; compute the power
pro cmppwr,b,usea,useb,tp,TsysN,median=median,usemask=usemask,iigd=iigd

	tp=fltarr(2)
	useMed=keyword_set(median)
	if useA then begin
		if useMask then begin
			tp[0]=(usemed)?median(b.d[iigd,0]):mean(b.d[iigd,0]) 
		endif else begin
			tp[0]=(usemed)?median(b.d[*,0]):mean(b.d[*,0]) 
		endelse
		if tsysN[0] lt 0. then tsysN[0]=tp[0] 
		tp[0]/=tsysN[0]
	endif
	if useB then begin
		if useMask then begin
			tp[1]=(usemed)?median(b.d[iigd,1]):mean(b.d[iigd,1]) 
		endif else begin
			tp[1]=(usemed)?median(b.d[*,1]):mean(b.d[*,1]) 
		endelse
		if TsysN[1]  lt 0. then TsysN[1]=tp[1]
		tp[1]/=tsysN[1]
	endif
	return
	end
; -----------------------------------------------------------------
;         
pro masstripch,desc,maxpnt=maxpnt,rdDelay=rdDelay,rec=rec,v1=v1,v2=v2,$
        rdstep=rdstep,pltDelay=pltDelay,sub=sub,win=win,polList=polList,$
			median=median,maskar=maskar
;
;   
    common colph,decomposedph,colph
    forward_function checkkey
    !x.style=!x.style or 1
    !y.style=!y.style or 1

	usemask=(n_elements(maskar) gt 0)
	iigd=(useMask)?where(maskAr gt .01):0
	TsysN=[-1d,-1d]			; use first point to define Tsys
	polListL=12
	if n_elements(pollist) ne 0 then polListL=polList
	if polListL eq -1 then begin
		useA=1
		useB=1
	endif else begin
		l=string(polListL)
		useA=strpos(l,'1') ne -1
		useB=strpos(l,'2') ne -1
	endelse

    xdimdef=640
    ydimdef=512
    wpixwintouse=4
    nlines=2L               ; a,b 
	if (n_elements(maskAr) gt 0) then begin
		useMask=1
        iiuse=where(maskAr gt .01,ngd)
	endif
;
    if not keyword_set(sub) then sub=0
    if n_elements(rdstep) eq 0 then rdstep=1L
	; hardcode to 1 for now
	rdstep=1L
    if n_elements(maxpnt) eq 0 then maxpnt=1000L
    if n_elements(rddelay) eq 0 then rddelay=1
	nxtRowToRd=1L
    if n_elements(rec) ne 0  then nxtRowToRd=rec
    if n_elements(pltDelay) eq 0 then pltDelay=0
    maxpntl=long(maxpnt)
    if (maxpntl mod rdstep) ne 0 then  begin
        n=long(maxpntl)/long(rdstep)
        maxpntl=(n + 1) * rdstep
    endif
    maxpntl2=maxpntl*2L
    if keyword_set(sub) then begin
    	v1def=[-.01,.01]
        v2def=v1def
    endif else begin
        v1def=[.9,1.2]
        v2def=[-.2,.2]
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
restart:
    npts=0
    d=fltarr(maxpntl2,nlines)
    !p.multi=0
    x=findgen(maxpntl2)
    i1=0L                   ; start of dataset index
    i2=0L                   ; end of dataset   index
	firstTm=1
    xinc1=.04
    xinc2=.03
    xp=.02
    ln2=17
    ln1=2
    n=rdstep
    labpol=['A ','B ']
    csn=1.2
    ch=checkkey()                   ; flush any chars here
    for i=0L,99999L-1L do begin &$
        staylooping=1
        istat=0L
        n=0L
; 
;       keep reading till:
;       1. we've read at least  1 rec and then we need to block waiting for
;          a new rec  
;       2. or we've read rdstep recs
;
        while istat eq 0  do begin
;			print,"nxtRowtoRd:",nxtRowToRd," decCurrow:",desc.currow
			istat=masget(desc,b,row=nxtRowToRd)
            if istat eq 1 then begin    ; found the grp
                nxtRowToRd=0L
				n++
				break
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
							nxtRowToRd=1L
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
            wait,rddelay &$
			istat=masupdfsize(desc)
        endif else begin
			cmppwr,b,useA,useB,tp,TsysN,median=median,usemask=usemask,iigd=iigd
			npnt=1L
            if (i2 + npnt) ge (maxpntl2) then begin
                nnkeep=i2-i1 - npnt + 1
                if nnkeep gt 0 then begin
                    d[0L:nnkeep-1L,*]=d[i2-nnkeep+1:i2,*]
                    x=x+i2-nnkeep+1L
                    i2=nnkeep-1L
                endif else begin
                    x=x+i2-nnkeep+1L
                    i2=0L
					firstTm=1
                endelse
                i1=0L
;               d=reform(shift(reform(d,maxpntl*nlines,/overwrite),-npnt),$
;                   maxpntl,nlines,/overwrite)
;               i1=i1-npnt
            endif
            if (i2 eq 0) and firstTm then begin
                d[i2:i2+npnt-1,*]= reform(tp,npnt,nlines)
                i2=i2+npnt-1l
				firstTm=0
            endif else begin
                d[i2+1:i2+npnt,*]= reform(tp,npnt,nlines)
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
                if (keyword_set(sub)) then begin
                    mean2=total(d[i1:i2,*],1)/(i2-i1+1.)
;                   print,npnt,i1,i2,mean8
                    y=d[i1:i2,*]
                    for k=0,nlines-1 do y[*,k]=y[*,k]-mean2[k]
                endif else begin
                    y=d[i1:i2,*]
                endelse
				secMid=long(b[0].h.crval5 - 4*3600L + .5)
				if secMid lt 0 then secMid +=86400L
                lab=string(format=$
                '("TOTAL POWER: timeAST:",a)',fisecmidhms3(secMid) )
                plot,x[i1:i2],y[*,0],$
                    xtitle='sample',ytitle='power',$
                    title=lab,/nodata
                    if (useA) then oplot,x[i1:i2],y[*,0],col=colph[1]
                    if (useB) then oplot,x[i1:i2],y[*,1],col=colph[2]
;
;           pixwin copy     
;
                wset,win
                device,copy=[0,0,xdim,ydim,0,0,wpixwin]
                if pltDelay gt 0. then wait,pltDelay
            endif 
        endelse &$
    endfor
done: return
end
