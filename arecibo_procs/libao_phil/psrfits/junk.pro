    fileLoc='/share/pdata1/pdev/psrfits.20081027.b0s0g0.00300.fits'
istat=psrfopen(fileloc,desc,hdr=hdr)
;
	
    errmsg=''
    lun=-1
	extension=1
;    fxbopen,lun,fileLoc,extension,hdrT,errmsg=errmsg
;	rew,lun
;    fxhread,lun,hdrM,status
;
	a={ $
		OBSERVER :'' ,$
		PROJID   :'' ,$
		TELESCOP :'' ,$
		ANT_X    :0d ,$
		ANT_Y    :0d ,$
		ANT_Z    :0d ,$
	    NRCVR    :0  ,$; number of receiver pol channels
	    FD_POLN  :'' ,$; 
	    FD_HAND  :0  ,$; 
	    FD_SANG  :0. ,$; 
	    FD_XYPH  :0. ,$; 
	    FRONTEND :'' ,$;
	    BACKEND  :'' ,$; 
	    BECONFIG :'' ,$;
	    BE_PHASE : 0 ,$;    0 / 0/+1/-1 BE cross-phase:0 unknown,+/-1 std/rev  
        BE_DCC   : 0 ,$;    0 / 0/1 BE downconversion conjugation corrected    
        BE_DELAY : 0D,$; [s] Backend propn delay from digitiser input   
        TCYCLE   : 0D,$; [s] On-line cycle time (D)                     
        OBS_MODE : '',$; (PSR, CAL, SEARCH)                             
        DATE_OBS : '',$; Date of observation (YYYY-MM-DDThh:mm:ss UTC) 
        OBSFREQ  : 0d,$; [MHz] Centre frequency for observation         
        OBSBW    : 0d,$; [MHz] Bandwidth for observation                
        OBSNCHAN : 0L,$; Number of frequency channels (original)        
	    SRC_NAME : '',$; Source or scan ID                              
        COORD_MD : '',$; Coordinate mode (J2000, GAL, ECLIP, etc.)      
        EQUINOX  : 0d,$; Equinox of coords (e.g. 2000.0)                
        RA       : '',$; Right ascension (hh:mm:ss.ssss)                
        DEC      : '',$; Declination (-dd:mm:ss.sss)                    
        BMAJ     : 0.,$; [deg] Beam major axis length                   
        BMIN     : 0.,$; [deg] Beam minor axis length                   
        BPA      : 0D,$; [deg] Beam position angle                      
        TRK_MODE : '',$; Track mode (TRACK, SCANGC, SCANLAT)            
        STT_CRD1 : '',$; Start coord 1 (hh:mm:ss.sss or ddd.ddd)        
        STT_CRD2 : '',$; Start coord 2 (-dd:mm:ss.sss or -dd.ddd)       
        STP_CRD1 : '',$; Stop coord 1 (hh:mm:ss.sss or ddd.ddd)         
        STP_CRD2 : '',$; Stop coord 2 (-dd:mm:ss.sss or -dd.ddd)        
        SCANLEN  : 0d,$; [s] Requested scan length (E)                  
        FD_MODE  : '',$; Feed track mode - FA, CPA, SPA, TPA            
        FA_REQ   : 0d,$; [deg] Feed/Posn angle requested (E)            
        CAL_MODE :'' ,$; Cal mode (OFF, SYNC, EXT1, EXT2)               
        CAL_FREQ : 0.,$; [Hz] Cal modulation frequency (E)              
        CAL_DCYC : 0.,$; Cal duty cycle (E)                             
        CAL_PHS  : 0.,$; Cal phase (wrt start time) (E)                 
        STT_IMJD : 0L,$; Start MJD (UTC days) (J - long integer)        
        STT_SMJD : 0L,$; [s] Start time (sec past UTC 00h) (J)          
        STT_OFFS : 0d,$; [s] Start time offset (D)
		STT_LST  : 0d }; [s] Start LST (D)     
		nmAr=tag_names(a)
		keys=strmid(hdrM,0,8)
		for i=0,n_elements(nmAr)-1 do begin
			l=strlen(nmAr[i])
//          for struct nm < 8 char blank fill for match with fits data
			if l lt 8 then nmAr[i]=nmAr[i]+ strmid('        ',0,8-l);
			gotit=0 
			if ((ii=where(keys eq nmAr[i],cnt)) ne -1) then begin
				s1=strmid(hdrM[ii],10,20)
				gotit=1
			endif else begin

//              some keywords have - where are illegal struct names..

				keyTmp=''
				if (nmAr[i] eq 'DATE_OBS') then keyTmp='DATE-OBS'
				if (keyTmp ne '') then begin
			       if ((ii=where(keys eq keyTmp,cnt)) ne -1) then begin
						s1=strmid(hdrM[ii],10,20)
					    gotit=1
				   endif
				endif
			endelse
			if not gotit then begin
				print,'could not find key:', nmAr[i]
			endif else begin
//              we grabbed 20 chars. strip off quotes trailing spaces
				sa=stregex(s1,"^[ '" + '"]*([^"' + "']*)",/extr,/sub)
				if n_elements(sa) eq 2 then begin
					a.(i)=sa[1]
					print,nmAr[i],sa[1]
				endif else begin
					print,'could not parse data:' + s1 + ' for key:', nmAr[i]
				    gotit=0
				endelse
			endelse
		endfor
end
;
; create structure..
;
fxbtform,hdrExS,tbcol,tbtype,tbform,tbnumval
;
fxbfind,hdrExS,"TTYPE",COLS,VALS,NFOUND 	
;
for i=0,nfound-1 do begin &$
	icol=i+1 &$
	tag=strtrim(vals[i]) &$
	len=(tbnumval[i] > 2) &$
	val=make_array(len,type=tbtype[i]) &$
	if tbnumval[i] eq 1 then begin &$
		len=1 &$
		val=val[0] &$
	endif &$
    print,icol,tag &$
	if len gt 1 then begin &$
		if (((tag eq 'DAT_OFFS') or (tag eq 'DAT_SCL')) ) then begin &$
	   	 if (hdrExSI.npol gt 1)  then val=reform(val,hdrExSi.nchan,hdrExSi.npol) &$
		endif else begin &$
		  if (tag eq 'DATA') then begin &$
		    if hdrExSi.npol eq 1 then begin &$
			  val=reform(val,hdrExSi.nchan,hdrExSi.nsblk) &$
		    endif else begin &$
		  	  val=reform(val,hdrExSi.nchan,hdrExSi.npol,hdrExSi.nsblk) &$
		    endelse &$
		  endif &$
		endelse &$
	endif &$
;
	if i eq 0 then begin &$
		str=create_struct(tag,val) &$
	endif else begin &$
		str=create_struct(temporary(str),tag,val) &$
	endelse &$
endfor
;
d=float(b.data[*,*,0])
ii=where(d lt 0)
d[ii]=d[ii]+ 32768.*2.
plot,d
