;
; axis profile
;
pro axisprof,pi,axis

	case axis of 
	'hor': begin
		pi.lenInches =12.
		pi.totTurns  =120
		pi.motRpmMax =2100.   
		end
	'ver': begin
		pi.lenInches =17.7165
		pi.totTurns  =225
		pi.motRpmMax =1500.   
		end
	'tilt': begin
		pi.lenInches =24.
		pi.totTurns  =240
		pi.motRpmMax =2100.   
		end
	else: message,'illegal axis request..hor,ver, or tilt'
	endcase
	return
end
