;+
;NAME:
;modinp - input model coefficeints
;
;SYNTAX :p12mmodinp,modelData,model=model,suf=suf,rcv=rcv
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
pro p12mmodinp,modelData,model=model,suf=suf,rcv=rcv,$
			dirmod=dirmod


;    dir=aodefdir() + 'data/pnt/'
	dir='/share/megs/phil/svn/aosoft/p12m/etc/'
	mfile='model12m'
	if n_elements(dirmod) gt 0 then dir=dirmod
    modelData={p12mModelData}
    if n_elements(model) eq 0 then model='model'
;   comment out for now	
	if 0 then begin
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
	endif
;    if n_elements(suf)   eq 0 then suf='1A'
;   matches the first we find
    if n_elements(suf)   eq 0 then suf=''
	
    pathname=dir + mfile
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
; get number of points
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
    modelData.fname = pathname
    modelData.name  = strmid(arr[0],2)
    modelData.type  = fix(arr[1])
    modelData.nargs = fix(arr[2])
    modelData.yymmdd=long(arr[3])
    i=0
    on_ioerror,done2
	az=0D
	el=0D
    while i lt modelData.nargs do begin
         readf,lun,inp 
         if (strmid(inp,0,2) eq '#!' ) then  inp=strmid(inp,2,strlen(inp)-2)
         if ( strmid(inp,0,1) ne '#') then begin
			if modelData.type eq 1 then begin
            	reads,inp,c1
           		 modelData.coefC1[i]=c1
			endif
            i=i+1
         endif
    endwhile
done2:
    if lun ge 0 then free_lun,lun
    if i ne modeldata.nargs then message,'did not get all the coefficeints'
;----------------------------------------------
;   try and get the encoder data
;
    return
end
