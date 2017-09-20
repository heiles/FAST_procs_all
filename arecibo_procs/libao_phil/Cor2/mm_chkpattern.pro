;+
;NAME:
;mm_chkpattern - check if a mueller pattern is complete
;SYNTAX: stat=mm_chkpattern(scan,sl)
;ARGS:
;   scan    : long  scan number for cal on at start of pattern
;   sl[]    : {getsl} scan list array
;RETURNS:
;   istat   : long  >=0  pointer into sl array where pattern starts.
;                   <0   not a complete pattern
;                   -1   scan not in file
;                   -2   pattern not complete , hit eof
;                   -3   not a complete pattern, wrong rec types
;                   -4   not a complete pattern, wrong rec nums
;DESCRIPTION:
;   Check that a mueller pattern is complete. You must first input a 
;scanlist array for the file. The program will check for the correct record 
;types and number of records. If the pattern is complete then the routine 
;will return the index into the sl array that points to the scan that starts
;the pattern. If is not complete then istat will be less than zero.
;
;EXAMPLES:
;   file='/proj/a1489/calfile.17may01.a1489.1'
;   openr,lun,file,/get_lun
;;
;;  scan then entire file, then search for scan 113700159L 
;;  if it's ok, read all the records in  
;;
;   sl=getsl(lun)
;   scan=113700159L 
;   istat=mm_chkpattern(scan,sl)
;   if istat ge 0 then istat=corgetm(lun,242,bb,scan=scan,sl=sl)
;   free_lun,lun
;
;; scan only the 6 records about the requested scan (this will 
;;  go faster if you only are interested in a single pattern)
;;  if it's ok, read all the records in  
;   sl=getsl(lun,scan=scan,maxscans=6)
;   if istat ge 0 then istat=corgetm(lun,242,bb,scan=scan,sl=sl)
;SEE ALSO:
;   mm_findpattern
;-
function mm_chkpattern,scan,sl

    on_error,1
    ntot=n_elements(sl)
    i=where(sl.scan eq scan,count)
    i=i[0]
    if count lt 1 then                      return,-1 ; scan not in file
;
    if (i+5) ge ntot  then               return,-2 ; pattern not yet complete
    if total(sl[i:i+5].rectype ne [1,2,0,0,0,0]) ne 0 then return,-3
    if total(sl[i:i+5].numrecs ne [1,1,60,60,60,60]) ne 0 then return,-4
    return,i
;
end
