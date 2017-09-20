;+
;NAME:
;chkswaprec - check hdrlen to see if the record needs to be swapped
;SYNTAX: swap=chkswaprec(stdhdr)
;ARGS:
;       stdhdr: {hdrStd} standard portion of data header
;RETURNS:
;      swap : int 1 --> need to swap,0 --> no need to swap
;DESCRIPTION
;   Check to see if the record needs its data swapped because of
;big/little endian differences. The user passes in the standard header
;and the routine checks that the abs(hdrstd.hdrlen) < 65535. If the
;number i larger than this then the record needs to be swapped (headers
;are never larger than 65535.
;-
;
function chkswaprec,stdhdr

    if  abs(stdhdr.hdrlen) ge 65536L  then return,1
    return,0
end
