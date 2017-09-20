;+
;NAME:
;modinp - input model coefficeints
;
;SYNTAX : modinp,modelData,model=model,suf=suf,mfile=mfile,efile=efile,$
;                rcv=rcv
;
; ARGS  : 
;modelData: {modelData} data returned here. Structure defined in
;                       aodefdir()/idl/h/hdrPnt.h
;
; KEYWORDS:
;    model:   model name: eg modelSB, modelCB.. filename should be in
;             aodefdir()+"data/pnt" directory with a name modelXXX. You
;             can override this with the rcvNmm keyword.
;             default: modelSB
;    suf  :   suffix for the model you want. suffixes are changed as
;             new models are added. current suffix may00 is 11A.
;             if not provided then use the current model.
;    mfile:  string model filename (if not standard format).
;    efile:  string encoder filename (if not standard format)
;   rcvNum:  int    if supplied then use model for this receiver. 
;                   overrides model= keyword
;   dirmod:  string  directory for model. override default directory
;WARNING:
;   If you are not at AO, then the model info was current when you downloaded
; the aoidl distribution. It may have been updated since then. Check
; the file aodefdir()+"data/pnt/lastUpdateTmStamp. It contains the date
; when your data was copied from the online archive.
;-
pro modinp,modelData,model=model,suf=suf,mfile=mfile,efile=efile,rcv=rcv,$
			dirmod=dirmod

;                 0    1   2     3    4    5    6     7    8     9   10
    rcvnumtonam=['','327','430','610','','LBW','LB','SBW','SBH','CB','CBH',$
;                 11   12  13 14 15 16 17
                 'XB','SB','','','','','ALFA']

    dir=aodefdir() + 'data/pnt/'
	if n_elements(dirmod) gt 0 then dir=dirmod
    encname='enctbl'
    modelData={modelData}
    if n_elements(model) eq 0 then model='modelSB'
    if keyword_set(rcv) then begin
        badrcv=0
        if (rcv eq 100) then begin
            rcvNam='CH'
        endif else begin
            if (rcv lt 1) or (rcv gt n_elements(rcvnumtonam)) then begin
                badrcv=1
            endif else begin
                if rcvnumtonam[rcv] eq '' then badrcv=1
            endelse
            if badrcv then begin
                lab=string(format='("unknown rcvNum ",i2," use values 1..17")',$
                        rcv)
                message,lab
            endif else begin
                rcvnam=rcvnumtonam[rcv]
            endelse
        endelse
        model='model' + rcvnam
    endif
;   if n_elements(suf)   eq 0 then suf='11A'
    if n_elements(suf)   eq 0 then suf=''
    pathname=dir + model
    if n_elements(mfile) ne 0 then pathname=dir + mfile
    lun=-1
    openr,lun,pathname,/get_lun,error=err
    if err ne 0 then begin
        message,'error ' + !err_string 
    endif
;
;   loop looking for start of model
;
    gotit=0
    match='#!' + model + suf
    len=strlen(match)
    inp=' '
    on_ioerror,done1
    while gotit eq 0 do begin
        readf,lun,inp 
        if strmid(inp,0,len) eq match then gotit=1
    endwhile
done1:
    if gotit eq 0 then begin
        if lun ge 0 then free_lun,lun
        message,match + ' not found in ' + pathname
    endif
;
; get number of points, encoder table name
;
    name=' '
    format=' '
    enctbl=' '
    inp=strcompress(inp)
    if !version.release ge '5.3' then begin
        arr=strsplit(inp,' ',/extract)
    endif else begin
        arr=str_sep(inp,' ')
    endelse
    modelData.name  = arr[0]
    modelData.numElm  = long(arr[1])
    modelData.format  = arr[2]
    modelData.enctblNm=arr[3]
    modelData.name=model
    modelData.suf =suf
    i=0
    on_ioerror,done2
    while i lt modelData.numElm do begin
         readf,lun,inp 
         if (strmid(inp,0,2) eq '#!' ) then  inp=strmid(inp,2,strlen(inp)-2)
         if ( strmid(inp,0,1) ne '#') then begin
            reads,inp,az,za
            modelData.azC[i]=az
            modelData.zaC[i]=za
            i=i+1
         endif
    endwhile
done2:
    modelData.numElm=i
    if lun ge 0 then free_lun,lun
    if i ne modeldata.numelm then message,'did not get all the coefficeints'
;----------------------------------------------
;   try and get the encoder data
;
    pathname=dir + modelData.enctblNm
    if n_elements(efile) ne 0 then pathname=dir + efile
    lun=-1
    openr,lun,pathname,/get_lun,error=err
    if err ne 0 then begin
        message,'error ' + !err_string 
    endif
;
;   loop looking for start of data
;
    gotit=0
    match='#!' + modelData.enctblNm
    len=strlen(match)
    inp=' '
    on_ioerror,done3
    while gotit eq 0 do begin
        readf,lun,inp 
        if strmid(inp,0,len) eq match then gotit=1
    endwhile
done3:
    if gotit eq 0 then begin
        if lun ge 0 then free_lun,lun
        message,match + ' not found in ' + pathname
    endif
;
; input the data
;
    i=0
    on_ioerror,done4
    while i lt 41 do begin
         readf,lun,inp 
         if (strmid(inp,0,2) eq '#!' ) then  inp=strmid(inp,2,strlen(inp)-2)
         if ( strmid(inp,0,1) ne '#') then begin
            reads,inp,az,za
            modelData.encTblAz[i]=az
            modelData.encTblZa[i]=za
            i=i+1
         endif
    endwhile
done4:
    if lun ge 0 then free_lun,lun
    if i ne 41 then message,'did not get all the encoder table values'
    return
end
