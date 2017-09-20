;+
;NAME:
;wasfnamemk - make a fits filename.
;
;SYNTAX: istat=wasfnamemk(nmpars,filename)
;
;ARGS:
;  nmpars: {}        structure returned from wasfnamepars
;
; RETURNS: 
;   istat: int       1 - fits filename returned in filename
;                    0 - nmpars does not contain a valid filename
;
;DESCRIPTION:
;   Create a fits filename from the structure returned from wasfnamepars().
;   
;Example:
;   filename='/share/wappdata/wapp.20050807.a2004.0001.fits'
;   istat=wasfnamepars(filename,nmpars)
;
;;  change  the sequence number to 0.
;   nmpars.seqnum=0
;
;;  make the new filename
;
;   istat=wasfnamemk(nmpars,filename0)
;   print,filename0
;
;-
;
function  wasfnamemk,nmpars,filename
;
;  check that we have a valid structure.
;
    if (nmpars.wapp ne 'wapp') or (nmpars.fits ne 'fits') then return,0
    filename=string(format=$
    '(a,"wapp.",a,".",a,".",i4.4,".fits")',$
    nmpars.dir,nmpars.date,nmpars.projid,nmpars.seqnum)
    return,1
end
