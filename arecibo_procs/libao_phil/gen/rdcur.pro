;+
;NAME:
;rdcur - read cursor position multiple times
;SYNTAX: n=rdcur(curI)
;  RETURNS:
;        n: long  number of points read
;curI[2,n]: float x,y data positions for each cursor position requested.
;
;DESCPRIPTION:
;   Read the cursor position multiple times. Return the number of points
;read in n. Return the positions in the array curI[2,n]. The positions 
;are returned in data coordinates. 
;
;   As you move the cursor around the cursor position will continuously
;update on the terminal. When the left or center button is depressed, the
;position will be stored in curI and a newline will be started on the
;terminal (so you can see the value that was stored).
;
; Mouse Button usage is:
;
;    Button           Action
;    Depress   left:  record position, new terminal line 
;    Depress center:  record position, new terminal line 
;    Depress  right:  exit routine.
;
; The routine will return a maximum of 1000 points.
;
;SEE ALSO:
;    cp
;
;NOTE:
;   Points are only recorded on the downward press of the left or center
;button.
;-
;
function rdcur,curI 
;
; right button quit
; left button record
; center button button message
;
    maxpnts=1000
    curI=fltarr(2,maxpnts)
    icnt=0
    cr=string("15b)
    wchange=2
    wnone  =0
    !mouse.button=0
    form="($,'x=',f,', y=',f,a)
    while (!mouse.button ne 4 ) do begin
        cursor,x,y,wchange
        if (!mouse.button and 3) ne 0 then begin
            curI[*,icnt]=[x,y] 
            print,form="($,a)",string("12b)
            icnt=icnt+1
            if icnt ge maxpnts then goto,done
            while (!mouse.button ne 0) do begin
                wait,.1 &
                cursor,x1,y1,0,/dev
            end
        endif
        print,form=form,x,y,cr
    endwhile
done:   print,form="(/)"
    if icnt lt maxpnts then begin
        if icnt lt maxpnts then begin
            if icnt eq 0 then begin
                curI=''
            endif else begin
                curI=curI[*,0:icnt-1]
            endelse
        endif
    endif
    return,icnt
end
