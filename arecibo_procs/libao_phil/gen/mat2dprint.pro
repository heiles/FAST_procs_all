pro mat2dprint,mat

    n=(size(mat))[1]
    m=(size(mat))[2]
    for i=0,n-1 do begin
     ln=string(i) + ' '
     for j=0,m-1 do begin
        ln=ln + string(format='(g10.4," ")',mat[i,j])
     endfor
    print,ln
    endfor
    return 
end
