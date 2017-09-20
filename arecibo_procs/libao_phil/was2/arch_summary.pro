;+
;NAME:
;arch_summary - print summary info of arhive list.
;
;SYNTAX: arch_summary,slar,logfile=logfile,append=append
;
;ARGS:
;   slar[n]: {wassl}   slar input from arch_gettbl
;  
;KEYWORDS:
;   logfile: string   file name to write the data. If append keyword is
;                     set the append to file rather than overwriting.
;
;DESCRIPTION:
;   Output a 1 line summary for every scan in the slar. If logfile is
;supplied then output to this file. The file will be overwritten unless
;the append keyword is set.
;proj    scan      srcname      procNm    step  rcv recs    ra    dec
;a1946xsssssssssxllllllllllllxppppppppppxsssssssxrrxnnnnxhh:mm:ssxdd:mm:ss
;12345 123456789 123456789012 1234567890 1234567 12 1234 12345678 12345678
;-
;
pro  arch_summary,slar,logfile=logfile,append=append
;
;
    lunout=-1
    if n_elements(logfile) gt 0 then begin
        openw,lunout,logfile,append=append,/get_lun
    endif
        
    tit=$
'proj    scan      srcname      procNm    step  rcv recs    ra    dec'
    if lunout gt -1 then begin
        printf,lunout,tit
    endif else begin
        print,tit
    endelse
    nscans=n_elements(slar)
    for i=0,nscans-1 do begin
        lab=string(format=$
'(a5,1x,i9,1x,a12,1x,a10,1x,a7,1x,i2,1x,i4,1x,a8,1x,a8)',$
        slar[i].projid,$
        slar[i].scan,$
        slar[i].srcname,$
        slar[i].procname,$
        slar[i].stepName,$
        slar[i].rcvnum,$
        slar[i].numrecs,$
        fisecmidhms3(slar[i].rahrReq*3600D),fisecmidhms3(slar[i].decdReq*3600D))
        if lunout gt -1 then begin
            printf,lunout,lab
        endif else begin
            print,lab
        endelse
    endfor
    if lunout gt -1 then free_lun,lunout
    return
end
