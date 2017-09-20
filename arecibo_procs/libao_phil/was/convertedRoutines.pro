;+
;NAME:
;converted routines
;
; 03feb04
; ------------------------------------------------------------
;The corr routines listed below had to be modified to work with the
;interim correlator data and the wapp fits data:
;
;corcalonoff
;corget     
;corgethdr     
;corinpscan 
;corplot
;corpwr
;corstostr
;posscan
;
; ------------------------------------------------------------
;The routines below have not yet been modified to work with the 
;wapp  fits data:
;
;corhcfrrest
;corhcfrtop
;corhdnyquist
;corhstokes
;corloop
;cormon
;cormonall
;corlist        try waslist,desc instead..
;cormap    ..none of the mapping routines work yet..
;cornext
;coronl
;corstokes
;all of the mmxxx mueller routines
;pfcalib
;pfposonoff
;pfcorimgonoff
;
; ------------------------------------------------------------
;Any other routines not listed above will probably work (unless they
;are missing something in the header).
;
; ------------------------------------------------------------
; The routines listed below provide the functionality of the corxxxx
; routines using the was data. They are called  by the corresponding
; corxxx routine
;
; wasget     - called by corget
; waspos     - called by posscan() to position inside fits file
; wasftochdr - read fits header, convert to interim correlator header
; waspwr     - called by corpwr
; ------------------------------------------------------------
; The following are utility routines
;
;   wasalignrec - make sure that we are aligned on the start of an 
;                 integration in the fits file.
;   wascheck - check if we are processing fits file or an older
;              interim correlator datafile.
;   wasclose - close the fits file
;   washdr   - read a fits header into a fits structure.
;   waslist  - list a scan summary for each entry in the fits file.
;              This replaces corlist for now..
;   wasopen  - open a fits file 
; ------------------------------------------------------------
;HISTORY:
; 03feb03   - corposonoff(), corcalonoff(), corhgainget(),
;             corcalib() now work.
;-
