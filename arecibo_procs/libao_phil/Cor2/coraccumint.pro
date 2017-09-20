; 
;NAME:
;coraccumint - accumulate a record in a summary rec
;SYNTAX: coraccumint(brec,baccum,new=new,scl=scl)
;ARGS:   bnew  : {corget} input data
;        baccum: {corget} accumulate data here
;KEYWORDS:
;       new    : if keyword set then this is the first call, alloc baccum.
;       scl    : float if provided, then scale the brec data by scl before
;                      adding. This can be used to weight data by g/t.
;DESCRIPTION:
;  Accumulate a records worth of data in baccum. If keyword /new set then
;copy brec into baccum. This will be the header for the accumulated data.
;Example:
;   print,corget(lun,b)
;   print,coraccumint(b,baccum,/new)
;   print,corget(lun,b)
;   print,coraccumint(b,baccum)
;   ...
;   to plot the dat out you need to normalize the data to the number
;   of records accumulated.
;
pro coraccumint,b,baccum,new=new,scl=scl
;
    on_error,1
    message,'02may02,coraccumint has been replaced by coraccum().
    return
end
