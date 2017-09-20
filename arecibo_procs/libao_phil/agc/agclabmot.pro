;+
;NAME:
;agclabmot - label the motor colors
;SYNTAX: agclabmot,axis,ln=ln,scl=scl,xpos1=xpos1,xpos2=xpos2,xposhb=xposhb,
;			cs=cs,grp=grp,font=font
;ARGS:
;axis : string  'az','gr', or 'ch'
;
;KEYWORDS:
;   ln: int line number to start 0..31, default=2
; step: float line step. Default=1.
;xpos1: float xpos start of first col. 0..1 . def:.02
;xpos2: float xpos start of 2nd   col. 0..1 . def:xpos1  + .1
;xposHB:float xpos for hydraulic brake labels (def:xpos + .1)
;   cs: float charsize scaling. default=1.
; grp : int   if 1 or 2 , then only label groups 1 or 2
; font: int   font to use . 0 normal, 1=truetype
;
;RETURNS:
;
;DESCRIPTION:
;   Label the colors used for the various motors.
;-
pro  agclabmot,axis,ln=ln,scl=scl,xpos1=xpos1,xpos2=xpos2,xposHB=xposHB,cs=cs,$
		 		grp=grp,font=font
;
    common colph,decomposedph,colph

	if n_elements(ln) eq 0 then ln=2.5
	if n_elements(scl) eq 0 then scl=.7
	if n_elements(xpos1) eq 0 then xpos1=.02
	if n_elements(xpos2) eq 0 then xpos2=xpos1+.1
	if n_elements(xposHB) eq 0 then xposHB=xpos2+.1
	if n_elements(cs) eq 0 then cs=1.
	if n_elements(grp) eq 0 then grp=0
	if n_elements(font) eq 0 then font=0 
	case  (axis) of
	  'az': begin
       mot=[ 'mot11','mot12','mot51','mot52','mot41','mot42','mot81','mot82']
		 end
	  'gr': begin
	    mot=[ 'mot11','mot12','mot21','mot22','mot31','mot32','mot41','mot42']
		 end
	  'ch': begin
	    mot=[ 'mot1','mot2']
		 tq=transpose(b.fb.tqch)
		 end
	else: message,'axis must be "az", "gr", or "ch"'
	endcase
;
;  compute velocity at torque timestamps
;
	nmot=n_elements(mot)
	case grp of
	0: begin
		i1=0
		i2=nmot/2-1
	   end
	1: begin
		i1=0
		i2=nmot/4-1
	   end
	2: begin
		i1=nmot/4
		i2=nmot/2-1
	   end
	else: begin
		i1=0
		i2=nmot/2-1
	   end
	endcase
		
    for i=i1,i2 do begin &$
    	note,ln+i*scl,mot[2*i]  ,xp=xpos1,color=colph[i*2+1],$
           charsize=cs,font=font&$
        note,ln+i*scl,mot[2*i+1],xp=xpos2,color=colph[i*2+2],$
            charsize=cs,font=font &$
        if ((i mod 2) eq 0) and (axis eq 'gr')  then $
             note,ln+i*scl,'(HB)',font=font,xp=xposHB,charsize=cs &$
    endfor
	
	return
end
