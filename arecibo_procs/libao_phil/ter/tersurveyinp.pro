;+
;NAME:
;tersurveinp - input transform data from survey
;
;SYNTAX: npts=tersurveyinp(lun,d,maxpnts)
;
;ARGS:
;      lun : 	int lun to read data from.
;   maxpnts: int    maximum number of points to input
;
;RETURNS:
;	   d[npts] : {tersvdat} xformdata that we read in
;      npts    : number of points we found
;
;DESCRPIPTION:
;	Input transform data. This data is taken from the logfile and must
;be edited. It looks for keywords at the beginning of a line:
;
;PNT   NAME  .. start of new measured pnt
;DELTA x y z .. v, hor, tilt motion we made from origin in inches 
;ENC   vl vr hl hr t .. encoder readings for this position
;Scale              1.000059374 sokkia 
;X Rotation            -0.00574
;Y Rotation             0.02027
;Z Rotation             0.00457
;X                      -0.1804
;Y                      -0.0980
;Z                       0.0618
;RMS of Residuals         0.0122
; a ; in col 1 is a comment.
;-
function tersurveyinp,lun,d,maxpnts
;
	d=replicate({tersurveydat},maxpnts)
	on_ioerror,done
	line=' '
	i=-1L
	f=1.
	dd=1.d
	f3=fltarr(3)
	f5=fltarr(5)
	needpnt=1
	while 1 do begin
		readf,lun,line
		skip=1
		case 1 of 
			strcmp(line,';',1)    :  i=i
			strcmp(line,'PNT',3)  : begin
					i=i+1
					a=''
					reads,strmid(line,3),a
					d[i].pnt=strtrim(a,1)
					needpnt=0
					end
			strcmp(line,'DELTA',5): begin
					if needpnt then goto,skip
					reads,strmid(line,5),f3
					d[i].deltaIn=f3
				    end
			strcmp(line,'ENC',3)  : begin
					if needpnt then goto,skip
					reads,strmid(line,3),f5
					d[i].enc=f5
					end
			strcmp(line,'Scale',5)  : begin
					if needpnt then goto,skip
					reads,strmid(line,5),f
					d[i].scale=f
				    end
			strcmp(line,'X Rotation',10)  : begin
					if needpnt then goto,skip
					reads,strmid(line,10),dd
					d[i].rot[0]=dd
				    end
			strcmp(line,'Y Rotation',10)  : begin
					if needpnt then goto,skip
					reads,strmid(line,10),dd
					d[i].rot[1]=dd
				    end
			strcmp(line,'Z Rotation',10)  : begin
					if needpnt then goto,skip
					reads,strmid(line,10),dd
					d[i].rot[2]=dd
				    end
			strcmp(line,'X  ',3)    : begin
					if needpnt then goto,skip
					reads,strmid(line,3),dd
					d[i].offset[0]=dd
				    end
			strcmp(line,'Y  ',3)    : begin
					if needpnt then goto,skip
					reads,strmid(line,3),dd
					d[i].offset[1]=dd
				    end
			strcmp(line,'Z  ',3)    : begin
					if needpnt then goto,skip
					reads,strmid(line,3),dd
					d[i].offset[2]=dd
				    end
			strcmp(line,'RMS',3)    : begin
					if needpnt then goto,skip
					reads,strmid(line,16),f
					d[i].rmsresid=f
					needpnt=1
				    end
			else: print,'-->skipped',line
		endcase
		skip=0
skip:
		if skip then  print,'-->skipped',line
	endwhile
done:
	if not eof(lun) then begin
		print,line
		print,!error_state.msg
	endif
	npts=i+1
	if npts ne maxpnts then d=d[0:npts-1]
	return,npts
end
