;+
;NAME:
;masonofffind - find onoff position switch patterns
;SYNTAX: n=masonofffind(projId,
;               patI,npat,upatIdAr,nsrc,usrcAr,$
;               yymmdd=yymmdd,appbm=appbm,dirI=dirI,bm=bm,band=band,grp=grp)
;ARGS:
;projid: string project id to search for
;KEYWORDS:
;yymmdd: long    yyyymmdd limit to this date
; appbm:         apply bm number to each directory. This should normally
;                be set:
;dirI[2]: string if data not in default /share/pdataN/pdev
;                see masfilelist for usage.
;bm     : int    if supplied limit to this beam
;band   : int    0,1 limit to this band. Note if you have single pixel
;                data you probably should set band=1 or masfilelist may
;                not find the files.
;grp    : int    limit to this group 0, or 1.
;
;RETURNS:
;   n   :int     number proccessed patterns. Each pointing pattern
;                can generate multiple processed patterns if you use
;                multple bms.
;patI[n]:		 info on processed patterns
;npat   : int    number of pointing patterns executed.
;nsrc   : int    number of unique sources
;srcAr[nsrc]: string list of sources used.
;
; patI STRUCTURE:
;	- there will be one entry for each pattern and bm used
;     If you have 4 bms then a single patId will have 4 entries
;     in patI[]
;
;      patI[i].srcNm      - source name
;      patI[i].nscans     - # of scans in pattern ..
;      patI[i].bm        - bm number 0..6
;      patI[i].grp       - grp 0 or 1
;      patI[i].flist[maxScans]  - list of filenames: 
;                                same orde as scanTypeAr
;      patI[i].sumI[maxScans]  - summary info for each scan 
;
;DESCRIPTION:
;	Find all of the onoff patterns the given project and constraints.
;The routine accepts the same parameters at masfilelist:
; yymmdd=,dirI=,bm=,band=,grp=num=,appbm=appbm
;The routine will pass back an array of patI structs holding info on 
;each pattern. 
;
;	There is a distinction between a pointing pattern and a processed 
;dataset. You can have multiple processed datasets for each pointing
;pattern if you used multiple beams or groups.
;	
;
;EXAMPLE:
;
;1.	Find the onoff info for project a2516 on 20100930 group 0.
;   n=masonofffind('a2516',patI,npat,upatIdAr,nsrc,usrcAr,$
;                yymmdd=20100930,grp=0,band=1,/appbm)
;       patI[n] - holds the info
;       npat    - number of pointing patterns found
;       upatIdAr[npat] - unique pattern id for each pointing pattern.
;                 This can include multiple patI[] entries if multiple
;                 bms taken on each pointing pattern.
;       nsrc    - Number of unique on source names found
;       usrcAr[nsrc] - list of source names.
;
;2. now process all of the patterns found using group 0 bm 1.
;   ii=where((patI.grp eq 0 ) and (patI.bm eq 0),cnt)
;   for i=0,cnt-1 do begin
;       j=ii[i]				; index in patI for this dataset
;       istat=masposonoff(patI[j].filelist,b,...params for masposonoff)
;       if i eq 0 then b0ar=replicate(b[0],cnt); generate large array
;       b0ar[i]=b
;  endfor
;
;  this assumes that all of the bm=0 data sets have the same
;  number of channels (since we are trying to store them all in an array).
;
;3. plot out the first set of results
;   masplot,b0ar[0]
;
;-
function masonofffind,projId,$
                    patI,npatId,upatId,nsrc,usrcar,$
			yymmdd=yymmdd,appbm=appbm,dirI=dirI,$
			bm=bm,band=band,grp=grp
;
	obsModeAr =["ONOFF","ONOFF","CAL","CAL"]
	scanTypeAr=["ON","OFF","ON","OFF"]
	minScanPat=2
	recCntMatch=[-1,0,-1,2]
	n=maspatfind(projId,obsModeAr,scanTypeAr,minScanPat,recCntMatch,$
                   patI,npatId,upatId,nsrc,usrcar,$
			yymmdd=yymmdd,appbm=appbm,dirI=dirI,$
			bm=bm,band=band,grp=grp)
	return,n
end
