; plot the individual elements of the az swings vs za
;
pro plazswvsza,azfit,ind,roll=roll,label=label,ln=ln,scl=scl,_extra=e
;
; ARGS:
;      azfit[data,nza]
;      ind  - of coefficient 0..6
;           0 - constant - linear fit to za
;           1 - linear term in az
;           2 - 1az Amp
;           3 - 1az phase
;           4 - 3az Amp
;           5 - 3az phase
; 
;       roll - 0--> pitch, 1--> roll
    if (n_elements(ind)     eq 0) then ind    =0
    if (n_elements(roll) eq 0) then roll=0
    if (n_elements(label) eq 0) then label=' '
    if (n_elements(ln) eq 0) then ln=4
    if (n_elements(scl) eq 0) then scl=1.

    if  roll ne 0 then begin
        labtype=' ROLL '
    endif else begin
        labtype=' PITCH '
    endelse
    case ind of
;
;       constant term - linear fit to za
;
        0 : begin
            if roll eq 0 then yy=azfit.p.c0 else yy=azfit.r.c0
            a2=linfit(azfit.za,yy)
            y= yy - (a2[0]+a2[1]*azfit.za)
            plot,azfit.za,y, charsize=1.2, psym=-2,_extra=e, $
             title = label + labtype +' azswings (constant-linear fit) vs za', $
             xtitle='za',ytitle='constant -linear fit degrees',xstyle=1,ystyle=1
            a=rms(y)
            note,ln,string(format=$
                 '("(c0-fit) mean:",f7.4," rms:",f7.4," deg/deg")',a[0],a[1])
            note,ln+1*scl,string(format=$
                '("fit:y=a+b*za a=",F7.4," b=",F7.4," degrees")',a2[0],a2[1])
            end
;
;       linear fit to azimuth
;
        1 : begin
            if roll eq 0 then yy=azfit.p.c1 else yy=azfit.r.c1
            plot,azfit.za,yy, charsize=1.2, psym=-2,_extra=e, $
              title = label + labtype+' linear term in az  vs za', $
              xtitle='za',ytitle='linear term degrees/degree',xstyle=1,ystyle=1
            a=rms(yy)
            note,ln,string(format=$
                 '("mean:",e8.1," rms:",e8.1," deg/deg")',a[0],a[1])
            end
;
;       1az amp
;
        2 : begin
            if roll eq 0 then yy=azfit.p.az1A else yy=azfit.r.az1A
            plot,azfit.za,yy, charsize=1.2, psym=-2,_extra=e, $
               title = label +  labtype + ' 1az amplitude vs za', $
               xtitle='za',ytitle='1Az amplitude degrees',xstyle=1,ystyle=1
            
            a=rms(yy)
            note,ln,string(format=$
                 '("mean:",F7.4," rms:",F7.4," degrees")',a[0],a[1])
            end
;
;       1az phase
;
        3 : begin
            if roll eq 0 then yy=azfit.p.az1Ph else yy=azfit.r.az1Ph
            plot,azfit.za,yy * !radeg, charsize=1.2, psym=-2,_extra=e, $
               title = label + labtype+' 1az Phase vs za', xtitle='za',$
                ytitle='phase [deg]',xstyle=1,ystyle=1
;
;       for phase jumps, compute rms at this and this plus pi mod 2pi
;       take the one that has the smallest rms
;
            a=rms(yy)
            a1=rms((yy+!pi) mod (2.*!pi))
            if  a1[1] lt a[1] then begin
                a[0]=a1[0] - !pi
                a[1]=a1[1]
            endif
			if  a[0] lt 0. then a[0]=a[0] + 2.*!pi
            note,ln,string(format='("mean:",F7.2," rms:",F7.2," degrees")', $
                a[0]*!radeg,a[1]*!radeg)
            note,ln+1*scl,"Asin(1az-phase)"
            end
;
;       3az amp
;
        4 : begin
            if roll eq 0 then yy=azfit.p.az3A else yy=azfit.r.az3A
            plot,azfit.za,yy, charsize=1.2, psym=-2,_extra=e,$
               title = label + labtype+' 3az amplitude vs za', $
               xtitle='za',ytitle='3Az amplitude degrees',xstyle=1,ystyle=1
            a=rms(yy)
            note,ln,string(format=$
                 '("mean:",F7.4," rms:",F7.4," degrees")',a[0],a[1])
            end
;
;       3az phase
;
        5 : begin
            if roll eq 0 then yy=azfit.p.az3Ph else yy=azfit.r.az3Ph
            plot,azfit.za,yy * !radeg, charsize=1.2, psym=-2,_extra=e, $
               title = label + labtype+'3az Phase vs za', xtitle='za',$
               ytitle='phase [deg]',xstyle=1,ystyle=1
            a=rms(yy)
            a1=rms((yy+!pi) mod (2.*!pi))
            if  a1[1] lt a[1] then begin
                a[0]=a1[0] - !pi
                a[1]=a1[1]
            endif
			if  a[0] lt 0. then a[0]=a[0] + 2.*!pi
            note,ln,string(format='("mean:",F7.2," rms:",F7.2," degrees")', $
                a[0]*!radeg,a[1]*!radeg)
            note,ln+1*scl,"Asin(3az-phase)"
            end
      else: message,$
        ' ind should be 0-con,1-line,2-1azAmp,3-1azPh,4-3azAmp,5-3azPh'
      endcase
      return
end
