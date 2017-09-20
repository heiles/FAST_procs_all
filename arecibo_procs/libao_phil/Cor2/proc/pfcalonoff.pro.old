;+
;pfcalonoff - extract calon/off scans and compute cal size and tsys.
;SYNTAX: ncals=pfcalonoff(hdrscn,pfcalonoff)
;ARGS:
;		 hdrscn[] : {pfhdrstr} array of headers input by pfinphdrs.
;ret  pfcalonoff[]: {pfcalonoff} array of cal info returned..
;ret   ncals 	  :  long       number of cal measures. npairs*nbrds*nsbc
;DESCRIPTION:
; 	For each sbc of each board of each calon/off pair compute
;   calval : calK
;	calscl : CalK/(calon-caloff)
;   tsyson   K
;   tsysoff  K
;	and also return indices into hdrscn[] so you can match a calon/off
;   measurement with the correct integration,board,sbc.
;-
function pfcalonoff,hdrscn,pfcalonoff 
;
	npairs=pfchkcalonoff(hdrscn,indarr)
	if npairs eq 0 then goto,done
	maxcals=npairs*4L*2L 		; max number possible in npair calon/offs
	pfcalonoff=replicate({pfcalonoff},maxcals); max number we can have
;
;	we need to individually look up the cal value for each board of each
;   on/off pair..
;
	cind=0L
	eps= 1e-4
	for i=0,npairs-1 do begin
;
; 		loop over the boards in a pair
;
		onInd=indarr[i]				; index in hdrscn for calOn
		for j=0,hdrscn[onind].nbrds-1 do begin
;
; 			get the cal value.. returned as polA, polB in calval
;			we fix it up to match the pol order  in the sbc 
;
	        if corhcalval(hdrscn[onind].hst[j],calval) ne 1 then begin
                print,"err:corhcalval."
				npairs=0
				goto,done
            endif
			pol=hdrscn[onind].pol[*,j]
			numpol=1
			if pol[1] ne 0 then numpol=2
;
;			loop over sbc of this board
;
			for k=0,numpol-1 do begin
;
;			bookkeeping indices so we can go back to hdrscn[] and get the
;			info for this integration,board, and sbc of board..
;
		    	pfcalonoff[cind].pol=pol[k]
		    	pfcalonoff[cind].hind=onInd	; index into hdrscn[] calOn 
		    	pfcalonoff[cind].bind=j	    ; index into board
		    	pfcalonoff[cind].sind=k	    ; index sbc for this board
;
;			compute calOn - calOff then scale on,off Tsys to kelvins
;
		        pfcalonoff[cind].calval=calval[pol[k]-1]; 1,2 --> 0,1
	            delta=hdrscn[onInd].avglag0pwr[k,j] - $
				      hdrscn[onInd+1].avglag0pwr[k,j]
				if (delta lt eps) then begin
	            	pfcalonoff[cind].calscl =0.
				endif else begin
	            	pfcalonoff[cind].calscl =pfcalonoff[cind].calval/delta
				endelse
	            pfcalonoff[cind].tsyson =hdrscn[onInd].avglag0pwr[k,j] * $
									     pfcalonoff[cind].calscl
	            pfcalonoff[cind].tsysoff =hdrscn[onInd+1].avglag0pwr[k,j] * $
									      pfcalonoff[cind].calscl
			    cind=cind+1L
			endfor
		endfor
	endfor
;
;	now resize array to have the number we actually found
;	
	if cind ne maxcals then pfcalonoff=pfcalonoff[0:cind-1]
	
done:
	return,cind
end
