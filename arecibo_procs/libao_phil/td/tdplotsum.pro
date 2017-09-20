;+
;NAME:
;tdplotsum - plot a summary of the tiedown data.
;SYNTAX: tdplotsum,d,tdstat=tdstat,title=title,tmrange=tmrange,$
;                  vpos=vpos,vkips=vkips,vtq=vtq,tqinc=tqinc,tqsmo=tqsmo,$
;                  win=win,wait=wait,page=page,fl=fl
;ARGS:
;    d[] :{tdall} data to display. read via tdinpday() or tdinp(xx,/all)
;
;KEYWORDS:
; tdstat : int    tiedown to use for status display: 12,4,8 (def=12)
;   title: string title for each plot (eg date..)'
;tmrange[2]:long  if provided, then limit the plots to
;                 the tmrange[0],tmrange[1] time range. the units are hours.
;   vpos[2]:float min max for pos vs time
;  vkips[2]:float min max for kips vs time
;    vtq[2]:float min max for torque plots
;    tqinc :float display offset between each motor tq plot. def=0
;   tqsmo  :int   number of seconds to smooth motor tqs. def=1 (no smoothing)
;     win[]:int   window numbers to plot each page in..
;     wait :      if set then wait for user to hit a key between each plot
;      fl[]:float list of hours to flag in each page
;     page :int   plot just one page of the info. default is all
;
;DESCRIPTION:
;    Plot the tiedown data and status info. The data comes from:
;n=tdinpday(yymmdd,td,/all) .. you need to use the /all keyword.
;
;    You can plot a subset of the data in td by using the tmr=[hr1,hr2] keyword
;to limit the plots to between hr1 and hr2 hours of the day.
;
;    the keyword page=n will output a single page (1..7)
;    By default pages are output one after another with stopping. This is
;normally used when plotting to a file. For inspection from a terminal,
;use /wait so the program pauses after each page waiting for keyboard input.
;
;    The output consists of analog data as well as status bits. 
;
;    The analog data is output for all 3 tiedowns using color to distinguish
;the tiedown. The outputs are:
;        position,torques: red=td12,green=td4,blue=td8
;        kips: Tension on each tiedown cable is output 2*3=6 outputs. the
;              colors used are:
;              white,red    : td12 cable1,2
;              green,blue   :td4 cable 1,2
;              yellow,purple:td8 cable 1,2
;		
;    The status info is output for a single tiedown ( the default is td12).
;You can change the tiedown for status output using tdstat=[12,4,8].
;    The status plots:
;   -  Each bit is plotted as a line vs time
;   -  The left side shows the bit label as well as a colored *.
;   -  The * is the value=0 position the bit, value=1 moves the line 
;      farther up.
;   -  Labels that start with - (eg -CRmEmgS) negate the label.
;       eg. -CRmEmgSt 1 value means control room emergency stop is off.
;
;The pages are:
;   
;page 1; position, kips
;page 2: the tiedown device status vs time
;page 3: the little star digital inputs 
;page 4: digital uio 1 and 2 inputs
;page 5: little star digital output
;page 6: drive and fault status
;page 7: motor torques (for all 3 tiedowns)
;
;To use these routines:
;idl71
;@phil
;@tdinit
;yymmdd=110413
;n=tdinpday(yymmdd,td,/all)
;tdplotsum,td,/wait
;
;to send output to a ps file:
;
;pscol,'junk.ps',/full
;tdplotsum,d
;hardcopy
;x
;-
pro  tdplotsum,td,tdstat=tdstat,title=title,xplab=xplab,loff=loff,$
				 vpos=vpos,vkips=vkips,vtq=vtq,tqsmo=tqsmo,tqinc=tqinc,$
                 win=win,wait=wait,page=page,sym=sym,fl=fl,tmrange=tmrange
;
	forward_function tdparms,tdlab
    common colph,decomposedph,colph

	hor
	ver
	!p.multi=0
	tdparms,inchPerEncCnt=inchPerEncCnt
	ldCellCntsToKips=.02			; 1 cnt=.02 kips
    cntToCurI=.01788                ; comes from forcing foldback=10amps
                                    ; see tieProg.h bottom.
	ltd=[' Td12',' Td4',' Td8']
	n=n_elements(td)
    if n lt 2 then begin
        print,'not enough data to plot..'
        return
    endif
;
	tm=td.secm/3600.
;   in case last sec of prev day
    if (tm[0] gt tm[1]) then tm[0]=tm[1]-1./3600.
;
   if n_elements(tmrange) eq 2 then begin
        ind=where((tm ge tmrange[0]) and (tm le tmrange[1]),n)
        if n eq 0 then return
        i1=ind[0]
        i2=ind[n-1]
    endif else begin
        i1=0L
        i2=n-1
    endelse

    if n_elements(page) eq 0 then page=0
    if not keyword_set(loff) then loff=.06
	nwin=n_elements(win)
	if nwin gt 0 then begin
		for i=0,nwin-1 do window,win[i],xsize=640,ysize=800
	endif
	tm=tm[i1:i2]
;
;
;the program will then plot pages containing:
; page 1: tiedown position (for all 3 tiedowns)
;         tiedown kips: for each td cable 2*3 = 6 in all
;                       white,red    : td12 cable1,2
;                       green,blue   :td4 cable 1,2
;                       yellow,purple:td8 cable 1,2
;
; The following status are for 1 tiedown (selected by keyword tdstat=)
	wini=0
	useflag=n_elements(fl) gt 0
	if n_elements(tqinc) eq 0 then tqinc=0
    fls=2
	if n_elements(tdstat) eq 0 then tdstat=12
	case tdstat of
          12: itd=0
           4: itd=1
           8: itd=2
	   else : begin
			print,'tdstat should be 12,4, or 8'
			end
	endcase

    if not keyword_set(title) then title=''
    if not keyword_set(xplab) then xplab=-.2
;--------------------------------------------------------
; 
; page 1   tm vs pos, tm vs kips
;
;    az=td.az*.0001
;    gr=td.gr*.0001
;    ch=td.ch*.0001

	if nwin gt 0 then wset,win[wini]
	wini=(wini+1 ) < (nwin-1)
	if (page eq 0) or (page eq 1) then begin
    !p.multi=[0,1,2]
	pos=transpose(td[i1:i2].slv.ticki.pos)*inchPerEncCnt
    if (n_elements(vpos) eq 2) then  begin
		ver,vpos[0],vpos[1] 
	endif else begin 
		ver,min(pos)*.9,max(pos)*1.1
	endelse 
	stripsxy,tm,pos,0,0,/step,$
        xtitle='hour',ytitle='inches',psym=sym,$
        title=title + ' Td pos vs hour (page 1)'
	if useflag then flag,fl,linestyle=fls
;
;    page 1 kips 
;
	kips=fltarr(2,3,n)
	kips[0,*,*]=td[i1:i2].slv.tickI.ldcell1 * ldCellCntsToKips
	kips[1,*,*]=td[i1:i2].slv.tickI.ldcell2 * ldCellCntsToKips
    if (n_elements(vkips) eq 2) then begin
		 ver,vkips[0],vkips[1] 
	endif else begin
		 ver,min(kips)*.9,max(kips)*1.1
	endelse
	stripsxy,tm,transpose(reform(kips,6,n)),0,0,/step,$
        xtitle='hour',ytitle='Kips 1 cable',psym=sym,$
        title=title+ ' Td kips/cable  vs hour (page 1)'
	if useflag then flag,fl,linestyle=fls
	if keyword_set(wait) then begin
		print,'hit return to continue'
		wait,1
		key=checkkey(/wait)
	endif
    
;;    hor
    ver
	if nwin gt 0 then wset,win[wini]
	wini=(wini+1 ) < (nwin-1)
	endif
    !p.multi=0

;--------------------------------------------------------
; page 2 device stat
;   decode mode
;   ignore encoder feedback
;   move around reboot, trackdata
;
	if (page eq 0 ) or (page eq 2) then begin
    lab=tdlab('devstat')
	mask='fff7'X
;
;   need to shift around some of the bits for decoding
;   mode, move reboot,trandat
;
	ival=td[i1:i2].slv[itd].tickI.devStat
	modeBits=ishft(ival and '3000'X,-12)
	rebtr=ishft(ival and 'c000'X,-8)
	ival= ((ival and '0f3f'X) or rebtr) or (ishft(2^modeBits,12))
	
    pltbits,tm,ival,mask,maxbits=16,lab=lab,psym=sym,$
    xtitle='hour',title=title + lTd[itd] + ' device status (page 2)'
	if useflag then flag,fl,linestyle=fls
	 if keyword_set(wait) then begin
		print,'hit return to continue'
		wait,1
		key=checkkey(/wait)
    endif
    endif
;
;--------------------------------------------------------
; page 3 digital input little star
;
;
	if (page eq 0 ) or (page eq 3) then begin
	if nwin gt 0 then wset,win[wini]
	wini=(wini+1 ) < (nwin-1)
    lab=tdlab('dils')
	mask='ffff'X
    pltbits,tm,td[i1:i2].slv[itd].tickI.tdstat.di_ls,mask,maxbits=16,lab=lab,psym=sym,$$
    xtitle='hour',title=title + lTd[itd] + ' Little Star digital input (page 3)'
	if useflag then flag,fl,linestyle=fls
	 if keyword_set(wait)  then begin
		print,'hit return to continue'
		wait,1
		key=checkkey(/wait)
    endif
  endif
; 
;--------------------------------------------------------
; page 4 uio digital  input 1 and 2
;
;
    if (page eq 0 ) or (page eq 4) then begin
    if nwin gt 0 then wset,win[wini]
    wini=(wini+1 ) < (nwin-1)
    lab=tdlab('di1_2')
    mask='3ffff'XL 
	ival=long(td[i1:i2].slv[itd].tickI.tdstat.di_uio1) or $
			ishft(long(td.slv[itd].tickI.tdstat.di_uio2),16)
    pltbits,tm,ival,mask,maxbits=18,lab=lab,$
	psym=sym,$
    xtitle='hour',title=title + lTd[iTd] + ' UIO digital 1 and 2 (page 4)'
    if useflag then flag,fl,linestyle=fls
     if keyword_set(wait)  then begin
        print,'hit return to continue'
        wait,1
        key=checkkey(/wait)
    endif
  endif
;
;--------------------------------------------------------
; page 5 digital out LS
;
;
    if (page eq 0 ) or (page eq 5) then begin
    if nwin gt 0 then wset,win[wini]
    wini=(wini+1 ) < (nwin-1)
    lab=tdlab('dols')
    mask='0fdf'X  
    pltbits,tm,td[i1:i2].slv[itd].tickI.tdstat.DO_LSUIO1,mask,maxbits=16,lab=lab,$
    psym=sym,$
    xtitle='hour',title=title + lTd[itd] + ' Little star Digital out (page 5)'
    if useflag then flag,fl,linestyle=fls
     if keyword_set(wait)  then begin
        print,'hit return to continue' 
        wait,1 
        key=checkkey(/wait)
    endif
  endif
;--------------------------------------------------------
; page 6  driveStat , fault stat combined on one plot 
;  - drive stat
;      decode enable,disable,pwr,flt
;      shift up to make room for decoded value
;  - fault stat put at top
;    push pwrSfail,BrkFail together.
;
;
    if (page eq 0 ) or (page eq 6) then begin
    if nwin gt 0 then wset,win[wini]
    wini=(wini+1 ) < (nwin-1)
    lab=tdlab('drv_fltstat')
;
;   get drive stat , fault stat separately
;
	ivalD=td[i1:i2].slv[itd].tickI.tdstat.st_mdrv
	stBits=ivalD and '3'X
	ivalD= ishft(ivalD and '7C'X,2) or 2^stBits

	ivalF=(td[i1:i2].slv[itd].tickI.tdstat.st_fault) and '15d'X
	ivalF=ivalF or ishft(ivalF and '40'X,-1) or ishft(ivalF and '100'X,-2)
	ival= ivalD or ishft(ivalf,9)
    mask='fbff'X  
    pltbits,tm,ival,mask,maxbits=16,lab=lab,psym=sym,$
    xtitle='hour',title=title + lTd[itd] + ' Drive and Fault Status (page 6)'
    if useflag then flag,fl,linestyle=fls
    if keyword_set(wait)  then begin
        print,'hit return to continue' 
        wait,1
        key=checkkey(/wait)
    endif
    !p.multi=0
  endif
;
;--------------------------------------------------------
;   page 7 motor torques
    if ((page eq 0 ) or (page eq 7)) then begin
    if nwin gt 0 then wset,win[wini]
    wini=(wini+1 ) < (nwin-1)
    mlabln = 2.5
    mlabscl=.7
    mlabxp1=.02
    mlabxp2=mlabxp1 + .1
    mlabxpb=mlabxp1 + .2
    mlabcs=1.3
	tq=transpose(td[i1:i2].slv.tickI.tdstat.AI_mampcurmon) * cntToCurI
!p.multi=0
	if n_elements(vtq) eq 2 then begin
			ver,vtq[0],vtq[1]
	endif else begin
		vmin=min(tq)
		vmin=(vmin lt 0)?1.1*vmin:.9*vmin
		ver,vmin,max(tq)*1.01 
	endelse
	if n_elements(tqsmo) eq 0 then tqsmo=0
	stripsxy,tm,tq,0,tqinc,/step,xtitle='hour',ytitle='Torque Amps',$
			title=title + ' Motor torques page 7',smo=tqsmo
	if useflag then flag,fl,linestyle=fls
;
; 		label motors
;
		nmot=n_elements(mot)
	   for i=0,2 do begin
         note,mlabln+i*mlabscl,ltd[i],xp=mlabxp1,color=colph[i +1],$
                charsize=mlabcs&$
       endfor
	endif
;
    !p.multi=0
    return
end
