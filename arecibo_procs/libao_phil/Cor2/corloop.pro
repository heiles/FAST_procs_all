;modhistory
;31jun00 no changes needed for corget update
pro corloop,toloop,m=pltmsk,vel=vel,delay=delay,sl=sl,han=han
common corloop,lun,str
on_error,1
if (n_elements(delay) eq 0) then delay=0
slind=-1
if n_elements(sl) gt 0 then begin
     slind=0
     istat=posscan(lun,sl[0].scan,sl=sl)
     maxslind=(size(sl))[1]
endif
step=0
for i=0L,toloop do begin
newrec:    istat=corget(lun,b,han=han)
    if istat ne 1 then goto,done
    if slind ge 0 then begin
        scan=b.b1.h.std.scannumber
        if (scan ne sl[slind].scan) then begin ; new scan increment slind
           slind=slind+1
           if slind ge maxslind then goto,done ; were done
           if sl[slind].scan ne scan then begin; need to position the reread    
                istat1=posscan(lun,sl[slind].scan,sl=sl)
                goto,newrec;
           endif
        endif
    endif
;    corhan,b
    wset,str.pixwin
    corplot,b,m=pltmsk,vel=vel
    wset,str.win
    device,copy=[0,0,str.xdim,str.ydim,0,0,str.pixwin]
    if (delay gt 0 ) then wait,delay
    key=checkkey()
    if (key ne '') or (step) then begin
        print,'return to continue,s step,c continue, q to quit'
        key=checkkey(/wait)
        case key of
         's': step=1
         'c': step=0
         'q': goto,done
         else: 
        endcase
    endif
endfor
done:
return
end
