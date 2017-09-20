;+
;NAME:
;svinppnts - input data points from a file.
;SYNTAX: npts= svinppnts(lun,pnts)
;ARGS:
;	    lun: int  file to read from
;pnts[npts]: {surveypnts} return data here
;
;DESCRIPTION:
;	input the survey data points from the data file. The program looks for
;the following keys at the start of a line:
; -,; ignore line
; SET  begin a set of data points.. following lines should have:
;       name   x y z  ...
; Transform .. end of set 
; Res  begin residuals. following lines should have :
;       name  dx dy dz
; It will stay in SET or Res mode till the next SET or Res is found.
;The routine will add an entry for every point found. Duplicate points
;will be entered twice. Use uniq on the name to check for  duplicates.
;-
function svinppnts,lun,pnts,maxpnts=maxpnts,lunout=lunout

    on_ioerror,done

	if n_elements(lunout)  eq 0 then lunout=-1
	if n_elements(maxpnts) eq 0 then maxpnts=500
	pnts=replicate({surveypnts},maxpnts)
	onpnt=0
	onres=0
	vals=fltarr(3)
	i=0
	line=''
	firstset=0
	lab=''
	while 1 do begin
	  line=' '
      readf,lun,line
;	  a=string(format='("->",a,/)',strmid(line,0,49))
;	  printf,lunout,a
	  case 1 of
		  strcmp(line,';',1)    :  i=i
		  strcmp(line,'-',1)    :  i=i
		  strcmp(line,'SET',3)  : begin
		     	onpnt=1
		     	onres=0
				firstset=1
             end
		  strcmp(line,'Res',3)  : begin
		     	onpnt=0
		     	onres=1
             end
		  strcmp(line,'Transform',9)  : begin
		     	onpnt=0
		     	onres=0
             end
	      onpnt: begin
				reads,strmid(line,0,8),lab
				lab=strtrim(lab)
				reads,strmid(line,8),vals
				pnts[i].name=lab
				pnts[i].pos=vals
				i=i+1
				end
		  onres and firstset: begin
				reads,strmid(line,0,8),lab
				lab=strtrim(lab)
				reads,strmid(line,8),vals
				ind=where(pnts.name eq lab,count) 
			    if count  gt 0 then begin
					pnts[ind].rms=vals
			    endif else begin
				   a=string(format='("rmserr:",a)',strmid(line,0,29))
				    printf,lunout,a
				endelse
				end
		  else : begin
				a=string(format='("skip:",a)',strmid(line,0,29))
				printf,lunout,a
				end
	  endcase
	endwhile
done: 
 	if not eof(lun) then begin
        printf,lunout,line
        print,!error_state.msg
    endif
    npts=i
    if npts ne maxpnts then pnts=pnts[0:npts-1]
	return,npts
end
