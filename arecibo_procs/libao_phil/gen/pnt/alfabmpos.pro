;+
;NAME: 
;alfabmpos - compute alfa beam positions from az,za,jd beam 0.
;SYNTAX: alfabmpos,az,za,juldat,rahrs,decDeg,rotAngle=rotAngle,$
;                   hornOffsets=hornOffsets,offsetsonly=offsetsonly,$
;                   nomodel=nomodel
;  ARGS:
;   az[n]:  float  azimuth of central pixel in degrees
;   za[n]:  float  zenith angle of central pixel in degrees
;juldat[n]: double julian date for each az,za. Should include the fraction
;                  of the day.
;KEYWORDS:
;   rotAngl: float  rotation angle (deg)of alfa rotator. default is 0 degrees.
;                   sitting on the rotator floor, positive is clockwise.
;offsetsonly:       if set, then only return the offsets, don't bother to
;                   compute the ra,decs
;nomodel   :        If set , then then az,za supplied already has the 
;                   model removed. It will not remove it a second time.
;RETURNS:
;   raHrs[7,n]: float ra in hours for the 7  beams and the n positions.
;  decDeg[7,n]: float declination in degrees for the 7  beams and the 
;                     n positions.
;hornOffsets[2,7]:float The offsets of the horns relative to pixel 0 in
;                     great circle degrees. The first dimension is
;                     az,za. The second dimension is pixel number
;
;DESCRIPTION:
;   Given the az, za, and juldate for the center pixel of alfa, this routine
;will compute the ra,dec for each of the 7 beams of alfa. The order returned
;is pixel0,1,2,3,4,5,6,7. If az,za,juldat are arrays of length n then
;the return data will be [7,n].
;   By default the rotation angle for the array is 0 deg. You can uset a
;different rotation angle using the rotangle keyword.
;   The horn offsets relative to pixel 0 are returned in the hornOffsets
;keyword. The units are arcseconds. They are the azOff,zaOff values that are
;added to the az,za provided.
;   
;-
;23aug04 - az, za offsets were being added in with the wrong sign.
;26aug04 - when i flipped the az,za offsets, this also flipped the
;          rotation angle. This was not intended. P
;04dec04 - added offsetsonly keyword
;
pro alfabmpos,az,za,jd,rahr,decdeg,rotangle=rotangl,$
              hornOffsets=hornOffsets,offsetsonly=offsetsonly,nomodel=nomodel
;
; great circle offsets for the 7 beams in arc seconds. 
; these are the offsets that make an outer beam point at the
; ra,dec that beam0 was pointing at before the offsets.
; To compute ra,dec of outer beam given az,za of center pixel
; the offsets you add are the negative of the numbers below.
;
;
    azLen0=329.06D              ; center to az edge of ellipse
    zaLen0=384.005D              ; center to za edge of ellipse
    azAlfaOff=[0.000D  ,-164.530,-329.060,-164.530, 164.530,329.060,164.530]
    zaAlfaOff=[0.000D  , 332.558,  0.00 ,-332.558,-332.558,  0.000,332.558]

    n=n_elements(az)
    if n_elements(rotAngl) eq 0 then rotAngl=0.
;
;   compute the az,za offsets to add to the az, za coordinates
;   these are great circle.
;   1. With zero rotation angle,  the th generated is counter clockwise.
;      The offsets in the azalfaoff.. table were generated from using
;      this orientation of the angle.
;   2. The rotangl of the array is positive clockwise (since that is the
;      way the floor rotates when given a positive number). We use a 
;      minus sign since it is opposite of the angle used to generate the 
;      offset array above.
;   3. After computing the angle th and projecting it onto the 
;      major, minor axis of the ellipse, the values are subtracted 
;      from pixel 0 az,za. This is because the offsets computed are to
;      move beamN to beam0. What we want is to move beam0 to beamN.
;      to find the az,el of beamN.
;
    dtord=!dpi/180D
    azOffCmp  =dblarr(7)
    zaOffCmp  =dblarr(7)
    for i=1,6 do begin &$
        th= ((i-5.)*60 - rotAngl)*!dtor &$
        azOffCmp[i]=-azLen0*cos(th)/3600D &$
        zaOffCmp[i]=-zaLen0*sin(th)/3600D &$
    endfor
;
;   
    if not keyword_set(offsetsonly) then begin
        rcv=(keyword_set(nomodel))?0:17
        rahr=dblarr(7,n)
        decdeg=dblarr(7,n)
        for i=0,6 do begin
            azl=az + azOffCmp[i]/sin(za*dtord)
            zal=za + zaOffCmp[i]
;           print,i,azoff[i],zaoff[i],azl,zal
            ao_azzatoradec_j,rcv,azl,zal,jd,raL,decL
            raHr[i,*]  =raL
            decDeg[i,*]=decL
        endfor
    endif
    hornOffsets=dblarr(2,7)
    hornOffsets[0,*]=azOffCmp
    hornOffsets[1,*]=zaOffCmp
    return
end
