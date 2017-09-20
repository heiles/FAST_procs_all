;+
;NAME:
;terloginp - input tertiary log data
; use post 19nov00 format with monitor port included.
;SYNTAX: ld=terloginp(lun,numsteps);
;ARGS  :
;		lun	: 	  int assigned to file
;		numsteps long number of 5 ms steps to read in
;RETURNS:
;	ld[numsteps]: {terlog} return array of log data
;-
function terloginp,lun,numsteps
;
;
;   see how much of file is left
;
	steps=numsteps
    fst=fstat(lun)
    stepsleft=(fst.size-fst.cur_ptr)/124L
    if  stepsleft lt steps then steps=stepsleft
;
;   allocate array
;
    inp=replicate({terlog},steps)
    readu,lun,inp
	return,inp
end
