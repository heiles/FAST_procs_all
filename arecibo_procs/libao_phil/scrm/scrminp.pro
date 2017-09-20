;+
;NAME:
;scrminp - input scrm records for a scramnet log file.
;SYNTAX: pnts=scrminp(lun,b,nptsreq,type)
;ARGS:
;       lun:    long    lun for file to read from
;   nptsreq:    long    number of recs to read in. if <=0 or not supplied
;                       then read to end of file.
;      type:    char    type of data we're inputting: "pnt" or "agc"
;RETURNS:
;       b[] :   {}      return array of scram block.either{scrmagc} or {scrmpnt}
;      pnts :    long   return the number of points input.
;
;KEYWORDS:
;DESCRIPTION:
;   scrminp is normally called from scrmagcinpday or scrmpntinpday
;-
;
function scrminp,lun,b,npts,type
;
;   get the file size, what is left to read
;
	case (1) of
		strmatch(type,"pnt",/fold_case): st={PNT_STATE}
		strmatch(type,"agc",/fold_case): st={AGC_STATE}
		else: begin	
			print,"type is pnt or agc"
			return,-1
		    end
	endcase
	a={     log: 0ULL,$ ; log time 
             rd: 0ULL,$	; time read was complete
	        blk: 0ULL $ 	; timestamp for block
	  }
	rec={ tm:a ,$
		  st:st $
	    }
	recsize=n_tags(rec,/data_length)
    fst=fstat(lun)
    pntsleft=(fst.size-fst.cur_ptr)/recsize
    nptsl=npts
    if nptsl le 0 then nptsl=pntsleft
    if pntsleft lt npts then nptsL=pntsleft
    if pntsleft le 0 then return,0
    inppnts=nptsl
;
;    allocate the buffers
;
	b=replicate(rec,nptsL)
    readu,lun,b
    return,n_elements(b)
end
