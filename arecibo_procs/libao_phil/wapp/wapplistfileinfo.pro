;+
;NAME:
;wapplistfileinfo - list the fileinfo structure
;
;SYNTAX: wapplistfileinfo,wappI,cpu=cpu,projid=projid,logfile=logfile,lunOut=lunOut
;
;ARGS:
;wappI[]:  {wappfileInfo} The data to list (unless logfile is used).
;
;KEYWORDS:  
;     cpu:    int       List only this cpu (1..4). The default is all.
; projid :   string     If present then create logfile name for this projid.
;                       comments for logfile keyword also apply..
; logfile:   string     If present call wappgetfileinfo to scan this
;                       logfile. Load wappI with the results and then 
;                       list it.
;  lunOut:    int       logical unit number to write the data. The default
;                       is standard out. If lunout is supplied then the
;                       first line header is not written (to make it easier
;                       to parse the data
;RETURNS
;   wappI[n]{wappfileInfo} If logfile keyword is used then the new
;                       wappfileInfo will be retured in wappI
;DESCRIPTION:
;   List the contents of a wappfileInfo array. The user passes in the 
;array via wappI unless the logfile keyword is used. In this case, the
;routine will scan the file, load wappI with the data, and then list it.
;   The user can list a single cpu with the cpu keyword. The lunOut
;keyword will write the data to lunout rather then stdout.
;
;EXAMPLES:
;1. Read a logfile and list it to terminal.
;
;   projid='p1770'
;   wapplistfileinfo,wi,projid=projid
;
;Find StartAst wapp nifs lagC mode   fname
;  1  02:35:16   1   d    d   Search B1737+13_north.wapp.52776.000
;                2        Search  B1737+13_north.wapp2.52776.001
;                3         Search  B1737+13_north.wapp3.52776.001
;                4         Search  B1737+13_north.wapp4.52776.000
;  2  02:36:02   1         Search  B1737+13.wapp.52776.001
;                2   Search  B1737+13.wapp2.52776.002
;                3   Search  B1737+13.wapp3.52776.002
;                4   Search  B1737+13.wapp4.52776.001
;
;2. List the contents of wi and write it to junk.out
;   openw,lunOut,'junk.out',/get_lun
;   wapplistfileinfo,wi,lunOut=lunOut     
;   free_lun,lunOut
;
;SEE ALSO:
;   wappgetfileinfo
;-
pro  wapplistfileinfo,wappI,cpu=cpu,projid=projid,logfile=logfile,dir=dir,lunOut=lunOut
;
;     
;
    if n_elements(lunOut) ne 0 then begin
        useOutFile=1
    endif else begin
        useOutFile=0
        lunOut=-1
    endelse
    if (n_elements(logfile) ne 0) or (n_elements(projid) ne 0) then begin
        nsets=wappgetfileinfo(lun,wappI,logfile=logfile,projid=projid)
        if nsets eq 0 then begin
            print,'logfile empty:',logfile
            return
        endif
    endif else begin
        nsets=n_elements(wappI)
    endelse
    usecpu=0
    if n_elements(cpu) gt 0 then begin
        if (cpu lt 1) or (cpu gt 4) then begin
            print,'Illegal cpu requesed:',cpu,' valid # 1-4'
            return
        endif
        usecpu=1
    endif
            
    modeLab=['Search ','Folding','SpcTotP','Unknown']
    lagFLab=['Acf16S','Acf32I','AcfFlt','SpcFlt']
;Find StartAst wapp nifs lagF  mode    fname
;ddd  dd:dd:ddxxxdxxxdxxaaaaaaxaaaaaaa
    if not useOutFile then $
       printf,lunout,'Find StartAst wapp nifs lagF  mode    fname'
    for iset=0,nsets-1 do begin
        if usecpu then begin    
            count=wappI[iset].wappused[cpu-1] eq 1
            if count then ind=cpu-1
        endif else begin
            ind=where(wappI[iset].wappused eq 1,count)
        endelse
        if count gt 0 then begin
;           hr =long(strmid(wappI[iset].start_time,0,2))
;           min=long(strmid(wappI[iset].start_time,3,2))
;           sec=long(strmid(wappI[iset].start_time,6,2))
;           secs=(hr*3600L+min*60L+ sec)-4L*3600L           ; go to ast
;           if secs lt 0 then secs=86400-secs
            lab=string(format=$
            '(i3,"  ",a,"   ")',iset+1,fisecmidhms3(wappI[iset].astsec))
            pre=lab
            for i=0,count-1 do begin
                ii=wappI[iset].wapp[ind[i]].hdr.obs_type_code - 1
                if ii lt 0 then ii=3
                fname=wappI[iset].wapp[ind[i]].fname
                if keyword_set(dir) then $
                    fname=wappI[iset].wapp[ind[i]].dir + fname
                lab=string(format='(i1,"   ",i1,"  ",a," ",a," ",a)',$
                    ind[i]+1,wappi[iset].wapp[ind[i]].hdr.nifs,$
                      lagFLab[(wappi[iset].wapp[ind[i]].hdr.lagformat) and 7],$
                    modeLab[ii],fname)
                printf,lunout,pre+lab
                pre='                '
            endfor
        endif
    endfor
    return
end 
