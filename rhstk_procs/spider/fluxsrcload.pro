;+
;NAME:
;fluxsrcload - load source flux into common block
;SYNTAX: fluxsrcload=(retdata,file=file,salter=salter)
;ARGS:
;   retdata[]:{fluxsrc} if supplied, then return all the flux structures
;                       in retdata.
;KEYWORDS:
;   file     : string   filename that holds the source fluxes. Default
;                       is aodefdir() + 'data/fluxsrc.dat
;   salter   : if set then input file from chris salter's file. This 
;              file is used to generate the fluxsrc.dat file. The option
;              is used when checking that the files are in sync (see chkflux 
;              below).
;DESCRIPTION:
;   Read in all of the source fluxes from the fluxsrc.dat file into 
;the common block fluxcom. The user can optionally specify
;another file to use for the source fluxes. 
;   The routine fluxsrc() computes fluxes from data in this common block. 
;It will automatically call  fluxsrcload() if the common block is not
;initialized.
;
;   The routine aodefdir()/data/chkflux.pro is used to keep the two files
;in sync (chris's file and fluxsrc.dat).
;SEE ALSO:
;   fluxsrc(), fluxsrclist()
;-
;28jun01 - fixed so aliases worked..
;17dec02: transferred to ~heiles@vermi

pro fluxsrcload,retdata,file=file,salter=salter
    common fluxcom  ;,fluxdata,fluxcominit, fluxfilename, salterfilename

    fluxcominit=0
    on_ioerror,doneio
    fname= fluxfilename
    sname= salterfilename
    if n_elements(file) ne 0 then fname= file
    if n_elements(salter) eq 0 then salter= 0
    if salter then fname=sname
;stop
    openr,lun,fname,/get_lun
    inpline=''
    fluxdata=replicate({fluxdata},1000)
    aliasind=lonarr(1000)       ; index into flux src with alias
    aliasnm =strarr(1000)       ; name with the source
    i=0
    numalias=0
    while  1 do begin
        readf,lun,inpline
        ind=strsplit(inpline,length=len)
        if salter then begin
            good=(strmid(inpline,0,1) eq 'B') and $
                 n_elements(ind) gt 4 and $
                 ((strmid(inpline,5,1) eq '+') or $
                  (strmid(inpline,5,1) eq '-'))
        endif else begin
            good=strmid(inpline,0,1) ne '#'
        endelse
                
        if good  then begin
            nelm=n_elements(ind)
            isalias=0
            if (nelm ge 3) then isalias=strmid(inpline,ind[1],len[1]) eq 'alias'
            if isalias or (nelm ge 4) then begin
              fluxdata[i].name=strmid(inpline,ind[0],len[0])
              if isalias then begin
                aliasind[numalias]=i
                aliasnm[numalias]=strmid(inpline,ind[2],len[2])
                numalias=numalias+1
              endif else begin
                fluxdata[i].coef[0]=strmid(inpline,ind[1],len[1])
                fluxdata[i].coef[1]=strmid(inpline,ind[2],len[2])
                if (len[3] gt 1) or (strmid(inpline,ind[3],1) ne '-') then begin
                    fluxdata[i].coef[2]=strmid(inpline,ind[3],len[3])
                endif else begin
                    fluxdata[i].coef[2]=0.
                endelse
                if salter then begin
                    fluxdata[i].rms=strmid(inpline,ind[4],len[4])
                    fluxdata[i].code=0
                    if nelm  gt 5 then begin
                        fluxdata[i].notes=strmid(inpline,ind[5],$
                                    1+strlen(inpline)-ind[5])
                    endif else begin
                        fluxdata[i].notes=' '
                    endelse
                endif else begin
                    fluxdata[i].rms=strmid(inpline,ind[5],len[5])
                    fluxdata[i].code=strmid(inpline,ind[4],len[4])
                    if nelm  gt 6 then begin
                        fluxdata[i].notes=strmid(inpline,ind[6],$
                                    1+strlen(inpline)-ind[6])
                    endif else begin
                        fluxdata[i].notes=' '
                    endelse
                endelse
              endelse
              i=i+1 
            endif
        endif
   endwhile
doneio: fluxcominit=1
    free_lun,lun
    if i ne 1000 then fluxdata=fluxdata[0:i-1]
;
;   fill in the aliases
;
    for i=0,numalias-1 do begin
        indalias=aliasind[i] 
        indreal =where(aliasnm[i] eq fluxdata.name,count) 
        if count ne 1 then begin
            print,'Error mapping alias',fluxdata[indalias].name,$
                    ' in fluxsrc.dat'
        endif else begin
            nm=fluxdata[indalias].name
            fluxdata[indalias]=fluxdata[indreal]
            fluxdata[indalias].name=nm
        endelse
    endfor
    if n_params() gt 0 then  retdata=fluxdata
    return
end
