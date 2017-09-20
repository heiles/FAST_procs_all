;+
;NAME:
;immultiday - make multi day plots (spc or imgs) of hilltop data at 1 freq.
;SYNTAX: stat=immultiday(yymmdd,freq,outfile,daysPerPage=daysPerPage,$
;                        ndays=ndays,spc=spc,singleCol=singleCol)
;ARGS:
;yymmdd:  long   date to start on
;freq  :  long   freq of intm mon to use
;outfile: string filename for output. You don't need to
;                supply the .pdf suffix.
;                a temp file outfile.ps will be created and deleted
;                during the processing.
;KEYWORDS:
;daysPerPage: int  number of days per page. def=8
;ndays      : int  number of days to plot. def=daysPerPage
;spc        : int  if set then output average spectra. 
;                  def=dynamic spectra
;                    def="img"
;singleCol  :      if set then force 1 column output
;RETURNS:
;	stat:   1 ok, 0 we had trouble
;-
function immultiday,yymmdd,freq,outfile,daysPerPage=daysPerPage,$
					ndays=ndays,spc=spc,singleCol=singleCol
;
	spcL= (keyword_set(spc))?1:0
	retstat=0
	if n_elements(daysPerPage) eq 0 then daysPerPage=8
	if n_elements(ndays) eq 0 then ndays=daysPerPage
	dohardcopy=-1
	freqList=[70,165,235,330,430,550,725,955,1075,1325,1400,2200,3600,4500,5500,6500,7500,8500,9500]
;	if spc then begin
;		print,"/spc option for average spectra has not yet been implemented..bug phil.."
;		return,0
;	endif
;
;   make sure their freq is valid
;
	ii=where(freq eq freqList,cnt)
	if cnt eq 0 then begin
		print,"Invalid request freq:",freq
		print,"Valid freqs are:",freqList
		goto,done
	endif
	daysLeft=ndays
	jd=yymmddtojulday(yymmdd)
;
; 	limit days to not go beyond today 
;   note that systime uses local time not gmt.
;   so midnite local is xxxx.5
;
	jdToday=systime(/julian)
	if (jd gt jdToday) then begin
		print,"yymmdd can not be in the future"
		return,0
	endif
	nn=long(jdToday-jd) + 1
	if ( daysLeft gt nn) then daysLeft=nn
	dohardcopy=-1
;
; 	strip off .ps or .pdf (assume lower case)
	filename=outfile
	if ((ipos=strpos(filename,".ps",/reverse_search) ne -1) or  $
	    (ipos=strpos(filename,".pdf",/reverse_search) ne -1)) then begin
		filename=strmid(filename,0,ipos)
	endif
	filenameps=filename + ".ps"
	filenamepdf=filename + ".pdf"
	
	while daysLeft gt 0 do begin
		caldat,jd,mon,day,yr
		yr2=yr mod 100L
		nplts=(daysLeft < daysPerPage)
		if (spcL) then begin
			immosavg1frq,yr2,mon,day,dohardcopy,freq=freq,nplts=nplts,bpc=bpc,file=filenameps
		endif else begin
			immosimg1frq,yr2,mon,day,dohardcopy,freq=freq,nplts=nplts,bpc=bpc,file=filenameps,$]
				singleCol=singleCol
		endelse
		dohardcopy=-2
		daysLeft-=nplts
		jd+=nplts
	endwhile
;
;	now create .pdf file
;
    hardcopy
	cmd="/usr/bin/ps2pdfwr " + filenameps + " " + filenamepdf
    spawn,cmd,result,errresult
;	immosreset
	file_delete,filenameps
	retstat=1
done:  return,retstat
end
