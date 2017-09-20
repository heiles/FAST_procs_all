;+
;NAME:
;mmget - extract a subset of mueller array by key
;SYNTAX: mnew=mmget(mm,count,freq=freq,rcvnum=rcvnum,rcvnam=rcvnam,brd=brd,$
;                   src=src)
;ARGS: 
;       mm[]    :{mueller} array of mueller structs read in via mmrestore
;                          (or a subset of any of these)
;KEYWORDS:
;       freq    : float .. freq in Mhz to extract
;       rcvnum  : long  .. receiver number to extract:
;                       1=327,2=430,3=610,5=lbw,6=lbn,7=sbw,9=cb,12=sbn
;                       100=430ch
;       brd     : long  correllator board number to return 0-3
;       src     : string source name to return
;       rcvnam  : string rcvname to get:327,430,610,lbw,lbn,sbn,sbc,cband,430ch
;RETURNS:
;   mmnew[count]: {mueller} subset meeting the requested critiera
;   count       : long      number of patterns found
;DESCRIPTION:
;   The x102 calibration data can be input via mmrestore. It will input
;arrays of {mueller} structures containing reduces data for all the receivers
;and an individual array for each receiver:
;eg: mm[]   holds all the data
;    mm12[] holds only the rcvnumber 12: sbn data.
;
;You can display the structure format with:
; help,mm,/st and
; help,mm.fit,/st   total power fit info
; help,mm.fitq,/st   q fit info
; help,mm.fitu,/st   u fit info
; help,mm.fitv,/st   v fit info
;
;mmget allows you to select a subset of one of these arrays. It uses
;the specified keyword to determine what to return. It uses the
;first keyword found.
;EXAMPLES
;   return all of the brd 0 data from lbw
; aa5=mmget(mm5,count,brd=0)
;
;   return the source B0106+130 for cband data
; aa9=mmget(mm9,count,src='B0106+130')
;
;   return all the board 1 data for the above cband source.
;
; aa9b0=mmget(aa9,count,brd=0)
;
;NOTES:
;   beware that you donot accidentally wipe out the input array
;by using that name as the output..
;   eg: mm5=mmget(mm5,brd=0) changes mm5 to only have the brd 0 data.
;-
function mmget,mm,count,brd=brd,freq=freq,src=src,rcvnum=rcvnum,rcvnam=rcvnam
;
    on_error,1
    count=0
    if n_elements(brd) ne 0 then begin
        ind=where(mm.brd eq brd,count)
        if count gt 0 then return,mm[ind]
    endif
    if n_elements(freq) ne 0 then begin
        ind=where(mm.cfr eq freq,count)
        if count gt 0 then return,mm[ind]
    endif
    if n_elements(src) ne 0 then begin
        ind=where(mm.srcname eq src,count)
        if count gt 0 then return,mm[ind]
    endif
    if n_elements(rcvnum) ne 0 then begin
        ind=where(mm.rcvnum eq rcvnum,count)
        if count gt 0 then return,mm[ind]
    endif
    if n_elements(rcvnam) ne 0 then begin
        ind=where(mm.rcvnam eq rcvnam,count)
        if count gt 0 then return,mm[ind]
    endif
    message,'no data found'
end
