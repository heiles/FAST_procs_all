;+
;NAME:
;masopen - open mas file for reading
;SYNTAX: istat=masopen(filename,desc,fnmI=fnmI,hdr=hdr)
;ARGS:
;   filename: string    filename to open (unless fnmI is specified)
;   fnmI    : {]        returned from masfilelist. if provided,
;                       then ignore filename and use this as the
;                       file to open.
;KEYWORDS:
;RETURNS:
;   istat: 0 ok
;          -1 could not open file.
;   desc : {}  file descriptor to pass to the i/o routines.
;    hdr : [string] if present then return fits bintable header for the fille
;-
function masopen,filename,desc,hdr=hdr,fnmI=fnmI
;
;
;
   common mascom,masnluns,maslunar

   extension=1                 ; first extension

    errmsg=''
    lun=-1
    fileLoc=(n_elements(fnmI) gt 0)?fnmI[0].dir+fnmI[0].fname:filename
    fxbopen,lun,fileLoc,extension,hdr,errmsg=errmsg
    if errmsg ne '' then begin
        print,errmsg
        goto,errout
    endif
;
;    remember lun in case masclose,/all
;
    ind=where(maslunar eq 0,count)
    if count gt 0 then begin
        maslunar[ind[0]]=lun
        masnluns=masnluns+1
    endif


    naxis1=fxpar(hdr,"NAXIS1");
    naxis2=fxpar(hdr,"NAXIS2");
    if naxis2 le 0 then begin
        print,"No rows in file:"
        return,-1
    endif
;
;   get the pdev main and sp1 header from the fits bin extension header
;
    hmain={pdev_hdrpdev}
    hsp1={pdev_hdrsp1}

    h=fxbheader(lun)            ; get the header
	keys=strmid(h,0,8)
	if ((ii=where(keys eq 'CALCTL  ',cnt)) ne -1) then	hmain.calctl =strmid(h[ii[0]],10,20)
	if ((ii=where(keys eq 'WCALON  ',cnt)) ne -1) then	hmain.wcalon =strmid(h[ii[0]],10,20)
	if ((ii=where(keys eq 'WCALOFF ',cnt)) ne -1) then	hmain.wcaloff=strmid(h[ii[0]],10,20)
	if ((ii=where(keys eq 'WCALPHAS',cnt)) ne -1) then	hmain.wcalphase=strmid(h[ii[0]],10,20)
    ii=where(strmid(h,0,2)  eq "PH",cnt)
    if cnt gt 0 then begin
        a=stregex(h,"^(PH[^ =]*)[= ]+([^ ]*) /",/extract,/subexpr)
        nm=reform(a[1,*])
        val=reform(a[2,*])
        if ((ii=where(nm eq 'PHMAINID')) ne -1) then hmain.magic_num=val[ii]
        if ((ii=where(nm eq 'PHSP1ID')) ne -1) then hmain.magic_sp=val[ii]
        if ((ii=where(nm eq 'PHADCF')) ne -1) then hmain.adcf=val[ii]
        if ((ii=where(nm eq 'PHBSWAP')) ne -1) then hmain.byteswapCode=val[ii]
        if ((ii=where(nm eq 'PHBLKSIZ')) ne -1) then hmain.blkSize=val[ii]
        if ((ii=where(nm eq 'PHNBLKS')) ne -1) then hmain.nblksdumped=val[ii]
        if ((ii=where(nm eq 'PHBEAM')) ne -1) then hmain.beam=val[ii]
        if ((ii=where(nm eq 'PHSUBBND')) ne -1) then hmain.subband=val[ii]
        if ((ii=where(nm eq 'PHLO1MIX')) ne -1) then hmain.lo1mix=val[ii]
        if ((ii=where(nm eq 'PHLO2MX0')) ne -1) then hmain.lo2mix0=val[ii]
        if ((ii=where(nm eq 'PHLO2MX1')) ne -1) then hmain.lo2mix1=val[ii]
        if ((ii=where(nm eq 'PHADCCLK')) ne -1) then hmain.adcclk=val[ii]
        if ((ii=where(nm eq 'PHSTTIME')) ne -1) then hmain.time=val[ii]
        if ((ii=where(nm eq 'PHRESV1')) ne -1) then hmain.resv1=val[ii]
        if ((ii=where(nm eq 'PHIF1')) ne -1) then hmain.if1=val[ii]

        if ((ii=where(nm eq 'PHFMTWID')) ne -1) then hsp1.fmtWidth=val[ii]
        if ((ii=where(nm eq 'PHFMTTYP')) ne -1) then hsp1.fmtType=val[ii]
        if ((ii=where(nm eq 'PHFFTLEN')) ne -1) then hsp1.fftlen=val[ii]
        if ((ii=where(nm eq 'PHCHN1')) ne -1) then hsp1.chndump1=val[ii]
        if ((ii=where(nm eq 'PHCHN2')) ne -1) then hsp1.chndump2=val[ii]
        if ((ii=where(nm eq 'PHFFTACC')) ne -1) then hsp1.fftaccum=val[ii]
        if ((ii=where(nm eq 'PHDRPACC')) ne -1) then hsp1.fftdrop=val[ii]
        if ((ii=where(nm eq 'PHARSEL')) ne -1) then hsp1.arsel=val[ii]
        if ((ii=where(nm eq 'PHAISEL')) ne -1) then hsp1.aisel=val[ii]
        if ((ii=where(nm eq 'PHBRSEL')) ne -1) then hsp1.brsel=val[ii]
        if ((ii=where(nm eq 'PHBISEL')) ne -1) then hsp1.bisel=val[ii]
        if ((ii=where(nm eq 'PHARNEG')) ne -1) then hsp1.arneg=val[ii]
        if ((ii=where(nm eq 'PHAiNEG')) ne -1) then hsp1.aineg=val[ii]
        if ((ii=where(nm eq 'PHBRNEG')) ne -1) then hsp1.brneg=val[ii]
        if ((ii=where(nm eq 'PHBINEG')) ne -1) then hsp1.bineg=val[ii]
        if ((ii=where(nm eq 'PHPFBBYP')) ne -1) then hsp1.pfbBypass=val[ii]
        if ((ii=where(nm eq 'PHPSHIFT')) ne -1) then hsp1.fftshiftMask=val[ii]
        if ((ii=where(nm eq 'PHUPSHFT')) ne -1) then hsp1.upshift=val[ii]
        if ((ii=where(nm eq 'PHDSH_S0')) ne -1) then hsp1.Dshift_S0=val[ii]
        if ((ii=where(nm eq 'PHDSH_S1')) ne -1) then hsp1.Dshift_S1=val[ii]
        if ((ii=where(nm eq 'PHDSH_S2')) ne -1) then hsp1.Dshift_S2=val[ii]
        if ((ii=where(nm eq 'PHDSH_S3')) ne -1) then hsp1.Dshift_S3=val[ii]
        if ((ii=where(nm eq 'PHASH_S0')) ne -1) then hsp1.Ashift_S0=val[ii]
        if ((ii=where(nm eq 'PHASH_S1')) ne -1) then hsp1.Ashift_S1=val[ii]
        if ((ii=where(nm eq 'PHASH_S2')) ne -1) then hsp1.Ashift_S2=val[ii]
        if ((ii=where(nm eq 'PHASH_S3')) ne -1) then hsp1.Ashift_S3=val[ii]
        if ((ii=where(nm eq 'PHASH_SI')) ne -1) then hsp1.Ashift_SI=val[ii]
        if ((ii=where(nm eq 'PHDRPST')) ne -1)  then hsp1.fftDropSt=val[ii]
        if ((ii=where(nm eq 'PHDLO')) ne -1)    then hsp1.dLo=val[ii]
        if ((ii=where(nm eq 'PHDLOPH')) ne -1)  then hsp1.dLoPhase=val[ii]
        if ((ii=where(nm eq 'PHHRMODE')) ne -1) then hsp1.hrMode=val[ii]
        if ((ii=where(nm eq 'PHHRDEC')) ne -1)  then hsp1.hrDec=val[ii]
        if ((ii=where(nm eq 'PHHRSHIF')) ne -1) then hsp1.hrShift=val[ii]
        if ((ii=where(nm eq 'PHHROFF')) ne -1)  then hsp1.hrOffset=val[ii]
        if ((ii=where(nm eq 'PHHRLPF')) ne -1)  then hsp1.hrLpf=val[ii]
        if ((ii=where(nm eq 'PHHRDWEL')) ne -1) then hsp1.hrDwell=val[ii]
        if ((ii=where(nm eq 'PHHRINC')) ne -1)  then hsp1.hrInc=val[ii]
        if ((ii=where(nm eq 'PHBLKSEL')) ne -1) then hsp1.blanksel=val[ii]
        if ((ii=where(nm eq 'PHBLKPER')) ne -1) then hsp1.blankper=val[ii]
        if ((ii=where(nm eq 'PHADCTHR')) ne -1) then hsp1.ovfadc_thr=val[ii]
        if ((ii=where(nm eq 'PHADCDWL')) ne -1) then hsp1.ovfadc_dwell=val[ii]
        if ((ii=where(nm eq 'PHCALSEL')) ne -1) then hsp1.calsel =val[ii]
        if ((ii=where(nm eq 'PHCALPH')) ne -1)  then hsp1.calphase=val[ii]
        if ((ii=where(nm eq 'PHCALCTL')) ne -1) then hsp1.calctl =val[ii]
        if ((ii=where(nm eq 'PHCALON')) ne -1)  then hsp1.calon  =val[ii]
        if ((ii=where(nm eq 'PHCALOFF')) ne -1) then hsp1.caloff =val[ii]
    endif
;
;    get offset info
;
    fxbtform,hdr,tbcol          ; offset each col bytes from start of rec
    fxbread,lun,junk,3,1        ; read col three of first rec
    point_lun,-lun,pos
    rec1start=pos - tbcol[3]    ;
    descBytes=tbcol[2];         ; bytes for 2 array descriptor
;
;   see where scans start
;
;   fxbread,lun,subscan,"SUBSCAN" ; this is the record number
;    if needswap then subscan=swap_endian(subscan);
;   fxbread,lun,ifval,"IFVAL"     ; rows in a rec
;    if needswap then ifval=swap_endian(ifval);
;
    val1=1
    val2=1
    byteorder,val2,/htons
    needswap=val1 ne val2
    hdrb={masfhdrb} 
    n=n_tags(hdrb)
    ii=intarr(n)
    for j=0,n-1 do begin &$
        sz=size(hdrb.(j)) &$
;       .(90) is tcal_numCoef. byte arrays >=8 before this are strings
        if ((sz[0] gt 0) and (sz[1] ge 8) and (sz[2]=1) and (j lt 90) ) then ii[j]=1
    endfor
    ii=where(ii eq 1)
    desc={   lun     : lun       ,$;
             filename: fileLoc,$;
             needswap: needSwap,$;  1 if need to swap the data o nthe cpu
             bytesRow:  naxis1   ,$; bytes 1 row
             totRows :  naxis2   ,$; total number of rows in table
             curRow  : 0L        ,$;
             byteOffRec1:rec1start,$
             descBytes:descBytes,$  ; bytes used by descriptors
             hmain   : hmain,$ ; main pdev header
             hsp1    : hsp1,$ ; main pdev header
             strInd  : ii }     ; indices in hdr that are strings
    return,0  
errout:
    if (lun gt -1) then  fxbclose,lun
    return,-1 
end
