;---------------------------------------------------------------------------
;imtsys,freq return tsys for this freq
;---------------------------------------------------------------------------
function imtsys,freq
;
    tsysArr= [15e3,15e3,15e3,3500.,0., 800.,800.,900.,1000.,1100.,1800.];
    frqArr = [ 70, 165 ,235, 330,450, 550,725,955,1075,1325,1400 ];
    ind=where( (freq eq frqArr),count)
    if (count eq 0) then return,0.
    return,tsysArr[ind[0]]
end
