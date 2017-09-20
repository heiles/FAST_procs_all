;+
;NAME:
;tecdir - return tec data directory
;SYNTAX: dirNm=tecdir()
;RETURNS:
;dirNm : string directory name holding the tec monthly save files.
;
function tecdir
    return,'/share/megs2_u1/tecsavdat/'
end
    

