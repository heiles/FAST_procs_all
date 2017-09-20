;+
;NAME:
;aocatinp - input an ao source catalog
;SYNTAX: nsrc=aocatinp(file,srcI,calib=calib,galhI=galhI,gcl=gcl,lewis1=lewis1,$
;                      lewis2=lewis2,oh=oh,psr=psr,brightpsr=brightpsr,snr=snr,$;						sort=sort,novel=novel)
;ARGS:
;   file     :string    filename of catatlog
;KEYWORDS:
;	The following keywords select one of the standard catalogs available from
;Online at AO. These keywords will not work if you are not running at AO
;(since the files are not available).
;
;	calib    :          if set then use calib.cat source calibrator file
;	galhI    :          if set then use galaxy_HI.cat
;                         Arecibo HI standard galaxy list
;                         Objects with: no neighbor w/i 10' & 1000km/s radii; 
;                         Optical Diameter < 2.0'
;	gcl      :          if set then use gcl.cat 
;                       Globular Clusters in Harris' catalog visible from AO
;	lewis1   :          if set then use lewis_gals.cat
;                        Galaxy catalog (WITH velocities) 
;                         Lewis et al. (1985 ApJS 59 161)
;	lewis2   :          if set then use lewis_gals2.cat
;                        Galaxy catalog (WITHOUT velocities) 
;                        Lewis et al. (1985 ApJS 59 161)
;    oh      :          if set then use oh.cat
;                          Bright OH/IR stars in the Arecibo Sky
;                          Catalog for 1612 MHz velocity calibration sources
;   psr      :          if set then use the princeton pulsar catalog (our version
;                       of it used by cima
; brightpsr  :          if set then use bright pulsars from the princeton pulsar
;                       catalog.
;   snr      :          if set then use snr.cat
;                       Green's supernova remnant list
; sort       :          if set then  sort the sources by increasing ra
; novel      :          if set then the catalog has no velocity info.
;                       stop after the coordsys
;
;RETURNS:
;	nsrc     : int      number of sources found
;                       -1 could not read file.
;   srci[nsrc]:{srccat}  return data here
;
;DESCRIPTION:
;
;   Read in all of the sources in an ao catalog file. These are the standard
;and usr source list files that are used by CIMA (the telescope gui control
;program).
;
; The file format is:
;# col 1 is a comment
;  0     1  2     3       4     5        6
;srcNm  ra dec CoordSys  vel velFrame velType # comments
;ra : hh:mm:ss.s or hhmmss.s
;dec: dd:mm:ss.s or ddmmss.s
;Coordsys:   J,B
;vel     :   velocity of source relcative to vel coordinate system
;velFrame:   Topo - topocentric
;            Helio - helio centric
;            lsr   - local standard of reset
;velType :   v - velocity km/sec
;            zo - z optical
;            zr - z radio
;
;The returned srcI array will contain:
;help,srcI,/st
;history:
; str:   
;   NAME            STRING     ''           source name
;   RA              FLOAT     Array[3]      hh mm ss.ss 
;   DEC             FLOAT     Array[3]      dd mm dd.dd  (alway positive)
;   DECSGN          INT              0      +/- 1 sign of declination
;   RAH             DOUBLE           0.0    ra in hours (includes sign)
;   DECD            DOUBLE           0.0    dec in hours (includes sign)
;   Coord           string    'b','j'
;   vel             double     0.          
;   velCrdsys       string   ''          t-topo,h-helio,l-lsr,
;   velType         string   ''       v,zo,zr
;
;   EOL             STRING   ''         string after : following velType.
;-
function aocatinp,file,srcI,$
		calib=calib,galhI=galhI,gcl=gcl,lewis1=lewis1,$
        lewis2=lewis2,oh=oh,psr=psr,brightpsr=brightpsr,snr=snr ,sort=sort,$
		novel=novel
;
	astr={ NAME:''       ,$;          source name
        ra  : fltarr(3)  ,$;  hh mm ss.ss 
        dec : fltarr(3)  ,$;  dd mm dd.dd  (alway positive)
      decsgn:       0    ,$;   +/- 1 sign of declination
         rah:       0d   ,$;     ra in hours (includes sign)
        decd:       0d   ,$;    dec in degrees (includes sign)
      crdsys:       ''   ,$;    'b' -b1950,,'j'= j2000
         vel:       0d   ,$;    source velocity in velocity frame
     vcrdsys:      ''    ,$;     t-topo,h-helio,l-lsr,
     vtype  :      ''    ,$;   v -km/sec ,zo,zr
         eol:      ''    } ;  string after : following velType.
    on_ioerror,doneio
    comment='#'
    c='['+comment+']*'
;
;	see if they want a standard catalog. 
;   currently this only works from ao.
;
	defDir='/share/obs4/usr/aoui/'
	if keyword_set(calib) then file= defDir+'calib.cat'
	if keyword_set(galhI) then file= defDir+'galaxy_HI.cat'
	if keyword_set(gcl)   then file= defDir+'gcl.cat'
	if keyword_set(lewis1)   then file= defDir+'lewis_gals.cat'
	if keyword_set(lewis2)   then file= defDir+'lewis_gals2.cat'
	if keyword_set(oh)   then file= defDir+'oh.cat'
	if keyword_set(psr)   then file= defDir+'psr.cat'
	if keyword_set(brightpsr)   then file= defDir+'psr_bright.cat'
	if keyword_set(snr)   then file= defDir+'snr.cat'
	nlines=readasciifile(file,inpL,comment=comment)
	if (nlines eq -1 ) then begin
		print,'file read err (does it exist?):',file
		return,-1
	endif
	if nlines le 0 then return,0
    srcI=replicate(astr,nlines)
    irec=0L
	start=1
	ntokNeeded=(keyword_set(novel))?4:6
    for j=0,nlines-1 do begin
		if inpL[j]  eq '' then continue
		inpline=inpL[j]
		if strmid(inpline,0,1) eq comment then continue
        strlen=strlen(inpLine)
        tok   =strsplit(inpline,/extract)
        ntok=n_elements(tok)
		if ntok lt ntokNeeded then begin
			print,'bad line:',j+1, " not enough tokens:",inpline
			continue
		endif
		if ntok lt 7 then begin
			velType='v'
		endif else begin
			velType=strlowcase(strmid(tok[6],0,2))
		endelse
        srcI[irec].name=tok[0]
        srcI[irec].decsgn=1
;       has colons in ra,dec
	    if (strpos(tok[1],":") eq -1) then begin
        	sixtyunp,tok[1],junk,ra
            srcI[irec].ra=ra
            sixtyunp,tok[2],decsgn,dec
            srcI[irec].dec=dec
            srcI[irec].decsgn=decsgn
		endif else begin
			 srcI[irec].ra =float(strsplit(tok[1],":",/extract))
			 srcI[irec].dec=float(strsplit(tok[2],":",/extract))
			 if ((srcI[irec].dec[0] lt 0.) or (strpos(tok[2],'-') ne -1)) then begin
			    srcI[irec].dec[0]=-srcI[irec].dec[0] 
                srcI[irec].decsgn=-1
			 endif
		endelse
;
;		ra,dec
;
        srcI[irec].raH =srcI[irec].ra[0]+srcI[irec].ra[1]/60.D + $
                      srcI[irec].ra[2]/3600.D
        srcI[irec].decD=(srcI[irec].dec[0]+srcI[irec].dec[1]/60.D + $
                          srcI[irec].dec[2]/3600.D)*srcI[irec].decsgn
;
; 		position coordinate system
;
		a=strlowcase(strmid(tok[3],0,1))
		strpat='jb'
	    if (strpos(strpat,a) eq  -1) then begin
			lab=string(format=$
			'("line ",i3," bad. crdSys(j,b) illegal:",a)',j,inpLine)
			print,lab
			continue
		endif
		srcI[irec].crdsys =a
;
; 		velocity info
;
		if (keyword_set(novel)) then begin
		 	srcI[irec].vel    =0.
		    srcI[irec].vcrdsys=''
		    srcI[irec].vtype=''
		endif else begin
			srcI[irec].vel    =double(tok[4])
			strpat='lht'
			a=strlowcase(strmid(tok[5],0,1))
	    	if (strpos(strpat,a) eq  -1) then begin
				lab=string(format=$
				'("line ",i3," bad. illegal velFrame(h,t,l):",a)',j,inpLine)
				print,lab
				continue
			endif

;		check vel coord sys: v, zo,zr, z--> zo

			srcI[irec].vcrdsys=velType
			a=strlowcase(strmid(velType,0,2))
	    	if ((a eq 'v') || (a eq 'zo') || (a eq 'zr')) then begin
				srcI[irec].vtype=a
			endif else begin
				if ( a eq 'z') then begin
			    	srcI[irec].vtype='zo'
				endif else begin 
					if (strmid(a,0,1) eq 'v') then begin
			   			srcI[irec].vtype='v'
					endif else begin
						lab=string(format=$
				  '("line ",i3," bad. illegal velType(v,zo,zr)",a)',j,inpLine)
			      		print,lab
			      		continue
					endelse
				endelse
			endelse
		endelse
		i=strpos(inpLine,"#")
		srcI[irec].eol=(i eq -1)?'':strmid(inpLine,i+1)
		irec++
	endfor

doneio: 
    if irec ne nlines then begin
        if irec gt 0 then begin
            srcI=srcI[0:irec-1]
        endif else begin
            srcI=''
        endelse
    endif
	if (irec gt 0) and (keyword_set(sort)) then srcI=srcI[sort(srcI.raH)]
;
    return,irec
end
