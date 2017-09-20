;+
;NAME:
;cortblradius - get indices for all positions within radius.
;SYNTAX: num=cortlbradius(ra,dec,radius,slar,indlist,hms=hms,radDeg=radDeg,$
;                        encErr=encErr,pattype=pattype,dist=dist)
;ARGS  :
;       ra:  float/double ra Hours    J2000
;      dec:  float/double dec Degrees J2000
;   radius:  float/double radius to search for source. Default Arcminutes
;                         (keyword raddeg switches to degress).
;   slAr[]:  {slcor} array returned from arch_gettbl(../cor)
;KEYWORDS:
; hms   : if set then ra is in hms.s dec is in dms.s rather than hour,degrees
; radDeg: if set then radius is in degrees. default is arcminutes.
; encErr: float. Average encoder error (Asecs) of each scan selected 
;                must be less than this value. The default is 30asec.
; pattype: int   restrict the scans to a particular pattern type.
;                 1 - on/off position switch with cal on/off
;                 2 - on/off position switch whether or not cal there
;                 3 - on followed by cal on ,off
;                 4 - heiles calibrate scan two crosses
;                 5 - heiles calibrate scan 1 or more  crosses
;                 6 - cal on,off
;                 7 - x111auto with calonoff
;                 8 - x111auto with or without cal
;                 If a pattern type is specified then the returned indlist array
;                 will contain pointers to the first scan of each pattern (
;                 not every scan within the pattern). As an example 
;                 pattype=1 would return the indices for the on position scans.
;                 The default is to return all scans independant of pattern
;                 type.
;RETURNS:
;indList[num]: long indices into slar for positions that match the request.
;         num: long number of positions found
;
;DESCRIPTION:
;   Find all of the positions in the SLAR that lie within the specified
;RADIUS of the postion RA,DEC. Return the indicies into SLAR in the array
;INDLIST. The radius is measured as a true angle on the sky.
;
;   The slar positions are the requested ra,dec (rather than the actual).
;The routine requires that the average encoder error of each selected
;scan be less than 30 asecs (you can change this with the encerr keyword).
;   
;EXAMPLE:
;   The most efficient way to use this routine is to first extract a 
;subset of the archive into an slar, and then call this routine multiple
;times with different radii to see how many sources are available. You 
;can then view the sources and extract the actual data records from the archive.
;
;.. get indices of all lband data between 1370 and 1420 Mhz taken during
;.. 2002. 
;
;   n=arch_gettbl(010101,021231,slar,slfilear,freq=[1200.,1420],/cor)
;
;... search for observations of 3C286 (J2000 position).
;   ra =133108.3 
;   dec=303033.0
;... search within 5 arcminutes
;   radius=60.
;   num=cortblradius(ra,dec,radius,slar,indlist,/hms) 
;... print the project id's that took this data. 
;... print the record types (see arch_gettbl for a list).
;   print,slar[indlist].projid
;   print,slar[indlist].rectype
;
;... Look for all of the on/off patterns withing 5amin of Virgo A
;   radius=20.
;   ra=123049   
;   dec=122328  
;   num=cortblradius(ra,dec,radius,slar,indlist,/hms)
;... get the actual data scans processing on/off-1...
;   nfound=arch_getonoff(slar,slfilear,indlist,bout,infoAr,$
;                        incompat=incompat,/sclJy,/verbose)
;
;... look at an individual on/off-1 
;    corplot,bout[0]
;-
;modhistory
;
function cortblradius,ra,dec,radius,slar,indlist,hms=hms,radDeg=radDeg,$
                      encErr=encErr,pattype=pattype,dist=dist
;
    nslar=n_elements(slar)
    if n_elements(encErr) eq 0 then encErr=30.
    if nslar eq 0 then return,0
    distl=corcmpdist(ra,dec,slar=slar,hms=hms)
;
; distl[0,*]= ra  arcmin great circle
; distl[1,*]= dec arcmin great circle
; distl[2,*]= total dist arcmin great circle
    radiusl=radius*1.D
    if keyword_set(raddeg) then radiusl=radiusL*60.D

    indlist =where(  distl[2,*] le radiusL,count)
    if count eq 0 then return,0
;
;   check that telescope was tracking
;
    ind1=where((slar[indlist].azErrAsec^2 + slar[indlist].zaErrAsec^2) le $
                (encErr^2) ,count)
    if count eq 0 then return,0
    indlist=indlist[ind1]
;
;   see if they want a pattern type
;    
    if n_elements(pattype) gt 0  then begin
        n=corfindpat(slar,ind1,pattype=pattype)
        if n eq 0 then return,0
        l1=bytarr(nslar)
        l1[indlist]=1
        l1[ind1]=l1[ind1]+1
        indlist=where(l1 ge 2,count)
    endif
    dist=distl[2,indlist]
    return,n_elements(indlist)
end
