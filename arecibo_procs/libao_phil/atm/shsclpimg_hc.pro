;-
;NAME:
;shsclpimg_hc: make hardcopy image of decoded clp file
;SYNTAX:istat=shsclpimg_hc,inpDir,fbase,bandToUse,outDir,ofilePrefix,htmlUrl,htmlfName,$
;				   cfrAr, tmStep=tmStep,fnumstart=fnumstart,bpcind=bpcind,medlen=medlen,$
;                  bw=bw,nsig=nsig,zx=zx,zy=zy,title=title,nhghts=nhghts,fiarOut=fiarOut,$
;					htmlAr=htmlAr,noimg=noimg,usefiarout=usefiarout,allimg=allimg
;ARGS:
;inpDir: string     input directory of reduced files to process
;fbase: string      basename for input files in directory:'t2686_09feb2013_'
;bandToUse: int     1,2, or 12 for both
;outDir: string     where to write the images
;ofilePrefix: string  prepend to output files (in case differnt types of data
;                   in output directory with same data,fnum)'
;htmlUrl:string    url for links to gif images for html table,if '' then no html file
;htmlfName:string   file name for html file to create (in outdir)
;                   in outDir
;cfrAr[2]:float     cfr for bands.if 1 band then just use cfrar[0]
;
;KEYWORDS:
;tmStep   :long     second between each recorded image to output
;fnumStart:long     first filenum in inpdir to use 
;fnumEnd:long       last  filenum in inpdir to use. default all. 
;bpcInd[2]:long     first last height indices to use for bpc
;                   default last 100 hghts
;medlen:   long     length median filter each spc. default=71 channels
;nsig: float        for scaling the image. default=6 sigma
;zx  : int          scaling for x axis (neg is smaller)
;zy  : int          scaling for y axis (neg is smaller)
;nhghts:int         limit to this number of heights (def all)
;title: string      title
;noimg: int         if set then don't make images, just return
;                   fiarout.. files we'll use 
;userfiarout: int   if set then use whatever is passed in via fiarout to
;                   make the images
;nsig[2]: float     clip to -nsig[0],nsig[1] sigmas
;ftype  : string    file type: gif,png,jpg
;allimg :           if set then output all imgs in file. if not, just the first
;
;RETURNS:
;
;istat:    >=0      number of images we made
;          -1       error
;fiarOut[]: {}      array of structs holding info on output files
;
;DESCRIPTION:
;   Make a dynamic spectra image of decoded shs file (.dcd) and then write
;the graphics file to disc. Do this for all of the files in the inpdir subject
;to:
; - start at firstFnum
; - make a plots every tmSpace secs
;
;-
function shsclpimg_hc,inpDirU,fbase,bandToUse,outDir,ofilePrefix,htmlUrl,htmlFname,$
		 cfrAr, tmStep=tmStep,fnumstart=fnumstart,fnumend=fnumend,bpcind=bpcind,medlen=medlen,bw=bw,$
         nsig=nsig,zx=zx,zy=zy,title=title,nhghts=nhghts,fiarOut=fiarOut,$
		 htmlAr=htmlAr,noimg=noimg,usefiarout=usefiarout,ftype=ftype,allimg=allimg
;
  forward_function shsclpmonimgscan

	usehtml=htmlUrl ne ''
	if n_elements(ftype) eq 0 then ftype='gif'
	ofileSuf=''
	useGif=0
	usePng=0
	useJpg=0
	if (ftype eq 'gif') then begin
		useGif=1
		ofileSuf='.gif'
	endif 
	if (ftype eq 'png') then begin
		usePng=1
		ofileSuf='.png'
	endif
	if (ftype eq 'jpg') then begin
		useJpg=1
		ofileSuf='.jpg'
	endif
	if ofileSuf eq '' then begin
		print,"Unknown output file type. allowable values: gif png jpg"
		return,-1
	endif
    if n_elements(nhghts) eq 0 then nhghts=-1
    if n_elements(fnumStart) eq 0 then fnumStart=0L
    if n_elements(fnumEnd) eq 0 then fnumEnd=99999L
	fnumStart=(fnumStart > 0)
    if n_elements(tmStep) eq 0 then tmStep=3600.
	case (bandToUse) of 
	 	1:  BandAr=[1]
		2:  bandAr=[2]
		12: bandAr=12
	   else: begin
			print,"BandToUse is 1,2, or 12. ",bandToUse," is illegal"
			return,-1
		    end
	endcase
		
    zx=(bandAr eq 12)?-6:-4
    winsToUse=1                     ; 1 or 2 simultaneous windows
    if n_elements(zy) eq 0 then  zy=-5
	inpDir=inpDirU
	if strmid(inpDir,0,1,/reverse_offset) ne '/' then inpDir+='/'
	if not keyword_set(usefiarout) then begin
    	nfiles=shsclpimgmonscan(inpDir,fbase,fiar,firsttime=1,/allhdrs)
		if nfiles eq 0 then begin
			print,"no files found for",inpdir,"/",fbase
			return,0
		endif	
;
;   now find set of files they want to process
;
;	>= fnumstart <= fnumend
;
		ii=where((fiar.hdr[0].filenum ge fnumStart) and $
		         (fiar.hdr[0].filenum le fnumEnd) ,nfiles)
		if nfiles eq 0 then begin
			print,"no files between fileNums::",fnumStart,fnumEnd
			return,0
		endif	
		fiar=fiar[ii]
;
; 	spaced by tmStep secs.. first entry of each file
;   
		jdAr=yymmddtojulday(fiar.hdr[0].date*1D) + fiar.hdr[0].secMid/86400D + 4D/24D
		tmStpDay=tmStep/86400D
		iiuse=0L
		tmCur=jdar[0]
		print,tmStpDay
		for i=1,nfiles-1 do begin
			if (tmCur+tmStpDay) le jdar[i] then begin
;	 			print,i,[jdar[i],tmCur+tmStpDay,jdar[i]]-2456333D
				iiuse=[iiuse,i]
;	        	use requested step, not current value      
				tmCur=tmCur+tmStpDay
			endif
		end
		fiar=fiar[iiuse]
		nfiles= n_elements(fiar)
		fiarOut=fiar
	endif else begin
		fiar=fiarout
		nfiles=n_elements(fiar)
	endelse

	if keyword_set(noimg) then return,0
;
;	now start making the images
;
	ldir=outdir
	if strmid(ldir,0,1,/reverse_offset) ne '/' then ldir+='/'
	nbands=n_elements(bandAr)
	nimgTot=(keyword_set(allimg))?total(fiar.nimg)*nbands*10 + 100:$
	                             n_elements(fiar)*nbands*10 + 100 
	if usehtml then begin
	htmlAr=strarr(nimgTot)
	iih=0;
    htmlAr[iih++]='<table nosave="" border="1" width="100%">'
    htmlAr[iih++]='<caption><b>Clp range vs freq spectra</b></caption>'
    htmlAr[iih++]='<tbody>'
    htmlAr[iih++]='<tr nosave="" align="center">'
	endif
	for ifile=0,nfiles-1 do begin
;
;		we are only looking at first image of each file (in fiarout.hdr)
	  iLast=keyword_set(allimg)?fiar[ifile].nimg:1
	  for iiImg=0,iLast-1 do begin
		
        if ( fiar[ifile].fnum lt 1000) then begin
            fnameB=fbase + string(format='(i03,".",i03)',$
                        fiar[ifile].fnum,fiar[ifile].imgNumAr[iiImg])
        endif else begin
            fnameB=fbase + string(format='(i04,".",i03)',$
                   fiar[ifile].fnum,fiar[ifile].imgNumAr[iiImg])
        endelse
	    bw=1./fiar[ifile].hdr[iiImg].smpTmUsec
		ltm=fisecmidhms3(fiar[ifile].hdr[iiImg].secMid,hr,min,sec) &$
		lpos=string(format=$
			'(" pos(az,zagr,zach):(",f5.1,",",f4.1,",",f4.1,")")',$
			(fiar[ifile].hdr[iiImg].az mod 360.),$
			fiar[ifile].hdr[iiImg].zaGreg,$
			fiar[ifile].hdr[iiImg].zaCh)
        title=string(format='("date:",i08," tm:",a)',fiar[ifile].hdr[iiImg].date,ltm) + lpos
		if usehtml then htmlAr[iih++]='<td> ' + ltm + "<br>"
		for iband=0,nbands-1 do begin
			  cfr=(bandar[0] eq 12)?cfrAr:cfrAr[bandAr[iband]-1]
			  istat=shsclpimg(inpDir+fnameB+".dcd",bandAr[iband],cfr=cfr,$
       			    bw=bw,zx=zx,zy=zy,title=title,nhghts=nhghts,wintouse=win,nsig=nsig)
			  if (bandtouse eq 12) then begin
		      ofileName=ofilePrefix + fnameB + string(format='("_",i2)',bandAr[iband]) +$
				  ofileSuf
			  endif else begin
		      ofileName=ofilePrefix + fnameB + string(format='("_",i1)',bandAr[iband]) +$
				  ofileSuf
			  endelse
			  if useGif then write_gif,ldir + ofileName,tvrd() 
			  if usePng then write_png,ldir + ofileName,tvrd() 
			  if useJpg then write_jpeg,ldir + ofileName,tvrd() 
			  if usehtml then begin
			  htmlAr[iih]='<a href='+htmlUrl + ofileName + '>' +$
			 		string(format='("band",i1)',bandAr[iband]) + "</a>"
			  if (iband eq (nbands-1)) then begin
				htmlAr[iih++]+='</td>'
			  endif else begin
				htmlAr[iih++]+='<br>'
			  endelse
			endif
		endfor
	  endfor
	endfor
	if usehtml then begin
	htmlAr[iih++]='</tr></tbody></table>'
	htmlAr=htmlAr[0L:iih-1]
;
; 	now output the html array
;
	file=ldir + htmlFname
	openw,lunout,file,/get_lun
	for i=0,n_elements(htmlAr)-1 do printf,lunout,htmlAR[i]
	free_lun,lunout
	endif
	return,nfiles
end
