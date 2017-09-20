;+
;NAME:
;coravgint - average multiple integrations.
;SYNTAX: bavg=coravgint(bin)
;ARGS:   bin[] : {corget} input data
;RETURNS:bavg  : {corget} averaged data
;DESCRIPTION:
;  If you have input an entire scans worth of data (eg corinpscan), you can
;use coravgint to compute the average of all of the records of the scan. It 
;returns a {corget} structure that is the average of the N records input.
;The header returned will be from the first record of the data (bin[0]). 
;Example:
;   assume scan 32500029 has 300 1 second integrations. Then:
;   print,corinpscan(lun,bin,scan=32500029L)
;   bavg=coravgint(bin)
;   bavg will then contain the average of the 300 records.
;NOTES:
;   Many routines will do the averaging for you automatically if you request
;it (eg corinpscan,coronoffpos,..)
;SEE ALSO:
;   cormedian - to compute the median rather than the average of a scan.
;-
function coravgint,bin
;
    on_error,2
    numin=(size(bin))[1]
    scl=1./numin
    bavg=bin[0]
    numbrds=bavg.b1.h.cor.numbrdsused
    for j=0,numbrds-1 do begin
        avgdim=(size(bin.(j).d))[0]
        bavg.(j).d=total(bin.(j).d,avgdim)*scl
    endfor
    return,bavg
end
