;---------------------------------------------------
pro plLrFitZa,lrfit,ind,useroll
;
; plot fit residuals vs za for al az swings
; you will typpically change the hor scales for this routine locally
;
    if n_elements(ind)     eq 0 then ind     = 0
    if n_elements(useroll) eq 0 then useroll = 0
;
;   setup the vertical scale
;
    case ind of
        0 : if useroll eq 0 then ver,-.01,.01     else ver,-.01,.01
        1 : if useroll eq 0 then ver,-1e-4,1e-4 else ver,-1e-4,1e-4
        2 : if useroll eq 0 then ver,.01,.02      else ver,.01,.02
        3 : if useroll eq 0 then ver,100.,120.   else ver,190,210
        4 : if useroll eq 0 then ver,.0,.01  else ver,.0,.01
        5 : if useroll eq 0 then ver,260,300.  else ver,0,150.
      else: message,'ind:0-con,1-lin,2-1azAmp,3-1azPh,4-3azAmp,5-3azPh'
    endcase
    plazswvsza,lrfit,ind,useroll
    ver
    return
end
