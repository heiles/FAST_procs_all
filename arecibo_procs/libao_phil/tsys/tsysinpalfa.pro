;+
;tsysinpalfa - input tsys info for alfa receiver.
;SYNTAX: numfound=tsysinpalfa(rcvI,year=year)
;ARGS  :
;KEYWORDS:
;	year:	int  .. year to input. 1999,2000,... default is current year
;RETURNS:
;         istat: long   -1=error. ge 0 is the number found
;rcvI[numfound]: {tsysArec} return array of structures 
;					      tsysrec defined in ~phil/idl/tsys/tsys.h
;		
;-
; rcvnum   - number for feed
; rcvI  - return data here
;history:
;07dec03 - tsysinp broke when i added the lst line to the output
;          for ganesh back on 11nov03.
;
; date: 10 toks
; bm  :  0 toks
; tsys: 13 if or 12 if |***
function tsysinpalfa,rcvI,year=year
;
; 	open the file
;
	forward_function dmtodayno,montonum

	maxentry=2000
	a=bin_date()
	yearcur=a[0]
	yearl = keyword_set(year) ? year: yearcur
    rcvnum=17
	if yearl ne yearcur then begin
	name=string(format='("/share/obs4/rcvm/",i4,"/tsys.log",I0)',yearl,rcvnum)
	endif else begin
		name=string(format='("/share/obs4/rcvm/tsys.log",I0)',rcvnum)
		a=bin_date()
		yearl=a[0]
	endelse
	openr,lun,name,/get_lun,error=ioerr
	if (ioerr ne 0) then begin
    	printf,-2,!ERR_STRING;
		return,-1
	endif
	lineNum=0L
;
;	setup cal name to index mapping
;
	rcvI=replicate({tsysrecalfa},maxentry)
	l=''
	on_ioerror,hiteof
	gotpnt=0
	ind=0 
	numgood=0L     ; count good tsys each set
	while 1 do begin
		readf,lun,l
		if (strmid(l,0,1) eq '#' )  then goto,botloop
;		pararr=str_sep(strcompress(strtrim(l,2)),' ')
		pararr=strsplit(strcompress(strtrim(l,2)),' ',/extract)
	    numToks=(size(pararr))[1]
		case 1 of 
;
;			goood data line 13 entries rcvnum..
;
			numToks eq 13 : begin  
				    ibm=fix(pararr[1])
					rcvI[ind].digrms[*,ibm]=float(pararr[9:12])
					rcvI[ind].calVal[*,ibm]=float(pararr[3:4])
					rcvI[ind].tsys[0,ibm]=float(pararr[6])
					if (strmid(pararr[7],0,1) ne '*') then begin
						rcvI[ind].tsys[1,ibm]=float(pararr[7])
					endif
					rcvI[ind].freq        =float(pararr[2])
					numgood++
				end
;
;			12 |****  bad temp
;              |439.x big temp
;
			numToks eq 12 : begin  
				 ibm=fix(pararr[1])
				 got1=0            ; want at least 1 good temp
				 if (strlen(pararr[5]) gt 1) then begin
					pararr[5]=strmid(pararr[5],1) ; get rid of |
					if (strmid(pararr[5],0,1) ne '*') then begin
						rcvI[ind].tsys[0,ibm]=float(pararr[5])
					    got1++
				    endif
					if (strmid(pararr[6],0,1) ne '*') then begin
						rcvI[ind].tsys[1,ibm]=float(pararr[6])
					    got1++
				    endif
					if got1 gt 0 then begin 
						rcvI[ind].digrms[*,ibm]=float(pararr[8:11])
						rcvI[ind].calVal[*,ibm]=float(pararr[3:4])
					    rcvI[ind].freq         =float(pararr[2])
				        numGood++
					endif
				 endif
				 end
;
;			date line.. start of new entry.. 10 entries
;
			 (numToks eq 10): begin  
					if numGood gt 0 then begin
						ind=ind+1
					endif 
					if (ind ge maxentry) then begin
						ind=maxentry-1
						goto,toomany
					end
;
;				try and parse the date to daynumber
					daynum=dmtodayno( $
						long(pararr[2]),montonum(pararr[1]),long(pararr[4]))
 					tarr=strsplit(pararr[3],':',/extract)
					rcvI[ind].date=daynum + $
				long(tarr[0])/24. + long(tarr[1])/1440. + long(tarr[2])/86400.
					rcvI[ind].year=yearL
						rcvI[ind].az=float(pararr[7])
						rcvI[ind].za=float(pararr[8])
						rcvI[ind].lst=float(pararr[9])
					numGood=0
				 end
;
;			9   bm ..
;
			numToks eq 9 : begin  
				 end
			else: begin 
					print,'linenum:',lineNum,' badline:',l	
				  end
		endcase
botloop:
		lineNum++
	end
done:	free_lun,lun
	   numfound=ind+1
;
;	now build the struct to return
;
	if numfound gt 0 then begin
	   rcvI= rcvI[0:numfound-1]
	endif else begin
		rcvI=''
	endelse
return,numfound
hiteof:	if (not eof(lun)) then print,"ioerror:",!ERROR_STATE.MSG
		goto,done
toomany:print,"> 2000 entries. need to  increase array in tsysinpalfa.pro
end
