;+
;NAME:
;pupffilelist - get list of puppi files 
;SYNTAX: nfiles=pupffilelist(dirBase,flist,seqI,yymmdd=yymmdd,$
;				mjd=mjd,src=src ,seqNum=seqNum
;
;ARGS:
;   dirBase: char    base directory to start search
;                    if '' then use default /share/pdata
;
;KEYWORDS:
; yymmdd   : long    date for data you want (this is an AST date)
;    mjd   : long    mjd for data (instead of yymmdd)
;    src   : string  limit to this source name
;  seqNum  : long    limit to this seq num puppi_mjd_src_seqnum
;              
;RETURNS:
;   nfiles    : long  number of .fits files found
;flist[nfiles]: string  array of filenames
;  seqI[nseq] : {} seq info for each sequence
;
; 
;DESCRIPTION:
;   Search for puppi psrfits files.
; Example:
;   Assume files in "/local/data/phil/puppi/"
;  n=pupffilelist(dir,flist,yymmdd=120309,src='1713+0747')
;
;
;-
function pupffilelist,dirBase,flist,seqI,yymmdd=yymmdd,mjd=mjd,$
			src=src,seqnum=seqnum
;
;	build the regex to find the files
;

	seqInfo={fname:'', $
	   mjd : 0L, $
	   srcNm:'',$
	   seqNum:0L,$
	   nfileSeq:0l,$; number of files in sequence
	   obsNum:0l  ,$;  MJD_SEQNUMSt .  all obs of 1 source 
	   nseqObs:0l}  ; number of seq this obs
		
	mjdtojd=2400000.5D
	astToUtc=4D/24d
	dirL=dirBase
	if (strmid(dirBase,0,/reverse_offset) ne '/') then dirL+='/'
;
	seqNumL=(n_elements(seqnum) eq 0)?-1:seqnum
;
	srcL=(n_elements(src) eq 0)?'*':src
;	
	mjdL=-1L
	if n_elements(yymmdd) gt 0  then begin
	    mjdL=long((yymmddtojulday(long(yymmdd))  + astToUtc) - mjdToJd)
	endif
;
	if keyword_set(mjd) then mjdL=mjd
;
	cmd='puppi_'
	cmd+=(mjdL eq -1)?'*_':string(format='(I5,"_")',mjdL)
	cmd+=srcL  + '_'
	cmd+=(seqNumL eq -1)?'*_':string(format='(i04,"_")',seqNumL)
	cmd+="*.fits"
;	print,"dir + cmd:",dirL+cmd
	flist=file_search(dirL+cmd)
	nfiles=n_elements(flist)
	if (flist[0] eq '') then begin
		return,0
	endif
;
;	find the different sequences ..
;                              mjd     srcNm   seqnum
	a=stregex(flist,".*/puppi_([^_]*)_([^_]*)_([^_]*)",/subex,/extract)
	mjdL=reform(long(a[1,*]))
	srcNmL=reform(a[2,*])
	seqNumL=reform(long(a[3,*]))
;	uniq number of seq.. add mjd in case the restart the seq nums
	aa=mjdL*10000L + seqNumL
	useq=uniq(aa,sort(aa))
	nseq=n_elements(useq)
	seqI=replicate(seqInfo,nseq)
	umjd=mjdL[uniq(mjdL,sort(mjdL))]

	icur=0
	obsNum=-1L
	lastSeqStartTm=-1D
	for imjd=0,n_elements(umjd)-1 do begin
		mjd1=umjd[imjd]
		iim=where(mjdL eq mjd1)
		seqLd=seqNumL[iim]
		useqLd=seqLd[uniq(seqLd,sort(seqLd))]
		for iseq=0,n_elements(useqLd)-1 do begin
			seq1=useqLd[iseq]
			jj=where((mjdL eq mjd1) and (seqNumL eq seq1),cntseq)
			jj=jj[0] 
			seqI[icur].fname=flist[jj]
			seqI[icur].mjd  =mjd1
			seqI[icur].srcNm=srcNmL[jj]
			seqI[icur].seqNum=seq1
			seqI[icur].nfileSeq=cntseq
			openr,lun,flist[jj],/get_lun
			fs=fstat(lun)
			free_lun,lun
			if (obsNum lt 0L) then begin
				obsNum=mjd1*10000L + seq1
				lastSeqStartTm=fs.mtime
			endif
			newObs=1
			if (icur gt 0) then begin
				if (seqI[icur-1].srcNm eq seqI[icur].srcNm) and $
					((fs.mtime - lastSeqStartTm) lt 3600*12d) then newObs=0
			endif
			if (newObs) then begin
			 	obsNum=seqI[icur].mjd*10000L + seqI[icur].seqNum
			endif
			seqI[icur].obsNum=obsNum
			lastSeqStartTm=fs.mtime
			icur++
		endfor
	endfor
	uobsNum=seqI[uniq(seqI.obsNum,sort(seqI.obsnum))].obsNum
	for i=0,n_elements(uobsNum)-1 do begin &$
		ii=where(seqI.obsNum eq uobsNum[i],cnt) &$
		seqI[ii].nseqObs=cnt &$
	endfor
	return,nfiles
end 
