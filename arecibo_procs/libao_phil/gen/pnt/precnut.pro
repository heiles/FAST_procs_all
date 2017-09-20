;+
;NAME:
; precNut - perform precession and nutation.
;SYNTAX: precV3=precNut(vec3,juldate,toj2000=toj2000,eqOfeq=eqOfEq)
;ARGS:
;   vec3[3,n]: double    vectors to precess
;   julDate  : double    julian date to use for precession matrix.
;   
;KEYWORDS:
;  toj2000:if set then precess from date to j2000. default is j2000 to date.
;
;DESCRIPTION
;   Perform the J2000 to date or Date to J2000 precession and nutation on the
;input vecotr vec3 (normalized 3 vector coordinates). The return
;value is in precV3. By default the precession is from J2000 to date. The
;keyword toj2000 will precess/nutate from date to J2000.
;
;   The routine computes 1 precession,nutation matrix based on the 
;average julDate and then applies it to all of the points n in vec3.
;The juldate is normally utc based (actually it should be ut1 based but that 
;makes little difference here).
;
;REFERENCE
; Astronomical Almanac 1992, page B18.
;-
function precnut,vec3Inp,julDate,toj2000=toj2000,eqOfEq=eqOfEq 
;
;   default is to go  j2000 -> date
;
    juldateLast=julDate
    precM=precj2todate_m(juldate)
    nutM =nutation_m(juldate,eqOfEq=eqOfEq)

;   j2000 to date, prec then nutate 

    if not keyword_set(toj2000) then begin
        precnutM=nutM ## precM
    endif else begin
;
;     date to J2000 nutatate then precess. The inverses are the 
;     tranposes, 
;
        precnutM= transpose(precM) ## transpose(nutM)
    endelse
;
;   i think this gives the correct output
;
    return , transpose(precnutM) # vec3inp
end
