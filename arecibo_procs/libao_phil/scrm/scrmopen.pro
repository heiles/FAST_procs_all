;+
;NAME:
;scrmpntopen - open an agc scramnet log file
;SYNTAX: lun=scrmopen(yymmdd,type,dirL=dirL,dirUsed=dirUsed,fnameUsed=fnameUsed)
;ARGS:
;    yymmdd:    long    data to open
;    dirL[]:  string   list of directories to include in default search path
;RETURNS:
;lun    : long   lun for open file. -1 if open failed
;dirUsed: string  directory used (with trailing /)
;fnameUsed: string basename used
; 
;DESCRIPTION:
;   scrmopen is normally called from scrmpntinpday or scrmagcinpday.
;-
function scrmopen,yymmdd,type,dirL=dirL,dirUsed=dirUsed,fnameUsed=fnameUsed
;
	yymm=string(format='(i02.2,i02.2)',yymmdd/10000L,(yymmdd/100L) mod 100L)
	dirArDef=["/share/pdata1/pdev/scramLog/"]
	dirAr=dirArDef
	for i=0,n_elements(dirL)-1 do begin
		d=dirL[i]
		if strmid(d,0,1,/reverse_offset) ne '/' then d=d+'/'
		dirAr=[d,dirAr]
	endfor
	case (1) of
		strmatch(type,"pnt",/fold_case):typel="pnt"
		strmatch(type,"agc",/fold_case):typel="agc"
		else: begin
			print,"type is agc or pnt"
			return,-1
		end
	endcase
	fnameUsed=string(format='(a,i06.6,".dat")',typel,yymmdd)
	if (file_exists(fnameUsed,fullname,dir=dirAr) eq 0) then begin
		msg="could not open " + fnameUsed
		print,msg
	    return,-1
	endif
	err=0
	openr,lun,fullname,error=err,/get_lun
	if err ne 0 then begin
		msg="could not open " + fnameUsed
		print,msg
	    return,-1
	endif
	return,lun
end
