;+
;NAME:
;galftochdr - convert fits hdr to cor header
;
;SYNTAX: istat=galftochdr(desc,h,hf=hf,nrows=nrows,irec=irec)
;
;ARGS: 
;   desc:{galdesc} gal descriptor returned from galopen()
;
;RETURNS:
;   istat: int  1 ok, 0 eof, -1 error.
;    h: {corhdr}  correlator header
;    hf:{galhdr}  gal hdr extension..
; nrows:   long   number of rows to advance desc.curpos if you
;                 want to update the position.
;pol[2,nbrds]:  long   codes the pol type polA=1, polB=2 for each 
;                 spectra on each board.
;iscan :   long   index into desc.scanI[] for this scans data.
;
;DESCRIPTION:
;   Read in a fits header for the current group and convert it
;to a correlator header. If the file is not positioned at
;the start of a group, then move forward to the start of the
;next group.
;
;NOTE: this routine does not update the position in the file.
;You are left pointing at the input position.
; This is a lowlevel routine that is not normally called via
;corget().
;
; current data being loaded into b1.h from fits header:
; tointerimHdr      from fitsHdr
; --------------------
; STD
;h.std.time          fits.crval5 convert to ast secs
;h.std.date          yyyyddd
;h.std.azttd         fits.ENC_AZIMUTH
;h.std.grttd         fits.ENC_ELEVATIO
;h.std.chttd         fits.ENC_ALTEL
;h.std.posTmMs       fits.ENC_TIME
;h.std.grpTotRecs    desc.scanI.nbrds 
;h.std.grpNum        
; --------------------
; COR
;h.cor.numbrdsused   desc.scanI.nbrds
;h.cor.numSbcOut     desc.scanI.nsbc
;h.cor.lagsbcout     desc.scanI.nlags
;h.cor.boardId       desc.scanI.brdNum
; --------------------
; PROC
;h.proc.srcname      fits.OBJECT
;h.proc.procname     fits.OBSMODE with name translation new to old
; --------------------
; -
;history
; 25jun04 - if frontend = alfa, force rfnum to be 17
; 13jul04 - check for eof by row.
; 18jul04 - added if2.. mixer
; 09aug04 - added rajcumrd decjcumrd
; 12aug04 - for spider scans with alfa include the pixel number in iar[5]
;           taken from the pattern name .
; 14aug04 - for spider scans load iar[0] with a beamwidth.Use stripLen/6.
; 20aug04 - added iscan keyword to return to user
; 22oct04 - updated to new header version. wide band has 512 channels
;           instead of just 256 V1 has the old 256 channel def.
; 28oct04 - version 3 header
; 18jul05 - added object, obs_name
;-
function galftochdr,desc,h,hf=hf,nrows=nrows,irec=irec
;
;   map the curpos row ptr (0 based) in the scan, grp we are about to read
;
    on_error,0
    errmsg=''
    istat=galalignrec(desc,recInd=recInd)
    if istat ne 1 then return,istat
;
    rowsInRec=desc.rowsInRec[recind]
    curposUsed=desc.curpos
    if (curposUsed + rowsInRec - 1 ) ge desc.totrows then begin
        return,0                ; hit eof
    endif
    recNum=recInd+1
    nrows=rowsInRec
;
    curPosStart=desc.curpos
        
    nbrds=7
    h =replicate({hdr},nbrds)
    if  desc.wbchan eq 256 then begin
        hf=replicate({galfhdrV1},nbrds)
    endif else begin
        hf=replicate({galfhdr},nbrds)
    endelse
    rng=[curPosStart+1,curPosStart+rowsInRec]
;
;  Get the data 
;
;   time crval5 and Ast .. this is from the datataking timestamp
;
    fxbread,desc.lun,crval1,'CRVAL1',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,cdelt1,'CDELT1',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,crpix1,'CRPIX1',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,crval4,'CRVAL4',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,bandwid,'BANDWID',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,restfreq,'RESTFREQ',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,frontend,'FRONTEND',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,ifval,'IFVAL',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_wide,'G_WIDE',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_err,'G_ERR',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_seq,'G_SEQ',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_beam,'G_BEAM',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_wshift,'G_WSHIFT',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_nshift,'G_NSHIFT',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_wpfb,'G_WPFB',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_npfb,'G_NPFB',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_mix,'G_MIX',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_ext,'G_EXT',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_adc,'G_ADC',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_wcenter,'G_WCENTER',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_wband,'G_WBAND',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_wdelt,'G_WDELT',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_dac,'G_DAC',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,g_time,'G_TIME',rng,errmsg=errmsg 
    if errmsg ne '' then goto,hdrreaderr
;
;   version 3 data
;
    if desc.version ge '3.0' then begin
        fxbread,desc.lun,crval2a,'CRVAL2A',rng,errmsg=errmsg 
        if errmsg ne '' then goto,hdrreaderr
        fxbread,desc.lun,crval3a,'CRVAL3A',rng,errmsg=errmsg 
        if errmsg ne '' then goto,hdrreaderr
        fxbread,desc.lun,crval2b,'CRVAL2B',rng,errmsg=errmsg 
        if errmsg ne '' then goto,hdrreaderr
        fxbread,desc.lun,crval3b,'CRVAL3B',rng,errmsg=errmsg 
        if errmsg ne '' then goto,hdrreaderr
        fxbread,desc.lun,alfa_ang,'ALFA_ANG',rng,errmsg=errmsg 
        if errmsg ne '' then goto,hdrreaderr
        fxbread,desc.lun,obsmode,'OBSMODE',rng,errmsg=errmsg 
        if errmsg ne '' then goto,hdrreaderr
        fxbread,desc.lun,obs_name,'OBS_NAME',rng,errmsg=errmsg 
        fxbread,desc.lun,object,'OBJECT',rng,errmsg=errmsg 
        if errmsg ne '' then goto,hdrreaderr
        fxbread,desc.lun,equinox,'EQUINOX',rng,errmsg=errmsg 
        if errmsg ne '' then goto,hdrreaderr
        fxbread,desc.lun,g_lo1,'G_LO1',rng,errmsg=errmsg 
        if errmsg ne '' then goto,hdrreaderr
        fxbread,desc.lun,g_lo2,'G_LO2',rng,errmsg=errmsg 
        if errmsg ne '' then goto,hdrreaderr
        fxbread,desc.lun,g_postm,'G_POSTM',rng,errmsg=errmsg 
        if errmsg ne '' then goto,hdrreaderr
        fxbread,desc.lun,g_azzatm,'G_AZZATM',rng,errmsg=errmsg 
        if errmsg ne '' then goto,hdrreaderr
    endif
    ind=lindgen(7)*2
    hf.version=desc.version
    hf.crval1 =crval1[ind]
    hf.cdelt1 =cdelt1[ind]
    hf.crpix1 =crpix1[ind]
    hf.crval4 =reform(crval4,2,nbrds)
    hf.bandwid=bandwid[ind]
    hf.restfreq=restfreq[ind]
    hf.frontend=frontend[ind]
    hf.ifval   =reform(ifval,2,nbrds)
    hf.g_wide  =reform(g_wide,desc.wbchan,2,nbrds)
    hf.g_err   =reform(g_err,2,nbrds)
    hf.g_seq   =reform(g_seq,2,nbrds)
    hf.g_beam  =g_beam[ind]
    hf.g_wshift=g_wshift[ind]
    hf.g_nshift=g_nshift[ind]
    hf.g_wpfb  =g_wpfb[ind]
    hf.g_npfb  =g_npfb[ind]
    hf.g_mix   =g_mix[ind]
    hf.g_ext   =g_ext[ind]
    hf.g_adc   =g_adc[ind]
    hf.g_wcenter=g_wcenter[ind]
    hf.g_wband  =g_wband[ind]
    hf.g_wdelt  =g_wdelt[ind]
    if desc.version ge '3.0' then begin
        hf.crval2a=crval2a[ind]
        hf.crval3a=crval3a[ind]
        hf.crval2b=crval2b[ind]
        hf.crval3b=crval3b[ind]
        hf.alfa_ang=alfa_ang[ind]
        hf.obsmode =obsmode[ind]
        hf.obs_name=obs_name[ind]
        hf.object  =object[ind]
        hf.equinox =equinox[ind]
        hf.g_lo1   =g_lo1[ind]
        hf.g_lo2   =g_lo2[ind]
        hf.g_postm =g_postm[ind]
        hf.g_azzatm=g_azzatm[ind]
    endif
;
;   version 1 g_dac had 14 elements
;
    if n_elements(g_dac) gt (2*nbrds) then begin
        hf.g_dac    =reform((reform(g_dac,2,14,nbrds))[0,*,*])
	endif else begin
        hf.g_dac    =reform(g_dac,2,nbrds)
	endelse

    hf.g_time   =reform((reform(g_time  ,2,2,nbrds))[*,0,*],2,nbrds)
    sec=round(g_time[0,0] + g_time[1,0]*1d-6)       ; assume utc
    jd=julday(1,1,1970,0,0D,sec)
    hf.jd_obs  =jd
    hf.sec1970= sec
    caldat,jd- 4D/24.,mon,day,yr,hr,min,sec ; get ast time

    h.cor.numbrdsused=nbrds
    h.cor.numsbcout=2
    h.cor.lagsbcout=desc.nbchan
    h.cor.boardid    =lindgen(nbrds)+1

    h.std.time=hr*3600L + min*60L + round(sec) ; may be 86400!! 
    h.std.date=yr*1000l + dmtodayno(day,mon,yr)
    h.std.grptotrecs  =nbrds
    h.std.grpnum      =reform((reform(g_seq,2,7))[0,*])
    h.std.azttd       =round(hf.crval2b*10000L)
    h.std.grttd       =round(hf.crval3b*10000L)
    h.std.postmms     =round(hf.g_azzatm*3600D*1000D)
    h.proc.procname   =byte(hf[0].obsmode)

    return,1

hiteof:
    return,0
hdrreaderr:
    print,'Error reading hdr data:'+ errmsg
    return,-1
end
