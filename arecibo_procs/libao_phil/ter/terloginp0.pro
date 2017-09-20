;+
;NAME:
;terloginp0 - input tertiary log data
; use pre 19nov00 format with no monitor port.
;SYNTAX: ld=terloginp(lun,numsteps);
;ARGS  :
;		lun	: 	  int assigned to file
;		numsteps long number of 5 ms steps to read in
;RETURNS:
;	ld[numsteps]: {terlog} return array of log data
;-
function terloginp0,lun,numsteps
;
;
;   see how much of file is left
;
	steps=numsteps
    fst=fstat(lun)
    stepsleft=(fst.size-fst.cur_ptr)/104L
    if  stepsleft lt steps then steps=stepsleft
;
;   allocate array
;
    inp=replicate({terlog0},steps)
    readu,lun,inp
	return,inp
end
