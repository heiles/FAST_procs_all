;+
;NAME:
;wascmppwrrms_gen - compute tp using rms to exclude rfi. generic
;SYNTAX:istat=wascmppwrrms_gen(yymmdd,projid,tpiar=tpiar,$
;             savdir=savdir,inpdir=inpdir,,$
;             maxrecs=maxrecs,recsNeeded=recsNeeded,
;             vrms=vrms,vtp=vtp,badfit=badfit,
;ARGS:
;yymmdd: long date to search for
;projid:string projid to look for
;KEYWORDS:
;savdir:string where to save the computed data
;inpdir:string where to look for wapp files. def: /share/wappdata/
;maxrecs: long dimesion for tpar. any scans with more spc
;              than this will be skipped. If you  only 1 rec length
;              make this equal to the recsneeded.
;              default: 300
;recsNeeded:long ignore scans with fewer points than this.
;              default:300
;vrms[2]: float  if supplied then min,max y value when plotting rms
;vtp[2] : float  if supplied then min,max y value  when plotting tp
;badfit : int    if bad rms fit then skip following bands. if
;                badfit=1 then just skip the 1 band. 
;RETURNS:
; n: long number of scans processed
; tpiar[n]:{}    array of structs holding results
;save            if savdir provided then tpiar will also be stored in savdir/tp_yymmdd.sav
;DESCRIPTION:
;	For a set of was files,compute the total power for each 
;spectra. Use the rms by channel to exclude rfi.
;	The user specifies the date and project id to search for.
;The routine compute by channel for each scan, then does a linear
;fit to the rms to exclude outliers. The total power is then 
;computed with the good freq points.
;	The information is stored in an array tpIar[]. one entry
;for each scan.
;Since the scans could have different number of points, the
;total power array is alloced to hold the max number.
;tpIar.tp[maxpnts,maxbrd] 
;The data is stored in a save file.
; The tpI returned struct contains:
;   tpI={scan    : 0L    ,$  ; scan number in file
;      fname     : ''    ,$  ; filename
;       npnts    :   0l  ,$  ; number of pnts we found (limited by maxrecs)
;i	   nbrds     :   0   ,$  ; number of brds found 1..8
;	   gdFit     : intarr[2,8],$; 1 --> fit ok ,0 --> no fit
;       rmsFitA  : fltarr(2,8),$ ; c0 +c1*nfrq  rms fit results 
;       rmsFitB  : fltarr(2,8),$ ; ditto
;       maskFract: fltarr(2,8),$  ;fraction used for mask ngood/nfreqchan 
;   tpA   : fltarr(maxrecs,8),$   ; avg tp/median  Tsys -1  Units
;   tpB   : fltarr(maxrecs,8),$ ; avg tp Tsys Units
;       tpMedian : fltarr(2,8)  ,$ ; value we divided by..polA,B
;       az       : 0.           ,$ ; az position for this drift
;       za       : 0.           ,$ ; za position for this drift
;       jd       : 0D            $ ; start of first sample
;        }
;-
function wascmppwrrms_gen,yymmdd,projid,savdir=savdir,tpIar=tpIar,$
        maxrecs=maxrecs,inpdir=inpdir,vrms=vrms,vtp=vtp,$
        recsNeeded=recsNeeded,badfit=badfit,maxscans=maxscans

	maxScans=1000;		we increase by 50% if we go over
    ln=2.5
    xp=.04 
	savdirL='./'
    if n_elements(savdir) eq 1 then savdirL=savdir
	if strmid(savdirL,0,1,/reverse) ne '/' then savdirL+='/'
    if n_elements(inpdir) eq 0 then inpdir='/share/wappdata/'
    if n_elements(maxrecs) eq 0 then maxrecs=300
    if n_elements(recsNeeded) eq 0 then recsNeeded=300
    mjdtojd=2400000.5D
;   rmssav=string(format='(i6.6,".sav")',yymmdd)
	yymmddL=yymmdd mod 1000000L
	
    tpsav =string(format='("tp_",i6.6,".sav")',yymmddL)
;
;   restore,rmssav,/verb
;
; computation:
;       mask  = linear fit to rms throw out outliers. remaining is mask
;       if next scan starts within 6 secs of the cal then
;           tpcaloff= avg(lastrec - 1stRecNxtScan)
;       else 
;           tpcaloff= lastrec 
;       endelse
;       calScl=calK/(tpCalOn -tpCalOff)
;       tpA= (tp - tpmedian)*calscl
;
; to archive:
;    brmsAr         rms/mean of each file
;    maskAr         used for each file
;    bcalRAr        calOn/calOff
;    tpIAr          totalPwrInfo
;
    tpI={   scan    : 0L    ,$
       fname    : ''    ,$
       npnts    :   0l  ,$  ; number of pnts (300) 
	   nbrds    :   0   ,$  ; 1..8
	   gdFit    : intarr(2,8),$; 1 --> fit ok ,0 --> no fit
       rmsFitA  : fltarr(2,8),$ ; c0 +c1*lagk
       rmsFitB  : fltarr(2,8),$ ;
       maskFract: fltarr(2,8),$  ;fraction used for mask 
   tpA   : fltarr(maxrecs,8),$ ; avg tp/median  Tsys -1  Units over 600 pnts
   tpB   : fltarr(maxrecs,8),$ ; avg tp Tsys Units
       tpMedian : fltarr(2,8)  ,$ ; median value we divided by..polA,B
       az       : 0.           ,$ ; az position for center of scan
       za       : 0.           ,$ ; za position for center of scan
       jd       : 0D            $ ; for center of scan
        }
	tpiAr=replicate(tpi,maxscans)
	maxScanCur=maxScans
;
; working array for a day:
;   maskAr[nfiles]   = from rms fits.. archive
;
	verb=-1
	deg=1
	fsin=0
	ndel=5
	plver=[0,.02]
	nfiles=wasprojfiles(projId,fi,yymmdd1=yymmdd,yymmdd2=yymmdd,dir=inpdir)
	if nfiles eq 0 then begin
		inpdirL="not specified"
		if n_elements(inpdir) eq 1 then inpdirL=inpdir
		print,"no files found proj:",projId," date:",yymmdd,$
		 	 "inpdir:",inpdirL
		return,0
	endif
	
	itot=0L	; count the entries
	for ifile=0,nfiles-1 do begin
    	wasclose,/all
    	print,fi[ifile].fname
		fname=fi[ifile].fname
    	istat=wasopen(fname,desc)
    	if istat eq 0 then goto,skipfile
    	nscans=desc.totscans
    	maxRecsScan=max(desc.scanI.recsinscan,idata)
    	print,maxRecsScan,desc.scanI[0].nbrds
    	if (nscans eq 0) then continue
    	if maxRecsScan lt recsNeeded then goto,skipfile
;
;		 loop over scans of file
;
		for iscan=0,nscans-1 do begin
			npnts=desc.scanI[iscan].recsinscan 
			nbrds=desc.scanI[iscan].nbrds
			if npnts lt recsneeded then continue
    		istat=corinpscan(desc,b,/han,scan=desc.scanI[iscan].scan)
    		if istat eq 0 then continue
    		brms=corrms(b)
			tpIar[itot].fname=fname
			tpIar[itot].npnts=(npnts < maxrecs)
			tpIar[itot].nbrds=nbrds

    		x=findgen(npnts)
    		wuse,1
    		istat=corblauto(brms,blfit,mask,coef,ndel=ndel,deg=deg,fsin=fsin,$
                plver=plver,verb=verb,badfit=badfit)
			tpIar[itot].rmsFitA=coef.coefAr[*,0,*]
			tpIar[itot].rmsFitB=coef.coefAr[*,1,*]
			tpIar[itot].maskFract=coef.maskFract
			tpiar[itot].az=b[npnts/2].b1.h.std.azttd*.0001
			tpiar[itot].za=b[npnts/2].b1.h.std.grttd*.0001
			tpiar[itot].jd=b[npnts/2].b1.hf.mjd_obs + mjdToJd

			for ibrd=0,nbrds-1 do begin
				for k=0,1 do begin
					ipol=b[0].(ibrd).p[k] - 1 
					ii=where(mask.(ibrd)[*,ipol] eq 0,cnt)
					if cnt eq 0 then continue
					tpiar[itot].gdfit[ipol,ibrd]=1
					tp=total(b.(ibrd).d[ii,ipol],1)/cnt
					nn=(maxrecs<npnts)
					if n_elements(tp) gt nn then tp=tp[0:nn-1l]
				    if (ipol eq 0) then begin
						tpiar[itot].tpMedian[0,ibrd]=median(tp)
						tpiar[itot].tpA[0L:nn-1L,ibrd]=tp/tpiar[itot].tpMedian[0,ibrd] - 1.
					endif else begin
						tpiar[itot].tpMedian[1,ibrd]=median(tp)
						tpiar[itot].tpB[0L:nn-1L,ibrd]=tp/tpiar[itot].tpMedian[1,ibrd] - 1.
					endelse
				endfor
			endfor
    		if n_elements(vtp) eq 2 then begin
    			ver,vtp[0],vtp[1]
    		endif else begin
    			ver,-.01,.1 
    		endelse
    		inc=.01
    		!p.multi=[0,1,2]
    		lab=string(format=$
    		'("scan:",i9," az,za:",f6.1,1x,f6.1," tm:",a)',$
        	tpiar[itot].scan,tpiar[itot].az,tpiar[itot].za,$
        	fisecmidhms3(tpiar[itot].scan mod 100000L))
   			 stripsxy,x,tpIAr[itot].tpA[0:nn-1,0:nbrds-1],0,inc,/step,$
       		 xtitle='sample in strip',ytitle='totalPwr/median ',$
        		title=lab + ' pol A'
    		lab=string(format='("medLag0:",7(f5.2,1x))',tpiar[itot].tpmedian[0,0:nbrds-1])
    		note,ln,lab,xp=xp
    		stripsxy,x,tpIAr[itot].tpB[0:nn-1,0:nbrds-1],0,inc,/step,$
        	xtitle='sample in strip',ytitle='totalPwr/median ',$
        	title='pol B'
    		lab=string(format='("medLag0:",7(f5.2,1x))',tpiar[itot].tpmedian[1,0:nbrds-1])
    		note,ln+14,lab,xp=xp
			if 0 then begin
    		wuse,0
    		if n_elements(vrms) eq 2 then begin
        		ver,vrms[0],vrms[1]
    		endif else begin
        		ver,0,.04
   		    endelse
    		corplot,brmsAr[itot]
			endif
    		itot=itot+1
		endfor	; end scan in file
skipfile:
	 endfor		; scan loop over files
	if itot eq 0 then begin
   		print,yymmdd,' no files found'
    	return,0
	endif
;
;   reduce to number we found
;
	tpIaR=tpiar[0L:itot-1]
;
	if n_elements(savDir) gt 0 then begin 
		save,tpIaR,file=savDir+tpsav
	endif
	return,itot
end
