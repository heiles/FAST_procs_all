;+
;NAME:
;tecsatlist - return list of all tec satellite names
;SYNTAX: satNmAr=tecsatlist()
;RETURNS:
;   satNmAr[]: strarr  array of all satellite names
;DESCRIPTION:
;   return list of all satellite names we know about.
;To map from a tec.sat to these names use:
; satNm=satNmAr[tec[i].sat -1] .. (the codes start counting from 1).
;-
function tecsatlist
        satList=[$
'COSMOS 2407',$
'DMSP F15',$
'FM1',$
'FM3',$
'FM4',$
'FM5',$
'FM6',$
'GFO',$
'OSCAR 23',$
'OSCAR 25',$
'OSCAR 31',$
'OSCAR 32',$
'RADCAL'$
]
    return,satList
end
