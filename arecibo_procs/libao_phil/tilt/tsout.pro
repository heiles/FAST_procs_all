;.............................................................................
pro tsout,lun,d,npnts
;
; output data to lun .. data will look like tsinp format
;  d[]  {ts}
;
;;  on_error,1
;
;   see how data in file
;
	npts=(size(d))[1]
	dout=fltarr(5,npts)
 	dout[0,*]=d.sec
 	dout[1,*]=d.p
 	dout[2,*]=d.r
 	dout[3,*]=d.aznomod
 	dout[4,*]=d.za
;
;   allocate array
;
    writeu,lun,dout
    return
end
