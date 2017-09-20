;+
;NAME:
;rfihistlist - make filelist for histogram
;SYNTAX: rfihistlist,yymmAr,inpdir=inpdirar,outdir=outdir
;ARGS:
;       yymmAr[]: int   dates to process. eg [0101,0102]
;KEYWORDS:
;       inpdir[]: string directories where the rms spectra files are located.
;                 default:...
;       outdir  : string directory to write the list of files to process.
;                 default: /share/megs/rfi/rms/histdat/
;DESCRIPTION:
;   pfrfihist() computes a histogram of rfi versus frequency using the
;rms spectra computed by pfrms(). It needs a list of rmsspectra files
;to process. This routine will generate that list of files and write them
;to disc. The user supplies an array of yymm values and the program 
;searches the rmsspectra directories for all files that fall within each
;of the yymm ranges (by checking the monyy part of the filename). For
;each yymm it will write a file (hlistinp.yymm) to the output directory
;that has a list of all rms spectra for this month.
;-
;15nov04 - included was file directory and file search.. 
pro rfihistlist,yymmAr,inpdir=inpdirar,outdir=outdir
;
    outNm='hlistinp.'
	useStdDir=0
    if n_elements(inpdir) eq 0 then begin
        inpdirar=['/share/rfi/rms/','/share/rfi/rmswas/']
		useStdDir=1
    endif
    if n_elements(outdir) eq 0 then begin
        outdirl='/share/megs/rfi/rms/histdat/'
    endif else begin
        outdirl=outdir
        if strmid(outdirl,0,1,/reverse_offset) ne '/' then outdirl=outdirl+'/'
    endelse
    monNmAr=['jan','feb','mar','apr','may','jun','jul','aug','sep','oct', $
             'nov','dec'] 
    maxfiles=15000
    filelist=strarr(maxfiles)
	a=bin_date()
	curYr= a[0] mod 100L
;
;   loop over each month
;
    for i=0,n_elements(yymmAr)-1 do begin
;
;   convert yymm to monyy corfiles.ddmonyy format 
;                   yyyymm for was files
;
        numfound=0
        mon =yymmAr[i] mod 100
        yr  =yymmAr[i] / 100
		yr4=yr
		if yr lt 1000 then begin
			yr4=(yr lt 85)?yr+2000L:yr+1900L
		endif
        monnm=monNmAr[mon-1]
        monyrC=string(format='(a3,i2.2)',monnm,yr)
        monyrW=string(format='(i4,i2.2)',yr4,mon)
		inpdirarL=inpdirar
		if useStdDir then begin
			if yr ne curYr then begin
				for j=0,n_elements(inpdirar)-1 do $
				 inpdirArL[j]=string(format='(a,"Y",i2.2,"/")',inpdirAr[j],yr)
			endif
		endif
        for j=0,n_elements(inpdirarL)-1 do begin
            inpdir=inpdirarL[j]
            if strmid(inpdir,0,/reverse_offset) ne '/' then inpdir=inpdir+'/'
            srchnameC=inpdir+'corfile.*' + monyrC + '.*'
            srchnameW=inpdir+'wapp.' + monyrW + '*'
            flistC=file_search(srchnameC,count=count)
			if count gt 0 then begin
				tmp=file_test(flistC,/zero_length)
				ii=where(tmp ne 1,count)
				if count gt 0 then flistC =flistC[ii]
;;            print,srchname,' found:',count
			endif
            if count ne 0 then begin
                filelist[numfound:numfound+count-1]=flistC
                numfound=numfound+count
            endif
            flistW=file_search(srchnameW,count=count)
			if count gt 0 then begin
				tmp=file_test(flistW,/zero_length)
				ii=where(tmp ne 1,count)
				if count gt 0 then flistW=flistW[ii]
;;            print,srchname,' found:',count
			endif
;;            print,srchname,' found:',count
            if count ne 0 then begin
                filelist[numfound:numfound+count-1]=flistW
                numfound=numfound+count
            endif
;			print,inpdir,mon,numfound
        endfor
        if numfound gt 0 then begin
            outfile=string(format='(a,a,i4.4)',outdirl,outNm,yymmAr[i])
;            print,'numfound',numfound,' outfile',outfile
            openw,lun,outfile,/get_lun
            for k=0,numfound-1  do begin 
                printf,lun,filelist[k] 
            endfor 
            free_lun,lun
        endif
    endfor
    return
end
