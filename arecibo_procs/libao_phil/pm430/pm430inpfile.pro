;+
;NAME:
;pm430inpfile - input a file of 430tx pwr data.
;SYNTAX: n=pm430inpfile(filename,d)
;ARGS:
;filename:string	name of file (including directory)
;RETURNS:
;n   : long       -1 can't read file
;                 >=0 points read from file
;d[n]:struct 	  struct array holding the data
;
;DESCRIPTION:
;	This routine will input all of the data from one of the ascii files created by
;the 430 tx power meter (ladybug software). You need to supply the name of the 
;disc file holding the ascii data. It returns the number of the entries as well as 
;an array of structures holding the data. Each structure entry contains:
;DL> help,d,/st
;** Structure <a4e9b1c>, 6 tags, length=40, data length=40, refs=2:
;   SEC     DOUBLE    31152.562 ; seconds from midnite AST this measurement
;   PULPWR  float     653.81971 ; pulse power
;   PKPWR   float     774.39393 ; pulse peak power
;   AVGPWR  float      18.471981; average power
;   DUTYCYC float       0.0280376; duty cycle (as a fraction).
;
;Notes:
; - Ladybug is the company that makes the hardware softare.
; - there is no date info other than the seconds from midnite timestamp.
;   I've made it double since they print out to usecs (although it probably isn't
;   accurate to that resolution.
; - I've left out the crest factor included in the ladybug software since it
;   is just avgpwr/peakpwr. 
;-
function pm430inpfile,file,d
;
;   input file as ascii
;
	nlines=readasciifile(file,inp)
	if nlines lt 0 then return,-1
;
;   ascii split on 
;
	tabM=string(9b) + "+"
	tok=tabM + "([0-9.]*)"
;             time     pulPwr  pkPwr avgpwr crestF  dutyCycl
	regex="([0-9.:]*)" + tok  + tok + tok  + tok   + tok
	a=stregex(inp,regex, /extract,/subexpr)
	n=n_elements(a[0,*])
	ii=where(a[0,*] ne '',cnt)
	if cnt lt n then begin &$
		if cnt eq 0 then return,0
		a=a[*,ii] &$
		n=cnt &$
	endif
;
	astr={  sec:0d ,$
		 pulpwr:0. ,$ ; pulse power
		 pkpwr:0. ,$  ; peak power
		 avgpwr:0. ,$ ; average power
	    dutycyc:0.} ; duty cycle as fraction.

	d=replicate(astr,n)
	d.pulPwr =double(reform(a[2,*]))
	d.pkPwr  =double(reform(a[3,*]))
	d.avgPwr =double(reform(a[4,*]))
	d.dutycyc=float(reform(a[6,*]))*.01
;             hh       mm         ss         
	regex="([0-9][0-9]):([0-9][0-9]):([0-9.]+)"
	aa=stregex(reform(a[1,*]),regex,/extract,/subexpr)
	d.sec=double(reform(aa[1,*]))*3600d + double(reform(aa[2,*]))*60d + double(reform(aa[3,*]))
	return,n
end
