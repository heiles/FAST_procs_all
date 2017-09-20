;+
;NAME:
;rdcurdif - read cursor position difference multiple times
;SYNTAX: n=rdcurdif(curI)
;  RETURNS:
;        n: long  number of points read
;curI[2,3,n]: float x,y data positions for each set
;             curI[0,0,*] x start
;             curI[1,0,*] y start
;             curI[0,1,*] x end
;             curI[1,1,*] y end
;             curI[0,1,*] xend -xstart
;             curI[1,1,*] yend -ystart
;
;DESCPRIPTION:
;   let the user pick two positions with the currsor and then compute the
;x,y difference between the two points.
;Return the positions and differences in the array curI[2,3,n]. The positions 
;are returned in data coordinates. 
;
; Mouse Button usage is:
;
;    Button           Action
;    Depress   left:  record start position, new terminal line 
;    Depress center:  record end position, compute difference
;    Depress  right:  exit routine.
;
;   As you move the cursor around there are continual updates:
; 1. on the first point, the 1st position updates
; 2. on the 2nd opint the the 2nd cursor position and difference
;   will continuously update on the terminal.
;
; The routine will return a maximum of 1000 points.
;
;SEE ALSO:
;    rdcur,cp
;
;NOTE:
;   Points are only recorded on the downward press of the left or center
;button.
;-
;
function rdcurdif,curI 
;
; right button quit
; left button pnt 1 
; center button pnt 2
;
    maxpnts=1000
    curI=fltarr(2,3,maxpnts)
    icnt=0
    cr=string("15b)
    wchange=2
    wnone  =0
    !mouse.button=0
    form="($,'x1=',f,', y1=',f,' x2=',f,' y2=',f,' dif:',f,1x,f,1x,i1,1x,i1,a)
	x1=0.
	x2=0.
	y1=0.
	y2=0.
	got1=0
	got2=0
	curI[*,*,*]=0.
	print,"leftButton: pnt1, MiddleButton: pnt2, rightButton: done"
    while (!mouse.button ne 4 ) do begin
        cursor,x,y,wchange
;
;	left button is first point.
;
		if (!mouse.button eq 4  ) then goto,done
        if ( !mouse.button and 1) then begin
				x1=x
				y1=y
			    x2=0.
				y2=0.
				got1=1
			    got2=0
        endif else begin
;
;	middle  button is 2nd  point.
;
        	if ( got1 && (!mouse.button and 2)) then begin
				x2=x
				y2=y
				got2=1
			endif
		endelse
; 
;        wait for button release
;
       	while (!mouse.button ne 0) do begin
          	wait,.1 &
           	cursor,xx,yy,0,/dev
       	end
		if (got1 eq 0) then begin
			x1=x
			y1=y
		endif else begin
			if got2 eq 0 then begin
				x2=x
				y2=y
			endif
		endelse
        print,form=form,x1,y1,x2,y2,x2-x1,y2-y1,got1,got2,cr
		if got2 then begin
			print,form="($,a)",string("12b)
			curI[*,0,icnt]=[x1,y1]	
			curI[*,1,icnt]=[x2,y2]	
			curI[*,2,icnt]=[x2-x1,y2-y1]	
			x1=0.
			x2=0.
			y1=0.
			y2=0.
            icnt=icnt+1
			got1=0
			got2=0
            if icnt ge maxpnts then goto,done
		endif
    endwhile
done:   print,form="(/)"
    if icnt lt maxpnts then begin
        if icnt lt maxpnts then begin
            if icnt eq 0 then begin
                curI=''
            endif else begin
                curI=curI[*,*,0:icnt-1]
            endelse
        endif
    endif
    return,icnt
end
