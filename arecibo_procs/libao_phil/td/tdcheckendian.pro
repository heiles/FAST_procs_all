;+
;NAME:
;tdcheckendian - check whether the data needs to be flipped or not.
;SYNTAX: needsflip=tcheckendian(d)
;ARGS:
;   d   :   {tdall} data to check for endian nes..
;RETURNS:
;   needsflip: int  1 need to flip data, 0 data in current machine format.
;DESCRIPTION:
;   tdcheckendian will check if the data needs to be flipped (via swap_endian)
;or not.
;-
function tdcheckendian,d
;
    if (d.secM lt -1)        or (d.secM gt 86500) or $
       (d.az   lt -3600000L) or (d.az gt 7250000L) or $
       (d.gr   lt 10000L)    or (d.gr gt 200000L) then return,1
    return,0
end
