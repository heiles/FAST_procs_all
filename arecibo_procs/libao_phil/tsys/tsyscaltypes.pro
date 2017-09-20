;---------------------------------------------------------------------------
;tsyscaltypes,{calA] - plot data for 1 receiver after inputing it
;---------------------------------------------------------------------------
; 
pro tsyscaltypes,calA
;
;
	calA=strarr(8)
	calA[0]='hcal'
	calA[1]='hxcal'
	calA[2]='hcorcal'
	calA[3]='h90cal'
	calA[4]='lcal'
	calA[5]='lxcal'
	calA[6]='lcorcal'
	calA[7]='l90cal'
	return
end
