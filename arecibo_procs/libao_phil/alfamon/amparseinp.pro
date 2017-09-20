;+
;NAME:
;amparseinp - parse the alfa mon input rec to a struct
;SYNTAX: dat=amparseinp(inpline)
;ARGS;
;inpline: string	ascii line of data read from file
;RETURNS:
;dat:{alfamon}   struct containing the data
;
function amparseinp,inpl
;
	val=strsplit(inpl,',',/extract)
;
;	define struct to hold data
;
	a={alfaMon}
;	now fill in the struct
;   i points into the val[] array.
;
	i=0l
	a.tma=val[i++]			; time:yyyymmddhhmmss
	a.locRem=val[i++]     ; [alfa status] bit 7 Local/remote 1/0
	a.bias_stat=val[i:i+14-1]
	i+=14
	; data[pol,bm,[vD,Id,Vg],[stage1,2,3]]
	dat=reform(float(val[i:i+(2L*7*3*3)-1]),2,7,3,3)
	a.vd=dat[*,*,0,*]
	a.id=dat[*,*,1,*]
	a.vg=dat[*,*,2,*]
	i+=2*7*3*3
	a.t20=val[i:i+3]
	i+=4
	a.t70=val[i:i+3]
	i+=4
	d=float(val[i:i+16-1])
	a.V32P=d[0]
	a.V20P=d[1]
	a.V20N=d[2]
	a.V9P =d[3]
	kk=[0,4,6,8,9,11]
	a.V15P=d[4+kk]
	kk=[1,5,7,10]
	a.V15N=d[4+kk]
	a.V5p =d[6:7]
	i+=16
;     address 5
	a.calCtl=val[i++]   ; noise_ctl alfa_status bits 0,1
;                         1=0n,2=off,3=active ttl bit drives
	a.nseLev=val[i++]   ; calLev h/l 1/0 alfastatus b5
    a.nseDiodeT=float(val[i++]);
	a.vacStat=val[i++]  ; vacMoniotr on/off 1/0 b4 alfa stat
	a.vacLev=float(val[i++])   ; 
;
; 	compute jd data from ascii time .. it is ast..
;
	yymmdd=long(strmid(a.tma,0,8))
	hhmmss=long(strmid(a.tma,8,8))
	a.jd=yymmddtojulday(yymmdd)
	frac=(60L*((hhmmss/100L mod 100L)+ 60L*(hhmmss /10000L))+hhmmss mod 100L)/$
		 86400.D
	a.jd=a.jd + frac +4./24d			; add on frac day and AO offset to UTC
	return,a
end
