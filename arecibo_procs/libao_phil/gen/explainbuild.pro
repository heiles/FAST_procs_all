;
; generate list of all routines in this directory
;
; args:
; topName : name of topic (without the top). used to generate the
;           filename and and the name for the 1 line line desc of topic file
; dirIn   : directory that hold the idl routines to search
; dirOut  : output directory..
;
pro explainbuild,topName,dirin,dirOut
;
;   find all of the .pro files in directory 
;
    dirInLoc=(strpos(dirin,'/',/reverse_search) ne (strlen(dirin)-1) )? $
        dirin+'/':dirIn
    dirOutLoc=(strpos(dirOut,'/',/reverse_search) ne (strlen(dirin)-1) )? $
        dirOut+'/':dirOut
    namePerLine=5
    charPerName=15
    filelist=findfile(dirinLoc+'*.pro',count=nfiles)
    procsfound=0L
    maxproc=nfiles*3
    namelist=strarr(maxproc)
    descList=strarr(maxproc)

    for i=0,nfiles-1 do begin
        openr,lunin,filelist[i],/get_lun
        on_ioerror,done
        gotit=0             ; 1 found ;, 2 found name: 3 found description
        line=''
        while 1 do begin
            readf,lunin,line
            case gotit of
                0 : if strmid(line,0,2) eq ';+' then gotit=1
                1 : if strlowcase(strmid(line,0,6)) eq ';name:' then gotit=2
                2 : begin 
                     i1=strpos(line,'-')
                     if i1 eq -1 then begin
                   print,'missing "-" in 1 line description for ' + filelist[i]
                   goto,done 
                     endif
                   nameList[procsfound]=strtrim(strmid(line,1,i1-1),2)
                   descList[procsfound]=strtrim(strmid(line,i1+1),2)
                   procsfound=procsfound+1
                   gotit=0
                   end
            endcase
        endwhile
done:   on_ioerror,null
        free_lun,lunin
    endfor
;
;   generate the output filenames
;
;   create the two output files
;
    out1=dirOutLoc+topName + 'doc.pro'
    out2=dirOutLoc+topName + 'docnames.pro'
    openw,lunout,out1,/get_lun
    printf,lunout,';+'
    printf,lunout,';NAME:'
    line=string(format='(";",a," - routine list (single line)")',topName+'doc')
    printf,lunout,line
    printf,lunout,';'
    for i=0,procsfound-1 do begin
        pad=strmid('                ',0,charPerName+1-strlen(namelist[i]))
        lab=';'+ namelist[i] + pad + ' - ' + desclist[i]
        printf,lunout,lab
    endfor
    printf,lunout,';-'
    free_lun,lunout
;
    openw,lunout,out2,/get_lun
    printf,lunout,';+'
    printf,lunout,';NAME:'
    line=string(format='(";",a," - list of routine names")',topName+'docnames')
    printf,lunout,line
    printf,lunout,';'
    line=';'
    n=0
    for i=0,procsfound-1 do begin
        pad=((n+1) eq nameperline)?'':$
            strmid('                ',0,charPerName+1-strlen(namelist[i]))
        line=line+namelist[i]+pad
        n=n+1
        if n eq nameperline then begin
            printf,lunout,line
            n=0
            line=';'
        endif
    endfor
    if n ne 0 then printf,lunout,line
    printf,lunout,';-'
    free_lun,lunout
    return
end
