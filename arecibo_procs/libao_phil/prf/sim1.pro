;
; simulate pitch,roll correction by just rotating the dome
; try shifting entire roll by + .118 deg 
; and pitch by -.1 degrees.
; @prfinit,@tdinit
; .compile sim.cmp
;
forward_function prfkposcmp
hard=1
prfit2dio,prf2d
mkazzagrid,az,za,zastart=2.,zastep=1.
nptsaz=(size(az))[1]
nptsza=(size(az))[2]
npts  =nptsaz*nptsza
az=reform(az,npts)
za=reform(za,npts)
temp=fltarr(npts)
;
; current at 72 degrees...
;
temp1=temp+72.
prfk1=prfkposcmp(az,za,temp1,prf2d)
;
; 	set average pitch above 11 degrees to +/-.04
;

pitchcor=-.1
pitchcor=-.06
pitchcor=-.04
rollCor=.12
pitch=prfk1.pitch + pitchcor
roll=prfk1.roll + rollcor
prfk2=prfkposcmp(az,za+.08,temp1,prf2d,pitch=pitch,roll=roll)
;
prfkT=replicate({prfk},6840,4)
j=0
for i=60,90,10 do begin &$
	temp1=temp+i &$
	zap2=za - .2 + .1*j &$
	prfk=prfkposcmp(az,zap2,temp1,prf2d,roll=prfk2.roll,pitch=prfk2.pitch) &$
	prfkt[*,j]=prfk &$
	j=j+1 &$
endfor
;
; do total tension at 60,90 degrees..
;
if hard then pscol,'prfsim1.ps', /full
prfkplot1,prfk1,prfk2,prfkT,pitchcor,rollCor
if hard then hardcopy
x
end
