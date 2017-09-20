;.............................................................................
pro tsscl,d,flrpitch=flrpitch,flrroll=flrroll
;
; d[] {ts}
; optional keywords:
; flrroll  - tilt sensor roll angel (ccw pos..= -lynn baker)
; flrpitch - tilt sensor roll angel (ccw pos..= -lynn baker)
;
; scale the tilt sensor data
;;for roll: divide / 5, remove floor angle,* -1 --> pos cw(lynnbaker convention)
; for roll: divide / 5, remove floor angle,  pos cw(lynnbaker convention)
; for pitch; sin correct (from tilt sensor documentation).
;            + is up.
;
; history:
;  floor angles:
;  after 31jan00  roll:.1231, tilt:.6152
; 07apr00 - roll floor angle now same as lynns  -.1231 +cw
; 08apr00 - need to also interpolate aznomod
; 02feb03 - flrroll,flrpitch, change from n_elements() to keyword_set. This
;           way the routine can pass back the value used.
;
	if keyword_set(flrroll)  eq 0 then flrroll=-.1231
	if keyword_set(flrpitch) eq 0 then flrpitch=.6152
;;    d.r=-(temporary(d.r)/5 - flrroll)
      d.r=-(temporary(d.r)/5) - flrroll
    d.p= -asin((temporary(d.p) -.0159)/19.9833)*!RADEG - flrpitch
;
; interpolate the azimuth, za.. use the az,za at timestamps
; .2 since the scramnet memory has been updated by then
;
;
;   we want to interpolate the az,za since we get 5 values
;   that are the same.
;
;   0 .2 .4 .6 .8  .... 1
;  unfortunately scramnet doesnot get updated until .2 seconds
;  so use the az,za values at .2 seconds as the true value at 0
;  then;
;  1.  get the indices for .2 secs
;  2.  create an array of az,za at the .2 secs
;  3.  interpolate this array to one 5 times larger that has the
;      intepolated points
;  4.  place this array into dat.az,za starting at the first n.0 position
;
;   get fraction of sec
;
    tmp=d.sec mod 1.
;
;    get the indices for the .2 sec frac
;
    i=where( (tmp gt .15) and (tmp lt .25))
;
;   number of elements we will end up with
;
    tmp=0
    n=n_elements(i)
    x=findgen(n)
    n=n*5
    u=findgen(n)*.2
;
;   get the az,za at 1 second steps
;
;   interpolate to .2 secs
;
    newaz=interpol(d[i].aznomod,x,u)
    newza=interpol(d[i].za,x,u)
;
;
    if i[0] eq 0 then  begin
        indget=5
        indput=4
    endif else begin
        indget=0
        indput=i[0]-1
    endelse
    npts= (n-indget) < (n_elements(d.aznomod)-indput)
    indput2=npts+indput-1
    indget2=npts+indget-1
    d[indput:indput2].aznomod=newaz[indget:indget2]
    d[indput:indput2].az=d[indput:indput2].aznomod
    d[indput:indput2].za=newza[indget:indget2]
    return
end
