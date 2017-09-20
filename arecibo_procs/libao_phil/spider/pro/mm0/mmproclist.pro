;+
;NAME:
;mmproclist - do mueller processing for a set of data files
;
;SYNTAX: ntot=mmproclist(listfile,scndata,$
;           mmInfo_arr,hb_arr,beamin_arr,beamout_arr,mmCmp_arr,mmCmpChn_arr,$
;          fnameind=fnameind,maxfiles=maxfiles,_extra=_e
;ARGS:
;   listfile: string. filename holding names of correlator files 
;                     (one per line). semi-colon as the first char is a comment.
;   scndata: {scndata} information that parameterizes how scan was done.
;                      This is set by @mm0init
;KEYWORDS:
; fnameind: int       index in line for filename (count from 0)
; maxfiles: int       maximum number of files to process (default is
;					  99999L)
;   _extra: {}      parameters that can be used by mmproc. Any parameters
;                   will be applied to all of the files.
;RETURNS:
;             ntot:long The number of beam fits done. For each pattern used
;                       there will be a beamfit for each board.
; mmInfo_arr[ntot]:{mueller} hold src info, fit info for each fit.
;   hb_arr[4,ntot]:{hdr} for each fit done, the hdr from the first point of
;                        each of the 4 strips.
; beamin_arr[ntot]:{beaminput} input for 2d beamfit (output of 1s fits)
;beamout_arr[ntot]:{mmoutput}  output of 2d beamfit.
;mmCmp_arr[ntot]:{muellerparams_carl}  if mm4 keyword set, then the
;                        computed mueller matrices are returned here.
;mmCmpChn_arr[128,ntot]:{muellerparams_carl}  if mm4 keyword set and /byChnl
;                        keyword set then this has the mueller matrices by
;                        frequency channel.
;          retsl[]:{sl}  Return the scanlist from scanning the file.
;                        If you reprocess the file, pass this in with sl=retsl
;DESCRIPTION:
;   Call mmproc for every filename in listfile. Return all of the 
;data in one array of structures. An example of the listfile is:
;
;;  a comment
;/share/olcor/calfile.19mar01.a1400.1
;/share/olcor/calfile.20apr01.a1446.1
;/share/olcor/calfile.20apr01.a1489.1
;/share/olcor/calfile.20mar01.a1389.1
;
;It would process all 4 files and return the data in mm,mmInfo.
;
;-
; history
; 30dec04: updates to get it to run with new version..
; 02jan05: added maxfiles keyword
; 	
function  mmproclist,listfile,scndata,$
            mmInfo_arr,hb_arr,beamin_arr,beamout_arr,mmCmp_arr,mmCmpChn_arr,$
            fnameind=fnameind,_extra=_e ,maxfiles=maxfiles

;;    on_error,1

	maxfilesL=keyword_set(maxfiles)?maxfiles:99999L
    maxpat=0L
    patInc=1000L
    if n_elements(fnameind) eq 0 then fnameind=0
    mm=''&hb=''&beamin=''&beamout=''&mmCmp=''&mmCmpChn=''
    cnt=0l
    cntmm=0l
    on_ioerror,done
    lun1=-1
    openr,lun1,listfile,/get_lun
    line=' '
	filesdone=0L
    while 1 do begin
        readf,lun1,line    
        if strmid(line,0,1) ne ';' then  begin
            filename=strsplit(line,' ',/extract)
            if file_exists(filename[fnameind]) eq 0 then begin
                print,'file does not exist, skipping:',filename[fnameind],$
                        string(7b)
            endif else begin
                print,'processing file:',filename[fnameind]
                npat=mmproc(filename[fnameind],scndata,mm,hb,beamin,beamout,$
                        mmCmp,mmCmpChn,_extra=_e)
;
;   allocate the total array or enlarge if needed
;
            if npat+cnt gt maxpat then begin
                if maxpat gt 0 then begin
                    mmInfo_arr=[temporary(mmInfo_arr),$
                            replicate({mueller},patInc)]
                    beamin_arr=[temporary(beamin_arr),$
                            replicate({beaminput},patInc)]
                    beamout_arr=[temporary(beamout_arr),$
                            replicate({mmoutput},patinc)]
                    hb_Arr   =reform([temporary(reform(hb_arr,4*maxpat,/over)),$
                            replicate({hdr},4*patInc)],4,maxpat+patinc)
                    if keyword_set(mmCmp) then $
                        mmCmp_arr=[temporary(mmCmp_arr),$
                         replicate({muellerparams_carl},patInc/4L)]
                    if keyword_set(mmCmpChn) then $
                        mmCmpChn_arr=reform([$
                            temporary(reform(mmCmpChn_arr,(128L*maxpat)/4)),$ 
                            replicate({muellerparams_carl},(128L*patInc)/4L)],$
                            128L,(maxpat+patInc)/4L)
                endif else begin
;
;               first time, just increment
;
                    mmInfo_arr=replicate({mueller},patInc)
                    beamin_arr=replicate({beaminput},patInc)
                    beamout_arr=replicate({mmoutput},patinc)
                    hb_Arr     =replicate({hdr},4,patInc)
                    if keyword_set(mmCmp) then $
                        mmCmp_arr=replicate({muellerparams_carl},patInc/4L)
                    if keyword_set(mmCmpChn) then $
                     mmCmpChn_arr=replicate({muellerparams_carl},128L,patInc/4L)

                endelse
                maxpat=maxpat+patInc
            endif
            if npat gt 0 then begin
               mmInfo_arr[cnt:cnt+npat-1]=mm
               beamin_arr[cnt:cnt+npat-1]=beamin
               beamout_arr[cnt:cnt+npat-1]=beamout
               nmm=n_elements(mmCmp)
               if keyword_set(mmCmp) then $
                 mmCmp_arr[cntmm:cntmm+nmm-1]=mmCmp
               if keyword_set(mmCmpChn) then $
                 mmCmpChn_arr[*,cntmm:cntmm+nmm-1]=mmCmpChn
               cnt=cnt+npat
               cntmm=cntmm+nmm
               mm=''&hb=''&beamin=''&beamout=''&mmCmp=''&mmCmpChn=''
            endif
			filesdone=filesdone+1L
			if filesdone ge maxfilesL then break
            endelse ; fileexists
        endif ;strmid
    endwhile
done: 
    if lun1 ne -1 then free_lun,lun1
    if cnt lt maxpat then begin
       if cnt eq 0 then begin
         mmInfo_arr=''  
         beamin_arr=''
         beamout_arr=''
       endif else begin
        mmInfo_arr=mmInfo_arr[0:cnt-1]
         beamin_arr=beamin_arr[0:cnt-1]
        beamout_arr=beamout_arr[0:cnt-1]
       endelse
    endif
    if keyword_set(mmCmp_arr) then begin
        if cntmm lt (maxpat/4L) then begin
            mmCmp_arr=mmCmp_arr[0:cntmm-1L]
            if keyword_set(mmCmpChn_arr) then  $
               mmCmpChn_arr=mmCmpChn_arr[*,0:cntmm-1L]
        endif
    endif
    return,cnt
end
