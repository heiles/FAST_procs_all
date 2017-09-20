;NAME:
;puprgethdr - get the puppi block header
;SYNTAX: istat=puprgethdra(lun,hdrI)
;ARGS:
;   lun:        lun pointing to file to read
;RETURNS:
;  istat:  1 ok
;           0 hit eof reading header
;          -1 i/o error reading file
;          -2 no header info in file
;          -3 no END header card after 1000 cards
;   hdrI:  {} return info with header info
;DESCRIPTION:
;   Input an puppi raw ascii header starting at the current 
;file position. Return the header Info in hdrI
;hdrI.hdrLines[] holds the asci cards. A subset of this
;is decoded in hdrI.xx
;-
function puprgethdr,lun,hdrI
;
;
   common puprcom,puprnluns,puprlunar

;
;   look reading the ascci header till we hit end (or max lines)
;
	on_ioerror,ioerr
	maxLines=200L
	hdrI={ posSt: 0LL , $; starting byte
		hdrBytes: 0L  , $; bytes in header. add to pos1 to get block start
		nlines  : 0L  , $; number of "good" header lines (exclude End).
	    maxLines: maxLines, $; max number header lines we store
	    hdrLines:strarr(maxLines),$
		partialDataBlk:0,$	; if true then only part of data block present.
                            ; only part of file copied??

;
;	selected elements from hdrLines decoded..
;   
		src_name: '',$
        ra_str  : '',$	
        dec_str  : '',$	
        frontEnd : '',$
		obsFreq  : 0D,$
        obsBw    : 0d,$
        obs_mode : '',$
		cal_mode : '',$
        scanLen  : 0d,$
        pktfmt   : '',$
        cal_freq : 0d,$
		obsNchan : 0L,$
	    nbits    : 0L,$
        pfb_over : 0L,$
        nbitsADC : 0l,$
        nrcvr    : 0l,$
        only_I   : 0l,$
 		dataDir  :'',$
        nbitsReq : 0L,$    
        stt_smjd : 0L,$ 
        stt_offs : 0L,$ 
        scanNum  : 0L,$ 
        basename : '',$ 
        tbin     : 0d,$ 
        chan_bw  : 0d,$ 
        ra       : 0d,$
        dec      : 0d,$
        az       : 0d,$
        za       : 0d,$
        fftlen   : 0l,$
        overlap  : 0l,$
        blocsize : 0l,$
        DAQPULSE : '',$
        DAQSTATE : '',$
        DISPSTAT : '',$
        DISKSTAT : '',$
        NETSTAT  : '',$
        DROPAVG  :  0d,$
        DROPTOT  :  0d,$
        DROPBLK  :  0L,$
        STTVALID :  0L,$
        CURBLOCK :  0L,$
        STT_IMJD :  0L,$
        PKTIDX   :  0L,$
        PKTSIZE  :  0L,$
        NPKT     :  0l,$
        NDROP    :  0l}
;
	point_lun,-lun,curPos
	posSt= curPos
;		
	cinp=bytarr(80)
	nlines=0L
	hdrLines=strarr(maxLines)
	for i=0,maxLines-1 do begin &$
		readu,lun,cinp &$
		if (strmid(cinp,0,3) eq 'END') then  break &$
	    hdrLines[nlines]=string(cinp) &$
	    nlines++ &$
    endfor
	if nLines eq 0 then begin
		print,"No header info found."
	    return,-2		
	endif
	if nlines eq maxLines then begin
		print,"No END card found in hdr after ",maxLines," lines"
	    return,-3
	endif
;
	point_lun,-lun,curPos
	hdrBytes=long(curPos - posSt)
;	 now loop creating the hdr struct
;
	key=''
	val=''
	icur=0L
	for  i=0,nLines-1 do begin &$
		a=strsplit(hdrLines[i],"=",/extract) &$
		if n_elements(a) ne 2 then begin
;;			print,"Warning. hdrLine",i," blank.(after hdrKey:)",key
		    continue
		endif
		key=a[0] &$
		val=a[1] &$
;
;		if value doesn't start with a quote, " then it's a number
;
		if (strpos(strmid(val,0,2),"'") eq -1) then begin &$
;
;		if a . then double, else long
;
			val=(strpos(val,'.') ne -1  )?double(strtrim(val,2)):long(strtrim(val,2)) &$

		endif else begin &$
;           get rid of leading blanks, quotes
			i0=strpos(val,"'")+1 &$
			i1=strpos(val,"'",/reverse_search) -1 &$
			val=strtrim(strmid(val,i0,i1-i0+1)) &$
		endelse &$
		key=strtrim(a[0]) &$
		if icur eq 0 then begin &$
			hdrs=create_struct(key,val) &$
		endif else begin &$
			hdrs=create_struct(hdrs,key,val) &$
		endelse &$
		icur++ &$
	endfor
;
;  so a struct assign it does relaxed struct assign.
;  
	struct_assign,hdrs,hdrI
;
;	this blanks hdrI elements not in strs. need to fill then in nows
;
    hdrI.posSt   =posSt
    hdrI.hdrBytes=hdrBytes
    hdrI.nlines  =nlines
    hdrI.maxLines=maxLines
    hdrI.hdrLines=hdrLines
	return,1
ioerr:
	if (eof(lun)) then begin
		return,0
	endif
	print,!err_string
	return,-1
end
