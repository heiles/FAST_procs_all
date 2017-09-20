;+
;NAME:
;agcplotsum - plot a summary of the agc data.
;SYNTAX: agcplotsum,b,az=az,gr=gr,ch=ch,title=title,loff=loff,$
;                   vaz=vaz,vdaz=vdaz,vtq=vtq,tqinc=tqinc,tqsmo=tqsmo,$
;                   win=win,/wait,page=page,fl=fl
;ARGS:
;       b[] :   {cbfb}  data read via agcinp,or agcinpday to plot
;
;KEYWORDS:
;   az   : if set plot az info (def)
;   gr   : if set plot gr info
;   ch   : if set plot ch info
;   title: string title for each plot (eg date..)'
;  loff  : float  offset for labels on left side of page
;                 units are fraction of x scale. The default
;                 is .06 which is good for interactive viewing.
;                 For hardcopy use loff=.15
;  vaz[2]: float  min max for az vs time
; vdaz[2]: float  min max for az encoder difference
;  vtq[2]: float  min max for torque plots
;  tqinc : float  display offset between each motor tq plot. def=0
; tqsmo : int	 number of seconds to smooth motor tqs. def=1 (no smoothing)
;   win[]:        window numbers to plot each page in..
;   wait :        if set then wait for user to hit a key between each 
;                 plot
;  fl[]: float  list of hours to flag
;  page : int    plot just one page of the info. default is all
;
;DESCRIPTION:
;   Plot the agc data input via agcinp or agcinpday. If you want a 
;range of the array, use where before calling this routine. The keywords
;select which axis to plot: az, gr or ch. By default the az data is plotted.
;If more than one keyword is set then the plot is determined by : az,gr,ch.
;
;To send the data to a ps file use:
; pscol,'junk.ps',/full
; agcplotsum,b
; hardcopy
; x
;
;NOTE:
;   only azimuth plotting has been implemented.. When something in the
;gr breaks, i'll probably implement it too...
;-
pro  agcplotsum,d,az=az,gr=gr,ch=ch,title=title,loff=loff,$
				 vaz=vaz,vdaz=vdaz,vza=vza,win=win,wait=wait,page=page,$
			     sym=sym,fl=fl,vtq=vtq,tqsmo=tqsmo,tqinc=tqinc
;
    common colph,decomposedph,colph
    if n_elements(page) eq 0 then page=0
    if not keyword_set(loff) then loff=.06
	nwin=n_elements(win)
	if nwin gt 0 then begin
		for i=0,nwin-1 do window,win[i],xsize=640,ysize=800
	endif
		
	wini=0
    taz=1
    tgr=2
    tch=3
	useflag=n_elements(fl) gt 0
	if n_elements(tqinc) eq 0 then tqinc=0
    fls=2
    if n_elements(d) lt 2 then begin
        print,'not enough data to plot..'
        return
    endif
	case 1 of
          keyword_set(gr): begin
					type=tgr
					axnm=' dome'
    				indax=1
					end
          keyword_set(ch): begin
					type=tch
					axnm=' ch'
    				indax=2
					end
		  else            : begin
					type=taz
					axnm=' azimuth'
    				indax=0
					end
	endcase

    if not keyword_set(title) then title=''
;--------------------------------------------------------
; 
; page 1   tm,az  , tm za
;
    azL=d.cb.pos[0]
    minAz=min(azL)
    maxAz=max(azL)
    tm=d.cb.time/3600.
    if (tm[0] gt tm[1]) then tm[0]=tm[1]-1./3600.

	if nwin gt 0 then wset,win[wini]
	wini=(wini+1 ) < (nwin-1)
	if (page eq 0) or (page eq 1) then begin
    !p.multi=[0,1,2]
    if (n_elements(vaz) eq 2) then  ver,vaz[0],vaz[1] else ver
    plot,tm,azL,xtitle='hour',ytitle='az',psym=sym,$
        title=title+ ' az pos vs hour (page 1)'
	if useflag then flag,fl,linestyle=fls
	titLoc=title + axnm 
	case type of
		taz: begin
    		if (n_elements(vdaz) eq 2) then  ver,vdaz[0],vdaz[1] else ver
    		plot,tm,d.fb.azencdif,xtitle='hour',psym=sym,$
    		ytitle='azEncoder Difference [deg]',$
    		title=title + ' az encoder difference vs hour'
			end
		tgr: begin
    		if (n_elements(vza) eq 2) then  ver,vza[0],vza[1] else ver
    		plot,tm,d.cb.pos[1],xtitle='hour',psym=sym,$
    		ytitle='greg za [deg]',$
    		title=title + ' greg za encoder vs hour'
			end
		tch: begin
    		if (n_elements(vza) eq 2) then  ver,vza[0],vza[1] else ver
    		plot,tm,d.cb.pos[2],xtitle='hour',psym=sym,$
    		ytitle='ch za [deg]',$
    		title=title + ' ch za encoder vs hour'
			end
	endcase
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
; page 2 cb general status
;
;
; cb general stat
;
	if (page eq 0 ) or (page eq 2) then begin
    lab=agclab('cbgstat')
    pltbits,tm,d.cb.genstat,'ffff'X,maxbits=16,lab=lab,psym=sym,loff=loff,$
    xtitle='hour',title=title+' vertex general status (page 2)'
	if useflag then flag,fl,linestyle=fls
	 if keyword_set(wait) then begin
		print,'hit return to continue'
		wait,1
		key=checkkey(/wait)
    endif
    endif
;--------------------------------------------------------
; page 3 axis status
;
;
; cb general stat
;
	if (page eq 0 ) or (page eq 3) then begin
	if nwin gt 0 then wset,win[wini]
	wini=(wini+1 ) < (nwin-1)
    lab=agclab('cbastat')
	mask=(type eq taz)? 'ffff'X : 'bffb'X
    pltbits,tm,d.cb.stat[indax],mask,maxbits=16,lab=lab,psym=sym,loff=loff,$
    xtitle='hour',title=title+' vertex axis status (page 3)'
	if useflag then flag,fl,linestyle=fls
	 if keyword_set(wait)  then begin
		print,'hit return to continue'
		wait,1
		key=checkkey(/wait)
    endif
  endif
;
;--------------------------------------------------------
; page 4 axis mode, equipment status
;
; cb axis mode
;
	if (page eq 0 ) or (page eq 4) then begin
	if nwin gt 0 then wset,win[wini]
	wini=(wini+1 ) < (nwin-1)
    !p.multi=[0,1,2]
lab=agclab('cbamode')
pltbits,tm,d.cb.mode[indax],'6f0f'X,maxbits=10,lab=lab,loff=loff,$
    xtitle='hour',title=title + axnm + ' axis mode (page 4)'
	if useflag then flag,fl,linestyle=fls
; 
; axis equipment status
;
    lab=agclab('fbeqstat')
    pltbits,tm,d.fb.ax[indax].equipstat,'10ff'X,maxbits=9,lab=lab,loff=loff,$
    xtitle='hour',title=title+  axnm + ' equipment status'
	if useflag then flag,fl,linestyle=fls
	 if keyword_set(wait) then begin
		print,'hit return to continue'
		wait,1
		key=checkkey(/wait)
    endif
   endif

;
;--------------------------------------------------------
; page 5 amp status
;
	if (page eq 0 ) or (page eq 5) then begin
	if nwin gt 0 then wset,win[wini]
	wini=(wini+1 ) < (nwin-1)
    !p.multi=0
	case type of
		taz: lab=agclab('fbampstataz')
		tgr: lab=agclab('fbampstatgr')
		tch: lab=agclab('fbampstatch')
	endcase
    pltbits,tm,d.fb.ax[indax].ampstat,'ffff'X,maxbits=16,lab=lab,loff=loff,$
        xtitle='hour',title=title + axnm + ' amp status (page 5)'
	if useflag then flag,fl,linestyle=fls
	 if keyword_set(wait) then begin
		print,'hit return to continue'
		wait,1
		key=checkkey(/wait)
    endif
   endif
;
;--------------------------------------------------------
; page 6 motor status, dcs 8
;
	if (page eq 0 ) or (page eq 6) then begin
	if nwin gt 0 then wset,win[wini]
	wini=(wini+1 ) < (nwin-1)
    !p.multi=[0,1,2]
	case type of
    	taz: lab=agclab('fbmotstataz')
    	tgr: lab=agclab('fbmotstatgr')
    	tch: lab=agclab('fbmotstatch')
	end
    pltbits,tm,d.fb.ax[indax].motorstat,'ff'X,maxbits=8,lab=lab,loff=loff,$
    xtitle='hour',title=title + axnm + ' motor status (page 6)'
	if useflag then flag,fl,linestyle=fls
;
; fb dcs q8
;
	if type eq taz then begin
	if nwin gt 0 then wset,win[wini]
	wini=(wini+1 ) < (nwin-1)
    lab=agclab('q8')
    pltbits,tm,d.fb.plcoutstat[8],'ff'X,maxbits=8,lab=lab,loff=loff,$
    xtitle='hour',title=title + ' dcs az output[8]'
	if useflag then flag,fl,linestyle=fls
	 if keyword_set(wait) then begin
		wait,1
		key=checkkey(/wait)
    endif
    endif
;--------------------------------------------------------
;   page 7
	if ((page eq 0 ) or (page eq 7)) and (type eq taz) then begin
	if nwin gt 0 then wset,win[wini]
	wini=(wini+1 ) < (nwin-1)
    !p.multi=[0,1,2]
;
    lab=agclab('q9')
    pltbits,tm,d.fb.plcoutstat[9],'ff'X,maxbits=8,lab=lab,loff=loff,$
    xtitle='hour',title=title + ' dcs az output[9] (page 7)'
	if useflag then flag,fl,linestyle=fls
;
	if nwin gt 0 then wset,win[wini]
	wini=(wini+1 ) < (nwin-1)
    lab=agclab('q10')
    pltbits,tm,d.fb.plcoutstat[10],'ff'X,maxbits=8,lab=lab,loff=loff,$
    xtitle='hour',title=title + ' dcs az output[10]'
	if useflag then flag,fl,linestyle=fls
	endif
	 if keyword_set(wait) then begin
		wait,1
		key=checkkey(/wait)
    endif
	endif
;--------------------------------------------------------
;   page 8 motor torques
    if ((page eq 0 ) or (page eq 8)) then begin
    if nwin gt 0 then wset,win[wini]
    wini=(wini+1 ) < (nwin-1)
    mlabln = 2.5
    mlabscl=.7
    mlabxp1=.02
    mlabxp2=mlabxp1 + .1
    mlabxpb=mlabxp1 + .2
    mlabcs=1.3
	case type of
    	taz: begin
			lab='az Motor Torques'
		    tq=transpose(d.fb.tqaz)
	    mot=[ 'mot11','mot12','mot51','mot52','mot41','mot42','mot81','mot82']

			end
    	tgr: begin
				lab='gregorian Motor Torques'
		    	tq=transpose(d.fb.tqgr)
	    mot=[ 'mot11','mot12','mot21','mot22','mot31','mot32','mot41','mot42']

			 end
    	tch: begin
			lab='ch Motor Torques'
		   	tq=transpose(d.fb.tqch)
	    mot=[ 'mot1','mot2']
			 end
	endcase
!p.multi=0
	if n_elements(vtq) eq 2 then begin
			ver,vtq[0],vtq[1]
	endif else begin
		ver,0.,max(tq)*1.01 
	endelse
	if n_elements(tqsmo) eq 0 then tqsmo=0
	stripsxy,tm,tq,0,tqinc,/step,xtitle='hour',ytitle='torque[ft-lbs]',$
			title=title + lab,smo=tqsmo
	if useflag then flag,fl,linestyle=fls
;
; 		label motors
;
		nmot=n_elements(mot)
	   for i=0,nmot/2-1 do begin &$
         note,mlabln+i*mlabscl,mot[2*i]  ,xp=mlabxp1,color=colph[i*2+1],$
                charsize=mlabcs&$
         note,mlabln+i*mlabscl,mot[2*i+1],xp=mlabxp2,color=colph[i*2+2],$
            charsize=mlabcs &$
         if ((i mod 2) eq 0) and (type eq tgr)  then $
             note,mlabln+i*mlabscl,'(HB)',xp=mlabxpb,charsize=mlabcs &$
        endfor

	endif
;
    !p.multi=0
    return
end
