; 
;NAME:
;cursorsubset - use the cursor to create a subset of the data
;
;SYNTAX: nsets=cursubset(xaxis,indArr)
;
;ARGS:
;        xaxis[]    : float ..data range for x axis.
;        indArr[2,nsets] : cursor xpos [0,*] start, [1,*] end  for nsets
;        
function cursorsubset,xaxis,indArr
;
    maxset=100
    indArrLoc=fltarr(2,maxset)
    nptsx=(size(xaxis))[1]
    done=0
    setcnt=0
    lnstyle=2
    print,'buttons: left mark, right quit'
    while  not done do begin
;
;       get starting point
;
        while 1 do begin
        print,format='($,i3,"--P1?--")', setcnt+1
            cursor,xp1,yp1,4
;           print,xp1,yp1,!mouse.button
            print,xp1
            case !mouse.button of 
                1:goto,got1
                2:print,'   ???   [buttons:left mark, right quit]")' 
                4:goto,done
            endcase
        endwhile
got1:
        ind= where(xp1 gt xaxis,count)
        print,'dbg:', count
        case count of
            nptsx:ind1=nptsx-1
            0    :ind1=0
             else:begin
                  ind1=ind[count-1]
                  if abs(xaxis[ind1]-xp1) gt abs(xaxis[ind1+1]-xp1) then $
                    ind1=ind1+1
                  end
        endcase
        plots,xaxis[ind1],!y.crange[0]
        plots,xaxis[ind1],yp1,/continue,linestyle=lnstyle

        while 1 do begin
        print,format='($,i3,"--P2?--")', setcnt+1
            cursor,xp2,yp2,4
;           print,xp2,yp2,!mouse.button
            print,xp2
            case !mouse.button of 
                1:goto,got2
                2:print,'   ???   [buttons:left mark, right quit]")' 
                4:goto,done
            endcase
        endwhile
got2:
;
;       figure out the indices..
;
        ind= where(xp2 gt xaxis,count)
        case count of
            0    :ind2=0
            nptsx:ind2=nptsx-1
             else:begin
                  ind2=ind[count-1]
                  if abs(xaxis[ind2]-xp2) gt abs(xaxis[ind2+1]-xp2) then $
                    ind2=ind2+1
                  end
        endcase
        if ind1 ge ind2 then begin
            print,'1st point >= 2nd point, ignored'
        endif else begin
            indArrLoc[0,setcnt]=ind1
            indArrLoc[1,setcnt]=ind2
            setcnt=setcnt+1
;;          print,'dbg: ind:',ind1,ind2,' x:',xaxis[ind1],xaxis[ind2]
            plots,xaxis[ind2],yp1,/continue,linestyle=lnstyle
            plots,xaxis[ind2],!y.crange[0],/continue,linestyle=lnstyle
        endelse
;;      print,"dbg:ind1,2",ind1,ind2
;
;
    endwhile    
done:
    if setcnt eq 0 then begin
        mask=0
    endif else begin
        indArr=indArrLoc[*,0:setcnt-1]
    endelse
    return,setcnt
end
