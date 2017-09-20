;+
;NAME:
;p12mdcdstat - decode the device status
;SYNTAX:stDcd= p12mdcdstat(stU)
;ARGS: 
; stU[n]   : {p12mdevStWdsU} undecoded device status words
;RETURNS:
;st[n]     : {p12mdevstWds} structs after decoding
;                      decoded
;DESCRIPTION:
; 	decode the 4 device status biffields. Passed in as
;array of stucts holding the 4 32bit numbers
;   Returns an array of decode structs
;-
function   p12mdcdstat,stU
;
;  byte 0
;
	ncnt=n_elements(stU)
	dst=replicate({p12mDevStWds},ncnt)
	ival=stU.azM
	dst.azM.status32=ival
	if (ival[0] eq 0) and (ncnt eq 1)  then begin 			; shortcut
			for i=0,n_tags(dst.azM)-1 do dst.azM.(i) =0
	endif else begin
		mask='80'xul;
		ipos=1
		for i=ipos,ipos+7 do begin
			dst.azM.(i)=(mask and ival) ne  0
			mask=ishft(mask,-1);
		endfor
		ipos=9
;  byte 1
		mask='8000'xul;
		for i=ipos,ipos+7 do begin
			dst.azM.(i)=(mask and ival) ne  0
			mask=ishft(mask,-1);
		endfor
;  byte 2
		mask='800000'xul;
		ipos=17
		for i=ipos,ipos+7 do begin
			dst.azM.(i)=(mask and ival) ne  0
			mask=ishft(mask,-1);
		endfor
	endelse

	ival=stU.azSl
	dst.azSl.status32=ival
	if (ival[0] eq 0) and (ncnt eq 1)  then begin
		for i=0,n_tags(dst.azSl)-1 do dst.azSl.(i) =0
	endif else begin
		ipos=1
		mask='80'xul;
		for i=ipos,ipos+7 do begin
			dst.azSl.(i)=(mask and ival) ne  0
			mask=ishft(mask,-1);
		endfor
	endelse

	ival=stU.el
	dst.el.status32=ival
	if (ival[0] eq 0) and (ncnt eq 1)  then begin
		for i=0,n_tags(dst.el)-1 do dst.el.(i) =0
	endif else begin
;  byte 0
		ipos=1
		mask='80'xul;
		for i=ipos,ipos+7 do begin
			dst.el.(i)=(mask and ival) ne  0
			mask=ishft(mask,-1);
		endfor
;  	byte 1
		ipos=9
		mask='8000'xul;
		for i=ipos,ipos+7 do begin
			dst.el.(i)=(mask and ival) ne  0
			mask=ishft(mask,-1);
		endfor
;  	byte 2
		ipos=17
		mask='800000'xul;
		for i=ipos,ipos+7 do begin
			dst.el.(i)=(mask and ival) ne  0
			mask=ishft(mask,-1);
		endfor
	endelse

	ival=stU.cen
	dst.cen.status32=ival
	if (ival[0] eq 0) and (ncnt eq 1)  then begin
		for i=0,n_tags(dst.cen)-1 do dst.cen.(i) =0
	endif else begin
;  byte 0
		ipos=1
		mask='80'xul;
		for i=ipos,ipos+7 do begin
			dst.cen.(i)=(mask and ival) ne  0
			mask=ishft(mask,-1);
		endfor
;  byte 1
		mask='8000'xul;
		dst.cen.azTrkStartOutOfRange=(mask and ival)   ne  0&mask=ishft(mask,-1);
		dst.cen.azTrkStartTurn      =(ishft(ival,-13)) and  3&mask=ishft(mask,-2);
		dst.cen.tmOut30secDisabled  =(mask and ival)   ne  0&mask=ishft(mask,-1);
		dst.cen.raDecTrkingData     =(ishft(ival,-10))  and 3&mask=ishft(mask,-2);
		dst.cen.trkCoordEquat       =(mask and ival)   ne  0&mask=ishft(mask,-1);
		dst.cen.stowInProgress      =(mask and ival)   ne  0&mask=ishft(mask,-1);
;  byte 2
		mask='800000'xul;

		dst.cen.curRunMode          =(ishft(ival,-22)) and 3&mask=ishft(mask,-2);
		dst.cen.azSlvOnline         =(mask and ival)  ne  0&mask=ishft(mask,-1);
		dst.cen.azMasterOnline      =(mask and ival)  ne  0&mask=ishft(mask,-1);
		mask=ishft(mask,-1);
		dst.cen.elOnline            =(mask and ival)  ne  0&mask=ishft(mask,-1);
		mask=ishft(mask,-1);
		dst.cen.trkArrReInit        =(mask and ival)  ne  0&mask=ishft(mask,-1);
;  byte 3
		mask='80000000'xul;
		dst.cen.connectFilterOn     =(mask and ival)  ne  0&mask=ishft(mask,-1);
		mask=ishft(mask,-1);
		dst.cen.correctionsDisa     =(ishft(ival,-28)) and 3&mask=ishft(mask,-2);
		dst.cen.curAzElOffsetMode   =(mask and ival)  ne  0&mask=ishft(mask,-1);
		dst.cen.curRaDecOffsetMode  =(mask and ival)  ne  0&mask=ishft(mask,-1);
		mask=ishft(mask,-1);
		dst.cen.curOffsetMode       =(mask and ival)   ne 0&mask=ishft(mask,-1);
	endelse
	return,dst;
end
