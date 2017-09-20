; @mcalinit before running
; example of inputing the sky,absorber data
;
; variables :
; dabs[] {meascal} data while on absorber
; dsky[] {meascal} data while on sky
; numsteps int     number of 100 Mhz steps to cover the band
;
; ufrq[] float	   frequencies each 25 Mhz covering the data.numsteps*4
; nfrq   int       number of frequencies
; calAbs[2,*]      cal value on absorber
; calSky[2,*]      cal value on sky
; calRatio[2,*]    cal from ratio
;
; user modifies
;
Tabs =302		; 85 F
Trcvr=12		;K
Tscattered=14	;
Tsky      =5
recsSCan=10
scanabs=202800160L
scansky=202800232L
numloopsAbs=9
numloopsSky=21
filename='/share/olcor/corfile.28jan02.x101.1'
;-------------------------------------------------------------------------- -
;no changes below here
;
onabs=1
onsky=2
numsteps=4
numSbcTot=numsteps*4
totRecs=numsteps*2L*recsScan*(numloopsAbs + numloopsSky)
;
; get data .. *2 since repeated each set of 3 loops twice
;
;free_lun,lun
openr,lun,filename,/get_lun
rew,lun
dabs  =replicate({meascal},numsteps*numloopsAbs*4)
dsky  =replicate({meascal},numsteps*numloopsSky*4)
;
; input the data
;
dabs  =mcalinp(lun,onabs,numsteps,numloopsAbs,scan=scanabs)
dsky  =mcalinp(lun,onsky,numsteps,numloopsSky,scan=scansky)
;
; 	get all the spectra for some diagnostics
;
rew,lun
print,corgetm(lun,totRecs,bar,/han)
free_lun,lun
;
; fix the indices for brd
;
ufrq=dabs[uniq(dabs.freq,sort(dabs.freq))].freq
nfrq=n_elements(ufrq)

	calAbs  =dabs.tpCal
	calSky  =dsky.tpCal
	calRatio=(Tsky+Tscattered-Tabs)*(calAbs*calSky)/(calAbs-calSky)
end
