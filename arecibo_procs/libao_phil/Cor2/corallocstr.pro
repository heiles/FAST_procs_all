;+
;NAME:
;corallocstr - allocate an array of structures. 
;SYNTAX:    barr=corstostr(b,len)
;ARGS:      b:  {corget} structure to duplicate
;         len:  long  length of the array to allocate
;RETURNS:
;     barr[n]:  {corget} array of structures to return.
;DESCRIPTION:
;   Use corallocstr to allocate an array of {corget} structures. This routine
;is necessary since each corget structure returned is an anonymous structure;
;-
function    corallocstr,b,len
    on_error,2
    return,replicate(b,len)
end
