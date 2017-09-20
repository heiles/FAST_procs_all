;+
;NAME:
;select - select elements from an array
;SYNTAX: anew=select(a,startInd,stepIndex)
;ARGS:
;     a[]:       array to select elements from
;startInd:  long starting index in a to start selecting (0 based).
; stepInd:  long spacing between indices to select
;KEYWORDS:
;RETURNS:
; aNew[]:        subarray extacted from a.
;
;DESCRIPTION:
;   Starting at index startInd select points spaced stepInd from the array
;a. Return the subarray in anew.
;
;EXAMPLE:
;   a1=select(a,0,2)    .. select every other sample from a starting at first
;   a2=select(a,1,3)    .. select every third sample from a start as the 2nd
;-
function select,x,istart,istep

    on_error,2
    case n_params() of
        0 : message,"usage: select,array,startInd,step... startInd 0 based"  
        1 : begin 
                istart=0 
                istep=2 
            end
        2 : istep=2
     else :
    endcase
;
;   length of first dimension
;
    len=(size(x))[1]
    npts=(len -istart-1L) / istep + 1L
    return,x[lindgen(npts)*istep + istart]
end
