;+
;NAME:
;wincos4 - generate a cos^4 window
;SYNTAX: win=wincos4(length)
;ARGS: 
;   length: long    number of point in the window
;RETURNS:
;   win[length]: window function.
;DESCRIPTION:
;   Create a cos^4 window function of length points. The maximum
;value is normalized to 1.
;SEE ALSO: windowfunc()
;-
function wincos4,len
    x=findgen(len)* !pi * 2. / len
    return,((cos(x)-1.)*.5) ^2
end
