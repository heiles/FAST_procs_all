;
;---------------------------------------------------
;
pro pltsfitvsza,azfit,ind,roll=roll,raw=raw,label=label,ver=ver
    if n_elements(ind)     eq 0 then ind     = 0
    if n_elements(roll) eq 0 then roll = 0
    if n_elements(raw) eq 0 then raw = 0
    if n_elements(label) eq 0 then label= ' '
;
;   setup the vertical scale
;   raw.. correction
;
    if n_elements(ver) ne  0 then begin
		ver,ver[0,ind],ver[1,ind]
	endif else begin
    	if raw eq 0 then begin
    	case ind of
        	0 : if roll eq 0 then ver,-.1,.1     else ver,-.1,.1
        	1 : if roll eq 0 then ver,-1e-4,1e-4 else ver,-1e-4,1e-4
        	2 : if roll eq 0 then ver,.02,.04      else ver,.02 ,.04
        	3 : if roll eq 0 then ver,0.,360.    else ver,0.,360.
        	4 : if roll eq 0 then ver,.01,.03  else ver,.03 ,.05
        	5 : if roll eq 0 then ver,0.,360.  else ver,  0.,360.
      	else: message,'ind:0-con,1-lin,2-1azAmp,3-1azPh,4-3azAmp,5-3azPh'
    	endcase
    	endif else begin
    	case ind of
        	0 : if roll eq 0 then ver,-.1,.1     else ver,-.1,.1
        	1 : if roll eq 0 then ver,-1e-4,1e-4 else ver,-1e-4,1e-4
        	2 : if roll eq 0 then ver,.0,.02      else ver,0. , .02
        	3 : if roll eq 0 then ver,0.,360.    else ver,0.,360.
        	4 : if roll eq 0 then ver,.01,.03  else ver,.03,.05
        	5 : if roll eq 0 then ver,0,360  else ver,0,360
      	else: message,'ind:0-con,1-lin,2-1azAmp,3-1azPh,4-3azAmp,5-3azPh'
    	endcase
    	endelse
	endelse
    plazswvsza,azfit,ind,roll=roll,label=label
    ver
    return
end
