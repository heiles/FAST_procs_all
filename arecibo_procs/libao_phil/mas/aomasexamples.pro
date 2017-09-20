;+
;NAME:
;aomasexamples - Using the idl mas (mock spectrometer)
;SYNTAX: none
;
;   At the Arecibo observatory (AO) the mock spectrometer run in 
;spectral line mode creates AO fits files (also known as cima fits V2.0). The
;format is based on the sdfits format (with a few additions). Idl routines
;have been written to access and process this data. All of these routines
;begin with mas (Mock Arecibo Spectrometer).
;
;<b>Terminology</b>
;bm or box: there are 7 mock boxes in a spectrometer set. 
;           -For alfa each of these is mapped to a beam.
;           -For single pixel observing these are mapped to different frequency bands.
;band     : each box has two separate 172 Mhz subbands.
;          -for alfa these two bands cover the 300 Mhz of alfa for a beam.
;          -for single pixel observing only band 1 is used.
;group    : there are two complete sets (or groups) of 7 boxes.
;           Box N of each group gets the same input IF. The different
;           groups can then vary the resolution, bandwidth, or integration time.
;
;<b>The data files:</b>
;
;<b>The file naming convention is </b>:
;projId.yyyymmdd.bMsNgP.nnnnn.fits where:
;projid  : is the project id entered when the datataking gui (cima) is started.
;yyyymmdd: is the date when the data file was openned (AST).
;bMsNgP  :bM,M=0..6 This is the box/bm number for this file b0..b6
;        :sN,N=0,1  The subband within each box. For single pixel observing
;            this is always s1. For alfa, this can be 0, or 1 for the lower or
;            upper 172 Mhz band.
;        :gP,P=0,1 This is the group number g0 or g1 for this file.
;nnnnnn  : 5 digit number. This gets incremented by 100 for each scan. If
;          a single scan requires more than 1 file (> 2gb) then the next
;          file is nnnnn +1.
;.fits     fits suffix.
;; for more info on the fits file  structure see:
;; http://www.naic.edu/~phil/software/datataking/fits/fit_header.html
;; 
;; Each scan starts a new datafile. If you do a position switch observation
;;followed by a cal on, cal off you will end up with 4 files: position on,
;;position off, calOn, caloff.
;
;<b>File locations:</b>
;	The online datafiles are written to:
;/share/pdataM/pdev/ where M= boxNumber+1 (it goes 1..7 sorry about that).
;They may eventually be moved to /share/projid/xxx where projid is the 
;projid of the file (this does not always happen).
;
;<b>Starting idl:</b>
;   To process the mas datasets:
;
;   idl
;   @phil     (or whatever you need to add your base directory) 
;   @masinit  ..initialize for mas data. This calls @geninit and then 
;               adds the ./mas  directory path to idl's search path.
; -----------------------------------------------------
;NOTE: These routines use the goddard binary fits table routines to
;      access the file. At AO they are in the directory:
;      /pkg/rsi/idl/lib/locallib/astron/pro/fits_bintable. If you download
;      the AO idl routines, you will also need to get a copy of the 
;      goddard routines and add the fits_bintable directory to the path.
;;------------------------------------------------------------------------
; 
;<b>SOME BASICS:</b>
;
;; open a file
;;
;   file='/share/pdata1/pdev/x106_5.20100819.b0s1g0.00000.fits'
;   istat=masopen(file,desc)
;;
;;  list contents of the file
;;
;   maslist,desc
;;
;;
;;  read a row full of data (1 or more spectra):
;;  first rewind the file since maslist() read till the end of file
;   rew,desc
;   istat=masget(desc,b)
;;
;;  look at the b data structure:
;   help,b
;** Structure <88f81dc>, 8 tags, length=656472, data length=656467, refs=1:
;   H               STRUCT    -> MASFHDR Array[1]
;   NCHAN           LONG              8192
;   NPOL            LONG                 2
;   NDUMP           LONG                10
;   BLANKCORDONE    INT              0
;   ST              STRUCT    -> PDEV_HDRDUMP Array[10]
;   ACCUM           DOUBLE           0.0000000
;   D               LONG      Array[8192, 2, 10]
;
;; Note that:
;;   nchan=8192 (8192 freq channels),
;;   npol=2     (2 polarizations)
;;   ndump=10   (there are 10 spectra in this row). 
;;   d[8192,2,10] the data is dimensioned 8192 chan,by 2 pols, by 10 dumps)
;;
;;look at fits header for this row:
; help,b.h,/st
;IDL> help,b.h,/st
;** Structure MASFHDR, 133 tags, length=888, data length=885:
;   TDIM1           STRING    '(8192,1,1,2,10)'
;   TDIM2           STRING    '(10,1,1,1,10)'
;   OBJECT          STRING    'STOPPED'
;   CRVAL1          DOUBLE       1.2000000e+09
;   CDELT1          DOUBLE           21000.000
;   CRPIX1          DOUBLE           4097.0000
;   CRVAL2          DOUBLE           243.63913
;   CRVAL3          DOUBLE           15.457966
;   CRVAL4          DOUBLE          -56.000000
;   CRVAL5          DOUBLE           79762.000
;   CDELT5          DOUBLE          0.10000000
;   AZIMUTH         DOUBLE           285.42697
;   ELEVATIO        DOUBLE           79.973986
;;   ... continues ...
;;
;; Plot the spectra
;; 
; masplot,b
;;
;; this will overplot the 10 .1 second spectra in the row.
;; red is polA, green is polB.
;;
;; look at the documentation for the idl routines:
; explain,masdoc
; ----- Documentation for /pkg/rsi/local/libao/phil/doc/masdoc.pro -----
;;NAME:
;masdoc - routine list (single line)
;
;gftget           - input next galfacts timedome  row from disc
;gftgetfile       - input an entire file
;gftgetstat       - input status info from file
;gftopen          - open galfacts decimation in time file.
;masaccum         - accumulate an array of buffers
;masavg           - read and average spectra
;masavgmb         - read and average spectra for multi beams
;mascalonoff      - compute cal scl factor from calon,caloff
;;  continues..
;;
;; look at the masplot routine:
;;
; explain,masplot
; ----- Documentation for /pkg/rsi/local/libao/phil/mas/masplot.pro -----
;;NAME:
;masplot - plot mas spectra
;SYNTAX: masplot,b,freq=freq ,over=over,pollist=pollist,norm=normRange,off=off,$
;                  retvel=retvel,restFreq=restFreq,velCrdsys=velCrdSys,$
;                                   mfreq=mfreq,colar=colar 
;ARGS:
; b[n]: {b}   mas structure from masget to plot
;KEYWORDS:
;freq[n]: float  if provided then use this as the x axis
;   over:        if set then overplot spectra
;pollist: long   pols to plot: 12 = polA,B, -1--> all pols available
;norm[2]: float  normalize the spectra. If two element array then is is the range
;                of frequency bins to use for the median (cnt from 0). If a single
;                element or /norm then use all the bins.
;    off: float  If multiple spectra then increment each spectra by off.   
;   chn :        if set then plot vs channel number (count from 0)
;   smo : int    smooth by this many channels
;
;; continues..
;;------------------------------------------------------------------------
;;<b> Summary of different routines:</b>
;;
;; Open a file: masopen()
;; close a file: masclose()
;; Input a single row : masget()
;; postion to a row in a file: maspos()
;; input an entire file: masgetfile()
;; plot one or more spectra: masplot()
;; find a set of files: masfilelist()
;; ..  masonofffind() find position switch files
;; ..  masdpsfind()  find double position switch files
;;
;; On off position switching:masposonoff()
;; double position switching:masdpsp()
;; Calibrate stokes data: masstokes()
;;
;; Accumulate spectra (after readin:):masaccum()
;; Perform arithmetic on spectra: masmath()
;; Compute rms/mean by channel for an array of spectra: masrms()
;;
;;------------------------------------------------------------------------
;;<b> automating file access:</b>
;; The datataking generates lots of files. You can automate the processing
;; of these files used masfilelist(). This will select a subset of files
;; on disc given the date, projid, beam, band, group, etc. It returns
;; an array of structures (fnmI[] filenamem info structures).
;; You can then pass elements of this array to masopen() and some other 
;; routines to automate the processing.
;; A second routine:
;; masfilesum() will take an fnmI[] array and read the headers for each of 
;; these files. You could then fine tune the selection process using the
;; where() routine of idl:
;; EG:
;; find the a2489 files on 09oct09, all beams,band=1:
;; n=masfilelist('',fnmI,proj='a2489',yymmdd=20091009,band=1,/appbm)
;; n returns 448 files found
;IDL> help,fnmI,/st
;** Structure MASFNMPARS, 9 tags, length=64, data length=62:
;   DIR             STRING    '/share/pdata1/pdev/'
;   FNAME           STRING    'a2489.20091009.b0s1g0.00000.fits'
;   PROJ            STRING    'a2489'
;   DATE            LONG          20091009
;   SRC             STRING    ''
;   BM              INT              0
;   BAND            INT              1
;   GRP             INT              0
;   NUM             LONG             0
;;
;; read the headers from all the bm =0 files
;;
; ii=where(fnmI.bm eq 0,cnt)
; fnmI0=fnmI[ii]
;
; nsum=masfilesum('',sumI,fnmI=fnmI0,/list)
;;
;; select the on source scans:
; ii=where((sumI.h.obsmode eq 'ONOFF') and (sumI.h.scantype eq 'ON'),cnt)
;;
;; The above was just a demo for explaining things.. 
;; All of the above can also be done using the routine masonofffind()
;; 
;-
