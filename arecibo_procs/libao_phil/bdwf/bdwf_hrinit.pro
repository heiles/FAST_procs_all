;+
;NAME:
;bdwf_hrinit - initialize for high res run
;SYNTAX:bdwf_hrinit,avgrow,yyyymmdd,rcvnum,srcToGet,proj,fileNumDat,$
;			savFileDir,hrI
;ARGS:
;  avgRow: int    1-->average spectra in row. gives .9 sec resolution
;                 0-->do not avg spectra in row. gives .1 sec resolution
;yyyymmdd:long    date for file
;rcvNum  :long    rcvr number (5=lbw, 7=sbw,8=sbh,9=cb,10=cbh,11=xb)
;srcToGet:string  srcname (in file header)
;proj    :string  project id (in filename)
;fileNumDat:int   file number for data (in file to process)
;                 (this is the data number, not the cal number)
;savDirNm:string  directory that holds save files (and 
;                 created binary files).
;
;RETURNS:
;   hrI :   struct containing above info;
;DESCRIPTION:
;	Call bdwf_hrinit to load the hrI struct with parameters for this run.
;On return the hrI struct will contain:
;
;This struct is then passed to the other bdwf_hr routines for processing.
;-
;  
pro bdwf_hrinit,avgrow,yyyymmdd,rcvnum,srcToGet,proj,fileNumDat,$
			savDirNm,hrI
;
	yy    =yyyymmdd/10000L mod 100L
	monNum=yyyymmdd/100l mod 100L
	day   =yyyymmdd mod 100L
	ldate=string(format='(i02,a,i02)',day,monname(monNum),yy)
	if (rcvnum lt 1) || (rcvnum gt 17) then begin
		print,"bad rcvNum:",rcvNum,' should be 1,2,5,7,8,9,10,11,12, or 17'
		return
	endif
	; this info from boutsave[0].h
	hdrI={ object: '',$ from boutsave[0].h.object
		   yyyymmddUtc:0L,$ ; start scan from .h.datexxobs
		   secMidUtc  :0d,$ ; from crval5
		   tmStp      :0d,$ ; secs. two samples in image
		   nrows      :0L,$ ; in 
		   ndumps     :0L}  ; after averaging

	lsavDirNm=savDirNm
	if (strmid(lsavdirNm,0,1,/reverse) ne '/') then lsavDirNm+='/'
        
	hrI={ yyyymmdd:yyyymmdd,$
		  ldate   :ldate,$
		  srcToGet: srcToGet,$
		  avgrow  : avgRow,$
		  rcvNum  : rcvNum,$
		  proj    : proj,$
		  fileNumDat:fileNumDat,$
	      savDirNm:lsavDirNm,$
		  nsavFiles:0l ,$ number of save files we generated
		  savFileNms:strarr(10), $ ;complete savefilenames
		  pntsEachScan:lonarr(10),$ ; in case more than 1 scan
		  hdrI    : hdrI		 $  ; loaded in hrmakesave

		}	
	return
end
