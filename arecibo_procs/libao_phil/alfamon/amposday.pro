;+
;NAME:
;amposday - position to start of day in file
;SYNTAX: istat=amposday(lun,yymmdd)
;ARGS:
;   lun :       int file containing data to read
; yymmdd:  long day to position to
;RETURNS:
;   istat : int  0 - positioned at start (yymmdd <= first rec)
;                1 - positioned in file
;                2 - positioned at end (yymmdd > last rec of file)
;DESCRIPTION:
;   amposday will position to the start of a day within the file.
;This routine is normally called from aminpday().
;
;EXAMPLE:
;   openr,lun,'logfile',/get_lun
;   yymmdd=021105
;   istat=amposday(lun,yymmdd)
;
;-
function amposday,lun,yymmdd
;
    on_ioerror,done

	comment="#"
    returnStat=1L
    year=yymmdd/10000L
	yyyymmdd=(year lt 100)?yymmdd/10000L + (year+2000)*10000L: yymmdd
	rew,lun
	point_lun,-lun,curpos
	done=0
	got1date=0
	foundit=0
	inpl=''
	irec=0L
	while (not foundit) do begin
		readf,lun,inpl
		irec++
		if (strmid(inpl[0],0,1) eq  comment) then begin
			point_lun,-lun,curpos &$
		 endif else begin
			date=long(strmid(inpl,0,8))
			if date ge yyyymmdd then begin
				foundIt=1
			endif else begin
				point_lun,-lun,curpos
				got1date=1
			endelse
		endelse
	endwhile
done:
	if got1date eq 0 then begin
		rew,lun
		return,0
	endif else begin
		if (foundIt) then begin	
			point_lun,lun,curpos
			return,1
		endif else begin
			return,2
		endelse
	endelse
end
