;+
;NAME:
;psrfmonimg - monitor psrfits files via dynamic spectra.
;SYNTAX: psrfmonimg,bsg=bsg,num=num,projid=projid,date=date,dirI=dirI,$
;                 nspc=nspc,pollist=pollist,desc=desc,zx=zx,zy=zy,$
;				  blankcor=blankcor,pixwin=pixwin
;ARGS: none
;KEYWORDS: 
;    bsg: string beam,band,group to monitor. Format is bBsSgG where:
;                B =0..6 is the beam 
;                S =0..1 is the band (0=1450 band, 1=1300 band)
;                G =0..1 is the group.
;                default:'b0s0g0'
;    num: int    the file number to start with. (The default is the most recent)
; projid: string project id (first part of filename) to monitor. The default
;                is the most recent one written.
; date  : long   The date (in the filename) to start monitoring. The
;                default is the most current (and still matches the other
;                criteria.) The format is yyyymmdd.
; dirI : strarr(2): directory info. If the files are in a non standard place
;                then pass in location in dirI
;                dirI[0]=prefix  for dir: /share/pdata
;                        Num 1..n goes here
;                dirI[1]=postfix for dir: /pdev
; IMAGE:
;    nspc: int   the number of spectra for each image. The default is 
;                500 (or the max number in the file). It will try and 
;			 	 round the number to a multiple of spectra per row.
; pollist: int   pols for image. 1,2,12, -1 --> all pols available
;                if stokes, it does not plot u,v
;  zx    : int   if single pol then zoom (=n) or contract (-n) x axis by this
;                amount.
;  zy    : int   if single pol then zoom (=n) or contract (-n) y axis by this
;                amount.
;blankcor:       if set then correct for adc blanking.
;pixwin  :       if set then use a pixwin to switch between images (
;				 stops the flashing.
;RETURNS:
; desc  : {}     You can return from masmon with the current file still
;                open (using the x command from the menu). The file descriptor
;                will be returned here (this is actually a structure used by the
;                masxx routines). It is then your responsibility to close the
;                file via masclose,desc or masclose,/all.
;
; -----------------------------------------------------------------------------
;DESCRIPTION:
;   Monitor online and offline psrfitst files by making a dynamic spectra of 
; the data. The files to monitor can be selected by:
;1. if no arguments are supplied, use the most recent files from 
;   beam0,band0,group0.
;2. Specify the projid,date using the startup keywords.
;3. Use the menu inside masmon to select a different set of files to monitor.
;   - Enter the menu once masmon is started by hitting any key. 
;
; -----------------------------------------------------------------------------
;EXAMPLES:
;
;   psrfmonimg - start monitoring most recent file for b0s0g0
;   psrfmonimg,bsg=b0s1g0     .. start with beam0, band1 , group0
;   psrfmonimg,projid='a2130' .. use a2130 files
;   psrfmonimg,pollist=1     .. images of only polA 
; -----------------------------------------------------------------------------
;USING THE INTERNAL MENU:
;
;   Enter the internal memory by hitting any key.
;The menu is:
;
;Cmd CurVal    function
;
; -->  IMAGES:
; p   12         pols for images (1,2,12)
; h   low high   set horizontal range for images (freq low,hihg), blank --> all
; nspc 500       number of spectra per image. blank--> auto
; c   .02        clip value for data
; delay secs     secs to delay between images..
;
; -->  FILE POSITIONING:
; bsg  b0s0g0     beam,band,grp to use (change all at once)
; bm   0          beam to plot
; band 0          band to display (0 = 1450, 1=1300)
; d    20081011   date to use. First number of data displayed
; num  00801      number.. file number to display
; r       1       position to row. maxRows:  99
; l    (all)      list files this date (all --> all dates)
;
; -->  MISC:
; hdr            display last header read
; s      0       step mode. 1-on,0-off
; z              stop in procedure (for debugging)
; q              to quit
; x              quit leaving the current file open. return description in desc keyword
;otherKeys       continue plotting
;
; Enter the cmd and a possible value. The program will then continue. 
;The menu options are:
;
; p 12        .. pols for image. By default both pols are used (but in stokes mode
;                u,v are note used.
;             .. The pols are numbered: 1-polA,2-polB. Any combination 
;             .. of the pols can be displayed (entered as a one number eg 12..)
;   Example:
;     p 12    .. use pols a and polB.
; h           .. change the frequency range of the image. Units are Mhz. The default
;                is the entire frequency range.
;   Example:
;     h 1400 1450 display frequencies 1400 thru 1450 (if they are in the band)
; delay       .. secs to delay between plots. Use if the plotting is going
;                too fast.
;   Example:
;     delay .1   Delay .1 seconds between plots
;
; bsg b0s0g0  .. Select the beam,band,group to display. 
;             .. By default beam0,band0,grp0 is displayed.
;   Example:
;     bsg b0s1g0   .. will display the band centered at 1300 Mhz.
;
; d  20080826 .. Move to first file on this date using the current 
;                project id.
;  
; n   100     .. Move to this filenumber for the current date and project id.
;                If the number does not exist, you remain on the current file.
; l  (all)    .. list files for this projid, data. If all is included then 
;                list files for this projid for all dates.
; r  1        .. position to a row in the current file (count from 1)
;
; hdr         .. print last header read
; s  0/1      .. step mode will stop and display the menu after each spectra is
;                plotted. s 1 turns on step mode. s 0 turns it off.
; z           .. stop in masmon routine (for debugging)
; q           .. exit masmon.
;-
;
; ----------------------------------------------------------------------------
; opennewfile 
; 0 ok, 
; -1 could not open
function opennewfile,curFI,newFI,desc
;
    desc1=''
   	istat=psrfopen(newFI.fdir+newFI.fbase,desc1)
    if (istat eq 0 ) then begin
        if n_tags(desc) gt 1 then psrfclose,desc
        desc=desc1
        curFI=newFI
    endif else begin
        print,"Error openning file:",newFI.fbase
		stop
    endelse
    return,istat
end
; ----------------------------------------------------------------------------
; displayMenu:  display menu
;
;
;           Cmd CurVal   Function
;           -->  PLOTTING
;            p   n        pols to plot 1,2,12
;            h   h1 h2    hor min,max
;            m   0/1      use Median to flaten image 1--> true
;            nspc 500 1   avgSpcPerimg, spctoavg
;            c   .02      clip value (-1 --> default)
;            blank 0      adc blanking correct 0,1
;            -->  POSITIONING:
;            bsg  b6s1g0     beam,band,grp to use
;            bm   0..6 0     beam 0..6
;            band 0,1        band 0,1
;            d    20081013   move to first file of date
;            fnum 01103      move to this file number
;            
;            r      41       position to row. maxRows: 241
;            l    (all)      list files this date (all --> all dates)
;           -->  MISC
;            hdr          print current hdr
;            s   n        stepMode s 1 on,s 0 off
;            d   -        debug.. just stop in routine
;            q   -        quit
;            x   -        quit leaving file open

pro displayMenu,key,prgI,desc,curFI,b,dirI=dirI
;
;    lab=string(format='(" nspc toavg ddddd DDDDD avgSpcPerImg spcToAvg")',prgI.nspc,prgI.toavg)
    print,'Cmd CurVal    function'
    print,''
    print,'-->  PLOTTING:'
    lab=string(format='(" p          ",i4,"       pol to use (1..4,-1=all)")',prgI.pollist)
    print,lab
    print," h          low high   set horizontal image ..no args --> all"
    lab=string(format='(" nspc toavg ",i5,i5," avgSpcPerImg spcToAvg")',prgI.nspc,prgI.toavg)
    print,lab
    lab=string(format='("                       rawSpcPerRow:",i5)',prgI.spcPerRow)
    print,lab
	lab=string(format='(" c          ",f7.4,"    clipping level for image")',prgI.clip)
    print,lab
;	lab=string(format='(" blank ", i2 ,"       adcBlanking correction (0,1)")',prgI.blankCor)
;    print,lab
    lab=string(format='(" m          ",i1,"          0,1=used median for bandpass flattening")',$
						(prgI.useMedian)?1:0)
    print,lab
    lab=string(format='(" delay     ",f5.2,"       plot delay secs")',$
                    prgI.sectoDelayPlot)
    print,lab
;
    print,''
    print,"-->  POSITIONING:"
    lab=string(format='(" bsg  ", a,"     beam,band,grp to use")',curFI.bsg)
    print,lab 
    bm=strmid(curFI.bsg,1,1)
    lab=string(format='(" bm   ", a,"          beam (0..6) to use")',bm)
    print,lab 
    band=strmid(curFI.bsg,3,1)
    lab=string(format='(" band  ", a,"         band to use (0=1450,1=1300)")',band)
    print,lab 
    lab=string(format=$
            '(" d    ", a,"   move to first file of date")',curFI.ldate)
    print,lab
    lab=string(format='(" fnum ", i2,"      number of file to use (from list)")',1)
    print,lab
    lab=string(format=$
            '(" r    ",i4,"       row of file to position. maxRows:",i4)',$
            desc.curRow,desc.totRows);
    print,lab
    print," l    (all)      list files this date (all --> all dates)"

    print,''
    print,"-->  MISC:"
    print,' cur            track cursor position'
    print,' hdr            print current header'
    lab=string(format=$
            '(" s   ",i4,"       step mode. 1-on,0-off")',prgI.stepmode)
    print,lab
    print,' z              stop in procedure (for debugging)'
    print,' q              to quit'
    print,' x              to quit leaving file open'
    print,'otherKeys       continue plotting'
    inpstr=''
    read,inpstr
    toks=strsplit(inpstr,' ,',/extract)
    cmd=toks[0]
;
    case cmd of
    'p':begin
        validPol=[-1,1,2,12]
        polList=(n_elements(toks) lt 2) ? -2 : toks[1]
        ii=where(pollist eq validPol,cnt)
        if cnt gt 0 then begin
			if polList ne prgI.polList then begin
            	prgI.polList=polList
				prgI.rowGot=0L
				prgI.newInfo=1L
			endif
        endif else begin
            print,"enter p -1,1,2,12 for pols to plot"
        endelse
        end
    'h':begin
        if n_elements(toks) eq 1 then begin
            prgI.useFreqIndex=0
		   	prgI.updateFreqIndex=0
        endif else begin
            if (n_elements(toks) eq 3) then begin
		    	prgI.useFreqIndex=1
		    	prgI.freqRange=(toks[1] lt toks[2])?[toks[1],toks[2]]:[toks[2],toks[1]]
		    	prgI.updateFreqIndex=1
            endif else begin
                print,"Enter: h  freqmin freqmax"
            endelse
        endelse
        end
    'nspc':begin
        if n_elements(toks) eq 1 then begin
			prgI.nspc=0
			prgI.toavg=1
        endif else begin
            if (n_elements(toks) eq 3) then begin
				if (toks[1] ne prgI.nspc) or (toks[2] ne prgI.toavg) then begin
                	prgI.nspc=toks[1]
                	prgI.toavg=toks[2]
	            	prgI.rowGot=0L
					prgI.newInfo=1
			    endif
            endif else begin
                print,"Enter: nspc avgSpcPerImg spcToAvg"
            endelse
        endelse
        end
;	 'toavg':begin
;        if n_elements(toks) eq 1 then begin
;			if prgI.toAvg ne 1 then begin
;            	prgI.toAvg=1
;				prgI.newInfo=1
;			endif
;        endif else begin
;            if (n_elements(toks) eq 2) then begin
;				if (toks[1] ne prgI.toAvg) then begin
;                	prgI.toAvg=toks[1]
;                	prgI.rowGot=0L
;					prgI.newInfo=1
;				endif
;            endif else begin
;                print,"Enter: toavg spectraToAvg"
;            endelse
;        endelse
;        end

    'm':begin
        if n_elements(toks) eq 2 then begin
            prgI.useMedian=(toks[1] eq 0)?0:1
        endif else begin
                print,"Enter: m  0,1"
        endelse
        end
   ;   plot delay

    'delay':begin
        if n_elements(toks) ne 2 then begin
            print,'Enter delay secsToDelay'
        endif else begin
            prgI.secToDelayPlot=toks[1]
        endelse
        end

;
    'z':begin &$
        prgI.dbgStop=1
        return 
        end

    ;   bsg: go use

    'bsg':begin
        if n_elements(toks) ne 2 then begin
            print,'Enter bsg  b0s0g0 for beam,band,group to use'
        endif else begin
            bsg=toks[1]
            istat=masmostrecentfile(curFI.proj,curFI.ldate,bsg,curFI.lnum,$
                          newFI,flist=flist,dirI=dirI,/psrfits,src=curFI.src)
            if istat eq 1 then begin
                istat=opennewfile(curFI,newFI,desc)
                prgI.dataAvail=0
				prgI.rowGot=0L
				prgI.newInfo=1
            endif else begin
                print,"no files found for " + bsg + "for this date and number"
            endelse
        endelse
        end

      'bm':begin
        if (n_elements(toks) ne 2) || ((toks[1] lt 0) or (toks[1] gt 6)) $
            then begin
            print,'Enter bm  0..6 beam to use'
        endif else begin
            bm=toks[1]
            bsg=curFI.bsg
            strput,bsg,bm,1 
            istat=masmostrecentfile(curFI.proj,curFI.ldate,bsg,curFI.lnum,$
                          newFI,flist=flist,dirI=dirI,/psrfits,src=curFI.src)
            if istat eq 1 then begin
                istat=opennewfile(curFI,newFI,desc)
                prgI.dataAvail=0
				prgI.rowGot=0L
				prgI.newInfo=1
            endif else begin
                print,"no files found for " + bsg + "for this date and number"
            endelse
        endelse
        end

      'band':begin
        if (n_elements(toks) ne 2) || ((toks[1] lt 0) or (toks[1] gt 1)) $
            then begin
            print,'Enter band  0..1  band to use'
        endif else begin
            band=toks[1]
            bsg=curFI.bsg
            strput,bsg,band,3 
            istat=masmostrecentfile(curFI.proj,curFI.ldate,bsg,curFI.lnum,$
                          newFI,flist=flist,dirI=dirI,/psrfits,src=curFI.src)
            if istat eq 1 then begin 
                istat=opennewfile(curFI,newFI,desc)
                prgI.dataAvail=0
				prgI.rowGot=0L
				prgI.newInfo=1
            endif else begin
                print,"no files found for " + bsg + "for this date and number"
            endelse
        endelse
        end
;              clipping
      'c':begin
        if (n_elements(toks) ne 2) || (toks[1] le 0.) $
            then begin
            print,'Enter c  value for image clipping level (>0.)'
        endif else begin
            prgI.clip=toks[1]
        endelse
        end
;              adc blanking correction
      'blank':begin
        if (n_elements(toks) ne 2)  then begin
            print,'Enter blank (0,1) for adc blanking correction.'
        endif else begin
            prgI.blankCor=(toks[1] eq 0)?0:1
        endelse
        end



;   date: postion to start of date

    'd':begin
        if n_elements(toks) ne 2 then begin
            print,'Enter d  yyyymmdd for date to position to'
        endif else begin
            ldate=toks[1]
            istat=masmostrecentfile(curFI.proj,ldate,curFI.bsg,"*",$
                          newFI,flist=flist,/oldest,dirI=dirI,/psrfits)
            if istat eq 1 then begin
                istat=opennewfile(curFI,newFI,desc)
                prgI.dataAvail=0
				prgI.rowGot=0L
				prgI.newInfo=1
            endif
        endelse
        end
;
;   num: postion to this file number (from start of day)
;
    'fnum':begin
        if n_elements(toks) ne 2 then begin
            print,'Enter fnum  filenumer position to this file number'
        endif else begin
            fnum=string(format='(i05)',toks[1])
			lnum='*'
            istat=masmostrecentfile(curFI.proj,curFI.ldate,curFI.bsg,lnum,$
                          newFI,flist=flist,dirI=dirI,/psrfits)
            if istat eq 1 then begin
				nn=n_elements(flist)
				fnum=(fnum gt nn)?nn:(fnum lt 1)?1:fnum
				a=stregex(flist[nn-fnum],$
;     proj     date    src     bsg               num
"(.*/)([^.]+).([0-9]+).(.*).(b[0-6]s[0-1]g[0-1]).([0-9]+)",/sub,/ext)
        		newFI={$
             		fdir: a[1],$
            		fbase: a[2]+'.'+a[3]+'.'+a[4]+'.'+a[5]+ '.' + a[6]+'.fits',$
            		proj : a[2],$
            		ldate: a[3],$
              		src: a[4],$
              		bsg: a[5],$
             		lnum: a[6]}
                istat=opennewfile(curFI,newFI,desc)
                prgI.dataAvail=0
				prgI.rowGot=0L
				prgI.newInfo=1
            endif else begin
                print,'file Number:'+lnum +" does not exists for date:",$
                    curFI.ldate
            endelse
        endelse
        end

;
    'l':begin
        ldate=curFI.ldate
        ldate=((n_elements(toks) eq 2) && (toks[1] eq 'all')) $
              ?"*":curFI.ldate
        istat=masmostrecentfile(curFI.proj,ldate,curFI.bsg,"*",$
                    flist=flist,dirI=dirI,/psrfits)
        if istat eq 1 then begin
			nf=n_elements(flist)
			print,"fnum  filename"
            for i=0,nf-1 do begin
                l=strpos(flist[i],"/",/reverse_offset,/reverse_search)
                print,nf-i,strmid(flist[i],l),format='(i4,1x,a)'
           endfor
        endif
        end

;       position to row

        'r':begin
            if n_elements(toks) lt 2 then begin
                print,'Enter: r  rownumber'
            endif else begin
                if (n_tags(desc) lt 2) then begin
                     print,'No file currenlty open.. no positioning allowed'
                endif else begin
                    irow=toks[1] -1
                    irow=(irow>0)<(desc.totRows-1)
                    desc.curRow=irow
                    prgI.dataAvail=0
				    prgI.rowGot=0L
                endelse     
            endelse
            end
        'q':begin
            print,'quitting...'
            prgI.done=1
            prgI.dataAvail=0
            end
        'x':begin
            print,'quitting leaving file open...'
            prgI.done=2
            prgI.dataAvail=0
            end
        's':begin
            if n_elements(toks) lt 2 then begin
                print,'Enter s 0 or 1 .. turn off,on step mode'
            endif else begin
                prgI.stepmode=(toks[1] eq 0) ? 0 : 1
            endelse
            end
       'hdr':begin &$
              help,desc.hpri,/st          ; display header
              help,desc.hsubint,/st          ; display header
              help,b,/st          ; display header
             end
	    'cur':begin
            print,"track cursor. LeftMouseButton:MarkPosition, RightMouseButton:done"
            i=rdcur(icur)
            end
        else:
    endcase
    print,'continuing...'
    return
end
;
; ----------------------------------------------------------------------------
;  psrfmonimg
pro psrfmonimg,bsg=bsg,num=num,projid=projid,date=date,nspc=nspc,pollist=pollist,$
               desc=desc,_extra=_e,dirI=dirI,zx=zx,zy=zy,toavg=toavg,blankcor=blankcor,$
			   pixwin=pixwin
	forward_function masmostrecentfile
    common colph,decomposedph,colph
;
;   figure out which file to start with
;
	ln=.5
	cs=1
	xstyle=9
    prgI={$
       dbgStop : 0        ,$ ; if true then stop in masmon after checkkey
       stepMode: 0        ,$ ; if one then menu each plot
       polList : -1       ,$ ; by default use all
       dataAvail: 0       ,$ ; 1 if data avail to plot
           done : 0       ,$; 1--> exit, 2--> exit leaving file open
    secToSleepFile: 2.    ,$; secs to sleep after ls -lt and no new file
    secToDelayPlot: 0.    ,$; secs to delay between plots
	toAvg         : 1     ,$; number of spectra to avg together.
	newInfo       : 1     ,$; set when we change toavg,nspc,

	nspc          : 0L    ,$; number spectra per image
	freqRange: fltarr(2)  ,$; freq1,freq2 for image.
	useFreqIndex: 0       ,$; if true then use subSet for freqRange
	ifreqIndex: lonarr(2) ,$; if useFreqIndex then use indices of spectra to use
	updateFreqIndex: 0    ,$ ; if true then need to recompute ifreqIndex
	useMedian      : 1    ,$ ; if true then use median for flattening image
	clip           : 3    ,$ ; by default lip to 3 sigma
	blankCor       : 0    ,$ ; by default no adcblanking correction
	
;   info on data we've currently read in
	spcPerRow     : 0L    ,$; we are currently using
	rowPerImg     : 0L    ,$; rows per image
	rowGot		  : 0L     $; we've currently gotten for image
    }
    wpixwinToUse=4
    wpixwin=-1
	win=0
	bimg=''
    desc=''
	if keyword_set(blankcor) then prgI.blankcor=1
    prgI.polList=(n_elements(polList) gt 0)?polList:-1
    if n_elements(bsg) eq 0 then bsg='b0s0g0'
    if n_elements(toavg) eq 0 then toavg=1
    if n_elements(nspc) ne 0 then prgI.nspc=nspc
    lnum=(n_elements(num) gt 0)?string(format='(i05)',num):'*'
    if n_elements(projid) eq 0 then projid='*'
    ldate=(n_elements(date) gt 0)?string(format='(i8)',date) :"*"
    a=stregex(bsg,"b([0-6])",/sub,/extr)
	prgI.toAvg=toavg
;;    beam=a[1]
;;    basDir=string(format='("/share/pdata",i1,"/pdev/")',beam+1);
;
    istat=masmostrecentfile(projid,ldate,bsg,lnum,curFI,dirI=dirI,/psrfits)
	if istat ne 1 then begin 
			print,'no files found for requested range'
			return
	endif
    psrfclose,/all
  	istat=psrfopen(curFI.fdir+curFI.fbase,desc)
    done=(istat lt 0)
	sameWin=0
	imgdim=[-1,-1]
	rowStartImg=-1
    while (prgI.done eq 0 ) do begin
        istatget=psrfget(desc,b,blankcor=prgI.blankcor) 
        prgI.dataAvail=(istatget eq 1)
        ; hit eof ..
        if ( not prgI.dataAvail)   then begin
            ; see if file has grown since last open
            istatupd=masupdfsize(desc)
            if istatupd eq 1 then continue  ; file grew.. read again
            istat1=masmostrecentfile(curFI.proj,"*",curFI.bsg,"*",newFI,$
                    curFI=curFI,dirI=dirI,/psrfits)
            ; moved to a new file
            if (newFi.fbase ne curFI.fbase) then begin
                istat=opennewfile(curFI,newFI,desc)
                if istat lt 0 then begin
					wait,prgI.secToSleepFile
				endif else begin
					prgI.newInfo=1
				endelse
            endif else begin
;                print,'waiting..'
                wait,prgI.secToSleepFile
            endelse
        endif 
        key=checkkey();
        if (key ne '')  then begin
            displayMenu,key,prgI,desc,curFI,b,dirI=dirI
            if prgI.dbgStop then begin 
            	print,"stopping in psrfmonimg (for debugging).  .continue to continue"
            	stop
            	prgI.dbgStop=0
            endif
;           requested mulitple pols and file has multiple pols, then 
;           leave samewin as it is..
			sameWin=((prgI.pollist gt 9) and (desc.hsubint.npol gt 1))?sameWin:0
        endif       
;
;
;		make sure we have spc/image and b.ndumps setup correctly
;
        if prgI.dataAvail ne 1 then continue
		if prgI.nspc eq 0 then prgI.nspc=500L
		ndumps=n_elements(b.stat)
		if (prgI.spcPerRow ne ndumps) || prgI.newInfo then begin
		   prgI.spcPerRow=ndumps
		   prgI.toAvg=(prgI.toAvg < ndumps)
		   avgDumpsPerRow=ndumps / prgI.toAvg
;          make spectra used divisible by ndumps
		   nrows=prgI.nspc/avgDumpsPerRow
		   if nrows eq 0 then nrows=1
		   prgI.nspc=(avgDumpsPerRow*nrows)
		   prgI.rowPerImg=(prgI.nspc*prgI.toavg)/ndumps
		   if ( (prgI.rowPerImg*ndumps) lt (prgI.nspc*prgI.toavg)) then prgI.rowPerImg+=1
		   prgI.rowGot=0
		   prgI.newInfo=0
		   !p.multi=(prgI.pollist lt 9)?[0,1,1]:[0,1,2]
		endif
;
;		rows/img changed or size[0]=0 --> '' start
;       need to check to make sure bimg is a struct before testing bimg.data
;
		needNew=(size(bimg,/type) ne 8)  ; if not struct then not defined
		needNew=(needNew)?needNew: (n_elements(bimg) ne prgI.rowPerImg) or  ((size(bimg))[0] eq 0) or $
					     (n_elements(bimg[0].data) ne n_elements(b[0].data)) 
		if needNew then begin
			bimg=replicate(b,prgI.rowPerImg)
			prgI.rowGot=0
		endif
		bimg[prgI.rowGot]=b
		if prgI.rowGot eq 0 then rowStartImg=desc.curRow
;	    print,"curRow:",desc.curRow," rStImg:",rowStartImg," rowGot:",prgI.rowGot
		prgI.rowGot += 1
		if prgI.rowGot lt prgI.rowPerImg then continue
;
;       here is the imaging
;
        if (prgI.stepMode) then begin
            displayMenu,key,prgI,desc,curFI,b,dirI=dirI
            if prgI.dbgStop then begin 
            print,"stopping in psrfmonimg (for debugging).  .continue to continue"
            stop
            prgI.dbgStop=0
            endif
        	if prgI.dataAvail ne 1 then continue
        endif       
        if ( (not prgI.stepMode) and (prgI.secToDelayPlot gt 0.)) then $
            wait,prgI.secToDelayPlot
        tm=desc.hpri.stt_smjd + bimg[0].OFFS_SUB - 4*3600.
        tm=(tm lt 0.)?tm + 86400.:tm
        tit=string(format=$
            '(a," Row:",i4,"/",i4," ",a,"_Ast az_za:",f5.1,1x,f4.1)',$
                curFI.fbase,rowStartImg,desc.totRows,fisecmidhms3(tm),$
				bimg[0].tel_az,bimg[0].tel_zen)
		if prgI.useFreqIndex then begin
			if prgI.updateFreqIndex then begin
				freq=b.dat_freq;
				if (freq[0] lt freq[1]) then begin
					i1=where(freq ge prgI.freqRange[0],cnt)
					i1=(cnt eq 0)?0:i1[0]
					i2=where(freq ge prgI.freqRange[1],cnt)
					i2=(cnt eq 0)?n_elements(freq)-1:i1[0]
			    endif else begin
					i1=where(freq le prgI.freqRange[1],cnt)
					i1=(cnt eq 0)?0:i1[0]
					i2=where(freq le prgI.freqRange[0],cnt)
					i2=(cnt eq 0)?n_elements(freq)-1:i2[0]
				endelse
				prgI.ifreqIndex=[i1,i2]
			    prgI.updateFreqIndex=0
			endif
			useInd=prgI.ifreqIndex
		endif else begin
			useInd=0
		endelse
		clip=(prgI.clip lt 0)?0:prgI.clip ; for masimgdisp, clip=0 is default clipping.
        imgdimCur=[desc.hpri.obsnchan,desc.hsubint.nsblk*n_elements(bimg)]
		if ((imgdimCur[0] ne imgdim[0])or(imgdimCur[1] ne imgdim[1])) then begin
            samewin=0
            imgdim=imgdimCur
        endif
;
;           write image .. into screen or pixwin
;
            if (wpixwin ne -1) and (sameWin eq 1)  then begin
                wset,wpixwin
                wintouse=wpixwin
            endif else begin
                wintouse=win
            endelse
		img=psrfimgdisp(desc,bimg,wxlen=1024,zx=zx,zy=zy,median=prgI.useMedian,samewin=samewin,$
				useInd=useInd, mytitle=tit,nsigClip=clip,pollist=prgI.pollist,$
				toavg=prgI.toAvg,ln=ln,cs=cs,xstyle=xstyle,win=winToUse)
		prgI.rowGot=0
;
;           if pixwin, copy to active window
;
            if (wpixwin ne -1) and (sameWin eq 1) then begin
                 wset,win
                 device,copy=[0,0,xdim,ydim,0,0,wpixwin]
            endif
;
;           first time, get dimensions of window for pixwin.
;           start pixwin write on 2nd iteration
;
        if (sameWin eq 0) and keyword_set(pixwin)  then begin
               if wpixwin ne -1 then wdelete,wpixwin
               xdim=!d.x_size
               ydim=!d.y_size
               window,wpixwintouse,/pixmap,xsize=xdim,ysize=ydim
               wpixwin=!d.window
        endif
		sameWin=1
        empty
    endwhile
    if n_tags(desc) gt 1 then begin
            if (prgI.done ne 2) then masclose,desc
    endif
    if wpixwin ne -1 then wdelete,wpixwin
    return
    end
