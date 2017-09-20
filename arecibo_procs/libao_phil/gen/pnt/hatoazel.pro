;+
;NAME:
;hatoazel - hour angle dec to az/el (3 vector)
;
;SYNTAX: azelv=hatoazel(hadecV,latRd)
;
;ARGS:
;   hadecV[3,npts] : hour angle dec 3 vector (see radecdtohav).
;   latRd          : float/double latitude in radians
;
;RETURNS:
;   azelv[3,npts]  : az,el 3 vector (for source position not feed).
;
;DESCRIPTION
; Transform from  from an hour angle dec system to an azimuth elevation system.
; These are the source azimuth and elevation.
;
; The returned 3 vector has z pointing at zenith, y pointing east (az=90),
; and x pointing to north horizon (az=0). It is a left handed system.
;-
function hatoazel,hadecv,latrd

        th   =latRd- !dpi/2.d
        costh=cos(th);
        sinth=sin(th);
        v=hadecv
        v[0,*]=  -(costh*hadecv[0,*])             -(sinth * hadecv[2,*]);
        v[1,*]=                      -hadecv[1,*]                 ;
        v[2,*]=  -(sinth*hadecv[0,*])                +(costh * hadecv[2,*]);
        return,v
end
