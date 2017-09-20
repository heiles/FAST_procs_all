;+
;NAME:
;shiftregcmp - compute a shift register code
;SYNTAX: codelen=shiftregcmp(codeI,code,lastval=lastval)
;ARGS:
;codeI:{}	code info structure describing the shift register code
;RETURNS:
;codelen: long	length of code computed
;code[codelen]: float :  computed shift register code
;lastval: ulong  if keyword provided then return the last value of the
;                shift register (only for galois lfsr codes).
;DESCRIPTION:
;	Compute a shift register code given the shift register description in
;the codeI structure. The structure contains:

;help,codeI,/st
;** Structure CODEINFO, 4 tags, length=92, data length=92:
;   NUM_REG         LONG        1 ; number of registers for this code
;   LEN             LONG        1 ; length of code
;   NUM_FDBACK      LONG        1 ; number of taps (feedbacsk)
;   FDBACK          LONG      Array[20] ; locations of feedbacks
;                             The indices in this array are 1 based..
;							  the N feedback locations are stored in
;				              fdback[0:n-1]
;   galois          int         i   ; 0==> fibonnaci, 1==> galois lfsr
;   startVal        ulong       0   ; for galois
;   endVal          ulong       0   ; for galois

;	routine that will generate the code info structure:
;shiftregcmp(): generates pncodes used by the sband radar.
;-
function shiftit,codeI,shiftreg

	ii=codeI.fdback[0] - 1
	newval=shiftreg[ii]
	for i=1,codeI.num_fdback-1 do begin
		ii=codeI.fdback[i] - 1
		newval= newval  xor shiftreg[ii]
	endfor
	newval=not newval
;
;	now shift the shift register
;
	shiftreg=shift(shiftreg,1)
	shiftreg[0]=(newval and 1u)
	return,newval
end
;
function shiftitgl,codeI,shiftreg,last
;
;	our shiftreg goes  N .. 1, 0 is only used to hold the output
;
	newVal=shiftreg[0]
	if last then return,newval
    shiftreg=shift(shiftreg,-1)
	for i=0,codeI.num_fdback-1 do begin
		ii=codeI.fdback[i] - 1
		shiftreg[ii]=(shiftreg[ii]  xor newval) and 1u
	endfor
	return,newval 	
end

	
function shiftregcmp,codeI,code,lastval=lastval  
;
; 	make it 1 longer then needed since shiftreg[0] not used
;   initializes to all zeros
;
	shiftreg=uintarr(codeI.num_reg) 
	code=intarr(codeI.len)
	minval=0
	maxval=1
;
;   not galois code
;
	if (not codeI.galois) then begin
		for i=0L,codeI.len-1 do begin
			code[i]=(shiftit(codeI,shiftreg))?maxval:minval
		endfor
	endif else begin
		startVal=codeI.startVal
		for i=0,codeI.num_reg-1 do begin
			shiftreg[i]=startVal and 1U
			startVal=ishft(startval,-1)
		endfor
		lenm1=codeI.len-1
		for i=0L,codeI.len-1 do begin
			last=i eq lenm1
			code[i]=(shiftitgl(codeI,shiftreg,last))?maxval:minval
		endfor
		if (arg_present(lastval)) then begin 
			lastval=0Ul
			for i=codeI.num_reg-1,0,-1 do begin 
    			lastval = ishft(lastval,1)  or (shiftreg[i] and 1) 
			endfor
		endif
	endelse
	return,codeI.len
end
