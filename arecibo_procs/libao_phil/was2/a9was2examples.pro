;+
;NAME:
;a0was2examples - Accessing was (wapp) fits files.
;
;   The wapp run in spectral line mode creates fits files. This is a 
;different file format than the one used by the interim correlator. 
;A set of routines has been written to access the fits files and map 
;them into the same data structure as the interim correlator.
;After this mapping, the normal corget,corplot,corxxx routines can be
;used to process the data. 
;
;   There are a few routines that are unique to this data format. They
;begin with wasxxx: Wideband Arecibo Spectrometer (the prefix wapp was
;already in use for the wapp pulsar data). These routines that 
;users should access are:
; wasopen()  - open a file
; wasclose() - close a file
; waslist()  - list a scan summary of file
; washdr()   - return the fits headers (only works on most recent
;              fits header version).
;
;   Some corxxx routines have been rewritten to process the was data. 
;These are documented here at corxxx(). I have tried to make the
;functionality the same. If in doubt, read the documentation here to
;see if there is anything different from the interrim correlator verion.
;
;   This documentation is for the verion that writes all of the 
;wapp data into a single datafile.
;
;Running idl:
;   To process the was datasets:
;
;   idl
;   @phil     (or whatever you need to add your base directory) 
;   @wasinit   ..initialize for was data. This calls @corinit and then 
;               adds the ./was2 directory path in front of the ./Cor2
;               directory path. Any corxxx() files in ./was2 will override
;               the files with the same name in ./Cor2.
;               note: wasinit() is now the same as the old wasinit2().
; -----------------------------------------------------
;NOTE: These routines use the goddard binary fits table routines to
;      access the file. At AO they are in the directory:
;      /pkg/rsi/idl/lib/locallib/astron/pro/fits_bintable. If you download
;      the AO idl routines, you will also need to get a copy of the 
;      goddard routines and add the fits_bintable directory to the path.
; -----------------------------------------------------
; 
;
;
;; open the file
;;
;   file='/share/pserverf.sda3/wappdata/wapp.20040118.a1849.0010.fits'
;   istat=wasopen(file,desc)
;;
;;  list contents of the file
;;
;   waslist,desc
;;
;;  read a recod
;;
;   istat=corget(desc,b)
;;  there is a new corplot keyword: sbc=123 that would plot
;;  sbc 1,2, and 3. This serves the same functionality as the m=
;;  keyword but it is easier to use.
;
;   corplot,b
;
;;
;;  read a scan
;;
;   istat=corinpscan(desc,b,scan=401867463L,maxrec=600)
;
;; position to a scan in the file   
;;
;   istat=posscan(desc,401868066)
;;
;;  process on,off position switched data.
;;
;   istat=corposonoff(desc,b,scan=scan,/han)
;;
;;  read 1 or more raw fits headers into a structure
;;  it reads by rows so you need to ask for numberOfRec*rowsPerRecs
;;  to get all the data in a scan.
;;  eg the the scan has 600 recs but we read 600*2*4  headers
;;  since there are 2 IFs per sbc and 4 sbc per measuremetns
;
;   istat=washdr(desc,h,scan=401864155L,numhdr=600*8)
;
;;
;; close the file when done. After calling this you must reopen
;;       the file with wasopen() to access it.
;;
;   wasclose,desc
;
;  SOME NOTES (20aug04) ;
;
;1. All wapp data is now in a single file
;2. Things that i have used and i thing work:
;    corget,corinpscan,corplot,corgetm, corimgdisp() works
;3. Some things that are not yet ready:
;   The velocities may still need some work
;   cormapping does not yet work. We need to add the mapping parameters
;           to the fits header.
;4. Some header values are not moved from the fits file to the 
;   old interim correlator data structure. If a corxxx routine 
;   fails it may be because the header info is not yet there.
;6. Let me know things that you find that don't work (phil@naic.edu). 
;    You can also look at http://www.naic.edu/~phil
;    --> software documenation
;      --> Using single dish fits header for wapp spectral line data..
;   toward the bottom of this page is a list of the current things
;   we are working on in the header.
;-
