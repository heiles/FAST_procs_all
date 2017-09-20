;+
;NAME: 
;wappalfabmpos - compute alfa beam positions from wapp hdr
;SYNTAX: wappalfabmpos,fileinp,fileout,inplist=inplist
;  ARGS:
;   fileinp: string inpfile to use. wappfilename or name of list file
;                   see inplist keyword
;   fileout: string file to write output to (in ascii).
;                  of the day.
;KEYWORDS:
;   inpList:        if set then the fileinp contains a list of wapp
;                   files to process.
;                   use the default value.
;DESCRIPTION:
;   wappalfabmpos will compute the ra,dec (J2000) for the 7 alfa beams
;given a wapp pulsar data file. It reads the header, finds the az,za, and
;start time, and finally computes the ra, dec from these. For now it
;is using the default orientation of the alfa array.
;
;The output format is ascii is:
;basename of wappfile
;beamNum raHrs decDeg hh:mm:ss dd:mm:ss 
;
;for beams 0 thru 6 
;-
;
pro wappalfabmpos,fileinp,fileout,inplist=inplist
;
;   
;
    on_ioerror,done
    lunlist=-1
    lunOut =-1
    useList=0
    openw,lunout,fileout,/get_lun
    if keyword_set(inplist) then begin
        openr,lunlist,fileinp,/get_lun
        useList=1
    endif 
    wappname=''
    done=0
    rcvnum=17
    while not done do begin
        if uselist then begin
            readf,lunlist,wappname
        endif else begin
            wappname=fileinp
        endelse
;
;   loop to process a file
;
        openr,lun,wappname,/get_lun
        istat=wappgethdr(lun,hdr)
        yr  =long(hdr.obs_date)/10000l
        mon =(long(hdr.obs_date)/100L) mod 100L
        day =long(hdr.obs_date) mod 100L
        hr  =strmid(hdr.start_time,0,2)
        min =strmid(hdr.start_time,3,2)
        sec =strmid(hdr.start_time,6,2)
        jd=julday(mon,day,yr,hr*1d,min,sec*1d)
        raHrCen  =hms1_hr(hdr.src_ra)
        decDegCen=dms1_deg(hdr.src_dec)
        ao_radecjtoazza,rcvnum,raHrCen,decDegCen,jd,az,za
;       az=hdr.start_az
;       za=hdr.start_za
        alfabmpos,az,za,jd,ra,dec
        ii=strpos(wappname,'/',/reverse_se)
        bname=strmid(wappname,ii+1)
        printf,lunout,bname 
        for i=0,6 do begin 
            ralab =fisecmidhms3(ra[i]*3600D)  
            declab=fisecmidhms3(dec[i]*3600D) 
            lab=string(format=$
    '(i2,1x,f9.5,1x,f9.4,1x,a,1x,a)',i,ra[i],dec[i],ralab,declab) 
            printf,lunout,lab 
        endfor
        free_lun,lun
        done=not uselist
    endwhile
done:   
    if lunout  ne -1 then free_lun,lunout
    if lunlist ne -1 then free_lun,lunlist
    return
end
