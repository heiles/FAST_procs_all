;+
;NAME:
;corpwrfile - input the power information from the entire file.
;SYNTAX: nrecs=corpwrfile(filename,pwra,maxrecs=maxrec)
;
;ARGS 
;   filename:  string.. filename to read from.  
;KEYWORDS  
;   maxrecs : long  max number of recs to read in. def:20000 
;
;RETURNS 
;   pwra  - returns an array pwra[nrecs]  of {corpwr} struct
;   nrecs - number of recs found, 0 if at eof, -1 if hdr alignment/io error
;
;DESCRIPTION:
;   This routine opens the file, calls corpwr() and then closes the
;file. See corpwr() for a description of the power structure.
;You only need to use the maxrecs keyword if the file has more than 
;20,000 records.
;-
;history:
;31jun00 - updated to new form corget
function corpwrfile,filename,pwra,maxrecs=maxrecs
    forward_function corgethdr
    on_ioerror,errout
    if not keyword_set(maxrecs) then  maxrecs=20000L
    lun=-1
    nrecs=0
    openr,lun,filename,/get_lun
    nrecs=corpwr(lun,maxrecs,pwra)
    if lun gt 0 then free_lun,lun
    return,nrecs
errout:
    print,'err:',!err_string.msg,' opening:',filename
    return,-1
end
