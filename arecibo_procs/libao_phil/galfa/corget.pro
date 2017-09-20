; 
;NAME:
;corget - input next correlator record from disc
;
;SYNTAX: istat=corget(lun,b,scan=scan,noscale=noscale,sl=sl,han=han)
;
;ARGS:
;     lun: logical unit number to read from.
;
;RETURNS:
;     b: structure holding the data input
; istat: 1 ok
;      : 0 hiteof
;      :-1 i/o error..bad hdr, etc..
;
;KEYWORDS:
;     noscale : if set, then do not scale each sub correlator to the 
;               9level corrected 0 lag.
;     scan    : if set, position to start of scan first..
;      han    : if set, then hanning smooth the data
;      sl[]   : {sl} array used to do direct access to scan.
;               This array is returned by the getsl procedure.
;
;DESCRIPTION:
;
;   Read the next group of correlator data from the file pointed to 
; by lun. If keywords scan is present, position to scan before reading.
;
; A group is the data from a single integration. Each correlator board 
; is written with a separate hdr and data array. The structure returned will
; contain 1 to 4 elements depending on the number of boards being used.
;  b.b1
;  b.b2
;  b.b3
;  b.b4
;  each bN will have:
;    b.b3.h     - complete header for this board 
;    b.b3.p[2]  int. 1-polA,2->polB, 0, no data this sbc
;    b.b3.accum double   . accumulate scale factor (if used)
;    b.b3.d[nfreqchan,nsbc] the data. nsbc will be 1 or 2 depending on
;                 how many sbc are using in this board.
;    use pol to determine what pol each sbc is. It will also tell you if
;    there is only 1 sbc pol[1] = 0. It will not compensate for
;    zeeman switching..
;
;  The header will contain:
;      .h.std - standard header
;      .h.cor - correlator portion of header
;      .h.pnt - pointing portion of header
;      .h.iflo- if,lo    portion of header
;      .h.dop - doppler frequency/velocity portion of header
;      .h.proc- tcl procedure portion of header
;
; The data is returned in increasing frequency order as floats.
;
; If an i/o error occurs (hit eof) or the hdrid is incorrect (you are not
; correctly positioned at the start of a header), then an error message
; is output and the file is left positioned at the position on entry to the
; routine.
;
;
;EXAMPLE:
;   .. assume 2 boards used, pola,b per board (lagconfig 9)
;   istat=corget(lun,b)
;   b.b1.h        - header first board
;   b.b2.d[*,0]    - data from 2nd board, polA
;
;SEE ALSO:
;    posscan,corgethdr
; 
; history:
; 18jun00 - before this time it was not scaling by the power values.
;           after this date scale by the power values. so carl H.. better
;           switch to /noscale
; 19jun00 - switched to be a function.
; 30jun00 - switched to return a single structure
;  0jul00 - added pol
; 31aug00 - test for divide by zero in scaling..
; 07sep00 - if they don't set noscale, scale the stoke too.
; 29nov03 - check if it is a was call. if so branch to wasget().
;
function corget, lun,b,noscale=noscale,scan=scan,sl=sl,han=han
;
; input correlator group  
;
    forward_function corhflipped
;
;  see if it is a was call
;
    return,galget(lun,b,scan=scan,han=han)
end
