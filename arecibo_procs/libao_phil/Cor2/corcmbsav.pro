;+
;NAME:
;corcmbsav - combine save files with multiple sources.
;SYNTAX - npat=corcmbsav(savelistinp,b_all,b_sec,b_rms,b_info,usrcname,$
;                         savefileout=savefileout,/filelist)
;ARGS:
;savelistinp[]: string list of save files to use as input
;                      These files should contain:
;                      bf[n]: an array of {corget} structures.
;KEYWORDS:
;filelist:  if set then  savelistinp is the data filelist used to input the
;           data. In this case this routine will generate the standard
;           save filenames to read:
;              corfile.ddmonyy.projid.n -> ddmonyy.projid.n.sav 
;           It will assume that the .sav files are in the current directory.
;savefileout: string   name of save file to store the combined arrays in.
;RETURNS:
;   npat   : long   number of patterns processed
;   b_all[]:{corget} the combined on/off -1 from the save files
;   b_sec[]:{corget} the combined secperchn  from the save files
;   b_rms[]:{corget} the combined rms/mean  from the save files
;   b_info[]:{}      struct telling which kind of data is valid for
;                    each b_rms/sec[m]
;   usrcname[l] string array holding the uniq source names present.
;           
;DESCRIPTION:
;   Process a set of idl save files each containing an array bf[n] of
;corget structures. Combine these into a single array and return
;them to the caller. optionally save them to an idl save file.
;
;   The routines pfposonoff(), pfposonoffrfi() process all of the
; on/off patterns in a file (as long as they are the same data size). 
; They then save this info to an idl save file. This would typically be 
; 1 days observations.
;   This routine's job is to combine all of the info from multiple
;save files (days) concatentating them into 1 large array. 
;
;   The input data in the save files are:
;   bf[n]          {corget} holds the n on/off's processed for 1 file
;   arSecPerChn[n] {corget} secs/chan integration for each bf[n]. This is
;                  output by pfposonoffrfi(). After rfi excision there may
;                  not be the same integration time in each freq channel
;   arRmsByChn[n] {corget} rms/mean for each on/off after rfi excision
;                 (actually after the rms fit, before the total power
;                 test).
;
;   These will be combined into:
;   b_all[M] holds the combined bf[n]
;   b_sec[M] holds the combined arsecperchn[n]
;   b_rms[M] holds the combined arrmsbychn[n]
;   b_info[M] a struct holding source name for each entry and 
;             whether or not there is b_sec and b_rms info for each
;             entry:
;       b_info[i].srcname   ; source name
;       b_info[i].usesec    ; 1 if it has secPerchn info from rfi processing
;       b_info[i].userms    ; 1 if it had rms/mean info from rfi processing
;
;
;   The new arrays are returned to the caller. They can also be saved
;to an idl save file with the savefileout keyword.
;
;
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
;;  Use corcmbsav() to combine them:
;;  1. input all the data from the daily save files.
;;  2. save all of these arrays in the savbysrc filename.
;;  3. the /filelist keyword flags that the string array has the
;;     original datafilenames and this routine should generate the
;;     input save file names.
;;
;   savefileout='onoff_cmb.sav'         ; place to store the new data
;
;   istat=corsavcmb(flist,b_all,b_sec,b_rms,b_info,$
;       savefileout=savefileout,/filelist) 
;;
;
;WARNING:
;   This works as long as the data structure is the same type for
;all of the on/offs. numboards, pol/brd, lags/pol
;
;-
;MODIFICATION HISTORY:
;
function corcmbsav,savelist,b_all,b_sec,b_rms,b_info,usrcname,$
            savefileout=savefileout,maxpat=maxpat,filelist=filelist
;
    aa={    srcname: '' ,$
            usesec : 0  ,$
            userms : 0  }
    firstTime=1
    on_error,1
    maxpatl=500l
    verbose=0
    iF N_elements(maxpat) ne 0 then maxpatl=maxpat
    if keyword_set(filelist) then begin
        savelistinp=savelist + '.sav'           ; put the output arrays here
        ii=lonarr(n_elements(savelist)) + 1
        for i=0,n_elements(savelist)-1 do begin 
            goit=0
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
        restore,savelistinp[i],verbose=verbose
;
;   create large array to hold all the data
;
        npat=n_elements(bf)
        if npat eq 0 then begin
            print,'array bf[] not found in:',savelistinp[i]
            goto,botloop
        endif
        if (firstTime ) then begin
            b_all   =corallocstr(bf[0],maxpatl)  
            b_sec   =corallocstr(bf[0],maxpatl)  
            b_rms   =corallocstr(bf[0],maxpatl)  
            b_info  =replicate(aa,maxpatl)
            firstTime=0
        endif
        if corchkstr(bf[0],b_all[0]) eq 0  then begin
            print,'incompatible data, save file skipped:',savelistinp[i]
            goto ,botloop
        endif
    
        corstostr,bf,ntot,b_all
        if n_elements(arsecperchn) eq npat then begin
            corstostr,arsecperchn,ntot,b_sec
            b_info[ntot:ntot+npat-1].usesec=1
        endif
        if n_elements(arrmsbychn) eq npat then begin
            corstostr,arrmsbychn,ntot,b_rms
            b_info[ntot:ntot+npat-1].userms=1
        endif
        b_info[ntot:ntot+npat-1].srcname=string(bf.b1.h.proc.srcname)
        ntot=ntot+npat
        arsecperchn=''
        arrmsbychn =''
        bf=''
botloop:
    endfor
;
    b_all   =b_all[0:ntot-1]
    b_sec   =b_sec[0:ntot-1]
    b_rms   =b_rms[0:ntot-1]
    b_info  =b_info[0:ntot-1]
    usrcname=b_info[uniq(b_info.srcname,sort(b_info.srcname))].srcname
;
    if keyword_set(savefileout) then $
        save,b_all,b_sec,b_rms,b_info,usrcname,file=savefileout
    
    return,n_elements(b_all)
end
