;
; simulate various things
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
pitchcon=.04
pitchp=reform(prfk1.pitch,nptsaz,nptsza)
pitchn=pitchp
za   =reform(za,nptsaz,nptsza)
ind=where( (abs(za[0,*] - 11.) lt .1))
ind11=ind[0]
for i=ind11,nptsza-1 do begin
	a=rms(pitchp[*,i],/quiet)
	pitchp[*,i]=pitchp[*,i] - a[0] + pitchCon
	pitchn[*,i]=pitchn[*,i] - a[0] - pitchCon
endfor
;
pitchp=reform(pitchp,npts)
pitchn=reform(pitchn,npts)
za   =reform(za,npts)
zap1p=za+.08
zap1n=za-.08
prfk2p=prfkposcmp(az,zap1p,temp1,prf2d,pitch=pitchp)
prfk2n=prfkposcmp(az,zap1n,temp1,prf2d,pitch=pitchn)
;
; now correct mean roll  to +/- .02 deg. for all 4 combinantions
; use only za 2 through 19 degrees for mean..
;
; pr    pos, neg
roll =reform(prfk1.roll,nptsaz,nptsza)
rollp=roll- mean(roll[*,0:17]) + .02
rolln=roll- mean(roll[*,0:17]) - .02
rollp=reform(rollp,npts)
rolln=reform(rolln,npts)
zapp=za+.08
zapn=za+2*.08
zanp=za-.08
zann=za-2*.08
prfk3pp=prfkposcmp(az,zapp,temp1,prf2d,roll=rollp,pitch=pitchp)
prfk3nn=prfkposcmp(az,zann,temp1,prf2d,roll=rolln,pitch=pitchn)
prfk3pn=prfkposcmp(az,zapn,temp1,prf2d,roll=rolln,pitch=pitchp)
prfk3np=prfkposcmp(az,zanp,temp1,prf2d,roll=rollp,pitch=pitchn)
;
; now correct mean roll for 60,80,90 degrees...
;
prfkT=replicate({prfk},6840,4)
j=0
for i=60,90,10 do begin &$
	temp1=temp+i &$
	zap2=za - .2 + .1*j &$
	prfk=prfkposcmp(az,zap2,temp1,prf2d,roll=rolln,pitch=pitchp) &$
	prfkt[*,j]=prfk &$
	j=j+1 &$
endfor
;
; do total tension at 60,90 degrees..
;
if hard then pscol,'prfsim.ps', /full
prfkplot,prfk1,prfk2p,prfk2n,prfk3pp,prfk3pn,prfk3nn,prfk3np,prfkT
if hard then hardcopy
x
end
