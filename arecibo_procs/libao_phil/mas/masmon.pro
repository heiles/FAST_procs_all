;+
;NAME:
;masmon - monitor mas files.
;SYNTAX: masmon,bsg=bsg,num=num,projid=projid,date=date,noavg=noavg
;               norm=norm,pollist=pollist,desc=desc,dirI=dirI,
;               noappbm=noappbm
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
;  noavg:        If set then don't average multiple spectra within one row.
;                By default each row is averaged to one spectra.
; desc  : {}     You can return from masmon with the current file still
;                open (using the x command from the menu). The file descriptor
;                will be returned here (this is actually a structure used by the
;                masxx routines). It is then your responsibility to close the
;                file via masclose,desc or masclose,/all.
; dirI : strarr(2): directory info. If the files are in a non standard place
;                then pass in location in dirI
;                dirI[0]=prefix  for dir: /share/pdata
;                        Num 1..n goes here
;                dirI[1]=postfix for dir: /pdev
;noappbm:        if set then no bm number between pre,pos dir name
;                eg.. /share/pdata/pdev
; PLOTTING 
;   norm:        if set then normalize spectra before plotting
; pollist: int   pols to plot: 1,2,12,123,1234. -1 --> all pols available
;     off: float if multiple spectra/plot (/noavg and multiple spectra per
;                row) then separate spectra by this amount vertically.
; -----------------------------------------------------------------------------
;DESCRIPTION:
;   Monitor online and offline mas files plotting each row in the file. The 
;files to monitor can be selected by:
;1. if no arguments are supplied, use the most recent files from 
;   beam0,band0,group0.
;2. Specify the projid,date using the startup keywords.
;3. Use the menu inside masmon to select a different set of files to monitor.
;   - Enter the menu once masmon is started by hitting any key. 
;
; -----------------------------------------------------------------------------
;EXAMPLES:
;
;   masmon - start monitoring most recent file for b0s0g0
;   masmon,bsg=b0s1g0     .. start with beam0, band1 , group0
;   masmon,projid='a2130' .. use a2130 files
;   masmon,projid='a2130',/noavg  .. do not average the 2 millisecond spectra
;   masmon,pollist=12    .. only only plot pola and B, ignore, U,V.
; -----------------------------------------------------------------------------
;USING THE INTERNAL MENU:
;
;   Enter the internal memory by hitting any key.
;The menu is:
;
;Cmd CurVal    function
;
; -->  PLOTTING:
; p   1234       pols to plot (1..4)
; h   low high   set horizontal plot range ..no args --> autoscale
; v   low high   set vertical   plot range ..no args --> autoscale
; delay secs     secs to delay between plots..
;
; -->  POSITIONING:
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
; p 1234      .. pol to plot. By default all pols in the file are plotted. The
;             .. The pols are numbered: 1-polA,2-polB,3-U,4=V. Any combination 
;             .. of the pols can be displayed (entered as a one number eg 12..)
;   Example:
;     p 12    .. just plot pols 1(a) and 2 (b)
; h,v         .. These will change the horizontal,vertical scale of the plots
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
function opennewfile,curFI,newFI,desc,gftd=gftd
;
    desc1=''
	if keyword_set(gftd) then begin
    	istat=gftopen(newFI.fdir+newFI.fbase,desc1)
	endif else begin
    	istat=masopen(newFI.fdir+newFI.fbase,desc1)
	endelse
    if (istat eq 0 ) then begin
        if n_tags(desc) gt 1 then masclose,desc
        desc=desc1
        curFI=newFI
    endif else begin
        print,"Error openning file:",newFI.fbase
    endelse
    return,istat
end
; ----------------------------------------------------------------------------
; displayMenu:  display menu
;
;
;           Cmd CurVal   Function
;           -->  PLOTTING
;            p   n        pols to plot 1,2,1234
;            h   h1 h2    hor min,max
;            v   v1 v2    ver min,max
;            -->  POSITIONING:
;            bsg  b6s1g0     beam,band,grp to use
;            bm   0..6 0     beam 0..6
;            band 0,1        band 0,1
;            d    20081013   move to first file of date
;            num  01103      move to this file number
;            r      41       position to row. maxRows: 241
;            l    (all)      list files this date (all --> all dates)
;           -->  MISC
;            hdr          print current hdr
;            s   n        stepMode s 1 on,s 0 off
;            d   -        debug.. just stop in routine
;            q   -        quit
;            x   -        quit leaving file open

pro displayMenu,key,prgI,desc,curFI,b,dirI=dirI,gftd=gftd,noappbm=noappbm
;
    prgI.dbgStop=0
    print,'Cmd CurVal    function'
    print,''
    print,'-->  PLOTTING:'
    lab=string(format='(" p     ",i4,"       pol to use (1..4,-1=all)")',prgI.pollist)
    print,lab
    print," h    low high   set horizontal plot range ..no args --> autoscale"
    print," v    low high   set vertical   plot range ..no args --> autoscale"
    lab=string(format='(" delay " ,f5.2,"  plot delay secs")',$
                    prgI.sectoDelayPlot)
    print,lab
;
    print,''
    print,"-->  POSITIONING:"
    lab=string(format='(" bsg  ", a,"         beam,band,grp to use")',curFI.bsg)
    print,lab 
    bm=strmid(curFI.bsg,1,1)
    lab=string(format='(" bm   ", a,"              beam (0..6) to use")',bm)
    print,lab 
    band=strmid(curFI.bsg,3,1)
    lab=string(format='(" band  ", a,"             band to use (0=1450,1=1300)")',band)
    print,lab 
    lab=string(format=$
            '(" d    ", a,"       move to first file of date")',curFI.ldate)
    print,lab
    lab=string(format=$
            '(" dn   ", a," ",a," move to date and filenum")',curFI.ldate,curFI.lnum)
    print,lab
    lab=string(format='(" num  ", a,"          number of file to use")',curFI.lnum)
    print,lab
    lab=string(format=$
            '(" r    ",i4,"           row of file to position. maxRows:",i4)',$
            desc.curRow,desc.totRows);
    print,lab
    print," l    (all)          list files this date (all --> all dates)"

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
    switch cmd of
    'p':begin
        validPol=[-1,1,2,3,4,12,123,1234,13,14,124,134,23,234,34]
        polList=(n_elements(toks) lt 2) ? -2 : toks[1]
        ii=where(pollist eq validPol,cnt)
        if cnt gt 0 then begin
            prgI.polList=polList
        endif else begin
            print,"enter p -1,1,2,3,4,1234, etc for pols to plot"
        endelse
		break
		end
    'h':begin
        if n_elements(toks) eq 1 then begin
            hor
        endif else begin
            if (n_elements(toks) eq 3) then begin
                hor,toks[1],toks[2]
            endif else begin
                print,"Enter: h  hormin hormax"
            endelse
        endelse
		break
        end
    'v':begin
        if n_elements(toks) eq 1 then begin
            ver
        endif else begin
            if (n_elements(toks) eq 3) then begin
                ver,toks[1],toks[2]
            endif else begin
                print,"Enter: v  vermin vermax"
            endelse
        endelse
		break
        end

   ;   plot delay

    'delay':begin
        if n_elements(toks) ne 2 then begin
            print,'Enter delay secsToDelay'
        endif else begin
            prgI.secToDelayPlot=toks[1]
        endelse
		break
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
                          newFI,flist=flist,dirI=dirI,noappbm=noappbm)
            if istat eq 1 then begin
                istat=opennewfile(curFI,newFI,desc,gftd=gftd)
                prgI.dataAvail=0
            endif else begin
                print,"no files found for " + bsg + "for this date and number"
            endelse
        endelse
		break
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
                          newFI,flist=flist,dirI=dirI,noappbm=noappbm)
            if istat eq 1 then begin
                istat=opennewfile(curFI,newFI,desc,gftd=gftd)
                prgI.dataAvail=0
            endif else begin
                print,"no files found for " + bsg + "for this date and number"
            endelse
        endelse
		break
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
                          newFI,flist=flist,dirI=dirI,noappbm=noappbm)
            if istat eq 1 then begin 
                istat=opennewfile(curFI,newFI,desc,gftd=gftd)
                prgI.dataAvail=0
            endif else begin
                print,"no files found for " + bsg + "for this date and number"
            endelse
        endelse
		break
        end

;   date: postion to start of date
;   dn    date num together

    'dn':
	'd' :begin
            if (cmd eq 'd') then begin 
        		if n_elements(toks) ne 2 then begin
            		print,'Enter d  yyyymmdd for date to position to'
					break
				endif
            	lnum='*'
				oldest=1
			endif else begin
           		if n_elements(toks) ne 3 then begin
                	print,'Enter dn  yyyymmdd number for date filenumber to position to'
					break
		   		endif
           		lnum=string(format='(i05)',toks[2])
		   		oldest=0
			endelse
        	lldate=toks[1]
        	istat=masmostrecentfile(curFI.proj,lldate,curFI.bsg,lnum,$
                         newFI,flist=flist,oldest=oldest,dirI=dirI,noappbm=noappbm)
            if istat eq 1 then begin
                istat=opennewfile(curFI,newFI,desc,gftd=gftd)
                prgI.dataAvail=0
            endif
		break
        end
;
;   num: postion to this file number
;
    'num':begin
        if n_elements(toks) ne 2 then begin
            print,'Enter n   number position to this file number'
        endif else begin
            lnum=string(format='(i05)',toks[1])
            istat=masmostrecentfile(curFI.proj,curFI.ldate,curFI.bsg,lnum,$
                          newFI,flist=flist,dirI=dirI,noappbm=noappbm)
            if istat eq 1 then begin
                istat=opennewfile(curFI,newFI,desc,gftd=gftd)
                prgI.dataAvail=0
            endif else begin
                print,'file Number:'+lnum +" does not exists for date:",$
                    curFI.ldate
            endelse
        endelse
		break
        end

;
    'l':begin
        ldate=curFI.ldate
        ldate=((n_elements(toks) eq 2) && (toks[1] eq 'all')) $
              ?"*":curFI.ldate
        istat=masmostrecentfile(curFI.proj,ldate,curFI.bsg,"*",$
                    flist=flist,dirI=dirI,noappbm=noappbm)
        if istat eq 1 then begin
            for i=0,n_elements(flist)-1 do begin
                l=strpos(flist[i],"/",/reverse_offset,/reverse_search)
                print,strmid(flist[i],l)
           endfor
        endif
		break
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
                endelse     
            endelse
			break
            end
        'q':begin
            print,'quitting...'
            prgI.done=1
            prgI.dataAvail=0
			break
            end
        'x':begin
            print,'quitting leaving file open...'
            prgI.done=2
            prgI.dataAvail=0
			break
            end
        's':begin
            if n_elements(toks) lt 2 then begin
                print,'Enter s 0 or 1 .. turn off,on step mode'
            endif else begin
                prgI.stepmode=(toks[1] eq 0) ? 0 : 1
            endelse
			break
            end
       'hdr':begin &$
              help,b.h,/st          ; display header
			 break
             end
       'cur':begin
            print,"track cursor. LeftMouseButton:MarkPosition, RightMouseButton:done"
            i=rdcur(icur)
			break
            end
        else: break
    endswitch
    print,'continuing...'
    return
end
;
; ----------------------------------------------------------------------------
;  masmon
pro masmon,bsg=bsg,num=num,projid=projid,date=date,noavg=noavg,pollist=pollist,$
                 desc=desc,_extra=_e,dirI=dirI,noappbm=noappbm
	forward_function masmostrecentfile
;
;   figure out which file to start with
;
    gfTd=(projid eq 'a2130_dtm')
    prgI={$
       dbgStop : 0        ,$ ; if true then stop in masmon after checkkey
       stepMode: 0        ,$ ; if one then menu each plot
       polList : -1       ,$ ; by default use all
       dataAvail: 0       ,$ ; 1 if data avail to plot
           done : 0       ,$; 1--> exit, 2--> exit leaving file open
        noavg   : 0       ,$; if 1 then don't average
    secToSleepFile: 2.    ,$; secs to sleep after ls -lt and no new file
    secToDelayPlot: 0.     $; secs to delay between plots
    }
    desc=''
    prgI.polList=(n_elements(polList) gt 0)?polList:-1
	bsgL='b0s0g0'
    if n_elements(bsg) gt 0 then bsgL=bsg
    lnum=(n_elements(num) gt 0)?string(format='(i05)',num):'*'
    if n_elements(projid) eq 0 then projid='*'
    ldate=(n_elements(date) gt 0)?string(format='(i8)',date) :"*"
	prgI.noavg=(keyword_set(noavg))?1:0
    a=stregex(bsgL,"b([0-6])",/sub,/extr)
;;    beam=a[1]
;;    basDir=string(format='("/share/pdata",i1,"/pdev/")',beam+1);
;
    istat=masmostrecentfile(projid,ldate,bsgL,lnum,curFI,dirI=dirI,noappbm=noappbm)
	if istat ne 1 then begin 
			if n_elements(bsg) eq 0 then begin
				bsgL='b0s0g1'
    			istat=masmostrecentfile(projid,ldate,bsgL,lnum,curFI,dirI=dirI,noappbm=noappbm)
			endif
			if istat ne 1 then begin
				print,'no files found for requested range'
				return
			endif
	endif
    masclose,/all
	if keyword_set(gftd) then begin
    	istat=gftopen(curFI.fdir+curFI.fbase,desc)
	endif else begin
    	istat=masopen(curFI.fdir+curFI.fbase,desc)
	endelse
    done=(istat lt 0)
    while (prgI.done eq 0 ) do begin
        istatget=(gfTd)?gftget(desc,bon,b):masget(desc,b) 
        prgI.dataAvail=(istatget eq 1)
        ; hit eof ..
        if ( not prgI.dataAvail)   then begin
            ; see if file has grown since last open
            istatupd=masupdfsize(desc)
            if istatupd eq 1 then continue  ; file grew.. read again
            istat1=masmostrecentfile(curFI.proj,"*",curFI.bsg,"*",newFI,$
                    curFI=curFI,dirI=dirI,noappbm=noappbm)
            ; moved to a new file
            if (newFi.fbase ne curFI.fbase) then begin
                istat=opennewfile(curFI,newFI,desc,gftd=gftd)
                if istat lt 0 then wait,prgI.secToSleepFile
            endif else begin
;                print,'waiting..'
                wait,prgI.secToSleepFile
            endelse
        endif 
        key=checkkey();
        if (key ne '') or (prgI.stepMode) then begin
            displayMenu,key,prgI,desc,curFI,b,dirI=dirI,gftd=gftd,noappbm=noappbm
            if prgI.dbgStop then begin 
            print,"stopping in masmon (for debugging).  .continue to continue"
            stop
            prgI.dbgStop=0
            endif
        endif       
        if prgI.dataAvail ne 1 then continue
;
;       here is the plotting
;
        if ( (not prgI.stepMode) and (prgI.secToDelayPlot gt 0.)) then $
            wait,prgI.secToDelayPlot
        tm=b.h.crval5 - 4*3600.
        tm=(tm lt 0.)?tm + 86400.:tm
        tit=string(format=$
            '("file:",a," Cur/Tot Row:",i5,"/",i5," AST:",a)',$
                curFI.fbase,desc.curRow,desc.totRows,fisecmidhms3(tm))
        if ( keyword_set(prgI.noavg) or (b.ndump eq 1) ) then begin
			if (gftd) then begin
            	masplot,bon,tit=tit,_extra=_e,pollist=prgI.polList &$
            	masplot,b,_extra=_e,pollist=prgI.polList,/over &$
			endif else begin
            	masplot,b,tit=tit,_extra=_e,pollist=prgI.polList &$
		    endelse
        endif else begin
			if (gftd) then begin
            	n=masaccum(b  ,bavgoff,/avg,/new)
            	n=masaccum(bon,bavgon,/avg,/new)
            	masplot,bavgon,tit=tit,_extra=_e,pollist=prgI.polList
            	masplot,bavgoff,_extra=_e,pollist=prgI.polList,/over
			endif else begin
            	n=masaccum(b,bavg,/avg,/new)
            	masplot,bavg,tit=tit,_extra=_e,pollist=prgI.polList
			endelse
        endelse
        empty
    endwhile
    if n_tags(desc) gt 1 then begin
            if (prgI.done ne 2) then masclose,desc
    endif
    return
    end
