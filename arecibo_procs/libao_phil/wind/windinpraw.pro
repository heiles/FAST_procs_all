;+
;NAME:
;windinpraw - input the raw wind monitor data.
;
;SYNTAX: nrecs=windinpraw(yymmdd,b,daynum=daynum,year=year,$
;						  append=append)
;ARGS:
;	yymmdd: long day to read in. -1 is current day. this can be overridden
;				 with the daynum,year keywords.  
;	b[]	  :{windstr} return the data here. If the append keyword is used
;			     then the user should pass in the current buffer and the 
;				 new data will be appended to it.
;KEYWORDS:
;   daynum: long daynumber of year for data to read.
;   year  : long if daynumber is used then this is the corresponding year.
;				 default is the current year.
;				
;DESCRIPTION:
;   This routine is called by windmon to input the next set of monitor
;data. This reads the raw ascii data written by the wind monitor 
;(regular or compressed files). 
;
; It returns number of recs read. returns -1 if it cannot open the file.
;SEE ALSO:
; WIND
;NOTES:
; 	The jd time stamp in the log file is not accurate. It is coming from
;the sbc clock which wanders by up to 1/2 hour. The hhmmss time stamp
;is accurate since it comes from obsdisplay which runs ntpd
;-
; line looks like:
;          1         2         3         4         5         6         
;01234567890123456789012345678901234567890123456789012345678901234
;Sun Jan 29 23:59:59 2006 windata 53765.166655 7.333984 171.289062
;
function windinpraw,yymmdd,b,daynum=daynum,year=year,append=append
    forward_function julday,bytesleftfile
;
;  allocate array to hold entire day
;
    forward_function bin_date,yymmddtojul
;

	mjdtojd=2400000.5D
	recslop=100L		; input buf 100 recslonger than we expect
    maxrecs=86400L  + recslop
	velmax=120.
	reclen =65		; bytes per standard rec
    fpre='/share/wind/wind1'
    fsuf1='.log'
    fsuf2='.log.gz'
    newrecs=0l
;   on_error,1
    on_ioerror,doneio
    if keyword_set(daynum) then begin
        if not keyword_set(year) then year=(bin_date())[0]
        julday=daynotojul(daynum,year)
    endif else begin
        if yymmdd lt 0 then begin
            a=bin_date()
            julday=julday(a[1],a[2],a[0],0,0,0)
        endif else begin
            julday=yymmddtojulday(yymmdd)
        endelse
    endelse
;   find col where string windata ends..
;   on 080319 last day of "windata" then winddata"
	newFormat=(julday gt 2454544.5D)
	indwdataEnd=(newFormat)?32L:31L 
;
;    create the filename to read
;
    fname1=string(format='(a,c(cyi2.2),a1,c(cmoi2.2),a1,c(cdi2.2),a)',$
            fpre,julday,"_",julday,"_",julday,fsuf1)
    fname2=string(format='(a,c(cyi2.2),a1,c(cmoi2.2),a1,c(cdi2.2),a)',$
            fpre,julday,"_",julday,"_",julday,fsuf2)
    lun=-1
    openr,lun,fname1,error=ioerr,/get_lun
;
; try the compressed name
;
    gzip=0
    if ioerr ne 0 then begin 
        openr,lun,fname2,error=ioerr,/get_lun,/compress
        if ioerr ne 0 then goto,badfile
        gzip=1
    endif
;
;   new day
;
    ibuf=strarr(maxrecs)
	readf,lun,ibuf
;
;	grab indices with good data
;
doneio: ind=where(strmid(ibuf,indwdataEnd,1)  eq 'a',newrecs)
	if newrecs gt 0 then begin
;
;		    see if we append or start anew
;
		eps=1./86400D * 10.
        jdmin=julday + 4D/24. - eps
        jdmax=julday + 4./24. + 1D + eps
       	if (n_elements(b) gt 0) and (keyword_set(append)) then  begin
			bloc=replicate({windstr},newrecs)
			bloc.vel=999.
			on_ioerror,ioerr1
			newRecsSav=newrecs
			if (newFormat) then begin
			   a={jd : 0d,junk:0.,vel:0.,dir:0.}
			   blocN=replicate(a,newrecs)
			   reads,ibuf[ind],format='((C(),9x,3f0))',blocN
			endif else begin
			   reads,ibuf[ind],format='((C(),22x,2f0))',bloc
			endelse
ioerr1:		if (newFormat) then begin
				bloc.jd=blocN.jd
				bloc.vel=blocN.vel
			    bloc.dir=blocN.dir
			endif
            bloc.jd+= 4D/24D				; our time was ast to to gmt
			ind=where((bloc.vel ne 999) and $
		    	(bloc.jd ge jdmin) and (bloc.jd le jdmax) and $
			    (bloc.vel lt velmax),newrecs)
			if newrecs eq 0 then goto,done
			if newrecs ne newrecsSav then bloc=bloc[ind]
			b=[b,bloc]
		endif else begin
			b=replicate({windstr},newrecs)
			b.vel=999.
			newRecsSav=newrecs
			on_ioerror,ioerr2
			reads,strmid(ibuf[ind],indwdataEnd+1),b
ioerr2:	    b.jd=b.jd +mjdtojd
			ind=where((b.vel ne 999) and $
				  (b.jd ge jdmin) and (b.jd le jdmax) and $
				  (b.vel lt velmax),newrecs)
		    if newrecs eq 0 then goto,done
		    if newrecs ne newrecsSav then b=b[ind]
	 	endelse
    endif
done: if lun ne -1 then free_lun,lun
    return,newrecs
badfile: if lun ne -1 then free_lun,lun
	return,-1
end
