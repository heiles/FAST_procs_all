;+
;pfsrc - process a contigous set of position swithching for a single source
;SYNTAX: istat=pfsrc(srcinfo,srciIndex,bb,srcOut,srcOutIndex,
;					   skip=skip,nocal=nocal,_extra=e)
;ARGS:
;		srcinfo[]		:{pfsrcinfo} array of holding general source info for
;						           sources we are processing.
;					 srcinfo[].name  : string .. source name
;					 srcinfo[].filenm: string .. filename holding source data
;					 srcinfo[].scanst: long   .. starting scan number for source.
;					 srcinfo[].npair : long   .. number of on/off pairs.
;					 srcinfo[].flux  : float  .. source flux in janskies..
;		srciIndex      : long index into srcinfo for the source to process.
;Ret:	bb[]           : {corget} return spectrum,headers for on/off-1 for
;								  each pair.header if 1st header of on with
;							      mods (a).
;Ret:   srcOut[]       : {pfsrcout} return summary info for on/off-1 . each
;								  on/off integration is an index value
;						 srcOut[].h      : header posOn 1st rec with mods:
;  (a)								       h.std.gr,az,chttd is the average 
;											for the entire on scan
;                                         h.cor.lag0pwratio is the average 
;										  of (on-off)/off the units will depend
;									      on nocal...
;                     TsysPosOff or kelvins depending on /sclcal.

;						 srcOut[].srcnum : srciIndex for this source 
;						 srcOut[].t      : {cortmp} cortemp array holding:
;							      t.k       :units. 1->kelvins,0-->Tsys
;							      t.p[2,4]  :int 1->pola,2->polb,0->nodata
;							      t.src[2,4]:float. on/off-1 total power source
;							      t.on[2,4] :float. on total power
;							      t.off[2,4]:float. off total power
;							      t.calscl[2,4]:float. Kelvins/(calOn-calOff)
;								             conversion factor
;					     flux               :float flux Janskies this source.
;in/out: srcOutIndex    : long  index into srcOut to start storing info.
;						        on return the value will be increments
;							    by the number of pairs processed.. so don't
;						        pass in a constant, or indexed array element.
;KEYWORDS:
;		skip		: long	number of pairs to skip between pairs we processs.
;							default is 0 (we process sequentially).
;		nocal       : if set, then don't scale by the cals.
;       calval[2,nbrds]: cal values to use, rather than looking them up.      
;
;DESCRIPTION:
;  This routine can be used to process all of the on off pairs in a file.
;Each call can process a number of scans from a single source. The pairs
;will be contigous unless skip is set. This variable will process :
; pair..
;  jump skip pairs.
; pair....
; It can be used when you have interleaved receivers on the same source.
;
; The returned data contains 2 parts:
;  1.  bb[] this is an array containg the on/off -1 spectral data for 
;           each on/off pair of this source. It is allocated by this routine.
;  2.  srcOut[] . this is a cumulative array that will contain summary 
;                 total power info (ton,toff, ton/off -1.. etc) for a number
;     			  of sources. It will normally hold info from a number
;				  of sources. The user allocates the array and passes in 
;				  the array and the current index to load this calls data.
;				  On exit the index is incremented by the number of pairs 
;				  processes.
;
; For each source there is also an informational array srcinfo that holds
;srcname,flux,srcnum, etc..
; The srcnum is loaded into the srcOut array so you can access the 
; results of a particular source via  where(srcOut.srcnum eq n) .. n=0..numsrc-1
;
;-
function pfsrc,srci,srciind,bb,srcout,srcoind,skip=skip,nocal=nocal,_extra=e
;
	if not keyword_set(skip) then skip = 0
	usecal=1
	if keyword_set(nocal) then usecal=0
	srcdone=0
	lun=-1
	ii=srciind
	openr,lun,srci[ii].filenm,/get_lun,error=errstat
 	if (errstat ne 0) then begin
		message,!err_string
	endif
	if corget(lun,b,scan=srci[ii].scanst) ne 1 then goto,done
	bb=corallocstr(b,srci[ii].npair)
	isrc=srcoind
	scan=srci[ii].scanst
	for i=0,srci[ii].npair-1 do begin
	    istat=corposonoff(lun,b,t,cals,scan=scan,sclcal=usecal,_extra=e)
		if istat ne 1 then goto,done
    	corstostr,b,i,bb
    	srcout[isrc].t=t
    	srcout[isrc].h=b.b1.h
    	srcout[isrc].flux  =srci[ii].flux
		srcout[isrc].srcnum=ii
    	isrc=isrc+1
    	scan=0
		srcdone=srcdone+1
		if skip gt 0 then begin
			for j=0,(skip-1) do begin
				for k=0,3 do begin
				 istat=posscan(lun,0,1,/skip)
				 if istat ne 1 then goto,done
				endfor
			endfor
		endif
	endfor
done:
	if lun ne -1 then free_lun,lun
	srcoind=srcoind+srcdone
	return,srcdone
end
