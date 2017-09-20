;+
;tsysinp - input tsys info for 1 receiver.
;SYNTAX: numfound=tsysinp(rcvnum,rcvI,year=year)
;ARGS  :
;		rcvnum: int receiver number 1-16..
;KEYWORDS:
;	year:	int  .. year to input. 1999,2000,... default is current year
;RETURNS:
;         istat: long   -1=error. ge 0 is the number found
;rcvI[numfound]: {tsysrec} return array of structures 
;					      tsysrec defined in ~phil/idl/tsys/tsys.h
;		
;-
; rcvnum   - number for feed
; rcvI  - return data here
;history:
;07dec03 - tsysinp broke when i added the lst line to the output
;          for ganesh back on 11nov03.
;
function tsysinp, rcvnum,rcvI,year=year
;
; 	open the file
;
	forward_function dmtodayno,montonum

	maxentry=2000
	a=bin_date()
	yearcur=a[0]
	yearl = keyword_set(year) ? year: yearcur
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
;
;	setup cal name to index mapping
;
    tsyscaltypes,calA
	calAvail=intarr(8) 
	inparr=replicate({tsysrec},maxentry)
	l=''
	on_ioerror,hiteof
	gotpnt=0
	ind=-1
	while 1 do begin
		readf,lun,l
		if (strmid(l,0,1) eq '#' )  then goto,botloop
;		pararr=str_sep(strcompress(strtrim(l,2)),' ')
		pararr=strsplit(strcompress(strtrim(l,2)),' ',/extract)
		numToks=(size(pararr))[1]
		case 1 of 
;
;			data line 6 entries rcvnum..
;
            (numToks eq 6) or (numtoks eq 12) : begin
					itemp=where(calA eq pararr[1],count)
					if (count eq 1) then begin
						cind=itemp[0];
						if ((cind ge 0) and (cind le 7)) then begin
							inparr[ind].ct[cind].calV[0] =float(pararr[2])
							inparr[ind].ct[cind].calV[1] =float(pararr[3])
							inparr[ind].ct[cind].tsysV[0]=float(pararr[4])
							inparr[ind].ct[cind].tsysV[1]=float(pararr[5])
							calAvail[cind]=1
						endif
					endif
				end
;
;			rcv  line 17 entries
;
			numToks eq 17 : begin  
					inparr[ind].freq=float(pararr[2])
					inparr[ind].if1Pwr[0]=float(pararr[7])
					inparr[ind].if1Pwr[1]=float(pararr[8])
					inparr[ind].if2Pwr[0]=float(pararr[10])
					inparr[ind].if2Pwr[1]=float(pararr[11])
					inparr[ind].corPwr[0]=float(pararr[13])
					inparr[ind].corPwr[1] =float(pararr[14])
					inparr[ind].corAttn[0]=float(pararr[15])
					inparr[ind].corAttn[0]=float(pararr[16])
				 end
;
;			date line.. start of new entry.. 8 entries
;
			 (numToks eq 8) or (numToks eq 10): begin  
					ind=ind+1
					if (ind ge maxentry) then begin
						ind=maxentry-1
						goto,hiteof
					end
;
;				try and parse the date to daynumber
					daynum=dmtodayno( $
						long(pararr[2]),montonum(pararr[1]),long(pararr[4]))
;					tarr=str_sep(pararr[3],':')
 					tarr=strsplit(pararr[3],':',/extract)
					inparr[ind].date=daynum + $
				long(tarr[0])/24. + long(tarr[1])/1440. + long(tarr[2])/86400.
					if numToks eq 8 then  begin
						inparr[ind].az=float(pararr[6])
						inparr[ind].za=float(pararr[7])
					endif else begin
						inparr[ind].az=float(pararr[7])
						inparr[ind].za=float(pararr[8])
					endelse
				 end
			else: begin 
					print,'badline',l	
				  end
		endcase
botloop:
	end
hiteof:	free_lun,lun
	   numfound=ind+1
;
;	now build the struct to return
;
	if numfound gt 0 then begin
	rcvI={rcvnum : rcvnum, numrecs:numfound,year:yearl,calAvail:calAvail,$
		        r: temporary(inparr[0:numfound-1])}	
	endif else begin
		rcvI=''
	endelse
return,numfound
end
