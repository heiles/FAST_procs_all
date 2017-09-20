;
; do calibrate offline
;
srcname='B0518+165'
file='calfile.31oct01.a1522.1'
pathin='/share/olcor/'
path='./'
scan=130400046L
openr,lun,pathin+file,/get_lun
print,posscan(lun,scan,1)
print,corget(lun,b)
;for brd=0,3 do begin
brd=0
	board=brd
	sourceflux=fluxsrc(string(b.b1.h.proc.srcname),corhcfrtop(b.(brd).h))
@testgodunc.idl
;endfor
