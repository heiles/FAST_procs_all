PRO count
;+
;NAME
;COUNT -- This procedure exists only as example of overwriting the screen in place
;with a running number without skipping lines.
;-

  cr = string('15'OB) 
  FOR i=1, 600 DO BEGIN 
     print, i, cr, format='($,I5,A)'
	wait,0.01
  ENDFOR 
  print
  FOR i=1, 8192 DO BEGIN ; Hexadecimal
     print, i, cr, format='($,Z5.4,A)'
	wait,0.01
  ENDFOR 
  print
  return
END
