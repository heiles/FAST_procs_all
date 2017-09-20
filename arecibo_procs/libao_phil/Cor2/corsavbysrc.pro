;+
;NAME:
;corsavbysrc - create arrays by source.
;SYNTAX - istat=corsavbysrc(savelistinp,savefileout,noavg=noavg,$
;                           nosingle=nosingle,/filelist)
;ARGS:
;savelistinp[]: string list of save files to use as input
;                      These files should contain:
;                      bf[n]: an array of {corget} structures.
;savefileout: string   name of save file to store the arrays by source.
;KEYWORDS:
;   noavg:  if set then do not bother to save averages. This may be
;           needed if you end up with too many variables to save at once.
;nosingle:  if set then do not bother to save the arrays of individual sources.
;           (it will save b_all and bavg_ if noavg is not set)
;filelist:  if set then  savelistinp is the data filelist used to input the
;           data. In this case this routine will generate the standard
;           save filenames to read:
;              corfile.ddmonyy.projid.n -> ddmonyy.projid.n.sav 
;           It will assume that the .sav files are in the current directory.
;           
;DESCRIPTION:
;   Process a set of idl save files each containing an array bf[n] of
;corget structures. This routine will input all of the save files into a single
;b_all[m] array and then create separate arrays by source name.
;
;   The new array names will be the source name with the following
;modifications:
;   1. Each source name will be prepended with 
;      b_     for the regular data.
;      bavg_  for the averaged data.
;   2. The following replacements are made within the src name:
;     + -> p
;     - -> m
;This is needed to make the source names legal variable names in idl.
;
;   For each source array also create an average array that averages
;over all of the entries for a single source and over polarization
;(there is  no weighting for gain or tsys in the averaging).
;
;   Save the new set of arrays in idl save format  to the file specified by 
;the savefileout parameter. This is the simplest way to pass a variable
;number of arguments back to the main routine.
;
;   This routine was written to combine datasets output by 
;multiple calls to pfposonoff(). pfposonoff() creates a save file bf[n]
;containing all of the processed on/off-1 position switch scans in a datafile.
;corsavbysrc() can then be used to combine these multiple files (days)
;so there is a single set of arrays by source. You can then edit/average
;each source array giving the final result.
;
;   The /noavg keyword will not save the average of each source. 
;   The /nosingle will not store the array for each individual source
;(before averaging). 
;   The array b_all() containing all of the sources (before averaging) is
;always saved. If you have many sources (gt say 150) then the save
;command may fail. In that case you should consider not saving the
;averages or the single arrays.
;
;EXAMPLE:
;   Suppose project a1721 generated the following corfiles (either in 
;/share/olcor or /proj/a1721). You could process all the data with the 
;following code:
;
;;  The pfposonoff processing:
;
;  flist=['corfile.08may03.a1721.2',$
;         'corfile.08may03.a1721.3',$
;         'corfile.09may03.a1721.1']
;  dir=['/share/olcor/','/proj/a1721/']  ; directories to look for the files
;  voff=.03                              ; plotting increment
;  han=1                                 ; hanning smooth
;  hor
;  ver
;  for i=0,n_elements(flist)-1 do begin &$
;      npairs=pfposonoff(flist[i],bf,tf,calsf,han=han,dir=dir,/scljy,/sav) &$
;
;;      plot the data so we can see what's up. offset each strip by voff 
;
;      ver,-voff,(npairs+1)*voff &$
;      corplot,bf,off=voff &$
;  endfor
;
;;  The processed on/off-1 are now in the save files (one for each corfile)
;;  Use corsavbysrc() to:
;;  1. input all the data from the daily save files.
;;  2. create two arrays for each source:
;;       b_srcname, bavg_srcname  which have the individual on/off-1
;;       and the average for the source. Some characters in the source
;;       name will be changed: + -> p - -> m
;;  3. save all of these arrays in the savbysrc filename.
;;  4. the /filelist keyword flags that the string array has the
;;     original datafilenames and this routine should generate the
;;     input save file names.
;;
;   savefileout='savebysrc.sav'         ; place to store the new data
;
;   istat=corsavbysrc(flist,savefileout,/filelist) ;this does all the work
;;
;; to load the data by source into memory:
;
;   restore,savefileout,/verbose
;; the averaged data:
;BAVG_NGC3384    STRUCT    = -> <Anonymous> Array[1]
;BAVG_NGC3389    STRUCT    = -> <Anonymous> Array[1]
;BAVG_NGC3412    STRUCT    = -> <Anonymous> Array[1]
;BAVG_NGC3489    STRUCT    = -> <Anonymous> Array[1]
;BAVG_NGC3607    STRUCT    = -> <Anonymous> Array[1]
;BAVG_U4385      STRUCT    = -> <Anonymous> Array[1]
;BAVG_U5326      STRUCT    = -> <Anonymous> Array[1]
;BAVG_U6018      STRUCT    = -> <Anonymous> Array[1]
;
;; the data before averaging. each entry is 1 processed on,off scan pair 
;
;B_NGC3384       STRUCT    = -> <Anonymous> Array[6]
;B_NGC3389       STRUCT    = -> <Anonymous> Array[1]
;B_NGC3412       STRUCT    = -> <Anonymous> Array[6]
;B_NGC3489       STRUCT    = -> <Anonymous> Array[6]
;B_NGC3607       STRUCT    = -> <Anonymous> Array[3]
;B_U4385         STRUCT    = -> <Anonymous> Array[2]
;B_U5326         STRUCT    = -> <Anonymous> Array[1]
;B_U6018         STRUCT    = -> <Anonymous> Array[1]
;
;;  to plot an averaged source:
;   ver,-.01.01                 ; since the galaxy blows up the scale
;   corplot,BAVG_NGC3384,/vel
;
;WARNING:
;   The data is save by executing a command:
;istat=execute(cmd) where cmd is a string holding the save command and all
;of the sources to save. If the length of cmd gets above about 2800 bytes
;i've seen the save fail. If you have so many sources, try using the 
;/noavg keyword to not save the averages.
;
;-
;MODIFICATION HISTORY:
;09may03 : took from the old code i wrote for jim rose a1633.
;
function corsavbysrc,savelist,savefileout,maxpat=maxpat,noavg=noavg,$
            nosingle=nosingle,filelist=filelist
;
    on_error,1
    maxpatl=500l
    verbose=0
	if n_elements(savelist) eq 0 then begin
	   print,"No save files provided in savelist"
	   return,-1
	endif
    iF N_elements(maxpat) ne 0 then maxpatl=maxpat
	
    if keyword_set(filelist) then begin
        savelistinp=savelist + '.sav'           ; put the output arrays here
        ii=lonarr(n_elements(savelist)) + 1
        for i=0,n_elements(savelist)-1 do begin 
            gotit=0
            j=strpos(savelistinp[i],'corfile.') 
            if  j gt -1 then begin
                savelistinp[i]=strmid(savelistinp[i],j+8) 
                gotit=1
            endif
            if not gotit then begin
                j=strpos(savelistinp[i],'wapp.') 
                if  j gt -1 then begin
                    savelistinp[i]=strmid(savelistinp[i],j+5) 
                endif
                gotit=1
            endif
            if not gotit then ii[i]=0
        endfor
        ind=where(ii ne 0,count)
        if count gt 0 then  begin
            savelistinp=savelistinp[ind]
        endif else begin
            print,'no save files found'
            return,0
        endelse
    endif else begin
        savelistinp=savelist
    endelse
        
    ntot=0L
    for i=0,n_elements(savelistinp)-1 do begin
        restore,SAVelistinp[i],verbose=verbose
;
;   create large array to hold all the data
;
        npat=n_elements(bf)
        if npat eq 0 then begin
            print,'array bf[] not found in:',savelistinp[i]
            goto,botloop
        endif
        if (n_elements(b_all) eq 0 ) then begin
            b_all   =corallocstr(bf[0],maxpatl)  
;           tsysall=replicate(tsysf[0],maxpatl)
;           calall =replicate(calf[0,0],4,maxpatl)
            srcall =strarr(maxpatl)
        endif
        if corchkstr(bf[0],b_all[0]) eq 0  then begin
            print,'incompatible data, save file skipped:',savelistinp[i]
            goto ,botloop
        endif
    
        corstostr,bf,ntot,b_all
        scnamesf=string(bf.b1.h.proc.srcname)
;
;       get the source name from this file
;
        srcall[ntot:ntot+npat-1] =srcnamesf
        ntot=ntot+npat
botloop:
    endfor
;
    b_all   =b_all[0:ntot-1]
    srcall =srcall[0:ntot-1]
    i=uniq(srcall,sort(srcall))
    srcdone=srcall[i]
    nsrcdone=n_elements(srcdone)
;
;   We will create variable names from the source names..
;   Make sure the name is ok 
;   1. If first char not a letter, prepend v
;   2. do the following replacments
;     + -> p
;     - -> m
    srcdoneV=strtovarnam(srcdone,/noleading)    ; valid variable names
;
;   create a variable holding all the data from a single source
;
; name of variable holding array of onoffs 1 source
;
    vnameAr =strarr(nsrcdone)   
    vnameAvgAr=strarr(nsrcdone) ;name of variable holding average of each source
    for i=0,nsrcdone-1 do begin
        src =srcdone[i]
        srcV=srcdoneV[i]
        vname   ='b_'   + srcV  ; name holding individual on/offs eg b_NGC7672
        vnameavg='bavg_'+srcV  ; name holding avg                eg bavg_NGC7672
        ind=where(srcall eq src,count)          ; find where this src is
        lab=string(format='("found ",i3," scans for:",a," ",a)',$
                    count,vname,vnameavg)
        print,lab                       ; tell them whats up
;
;       create commands to execute. we are generating the variable names 
;       so we need to use execute...
;
        cmd1=vname    + "=b_all[ind]"    ; find the scans
        istat=execute(cmd1)
;
;       check that the freqbcrest, velorz are the same
;
        if n_elements(ind) gt 1 then begin
            ii=where($
        (b_all[ind].b1.h.dop.VELORZ  ne b_all[ind[0]].b1.h.dop.VELORZ) or  $
        (b_all[ind].b1.h.dop.freqBCRest  ne b_all[ind[0]].b1.h.dop.freqBCRest),$
         count)
            if count gt 0 then begin
                print, 'Warning:', vname,' has different freq or vel'
            endif
        endif
        vnameAr[i]=vname                ; save the name of single array
        cmd2=vnameavg + "= coravg(" + vname + ",/pol)" ; average the scans
        istat=execute(cmd2)
        vnameAvgAr[i]=vnameavg          ; save the name of the average array
    endfor
;
;   now create the command to save the files 
;
    srclist   =vnameAr
    srclistAvg=vnameAvgAr
    cmd='save, b_all,srclist,srclistavg'
    for i=0,nsrcdone-1 do begin 
        if not keyword_set(nosingle) then begin
            cmd=cmd+','+vnameAr[i]
        endif
        if not keyword_set(noavg) then begin
            cmd=cmd+','+vnameAvgAr[i] 
        endif
    endfor
    cmd=cmd + ',file=savefileout'
;
    print,'executing save command:'
    print,cmd
    istat=execute(cmd)
    return,istat
end
