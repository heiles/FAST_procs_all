;+
;NAME:
;epvinput - input earth pos,vel chebychev polynomials
;SYNTAX: istat=epvinput(mjd1,mjd2,epvI,ndays=ndays,file=file)
;ARGS:
;   mjd1:   long  first mjd of range to include
;   mdj2:   long  last mjd  of range to include (ignored if ndays is
;                 included).
;KEYWORDS:
;   ndays: long    if provided then ignore mjd2. The last day of range
;                  will be mjd1+ndays-1
;   file : ''      If non blank then read the polynomials from here.
;                  If null (or not provided) then use the default 
;                  filename.
;RETURNS:
;  istat:  long    return status:
;                  0  --> dates range is outside filename range.
;                  > 0--> number of days returned.
;                  < 0--> error message 
;                  -1     could not open the file.
;                  -2     epv file header has wrong format.
;                  -3     mjd1 is not in the file date range
;   epvI: {}      structure containing the polynomials. this will be
;                  passed to epvcompute().
;
;DESCRIPTION:
;/*
;   epvcompute() returns the position and velocity of the Center of
;   the Earth with respect to the Solar System Barycenter at a given
;   TDB time.  The values are interpolated from the JPL ephemeris DE403, as
;   provided by their fortran routine dpleph.  Their polynomials were
;   re-interpolated onto approximately one-day intervals using the
;   numerical recipes routines.  
;
;   epvinput() inputs the daily polynomials that are used by epvcompute()
;   from the file data/epv_chebfile.dat. 
;
;   EPV_T1, EPV_T2 are the daily interval over which the chebychev 
;   polynomials are interpolated.  They shouldn't necessarily be evaluated 
;   this far out. They were chosen to be representable in base 2.
;   The polynomials should give correct results over the range minT,maxT.
;   This range is larger than 1 day. The idea is to allow some overlap in 
;   fractional days so that you don't have to switch in the middle of an 
;   observation.
;
;   The polynomial format is *hard-coded* to 5th order Chebychev polynomials,
;   and c(1) is multiplied by 0.5, so that that needn't be done in the
;   evaluator.
;
;   Calling sequence: call epvinput to open the data file and read the
;   day of interest.  Then calls to epvcompute will return the pv array.
;
;-Mike Nolan 1997 May 29
;   with mods by phil 27mar98.
;
;NOTE:
;   The data file data/epv_chebfit.dat has data from 2004 thru 2024.
;-
function  epvinput,mjd1,mjd2,epvI,ndays=ndays,file=file 
;
; 45 minutes before */
;
    EPV_MINTm=(-.03125D)
; 3 hours after
    EPV_MAXTm=(1.125D)

    istat=0L
    EPV_CHEBORDER=5             ; order of cheb polynomial
    EPV_NUMCOEF  =6             ; x,y,z,vx,vy,vz
    EPV_CHFORMATID=1
    EPV_T1= -0.0625D            ; start of daily interpolation units=day
    EPV_T2= 1.1875D             ; end of daily interpolation.   

    if n_elements(file) eq 0 then file=aodefdir()+ 'data/epv_chebfile.dat'
    if n_elements(ndays) gt 0 then mjd2=mjd1+ndays-1L
    mjd2L=mjd2
    lun=-1
    err=0
    openr,lun,file,/get_lun,err=err
    if err ne 0 then begin
        printf,-2,!error_state.msg
        istat=-1
        goto,done
    endif
;   /*
;    * input the header
;   */
;   on_ioerror,ioerr
    epvHdr={epv_chbheader}
    readu,lun,epvHdr
    needswap=epvHdr.formatid ne 1   ; for big,little endian
    if needswap then epvHdr=swap_endian(epvHdr)
;
;   verify that the header is ok
;   
    if ((epvHdr.formatid   ne  EPV_CHFORMATID) or $
        (epvHdr.headersize ne  n_tags(epvHdr,/data_length))  or $
        (epvHdr.order      ne  EPV_CHEBORDER) or $
        (epvHdr.ncoef      ne  EPV_NUMCOEF)) then  begin
            istat=-2
            goto,done
    endif
;   
;   see if  mjd range in the file
; 
    if ((mjd1 lt epvHdr.mjd1) or (mjd1 gt epvHdr.mjd2)) then begin
        istat=-3
        goto,done
    endif
;
;   make sure we don't go off the end of the file
;
    mjd2L=(mjd2L gt epvHdr.mjd2)?epvHdr.mjd2:mjd2
;   
;    position to start day of interest 
;   
    byteStart=(mjd1 - epvHdr.mjd1 + 1) * epvHdr.datasize 
    point_lun,lun,byteStart
;
;   allocate then read the data
;
    ndaysL=mjd2L-mjd1 + 1L
    data=replicate({EPV_CHBDAY},ndaysL) 
    readu,lun,data
    if needswap then data=swap_endian(data)
;
;   now stuff into array we will return
;
    epvI={  hdr  : epvHdr ,$
            t1: EPV_T1   ,$; start of daily interpolation
            t2: EPV_T2   ,$; end of daily interpolation.
         minTm: EPV_MINTm,$; before start of day you can use
         maxTm: EPV_MAXTm,$; after end of day you can use
         ndays: ndaysL ,$ ; we are returning
         dayI : data } 
    istat=ndaysL
done:
    if lun gt 0 then free_lun,lun
    return,istat
end
