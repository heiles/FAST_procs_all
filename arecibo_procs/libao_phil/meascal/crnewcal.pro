;
; compute new cal values for the "other cals"
;
; order in file:
;frq nd1PaH nd1PaL nd1PbH Nd1PbL nd2PaH nd2PaL nd2PbH nd2PbL
file='calcbratio.dat'
openr,lun,file,/get_lun
maxnum=100
frqr  =fltarr(maxnum)
rdat=fltarr(8,maxnum)
ldat=fltarr(8)
j=0
line=' '
f=0.
on_ioerror,done
for i=0,maxnum-1 do begin &$
	readf,lun,line &$
	if strmid(line,0,1) ne ';' then begin &$
		reads,line,f,ldat &$
		frqr[j]=f &$
		rdat[*,j]=ldat &$
	    j=j+1 &$
	endif &$
endfor
done:
	rdat=rdat[*,0:j-1]
	frqr=frqr[0:j-1]
	free_lun,lun
;
; 	get cal data with hcorcal
;
date=[2000,346]
caltype=1			; high cor cal
rcvnum=9
;
; this assumes that the hcorcal values have been already updated in the
; file.
print,calinpdata(rcvnum,caltype,calData,date=date)
for i=0,calData.numfreq-1 do begin
	ind=where(abs(caldata.freq[i]-frqr) lt .1,count)
	data=fltarr(8)
	if count eq 1 then  begin
		data[0:1]=rdat[0:1,ind]*caldata.cala[i]
		data[4:5]=rdat[4:5,ind]*caldata.cala[i]
		data[2:3]=rdat[2:3,ind]*caldata.calB[i]
		data[6:7]=rdat[6:7,ind]*caldata.calB[i]
	endif
	if data[0] eq 0 then begin
	   data[0]=caldata.cala[i]
	   data[2]=caldata.calb[i]
	endif
	lab=string(format='(i4,8f8.3)',long(caldata.freq[i]),data)
	print,lab
endfor
ind=lindgen(19)  
j=0
print,reform(rdat[j,ind],19)*caldata.cala[ind+1]
print,reform(rdat[j,ind],19)*caldata.calb[ind+1]
end
