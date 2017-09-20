;+
;NAME:
;fluxsrc - return source flux
;SYNTAX: flux=fluxsrc(srcname,freq,radec=radec,width=width,riseset=riseset)
;ARGS:
;srcname : string source to search for in files.
;freq    : float  the frequecy of interest in Mhz.
;RETURNS:
;flux    : float  The flux in janskies.
;radec[2]: double return the ra,dec B1950 in the radec keyword if
;                 provided.
;                 radec[0] (ra)  is in hours.
;                 radec[1] (dec) is in degrees.
;width[2]: float  width (major,minor) axis in arcseconds.
;                 0--> no data
;                 < 0 --> true values are less than these values
;riseset[2]: float  hhmmss.s rise,set time for source
;DESCRIPTION:
;   The file aodefdir()/data/fluxsrc.dat has fits of flux versus frequency
;for a number of sources. This routine will return the flux given a
;frequency if the source name is in the file. If you provide the 
;radec keyword, the the B1950 ra,dec position will be provided.
;SEE ALSO:
;fluxsrclist, fluxsrcload.
;-
;history
;12aug04 - force srcname to be upper case
;25nov04 - added positions
;06sep08 - added rise/set
function fluxsrc,src,freq,radec=radec,width=width,riseset=riseset
    common fluxcom,fluxdata,fluxcominit

    if not keyword_set(fluxcominit) then fluxsrcload
    srcl=strupcase(src)
    ind=where(srcl eq fluxdata.name,count)
    if count gt 0 then begin
        x=alog10(freq)
        if arg_present(radec) then $
            radec=[fluxdata[ind].rahB,fluxdata[ind].decDB]
        if arg_present(width) then $
            width=fluxdata[ind].widths
        if arg_present(riseset) then $
            riseset=[fluxdata[ind].rise,fluxdata[ind].set]
        return,10^(fluxdata[ind].coef[0]+fluxdata[ind].coef[1]*x+$
                                       fluxdata[ind].coef[2]*exp(-x))
    endif else return,0.
end
