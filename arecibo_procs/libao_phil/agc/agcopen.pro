;+
;NAME:
;agcopen - open log file
;SYNTAX: lun=agcopen(yymmdd,dirL=dirL,dirUsed=dirUsed,fnameUsed=fnameUsed)
;ARGS:
;    yymmdd:    long    data to open
;    dirL[]:  string   list of directories to include in default search path
;RETURNS:
;lun    : long   lun for open file. -1 if open failed
;dirUsed: string  directory used (with trailing /)
;fnameUsed: string basename used
; 
;DESCRIPTION:
;   agcinp is normally called from agcmoninp or agcinpday.
;-
function agcopen,yymmdd,dirL=dirL,dirUsed=dirUsed,fnameUsed=fnameUsed
;
	yymmddL=yymmdd
	if yymmddL gt 991231L then yymmddL-=20000000L
	yymm=string(format='(i02.2,i02.2)',yymmddL/10000L,(yymmddL/100L) mod 100L)
	dirArDef=["/share/obs1/pnt/log/","/share/phil/bkup/pnt/"+yymm + '/']
	dirAr=dirArDef
	for i=0,n_elements(dirL)-1 do begin
		d=dirL[i]
		if strmid(d,0,1,/reverse_offset) ne '/' then d=d+'/'
		dirAr=[d,dirAr]
	endfor
	fnameUsed=string(format='("cbFb",i06.6,".dat")',yymmddL)
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
