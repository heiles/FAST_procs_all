;+
;NAME:
;rfihistinp - input and sum a time range of histograms
;SYNTAX: rfihistinp,frq1,frq2,mon,prefix,hall,hinfo,freq,dir=dir
;ARGS:
;	frq1: long - starting frequency in Mhz
;	frq2: long - ending   frequency in Mhz
;  mon[]: long - array of yymm months to process
; prefix: string - any prefix that was prepended to hist file name
;			       (in case you were testing.. default is '')
;KEYWORDS:
;	 dir: string directory to find the histogram files. default is
;			     /share/megs/rfi/rms/histdat/
;RETURNS:
;  hall[n,3]: long [n,0] total counts in n bins	
;                  [n,1] total rfi counts in n bins	
;                  [n,2] total bad spectra in n bins	
; histinfo:{rfihistinfo} contains info on data in hall:frqst,end,binwidht,etc..
; freq[n] :    float     frequency for each bin.
;
;fileformat is:
;   prefixhsav_f1_f1.yymm
;
;-
pro rfihistinp,f1,f2,mon,prefix,hall,hinfo,freq,dir=dir 

    if n_elements(dir) eq 0 then dir='/share/megs/rfi/rms/histdat/'
    dirl=dir
    if strmid(dirl,0,1,/reverse_offset) ne '/' then dirl=dirl+'/'
    if n_elements(prefix) eq 0 then prefix=''
    nummon=n_elements(mon)
    start=1
    for i=0,nummon-1 do begin
        file=string(format='(a,a,"hsav_",i0,"_",i0,".",i4.4)',dirl,prefix,$
                             f1,f2,mon[i])
		if (file_exists(file) eq 0 ) then begin
         	print,file + ' does not exist'
		endif else begin
        	restore,file  ,/verbose
        	if start then  begin
           	  		 hall =histAr
               		hinfo=histinfo
				    start=0
               endif else begin
            		hall=hall+histAr        
        	endelse
	    endelse
    endfor
    freq=findgen(hinfo.totchn)*hinfo.frqstp + hinfo.frqst
    return
end
