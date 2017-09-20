

year=1999
if n_elements(r1) ne 0 then begin &$
	rr=r1 &$
	r={rcvnum :rr.rcvnum,$ &$
	   numrecs:rr.numrecs,$ &$
	   year   :year,$ &$
	   calAvail:rr.calAvail,$ &$
	   r       :rr.r } &$
	r1=r &$
endif

if n_elements(r2) ne 0 then begin &$
	rr=r2 &$
	r={rcvnum :rr.rcvnum,$ &$
	   numrecs:rr.numrecs,$ &$
	   year   :year,$ &$
	   calAvail:rr.calAvail,$ &$
	   r       :rr.r } &$
	r2=r &$
endif

if n_elements(r3) ne 0 then begin &$
	rr=r3 &$
	r={rcvnum :rr.rcvnum,$ &$
	   numrecs:rr.numrecs,$ &$
	   year   :year,$ &$
	   calAvail:rr.calAvail,$ &$
	   r       :rr.r } &$
	r3=r &$
endif

if n_elements(r5) ne 0 then begin &$
	rr=r5 &$
	r={rcvnum :rr.rcvnum,$ &$
	   numrecs:rr.numrecs,$ &$
	   year   :year,$ &$
	   calAvail:rr.calAvail,$ &$
	   r       :rr.r } &$
	r5=r &$
endif

if n_elements(r6) ne 0 then begin &$
	rr=r6 &$
	r={rcvnum :rr.rcvnum,$ &$
	   numrecs:rr.numrecs,$ &$
	   year   :year,$ &$
	   calAvail:rr.calAvail,$ &$
	   r       :rr.r } &$
	r6=r &$
endif

if n_elements(r7) ne 0 then begin &$
	rr=r7 &$
	r={rcvnum :rr.rcvnum,$ &$
	   numrecs:rr.numrecs,$ &$
	   year   :year,$ &$
	   calAvail:rr.calAvail,$ &$
	   r       :rr.r } &$
	r7=r &$
endif

if n_elements(r8) ne 0 then begin &$
	rr=r8 &$
	r={rcvnum :rr.rcvnum,$ &$
	   numrecs:rr.numrecs,$ &$
	   year   :year,$ &$
	   calAvail:rr.calAvail,$ &$
	   r       :rr.r } &$
	r8=r &$
endif

if n_elements(r9) ne 0 then begin &$
	rr=r9 &$
	r={rcvnum :rr.rcvnum,$ &$
	   numrecs:rr.numrecs,$ &$
	   year   :year,$ &$
	   calAvail:rr.calAvail,$ &$
	   r       :rr.r } &$
	r9=r &$
endif

if n_elements(r11) ne 0 then begin &$
	rr=r11 &$
	r={rcvnum :rr.rcvnum,$ &$
	   numrecs:rr.numrecs,$ &$
	   year   :year,$ &$
	   calAvail:rr.calAvail,$ &$
	   r       :rr.r } &$
	r11=r &$
endif

if n_elements(r12) ne 0 then begin &$
	rr=r12 &$
	r={rcvnum :rr.rcvnum,$ &$
	   numrecs:rr.numrecs,$ &$
	   year   :year,$ &$
	   calAvail:rr.calAvail,$ &$
	   r       :rr.r } &$
	r12=r &$
endif
;
save,r12,r2,r3,r5,r6,r7,r9,year,yearname,$
   file='/share/obs4/rcvm/1999/idlyear.sav'
end
