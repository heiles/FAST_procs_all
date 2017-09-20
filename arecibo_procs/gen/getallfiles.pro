pro getallfiles, filedir, source, board, tr0, forceonoff=forceonoff, $
                 infiles=infiles
;+
; NAME:  getallfiles
;
; PURPOSE:
; concatenate all filess for a given source files are of type
;       20450+2140_03jan09.a2332.3_bd1.sav  
;
; CALLING SEQUENCE:
; getallfiles, filedir, source, board, tr0
;
; INPUTS:
;fildir, the directory where the files reside
;source, the source name
;board, the board number
;
; OUTPUTS:
;tr, the concatenated tr structure
;
; KEYWORD:
;FORCEONOFF. if set, force the nr of on and off patterns in one day to be
;equal.
;
; MODIFICATION HISTORY:
;24apr2009 by ch
;24sep: forceonoff added.
;-

suffix= '*bd' + strtrim( string( board), 2) + '.sav'

infiles= file_search( filedir + source + suffix, count=nfiles)

;stop

if nfiles eq 0 then begin
   print, 'no files for this source! returning.'
   return
endif

out=file_info( infiles)
totalsize= total( out.size)

xd= double([1205 , 482, 3374])
yd= double([39786744ll , 15912320ll, 111398448ll])
polyfit, yd, xd, 1, coeffs, sigcoeffs, yfit
nrtr= round( coeffs[0] + coeffs[1]*totalsize) 
;stop

if (nrtr mod 241l gt 120l) then begin
   while (nrtr mod 241l) ne 0l do  nrtr= nrtr+ 1l
endif else while (nrtr mod 241l) ne 0l do  nrtr= nrtr- 1l

low= 0l
for nf=0, nfiles-1 do begin
   restore, infiles[nf]
   print, 'just read ' +  infiles[nf] + ' with nr spectra=  ' + strtrim(string(n_elements(tr)),2), n_elements(tr)/241.

;check for multiple of 241 spectra...
excess= (n_elements(tr) mod 241)
if excess ne 0 then begin
   tr= tr[ 0: n_elements( tr) - excess]
   print, 'trimming tr by ', excess
endif

;check that nr offs equals nr ons...
if keyword_set( forceonoff) then begin
npatt = n_elements( tr)/ 241l
if 2l*(npatt/2l) ne npatt then begin
stop, '********IN GETALLFILES TO CHECK PATTERN FILLUP...'
   tr= reform( tr, 241l, npatt)
   tradd= reform( tr[ *, npatt-2l], 241l)
   tr= reform( tr, 241l* npatt)
   tr= [tr, tradd]
   stop
endif
endif

   if nf eq 0 then tr0= replicate( tr[0], nrtr)
   tr0[ low: low+ n_elements( tr)-1l]= tr
      low=  low+ n_elements( tr)
;help, tr0
endfor

npatt = n_elements( tr0)/ 241l
tr0= reform( tr0, 241l, npatt)

;stop

end

