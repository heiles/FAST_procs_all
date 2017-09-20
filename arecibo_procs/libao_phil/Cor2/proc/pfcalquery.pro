;+
;pfcalquery - return hdr info pertaining to a set of calonoff's
;SYNTAX: pfcalquery,hdrscn,pfcalonoff,key,retval,
;ARGS:   
;		hdrscn[]	: {pfhdrsrt} header array
;		pfcalonoff[]: {pfcalonoff} returned from pfcalonoff
;		key:		string .. determine what to return
;	    retdat[]    : whatever the key determines it to be
;-
pro pfcalquery,hdrscn,cals,key,retval
;
;	
	npnts=(size(cals))[1]
	case key of 
;
;	return za of cal on
;
		'za'	: begin
				retval=hdrscn[cals.hind].hst[0].std.grttd*.0001
				  end
		'az'    : begin
				retval=hdrscn[cals.hind].hst[0].std.azttd*.0001
				  end
		'rfnum' : begin
				retval=ishft(hdrscn[cals.hind].hst[0].iflo.if1.st1 and $
						(lonarr(npnts) + 'f8000000'XL),-27)
				  end
		'frq'   : begin
				retval=fltarr(npnts)
				for i=0L,npnts-1 do begin
					retval[i]=$
				corhcfrtop(hdrscn[cals[i].hind].hst[cals[i].bind])
			    endfor 
			       end
		'tm'   : begin
				retval=hdrscn[cals.hind].hst[0].std.stscantime
			       end
		else    : begin 
			 print,'pfcalquery legal key: za az rfnum frq tm'
			 return
				  end
 	 endcase
	 return
end
