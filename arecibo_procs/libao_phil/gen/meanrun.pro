;+
;NAME:
;meanrun - compute the running mean of a 1 or 2d array
;SYNTAX: result=meanrun(data,len)
;ARGS:   
;    data[x,y]   data to operate on
;    len      : int length of running mean. If even , round up to next
;                   odd number
;DESCRIPTION:
;   Compute a running mean along  the last dimension of the array data.
;data can be a 1 or 2d array; The output will be float (unless data is
;a double array in which case it will be double). For each point
;   data[j,i] the routine will average:
;   data[j,(i-len/2):(i+len/2)] points.
;The edges will only average the above points which fall within
;the index bounds of the array. 
;(eg data[j,0:len/2]) 
;
;-
;history:
; 23jan03 added running mean
;
function meanrun,data,len

;
    a=size(data)
    case a[0] of
        1: begin
            ncols=1
            nrows=a[1]
            data=reform(data,ncols,nrows,/overwrite)
           end
        2: begin
            ncols=a[1]
            nrows=a[2]
           end
     else: message,'meanrun wants a 1 or 2d array'
    endcase
;
;   see if it is double
;
    if (a[n_elements(a)-2] eq 5) then begin
        one=1.D
        d=dblarr(ncols,nrows)
    endif else begin
        one=1.
        d=fltarr(ncols,nrows)
    endelse
    inc=len/2
    range=inc*2L+1L
;
;   len=9  then inc=4, range=9
;   len=10 then inc=5, range=11
;   inc is the first index where total average fits
;   len-inc-1 is the last index where total average fits
    i1=inc                  ; first complete average that fits
    i2=nrows-i1-1           ; last  complete average that fits
    sum=total(data[*,0:inc],2)
    sn=inc+one
;
;   first part partial sum missing lower strips
;
    for i=0,inc-1 do begin
        d[*,i]=sum/sn
        sum=sum+data[*,inc+i+1]
        sn=sn+one
    endfor
;
;   region where running mean fits..
;   sum has data for i=i1
;
    for i=i1,i2-1 do begin
        d[*,i]=sum/sn
        sum=sum + data[*,i+inc+1]-data[*,i-inc] ; next point i1+1
    endfor
;
;   last part  i2 to end missing upper strips
;
    for i=i2,nrows-1 do begin
        d[*,i]=sum/sn
        sum=sum - data[*,i-inc] ; next point i1+1
        sn=sn-one
    endfor
    if ncols eq 1  then begin
        d   =reform(d,/overwrite)
        data=reform(data,/overwrite)
    endif
    return,d
end
