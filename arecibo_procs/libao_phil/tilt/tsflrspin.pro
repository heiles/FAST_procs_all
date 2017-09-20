;+
; tsflrspin - compute the sensor floor angle from a floor spin
; 
; SYNTAX:
; tsflrspin,ts,pflrused,rflrused,timestart,pflrNew,rflrNew,indAr,tmstep=tmstep
; ARGS:
;     ts[]       {ts} hold data read in via tsnext()
;     plflrused  float. pitch floor angle used on call to tnsnext
;     rlflrused  float. roll floor angle used on call to tnsnext
;     timestart  float secMidnite that tsflrspin report for start at 75 deg
;
; RETURNS:
;	  pflrNew	float .. computed offset in pitch
;	  rflrNew	float .. computed offset in roll
;		indar    long[4  return the indices in 
;			   ts used for start,stop,start,stop.. pass this to flag 
; 			   to check that the positions were ok
; KEYWORDS:
;	   tmstep:  float  seconds between move to use. If not
;				supplied, use default. 
;
; DESCRIPTION
;     Compute the offset angle of the tilt sensor on the rotary floor
;  from the data taken during the routine tsflrspin. Use tsnext to
;  input the data. Pass in the data read: ts and the floor angles
;  that tsnext used (specify it on the call the tsnext) and the
;  seconds from midnight that tsflrspin reports when it starts at 75 degrees 
;
;  if floor is at angle th at 75 degrees and the tilt sensor has angle 
;  relative to the floor of flr, and we subtract flrUsed in tsnext then
;  when we sum the two positions we get:
;  
;  M=  (th +flr - flrUsed) + (-th + flr - flrUsed)
;  M=  2*(flr - flrUsedk
;  flr= M/2. + flrUsed   .. gives the true floor offset
;-
pro tsflrspin,ts,pflrused,rflrused,timestart,pflrNew,rflrNew,indar,tmstep=tmstep
;
;	time offsets: arrive at 255, 165,75
;
	if n_elements(tmstep) eq 0 then tmstep=143
	tmSt=tmstep*5
	tmSt=tmSt+100
	i=where(abs(ts.sec - timestart) lt .1)
	i=i[0]
	pst =[i+100,i+ tmst[0]]
	pend=pst+399
	pflrNew= total(ts[pst[0]:pend[0]].p + ts[pst[1]:pend[1]].p)/800. +pflrused
	rflrNew= total(ts[pst[0]:pend[0]].r + ts[pst[1]:pend[1]].r)/800. +rflrused
	indar=fltarr(4)
	indar=[pst[0],pend[0],pst[1],pend[1]]
	return
end
