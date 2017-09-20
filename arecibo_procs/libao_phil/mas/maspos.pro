;+
;NAME:
;maspos - position to row in fits file
;SYNTAX: istat=masposrow(desc,row)
;ARGS:
;   desc:{}             returned from masopen().
;   row : long          row to position to. Count rows from 1
;RETURNS:
;   istat: 0 ok
;-
function maspos,desc,row
;
;
;
    desc.currow=(row-1L)>0L
    return,0
end
