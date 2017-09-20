;*****************************************************************************
;+
;NAME:
;masgainget - return the gain given an mas header
;
;SYNTAX: stat=masgainget(hdr,gainval,date=date,az=az,za=za,onlyza=onlyza)
;
;ARGS:
;  hdr[n]: {hdr}    header for data
;
;KEYWORDS:
; date[2]: intarray [year,dayNum] if provided, then compute the gain value
;                   at this epoch (ast).
;   az[n]: fltarray If provided, use this for the azimuth value rather than
;                   the header values
;   za[n]: fltarray If provided, use this for the zenith angle values rather
;                   than the header values
;  onlyza:          If set then return the za dependence (average of az)
;RETURNS:
; gainval: float .. gainvalue in K/Jy
;    stat: int   -1 --> error, no data returned
;                 0 --> requested freq is outside freq range of fits.
;                       Return gain of the closed frequency.
;                 1 --> frequency interpolated gain value returned.
;DESCRIPTION:
;   Return the telescope gain value in K/Jy for the requested dataset.
;The gain fits for the receiver in use are input and then the
;values are interpolated to the az, za and observing frequency.
;   If hdr[] is an array then the following restrictions are:
;   1. each element must be from the same receiver and at the same 
;      frequency (eg. all the records from a single scan).
;   2. If the az,za keywords are provided, they must be dimensioned the same
;      as hdr
;
;EXAMPLE:
;   input a mas record and then get the gain value 
;   print,masgget(desc,b)
;   istat=masgainget(b.h,gain)
;   .. gain now has the gain value in K/Jy
;   
;   input an entire file and compute the gain for all
;   records of dataset
;   print,masgetfile(filenam,bar)
;   istat=masgainget(bar.h,gain)
;   gain is now a array = to number of rows in file
;
;NOTE:
;   Some receivers have measurements at a limited range of frequencies (in some
;cases only 1 frequency). If the frequency is outside the range of measured
;frequencies, then the closest measured gain is used (there is no 
;extrapolation in frequency).
;   The date from the header is used to determine which set of
;gain fits to use (if the receiver has multiple timestamped sets).
;   This routine takes the az,za, date, and frequency from the
;header and then calls gainget().
;
;SEE ALSO:
;gen/gainget gen/gaininpdata.pro
;-
;history: 
; 02dec09 - stole from corhgainget
;
function masgainget,hdr,gainval,date=date,az=az,za=za,onlyza=onlyza
;
; return the gain value for this board
; retstat: -1 error, ge 0 ok

;
	mjdtojd=2400000.5D
	asttoutc=4./24.
    rfnum =hdr[0].rfnum
    cfr   =hdr[0].crval1*1e-6
    if n_elements(az) eq 0 then az    =hdr.azimuth
    if n_elements(za) eq 0 then begin
    	za=(90. - hdr.elevatio)
    endif
    if n_elements(date) eq 2 then begin
        datel=date
    endif else begin
		caldat,hdr[0].mjdxxobs +mjdToJd - astToUtc,mon,day,year 
		dayno=dmtodayno(day,mon,year)
        datel=[year,dayno]
    endelse
    return,gainget(az,za,cfr,rfnum,gainval,date=datel,zaonly=onlyza)
end
