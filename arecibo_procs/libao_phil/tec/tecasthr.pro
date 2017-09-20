;+
;NAME:
;tecasthr - return ast hr of day for each point
;SYNTAX: hr=tecasthr(tar)
;ARGS:
;   tar[n]: {}  structure holding tec info returned by tecget()
;RETURNS:
;hr[n]  : double ast hr for each point.
;DESCRIPTION:
;   Convert the julian date of each point to AST hr from midnite.
;-
function tecasthr,tar
    return,((tar.jd - .5D - 4./24d) mod 1d) * 24.
end
