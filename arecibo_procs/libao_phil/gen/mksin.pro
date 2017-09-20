;+ 
;NAME:
;mksin - make a sine wave
;SYNTAX: d=mksin(len,numcycles,phase=phase,double=double)
;ARGS  : 
;  len : long.. number of points
;numcycles:float.. number of cycles in len
;KEYWORDS:
;phase : float  .. starting phase in fraction of a cycle
;double:        if set then return double precision values
;RETURNS:
;      d[len] :float .. the  sinwave
;- 
function mksin,len,numcycles,phase=phase,double=double
;
    if keyword_set(double) then begin
        if not keyword_set(phase) then phase=0D
         return,sin(dindgen(len)/(len) *2.d*!dpi*numcycles+(2D*!dpi*phase))
    endif else begin
        if not keyword_set(phase) then phase=0.
         return,sin(findgen(len)/(len) *2.*!pi*numcycles+(2*!pi*phase))
    endelse
            
end
