;+ 
;NAME:
;fitazzaprcov - print out the covariance matrix
;SYNTAX, fitazzaprcov,fiti,fd
;ARGS:
;   fitI:   {fitazza} returned from fitazza
;     fd:   int write the data to this file descriptor. Default is stdout.
;- 
pro fitazzaprcov,fiti,fd
;
    if n_elements(fd) eq 0 then fd=-1
;
;fittype: 1 2 3 4 5 6 7
useAz=   [1,1,1,0,1,0,1]
use10=   [0,1,0,0,0,1,0]
lab  =['c0  ','za  ','za^2','za^3','caz ','saz ','c2az','s2az','c3az','s3az']
lab5 =['c0  ','za  ','za^2','za^3','caz ','saz ','c3az','s3az','szac3az','szas3az']
lab7 =['c0  ','caz ','saz ','c2az','s2az','c3az','s3az']
for i=0,fiti.numcoef-1 do begin &$
    if i eq  0 then begin &$
        ind=where(fiti.fittype eq [1,2,3],count)
        if count gt 0 then  begin
            printf,fd,$
'      c0         za      za^2     za^3    caz       saz     c2az      s2az      c3az    s3az' &$
        endif 
        ind=where(fiti.fittype eq [4,6],count)
        if count gt 0 then  begin
            printf,fd,$
'      c0         za      za^2     za^3' &$
        endif
        ind=where(fiti.fittype eq [7],count)
        if count gt 0 then  begin
            printf,fd,$
'      c0         caz       saz     c2az      s2az      c3az    s3az' &$
        endif

        ind=where(fiti.fittype eq [5],count)
        if count gt 0 then begin
            printf,fd,$
'      c0         za      za^2     za^3    caz       saz     c3az      s3az      szac3az    szas3az' &$
        endif 
    endif &$
    ln=lab[i]+ ':' &$
    for j=0,fiti.numcoef -1  do begin &$
        ln=ln + string(format='(f8.5," ")',fiti.covar[i,j]) &$
    endfor &$
    printf,fd,ln &$
endfor
    return
end
