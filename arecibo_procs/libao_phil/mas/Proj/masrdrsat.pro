;+
;NAME:
;masrdrsat - look for radar saturation 
;SYNTAX: istat=masrdrsat(fnmiar,rfiFreq,aero=aero,faa=faa,$
;                           remy=remy,bwsrch=bwsrch,rfiBaseLnFreq=rfiBaseLnFreq)
;ARGS:
;   FNMIAR[N]: {} array holding files to process. see masfilelist
;   rfiFreq[m]: float cfr for each rfi that you are interested in.
;                     see also rdr keywords.
;KEYWORDS:
;bwsrch: float Number Mhz around center of rdr to search for peak.
;              default is larger of 1 Mhz or 1.5 channels
;aero:  if set then include aerostat freq's at [1241.74,1256.5,1246.2,1261.25] 
;faa  : if set then include faa radars at [1330, 1350]
;remy : if set then include remy rdr at [1270,1290]
;savFile: string Name for save file.. leave off the .sav 
;savaz: if set then record az positions
;savza: if set then record za positions
;deffreq: if set then use default freq rather than the header values (for early datasets).
;rfiBaseLnFreq: Mhz . If supplied then include the peak hold around this freq. You can
;              use it for a baseline. Needed if the time sampling is slower than the
;              rdr ipps.
;verbose:      if set then print record numbers as we process them
;
;DESCRIPTION:
;   Assume the two 170 Mhz bands have lo's of 175 and 325 Mhz and that the
;skycfr is 1375Mhz. The radar band will be in band1 and the clean band will
;be in band0 (since first lo is high side).
;-
function    masrdrsat,fnmiar,rfiFreq,aero=aero,faa=faa,remy=remy,$
                bwsrch=bwsrch,savNm=savNm,verbose=verbose,savaz=savaz,savza=savza,$
                deffreq=deffreq,rfiBaseLnFreq=rfiBaseLnFreq
;
;
;
	gftm_dec='a2130_dtm'
    bandCln=0       ; where the clean,rfi are located in the two bands..
    bandRfi=1
    useAero=keyword_set(aero) 
    useRemy=keyword_set(remy)
    useFaa=keyword_set(faa)
	useBaseLn=n_elements(rfiBaseLnFreq) gt 0
    useAz=keyword_set(savaz)
    useZa=keyword_set(savZa)
    if n_elements(savNm) eq 0 then savNm='rdrSat'
    if n_elements(verbose) eq 0 then verbose=0
;
;   get some params from file
;
    nfiles=n_elements(fnmiar)
	use_Gftm_dec=fnmIar[0].proj eq gftm_dec
	
	if (use_gftm_dec) then begin
		istat=gftopen(filename,desc,fnmI=fnmiar[0])
		istat=gftget(desc,bon,b,row=1)
	endif else begin
    	istat=masopen(junk,desc,fnmi=fnmiar[0])
    	istat=masget(desc,b)
	endelse
    spclen=b.nchan
    if not keyword_set(bwsrch) then begin
        bwSrch= 1.> (abs(b.h.cdelt1)*1e-6*1.5)
    endif
;
    if keyword_set(deffreq) then begin
        bw=170.000384
        frqdir=-1.
    endif else begin
        bw=abs(b.h.cdelt1)*spclen*1e-6
        frqdir=(b.h.cdelt1 lt 0)?-1.:1.
    endelse
    freqCln=[frqdir*(findgen(spclen)/spclen - .5)*bw +  1450]
    freqRfi=[frqdir*(findgen(spclen)/spclen - .5)*bw +  1300]
    aeroFrq=[1241.74,1256.5,1246.2,1261.25]
    faaFrq  =[1330,1350.]
    remyFrq =[1270,1290.]
    rdrFrqAr=fltarr(10)
    smpTm=b.h.cdelt5
;
;	add the frequencies they requested..
;
    ii=0
;
;   use aero.. just use 1..
;
    if (useAero) then begin
        rdrFrqAr[ii] =aeroFrq[0]
        iiAero1=where(abs(freqRfi - aeroFrq[0]) lt bwsrch,cntAero1)
        iiAero2=where(abs(freqRfi - aeroFrq[1]) lt bwsrch,cntAero2)
        iiAero3=where(abs(freqRfi - aeroFrq[2]) lt bwsrch,cntAero3)
        iiAero4=where(abs(freqRfi - aeroFrq[3]) lt bwsrch,cntAero4)
        indAero=ii
        ii++
    endif
    if (useFaa) then begin
        rdrFrqAr[ii] =faaFrq[0]
        iiFaa1=where(abs(freqRfi - faaFrq[0]) lt bwsrch,cntFaa1)
        iiFaa2=where(abs(freqRfi - faaFrq[1]) lt bwsrch,cntFaa2)
        indFaa=ii
        ii++
    endif
    if (useRemy) then begin
        rdrFrqAr[ii] =remyFrq[0]
        iiRemy1=where(abs(freqRfi - remyFrq[0]) lt bwsrch,cntRemy1)
        iiRemy2=where(abs(freqRfi - remyFrq[1]) lt bwsrch,cntRemy2)
        indRemy=ii
        ii++
    endif
;
;	see if they want a baseline freq
;
	if (useBaseLn) then begin
        rdrFrqAr[ii] =rfiBaseLnFreq[0]
        iiBaseLn=where(abs(freqRfi - rfiBaseLnFreq[0]) lt bwsrch,cntBaseLn)
        indBaseLn=ii
        ii++
	endif
	
    nradar=ii 
    rdrFrqAr=rdrFrqAr[0:nradar-1]
;
    beamList=fnmIar[uniq(fnmiar.bm,sort(fnmiar.bm))].bm
    bandList=fnmIar[uniq(fnmiar.band,sort(fnmiar.band))].band
    nbeams=n_elements(beamlist)
    nbands=n_elements(bandlist)
;
;   these are the file numbers..want to do them in order since thatis
;   how time goes.
    smpRec=b.ndump
;
;   count the recs and samples
;   
    ii=where((fnmiar.band eq bandList[0]) and $
             (fnmiar.bm eq beamList[0]),cnt)
    smpTot=0L &$
    nrecs=0L &$
    for i=0,cnt-1 do begin &$
        masclose,/all &$
		if use_Gftm_dec then begin &$
        	istat=gftopen(junk,desc,fnmi=fnmiar[ii[i]]) &$
		endif else begin &$
        	istat=masopen(junk,desc,fnmi=fnmiar[ii[i]]) &$
		endelse &$
        nrecs+=desc.totrows &$
        if i ne (cnt-1) then begin &$
            smpTot+=(desc.totrows*smpRec) &$
        endif else begin &$
			if use_Gftm_dec then begin &$
            	istat=gftget(desc,bon,b,row=desc.totrows)    &$
			endif else begin &$
            	istat=masget(desc,b,row=desc.totrows)    &$
			endelse &$
            smpTot+=((desc.totrows-1)*smpRec + b.ndump) &$
        endelse &$
    endfor
;
;   allocate some of the arrays
;
    nptsRfiAr=lonarr(nbeams)   ; points we found for rfi
    nptsClnAr=lonarr(nbeams)   ; points we found for cln .. should be the same
    tpRdr=fltarr(smptot,nbeams,nradar)
    tpCln=fltarr(smptot,nbeams)
    if useAz then encAz=fltarr(nrecs)
    if useZa then encZa=fltarr(nrecs)
    if (useZa || useAz) then encTm=dblarr(nrecs)

;
; let L be the low if band (hi rf band)
; let H be the hi if band (lo rf band)
;
;
;  now loop over all the files
;
    recCntAr=lonarr(nbeams,nbands)
    smpCntAr=lonarr(nbeams,nbands)
    for ibm=0,nbeams-1 do begin
        bm=beamList[ibm]
        for iband=0,nbands-1 do begin
            band=bandList[iband]
;
;           make sure the seq numbers are in ascending order
;
            indF=where((fnmIar.bm eq bm) and (fnmiar.band eq band),nfiles)
            jj=sort(fnmiar[indF].num)
            indF=indF[jj]
            for ifile=0,nfiles-1 do begin &$
                masclose,/all &$
                jj=indF[ifile]
				if use_Gftm_dec then begin
        			istat=gftopen(junk,desc,fnmi=fnmiar[jj]) &$
				endif else begin
                	istat=masopen(junk,desc,fnmi=fnmIar[jj])
				endelse
                if verbose then begin
                    lab=string(format=$
                    '("bm:",i1," band:",i1," bwsrc:",f5.3," file:",a)',$
                        bm,band,bwsrch,fnmiar[jj].fname)
                    print,lab
                endif
                for row=1,desc.totrows do begin &$
					if use_Gftm_dec then begin &$
            			if gftget(desc,bon,b) ne 1 then break    &$
					endif else begin &$
                    	if masget(desc,b) ne 1 then break &$
					endelse &$
                    ndump=(smpTot - smpCntAr[bm,band]) < b.ndump &$
                    ii=smpCntAr[bm,band] &$
                    if band eq bandCln then begin &$
                        tpCln[ii:ii+ndump-1,bm]=$
                            (total(b.d[*,0,*],1) + total(b.d[*,1,*],1))*.5 &$
                    endif else begin &$
                        if (useFaa) then begin  &$
                            tpRdr[ii:ii+ndump-1,bm,indFaa]=$
                                    max(b.d[iiFaa1,0,0:ndump-1],dim=1)>$
                                    max(b.d[iiFaa1,1,0:ndump-1],dim=1)>$
                                    max(b.d[iiFaa2,0,0:ndump-1],dim=1)>$
                                    max(b.d[iiFaa2,1,0:ndump-1],dim=1) &$
                        endif &$
                        if useRemy then begin &$
                            tpRdr[ii:ii+ndump-1,bm,indRemy]=$
                                     max(b.d[iiRemy1,0,0:ndump-1],dim=1) >$
                                     max(b.d[iiRemy1,1,0:ndump-1],dim=1) >$
                                     max(b.d[iiRemy2,0,0:ndump-1],dim=1) >$
                                     max(b.d[iiRemy2,1,0:ndump-1],dim=1) &$
                        endif &$
						if useBaseLn then begin &$
                            tpRdr[ii:ii+ndump-1,bm,indBaseLn]=$
                                     max(b.d[iiBaseLn,0,0:ndump-1],dim=1) >$
                                     max(b.d[iiBaseLn,1,0:ndump-1],dim=1)  &$
                        endif &$

                        if useAero then begin
                            tpRdr[ii:ii+ndump-1,bm,indAero]=$
                                     max(b.d[iiAero1,0,0:ndump-1],dim=1) >$
                                     max(b.d[iiAero1,1,0:ndump-1],dim=1) >$
                                     max(b.d[iiAero2,0,0:ndump-1],dim=1) >$
                                     max(b.d[iiAero2,1,0:ndump-1],dim=1) >$
                                     max(b.d[iiAero3,0,0:ndump-1],dim=1) >$
                                     max(b.d[iiAero3,1,0:ndump-1],dim=1) >$
                                     max(b.d[iiAero4,0,0:ndump-1],dim=1) >$
                                     max(b.d[iiAero4,1,0:ndump-1],dim=1) 
                        endif
                    endelse
                    if useaz then encAz[recCntAr[bm,band]]=b.h.enc_azimuth
                    if useza then encZa[recCntAr[bm,band]]=$
                                    90.- b.h.enc_elevatio
                    if (useAz || useZa) then $
                              encTm[recCntAr[bm,band]]=b.h.mjdxxobs
                    smpCntAr[bm,band]+=ndump
                    recCntAr[bm,band]++
                    if (verbose && ((recCntAr[bm,band] mod 10) eq 0)) then $
                            print,smpCntAr[bm,band]
                endfor   ; row loop
            endfor    ; file loop  of numbers
        endfor        ; loop over bands
    endfor            ; loop over beams
    nptsClnAr=smpCntAr[*,1]
    nptsRfiAr=smpCntAr[*,0]
    ii=nptsClnAr[0]
    if ii lt smpTot then begin
        tpRdr=temporary(tprdr[0:ii,*,*])
        tpCln=temporary(tpCln[0:ii,*])
    endif
    azAr=(useAz)?interpol(encAz,encTm,encTm[0]+dindgen(smptot)*smptm/86400D):$
            ''
    zaAr=(useZa)?interpol(encZa,encTm,encTm[0]+dindgen(smptot)*smptm/86400D):$
                ''
    hdr=b.h
    save,tpRdr,tpCln,hdr,nptsClnAr,nptsRfiAr,beamList,rdrFrqAr,azAr,zaAr,$
            file= savNm + '.sav'
    return,nptsClnAr[0]
end
