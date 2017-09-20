function grabfits, inpath, infile, b=b, hdr=hdr, silent=silent

;+
;GRABFITS.PRO: read a mock-style fits file and add some corrections
;CALLING SEQUENCE:
;       GRABFITS, inpath, infile, b=b, hdr=hdr, silent=silent
;
;INPUTS
;INPATH, INFILE: specify the fits file to read

;KEYWORDS:
;B=B
;HDR=HDR
;SILENT=SILENT
;
;RETURNS:
;ISTAT[2], indicates success:
;       istat[0] is 0 if the file couldn't be opened
;       istat[1] is 0 if the file couldn't be read
;-

forward_function masopen, masgetfile, masfreq

;OPEN, READ, AND CLOSE THE DATA FILE...
istatopen= masopen(inpath + infile, desc)
istatgetfile= masgetfile(desc,b,filename=inpath+infile, tp=tp, hdr=hdr)
masclose, desc, /all
nrb= n_elements( b)
if keyword_set( silent) eq 0 then $
   print, 'grabbed source ', b[0].h.object + '  ' + string(b[0].h.crval1/1.d6)
istat= [istatopen, istatgetfile]

;INTERPOLATE OVER CNTR CHNL...
b.d[4096,*]= 0.5*( b.d[4095,*] + b.d[4097,*])

;;PARALLACTIC ANGLE:
;para_ang_phil= b.h.para_ang
;COMPUTE PARALLACTIC ANGLEL AND STICK IT IN THE B STRUCTURE...
obslat = ten(18,21,14.2)
ha= b.h.lst/3600.d0- b.h.req_raj/15.d0
b.h.para_ang= parangle( ha, b.h.req_decj, obslat)

;the cross products need a factor of 2...
b.d[*,2,*]= 2.*b.d[*,2,*]
b.d[*,3,*]= 2.*b.d[*,3,*]

return, istat

end

