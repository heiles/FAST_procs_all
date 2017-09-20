;+
;NAME:
;galgerrdcd - decode the galfa g_err bitmap convert fits hdr to cor header
;
;SYNTAX: gdcd=galgerrdcd(g_err)
;
;ARGS: 
;   g_err[] :int  array of g_err values from header
;
;RETURNS:
;   gdcd[]: {g_errstr} array of structures with decoded values.
;
;DESCRIPTION:
;   The g_err status word holds overflow information for the galfa 
;spectromenter. Pol A and B of the same beam always have the same
;bits set. There are six flags in the status word. Each flag is decoded
; into a separate integer value. The structure field names, bits in the
; mask and description are:
;
;S    wbUpShSat  B0-1   wide band upshift saturation
;F    wbFftOvr   B2-3   wide band fft overflow
;S   nbUpShSat  B4-5   narrow band upshift saturation
;F    nbFftOvr   B6-7   narrow band fft overflow
;L   nbLpSat    B8-99  narrow band low pass filter saturation
;M   nbMixSat   B10-11 narrow band mixer saturation
;    adcSat     B12-13 adc input saturation
;
; For each field it can take on the value 0 thru 3. These values are:
;
; 0 - 0  to 15  errors in previous 1 sec
; 1 - 16 to 255 errors in previous 1 sec
; 2 - 256 to 4095  errors in previous 1 sec
; 3 - > 4096  errors in previous 1 sec
; note that pola,b will always have the same errors for a given beam.
;
;-
function galgerrdcd,g_err
;
    on_error,0
; 
;   make a linear array
;
    a=size(g_err)
    n=n_elements(g_err)
    gdcd=replicate({g_errst},n)
    g_errLoc=reform(g_err,n)
    gdcd.wbUpShSat= (g_errLoc and 3)
    gdcd.wbFftOvr = ishft(g_errLoc,-2) and 3
    gdcd.nbUpShSat= ishft(g_errLoc,-4) and 3
    gdcd.nbFftOvr = ishft(g_errLoc,-6) and 3
    gdcd.nbLpSat  = ishft(g_errLoc,-8) and 3
    gdcd.nbMixSat = ishft(g_errLoc,-10) and 3
    gdcd.adcSat   = ishft(g_errLoc,-12) and 3
    case  a[0] of
        2 : gdcd=reform(gdcd,a[1],a[2])
        3 : gdcd=reform(gdcd,a[1],a[2],a[3])
        4 : gdcd=reform(gdcd,a[1],a[2],a[3],a[4])
       else: 
    end
    return,gdcd
end
