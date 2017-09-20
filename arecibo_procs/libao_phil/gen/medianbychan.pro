;+
;NAME:
;medianbychan -  median 2d array by chan.
;SYNTAX  :  result=medianbychan(d,nsections=nsections,retsection=retsection)
;  ARGS  :
; d[m,n] : input array to compute median over 2nd dimension (n).
;KEYWORDS:
;nsections: int if provided, then break d[*,n] up into nsections sections. Compute the
;               median of each of these. For each channel return the minimum
;               of the nsections values for each channel.
;retsection: int    If nsections is used then the minimum value of the nsections
;                measurements is returned by default. retsection lets you change
;                how the return value is determined.
;               0: return the minimum value (this is the default).
;               1: return the maximum value
;               2: return the average value
;               3: return the median value
;   
;RETURNS:
;result[m]: result[i]= median(d[i,*])
;
;DESCTRIPTION:
;    Compute the median by channel for a 2d array. If the array
;is dimensioned d[m,n] then result[i]=median(d[i,*]).
;   The nsections keyword can be used to break the n samples up into nsections 
;units and compute the median of each of these separately. The minimum value
;of the nsections samples is then returned for each sample. The retsection keyword
;lets you changes this to the avg,max,or median.
;-
function medianbychan,d,nsections=nsections,retsection=retsection
    a=size(d)
    if a[0] ne 2 then begin
        print,'array should be 2d'
        return,0
    endif
    nx=a[1]
    ny=a[2]
    ret=d[*,0]
    if not keyword_set(nsections) then begin
        if !version.release ge '5.6' then begin
            ret=median(d,dimension=2)
        endif else begin
            for i=0L,nx-1L do ret[i]=median(d[i,*])
        endelse
        return,ret
    endif
;
;    they want to compute median by sections.
;    
    istep=ny/nsections          ; last one may be larger
    dsec=d[*,0:nsections-1]
    i1=0
    if not keyword_set(retsection) then retsection=0
    for isec=0l,nsections-1 do begin
        i2=(isec eq nsections-1L)?ny-1L:i1+istep-1L
        if !version.release ge '5.6' then begin
            dsec[*,isec]=median(d[*,i1:i2],dimension=2)
        endif else begin
            dtmp=d[*,i1:i2]
            for i=0L,nx-1L do dsec[i,isec]=median(dtmp[i,*])
        endelse
        i1=i2+1L
    endfor
    case retsection of
        1 :begin
            ret=dsec[*,0]
            for i=1,nsections-1 do ret=ret > dsec[*,i]
           end
        2 :begin
            ret=total(dsec,2)/nsections
           end

        3 :for i=0,nx-1 do ret[i]=median(dsec[i,*])
;
;    default to min
;
     else :begin
            ret=dsec[*,0]
            for i=1,nsections-1 do ret=ret < dsec[*,i]
           end
    endcase
    return,ret
end
