;+
;NAME:
;atmpwrscancal - grab cals for a set of rawdat power scans
;SYNTAX: n=atmpwrscancal(fbase,fnum1,fnum2,calD,maxblks=maxblks,verb=verb,yscale=yscale)
;ARGS:
; fbase  :string base name for files to scan. includes directory and fname
;                upto the filenumber: eg:"/share/aeron5/t1193_04sep2012.".
; fnum1  : int   first filenumber to scan
; fnum2  : int   last filenumber to scan
;KEYWORDS: 
; maxBlks: long  maximum number of blocks to return. The default is 1000.
;  verb  :       1-output filenames and block numbers as they are processed
;                2-output 1 and plot the cal on,off for each 10 sec block
; yver   :[min,max]  If verb=2 then the the vertical scale for the plotting.
;                If not provided, the default is [1000,40000]. The plot uses
;                /ylog so you can see the on,and off.
;RETURNS:
;       n:int    > 0 number of entries in calD[]
;                0 error
;                -1 - could not open first file fbase+fnum1
;                -2 - no  power data found in first file
; calD[n]:{}     caldata for each 10sec block
;  				{ fnum: 0L,$
;				  blk : 0l,$ ; in file
;		           h  :d.h,$ ; header for first rec of 10 sec block
;		          nipp: 0L,$ ; we found in this block 
; 				 nfifos:0L,$ ; number of fifos 1,2.. 
;		         calOn:fltarr(maxipp,nfifos),$ ; holds calOn totPwr each ipp
;                                           0=fifo1,1=fifo2. only nipp valid
;		        calOff:fltarr(maxipp,nfifos),$ ; holds calOff totPwr each ipp
;                                           0=fifo1,1=fifo2
;               }
;DESCRIPTION:
;   Scan rawdat files for power profile blocks (10secs) of data. Compute the power in the
;calOn,calOff, and  return it in the calD[n] structure. Each element of calD[] holds the 
;information for an entire 10 sec block. A block read will finish after 1000 ipps, or a data record
;of a different type (say mracf is found).
;	For each block of data, compute the total power for the calOn and calOff of each ipp.
;Then average over the calOn, and caloff samples (giving 1 calon,1 caloff value for each ipp,
;fifoChan). When averaging, ignore 25 samples at the start of calOn,calOff. This excludes the 
;calOn to calOff transition (which differs for the dome and the ch).
;
; 	The returned calD[n] array of structures contains:
;calD[n].fnum the filenumber where this block came from
;calD[n].blk  the 10sec block within the file where data came from (count from 0)
;calD[n].h    the header from the first ipp of the block.
;calD[n].nipp the number of valid ipps in calOn,calOff for this block (in case the
;             block had less than 1000 ipps before a different record type was found.
;calD[n].nfifos  the number of fifos found. This determines the 2nd dimension of 
;                calOn[x,nfifos],calOff[x,nfifos]
;calD[n].calOn[maxipp,nfifos] Hold the calOn total power for each ipp. [x,0] is fifo1 (ch)
;                        [x,1] is fifo2 (dome).
;calD[n].calOff[maxipp,nfifos] Hold the calOff total power for each ipp. 
;
;Notes:
;0. nfifos, and ipps/buf are taken from the first block of the first file. If this
;   configuration changes (between fnum1,fnum2) then it will still use the values from
;   the first rec of first block of first file.
;1. I've used 10secs of data in the above. It actually is 1000 ipps. If the power ipp is
;   different, then the time of each block will will be 1000*ipp.
;2. If there are 1000 +n ipps,then a different data rec, you will get a second
;   block with only N ipps (maybe there should be a keyword for specifying the minimum
;   number of ipps for a block?).
;3. The ipps within a block will be contiguous in time (spaced by an ipp). There will
;   normally be time gaps between blocks (if they run more that just pwr in the cycle).
;   You can look at the time in the header to see the start of each block.
;
;EXAMPLE:
;	fbase='/share/aeron5//share/aeron5/t1193_04sep2012.'   ; note the . a the end
;   n=atmpwrscancal(fbase,71,99,calD,/verb)
;-
function atmpwrscancal,fbase,fnum1,fnum2,calD,maxblks=maxblks,$
	verb=verb,yver=yver

    common colph,decomposedph,colph
;
;
	if n_elements(verb) eq 0 then verb=0
	if n_elements(yver) eq 0 then  yver=[1000.,40000.]
	if n_elements(maxBlks) eq 0 then maxBlks=1000L

	minRecsRead=100 ; if we read less than 100 recs, then skip..
	fbaseL=fbase
	if (strmid(fbasel,strlen(fbasel)-1,1) ne '.') then fbaseL=fbaseL + '.'
;   search for rawdat power data
	rectype='rpwrb'
;
;	read 1st rec to get header def
;
	file=fbase + string(format='(i03)',fnum1)
	err=0
	lun=-1
    openr,lun,file,err=err,/get_lun
	if err ne 0 then begin
		print,!error_state.msg," Opening 1st file:",file
		return,-1
	endif
	istat=atmget(lun,d,nrecs=1,rectype=rectype,/search)
	free_lun,lun
	lun=-1
	if (istat le 0 ) then begin
		print,"Did not find power data in 1st file:",file
		return,-2
	endif
	ippsBuf=d.h.ri.ippsperbuf
	nfifos=(d.h.ri.fifonum eq 12)?2:1 
	maxipp=1000
	a={ fnum: 0L,$
		blk : 0l,$ ; in file
		h   :d.h,$
		nipp: 0L,$
		calOn:fltarr(maxipp,nfifos),$ ; 2-> ch, gr
		calOff:fltarr(maxipp,nfifos)}
			
	nrecsPerRead=long((maxIpp)/ippsBuf + .5)
	maxBlks=1000L 
	calD=replicate(a,maxBlks)

	icur=0L
	edgSlop=25     ; for cal transitions, ignore at begining cal,noise
 	if (verb ge 2)  then begin
		ver,yver[0],yver[1]
		hor
	endif
	for fnum=fnum1,fnum2 do begin
		file=fbase + string(format='(i03)',fnum)
		if lun ne -1 then free_lun,lun
		lun=-1
		if (verb ge 1 ) then begin
	 		print,"Opening fnum:",fnum," icur:",icur
		endif
		err=0
		openr,lun,file,/get_lun,err=err
		if err ne 0 then begin
			print,"Error opening:",file," ..skipping"
			continue
		endif
		iblk=0L
		while (atmget(lun,d,nrecs=nrecsPerRead,rectype=rectype,/search))$
 			do begin
			n=n_elements(d)
			if n lt minRecsRead then continue
			spipp=d[0].h.ri.smppairipp
			ippsBuf=d[0].h.ri.ippsperbuf
			nsmpTx=d[0].h.sps.smpinTxPulse
			natm  =d[0].h.sps.rcvwin[0].numsamples
			ncalnoise=d[0].h.sps.rcvwin[1].numsamples
    		ncal=ncalnoise/2
			i0=nsmpTx + natm
			i1=i0 + ncalnoise - 1
			nn=ippsbuf*n
			cal1=transpose(total($
					(reform(abs((reform(d.d1,spipp,nn))[i0:i1,*])^2,ncal,2,nn))[edgslop:*,*,*],1))$
					/ (ncal-edgSlop)
		    if (nfifos eq 2) then begin
				cal2=transpose(total($
					(reform(abs((reform(d.d2,spipp,nn))[i0:i1,*])^2,ncal,2,nn))[edgslop:*,*,*],1))$
					/ (ncal-edgSlop)
		    endif
			calD[icur].fnum=fnum
			calD[icur].blk=iblk
			calD[icur].h=d[0].h
			calD[icur].nipp=nn
			l= (maxipp < nn)
			calD[icur].calOn[0:l-1,0]=cal1[0:l-1,0]
			calD[icur].calOff[0:l-1,0]=cal1[0:l-1,1]
			if (nfifos eq 2) then begin
			  calD[icur].calOn[0:l-1,1]=cal2[0:l-1,0]
			  calD[icur].calOff[0:l-1,1]=cal2[0:l-1,1]
			endif
			if (verb ge 2) then begin
				ltit=string(format='("fnum:",i3," iblk:",i3," date:",i7," tm:",a)',$
					fnum,iblk,d[0].h.std.date,fisecmidhms3(d[0].h.std.time))
				plot,cal1[*,0],title=ltit,/ylog
				oplot,cal1[*,1],col=colph[2]
				if (nfifos eq 2) then begin
					oplot,cal2[*,0],col=colph[3]
					oplot,cal2[*,1],col=colph[4]
		    	endif
				empty
			endif
			icur=icur+1
			iblk++
			if icur ge maxblks then begin
				print,"Hist max # blocks:",icur
				free_lun,lun
				goto,done
			endif 
		endwhile
	endfor
done:
	if icur lt maxBlks then calD=calD[0:icur-1]
	if lun ne -1 then free_lun,lun
	return,icur
end
