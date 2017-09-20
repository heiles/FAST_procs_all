;+
;getsl  - scan an corfile and return the scan list.
;SYNTAX: sl=getsl(lun)
;ARGS:
;		lun:	int assigned to open file
;RETURNS:
;	   sl[nscans]:{sl} holds scan list info
;DESCRIPTION
;	This routine reads a corfile and returns an array of scanlist structures.
;This array contains summary information for each scan of the file:
;
;	sl.scan 	  - long   scan number for this scan
;	sl.bytepos    - unsigned long for start of this scan
;   sl.stat       - .. not used yet..
;	sl.rcvnum     - byte receiver number 1-16
;	sl.numfrq     - byte  .. number of freq,cor boards used this scan
;	sl.rectype    - byte 1 -calon
;	                          2 -caloff
;	                          3 -onoff on  pos
;	                          4 -onoff off pos
;	sl.numrecs    - long  .. number of groups(records in scan)
;	sl.freq[4] float- topocentric frequency center each subband
;   sl.srcname  string  - source name (max 12 long)
;   sl.procname string  - procedure name used.
;	
;	Some routine can use the sl structure to perform random access to
;files (bypassing the need to search for a scan). With the where
;command, subsets of a file can be rapidly exctracted.
;
;EXAMPLE:
;	openr,lun,'/share/olcor/corfile.02nov00.x101.1',/get_lun
;	sl=getx111sl(lun)
;	1. plot all of the lband wide data
;		ind=where(sl.rcvnum eq 5,count)
;		slsub=sl[ind]
;		corloopinit,lun
;		corloop,9999,sl=slsub
;	2. plot all of the data where the lbw first sbc is centered at 1150. Mhz
;		freq=1150.
;		ind=where(sl.freq[0] eq freq,count)
;		slsub=sl[ind]
;		corloopinit,lun
;		corloop,9999,sl=slsub
;
;Note this will not work with files > 2gigabytes since it is 
;using a 32 bit integer.
;-
;
function getsl,lun
	on_error,1
	on_ioerror,done

	rew,lun
 	curscan=-1L
	hdr={hdr}
	maxscans=5000L
	sl=replicate({sl},maxscans)
	i=0L
	grpsinscan=0L
 	point_lun,-lun,curpos
	
	while (i lt maxscans ) do begin
		readu,lun,hdr
		if chkswaprec(hdr.std) then begin
			hdr.std=swap_endian(hdr.std)
			hdr.iflo.if1.st1=swap_endian(hdr.iflo.if1.st1)
			hdr.dop.freqbcrest=swap_endian(hdr.dop.freqbcrest)
			hdr.dop.freqoffsets=swap_endian(hdr.dop.freqoffsets)
		endif

;	if new scan,output old summary
;
		if (hdr.std.scannumber ne curscan) then begin
			sl[i].scan=hdr.std.scannumber
			sl[i].bytepos=curpos
			sl[i].rcvnum=iflohrfnum(hdr.iflo)
			sl[i].numfrq=hdr.std.grptotrecs
			if (i gt 0) then begin
				sl[i-1].numrecs=grpsinscan	;always for the prev scan
			endif
			sl[i].srcname =string(hdr.proc.srcname)
			sl[i].procname=string(hdr.proc.procname)
			sl[i].stat=0 
			sl[i].rectype=0
			calrec=corhcalrec(hdr)
			if (calrec ne 0) then begin
				sl[i].rectype=calrec
			endif else begin
				if sl[i].procname eq 'onoff' then begin
				    if string(hdr.proc.car[*,0]) eq 'on' then begin
						sl[i].rectype=3
					endif else begin
				    	if string(hdr.proc.car[*,0]) eq 'off' then begin
							sl[i].rectype=4
						endif
					endelse
				endif
			endelse
			for j=0,sl[i].numfrq-1 do begin
				sl[i].freq[j]=hdr.dop.freqbcrest + hdr.dop.freqoffsets[j]
			endfor
			curscan=hdr.std.scannumber
			i=i+1
		endif
;
;	position to next rec
;
	    grpsinscan=hdr.std.grpnum
	    curpos=curpos + hdr.std.reclen
		point_lun,lun,curpos
end
done:
	if i ne 0 then sl[i-1].numrecs=grpsinscan    ;always for the prev scan
	if i lt maxscans then sl=temporary(sl[0:i-1])
	point_lun,lun,0
return,sl
end
