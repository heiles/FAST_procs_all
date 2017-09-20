;+
;name 
; mmprocsav - process the mueller save files
;-
pro mmprocsav,mm,outfile
;
;;	mm=mmtostrall(filename)
;
	numpat=n_elements(mm)
;
; 	sort by rcv num
;
	ind=sort(mm.rcvnum)
	mm=mm[ind]
;
; 	get start,end index for each receiver in mm
;
	ind=where( (mm.rcvnum)-shift(mm.rcvnum,1) ne 0,count)
	if count le 0 then begin
		numrcv=1
		ind=[0]
	endif else begin
		numrcv=(size(ind))[1]
	endelse
;
; 	start , end ind each rcv
;
	mmrcvind=replicate({mmrcvind},numrcv)
	for i=0,numrcv-1 do begin &$
		mmrcvind[i].rcvnum=mm[ind[i]].rcvnum &$
		mmrcvind[i].startind=ind[i]		; start index &$
		if i eq numrcv-1 then begin &$
			mmrcvind[i].endind=numpat-1 &$
		endif else begin &$
			mmrcvind[i].endind=ind[i+1]-1 &$
		endelse &$
	endfor
;
; 	now sort each receiver by source and freq
;
	for i=0,numrcv-1 do begin
		temp=mm[mmrcvind[i].startind:mmrcvind[i].endind]
		temp=temp[sort(temp.srcname)]
		mm[mmrcvind[i].startind:mmrcvind[i].endind]=temp
	endfor
;
;	 now generate an array of structures for each receiver..
;    name is mmN  where N is the reiver number
;
	savelist=''
	for i=0,numrcv - 1 do begin
		case 1 of
			mmrcvind[i].rcvnum ge 100: begin
				rcvnm=string(format='("mm",i3)',mmrcvind[i].rcvnum)
				end
			mmrcvind[i].rcvnum ge 10: begin
				rcvnm=string(format='("mm",i2)',mmrcvind[i].rcvnum) 
				end
			else: begin
				rcvnm=string(format='("mm",i1)',mmrcvind[i].rcvnum) 
				end
		endcase
		savelist=savelist + rcvnm + ' ,'
		cmdstr=string(format='(a,"=mm[",i,":",i,"]")',$
			rcvnm,mmrcvind[i].startind,mmrcvind[i].endind)
;;	 	print,cmdstr
		ok=execute(cmdstr)
	endfor
	mmsrcnames=mm[uniq(mm.srcname,sort(mm.srcname))].srcname
	savelist=savelist + 'mmrcvind' + ', mmsrcnames'
	cmdstr='save,mm,' + savelist  + ",filename='" + outfile + "'"
;;	print,cmdstr
;;	print,outfile
	ok=execute(cmdstr)
;	print,savelist
;	print,mmsrcnames
	return
end
