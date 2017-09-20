pro mm9, inputfilename, a, beamout_arr

;+
;PURPOSE: calculate AND PRINT fractional stokes parameters of the source--one 
;per PATTERN.

;INPUT: the name of the mm0 file.
;-

indx=indgen( n_elements( a))

;DON'T DISCARD THE FOLLOWING!!!!
;fileout=path + 'mm9_' + inputfilename + 'print'
fileout= inputfilename + '.mm9print'

qsrc= beamout_arr.b2dfit[ 22,0]/ beamout_arr.b2dfit[ 2,0]
usrc= beamout_arr.b2dfit[ 32,0]/ beamout_arr.b2dfit[ 2,0]
vsrc= beamout_arr.b2dfit[ 42,0]/ beamout_arr.b2dfit[ 2,0]

sigqsrc= beamout_arr.b2dfit[ 22,1]/ beamout_arr.b2dfit[ 2,0]
sigusrc= beamout_arr.b2dfit[ 32,1]/ beamout_arr.b2dfit[ 2,0]
sigvsrc= beamout_arr.b2dfit[ 42,1]/ beamout_arr.b2dfit[ 2,0]

polsrc= sqrt( qsrc^2+ usrc^2)
pasrc= modanglem(!radeg* 0.5* atan( usrc, qsrc))

sigpolsrc_sq= ( qsrc^2* sigqsrc^2+ usrc^2* sigusrc^2)/ (qsrc^2+ usrc^2)

sig2pasrc_sq= ( qsrc^2* sigusrc^2+ usrc^2* sigqsrc^2)/ ((qsrc^2+ usrc^2)^2)

sigpolsrc= sqrt( sigpolsrc_sq)

sigpasrc= !radeg* 0.5* sqrt( sig2pasrc_sq)

sh= indx[0]

;for nrfile= -1,1,2 do begin
;if (nrfile eq 1) then begin
;close, nrfile
;openw, nrfile, fileout
;endif

nrfile= -1

printf, nrfile, 'printed output saved to ', fileout
PRINTf, nrfile,  ' '
printf, nrfile,  $
' NR  RX        SRC      FRQ  Daz" Dza" TSRC  QSRC%    DQ   USRC%    DU   PSRC%    DP   PASRC   DPA    AZ    ZA  VSRC%   DV'

FOR NR=0, N_ELEMENTS( A)-1 DO BEGIN
printf, nrfile, nr, a[ sh].rcvnam, a[ sh].srcname, trim(a[ sh].cfr), $
	fix(60.*beamout_arr[nr].b2dfit[ 3,0]), $
	fix(60.*beamout_arr[nr].b2dfit[ 4,0]), $
	beamout_arr[nr].b2dfit[2,0], $
	100*qsrc[ nr], 100*sigqsrc[ nr], 100*usrc[ nr], 100*sigusrc[ nr], $
	100*polsrc[ nr], 100*sigpolsrc[ nr], pasrc[ nr], sigpasrc[ nr], $
	trim( fix( beamout_arr[nr].azcntr[2])), trim( fix( beamout_arr[nr].ZAcntr[2])), $
	100*vsrc[ nr], 100*sigvsrc[ nr], $
format= '(i3, a4, x, a14, a6, 2i4, f7.1, 2f7.2, 2f7.2, 2f7.2, f7.1, f6.1, 2i6, x, 2f6.2)'
ENDFOR

;endfor
;close, 1

end

