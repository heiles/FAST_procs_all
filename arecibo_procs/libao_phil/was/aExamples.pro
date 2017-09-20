;+
;NAME:
;Accessing was (wapp) fits files.
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
;already in use for the wapp pulsar data). Another set of corxxx routines
;have been rewritten to process either set of data. The was routines
;are located in ~phil/idl/was instead of ~phil/idl/Cor2 (or wherever you've
;placed this directory structure on your computer). 
;
;Running idl:
;   To process the was datasets:
;
;   idl
;   @phil     (or whatever you need to add your base directory) 
;   @wasinit  ..initialize for was data. This calls @corinit and then 
;               adds the ./was directory path in front of the ./Cor2
;               directory path. Any corxxx() files in ./was will override
;               the files with the same name in ./Cor2.
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
;   file='/share/wapp11/wapp1.20040118.a1849.0010.fits'
;   istat=wasopen(file,desc)
;;
;;  list contents of the file
;;
;   waslist,desc
;;
;;  read a recod
;;
;   istat=corget(desc,b)
;   corplot,b
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
;;  read 1 or more fits headers into a structure
;;  note that the scan has 600 recs but we read 600*2 headers
;        since there are 2 IFs per rec and each IF has its own hdr/row.
;
;   istat=washdr(desc,h,scan=401864155L,numhdr=600*2)
;
;;
;; close the file when done. After calling this you must reopen
;;       the file with wasopen() to access it.
;;
;   wasclose,desc
;
;   The current state of these routines (21jan04) is:
;
;1. there is only one wapp board/file. If you want to look at 
;   different wapps, you need to call wasopen() multiple times.
;2. Things that i have used and i thing work:
;    corget,corinpscan,corplot,corgetm, corimgdisp() works
;3. Some things that are not yet ready:
;   The velocities are not yet correct.
;   cormapping does not yet work. We need to add the mapping parameters
;           to the fits header.
;4. Some header values are not moved from the fits file to the 
;   old interim correlator data structure. If a corxxx routine 
;   fails it may be because the header info is not there.
;5. Remember that if a scan has more that 300 records then you 
;   need to use the maxrec keyword to get the entire scan read at once.
;6. Let me know things that you find that don't work (phil@naic.edu). 
;    You can also look at http://www.naic.edu/~phil
;    --> software documenation
;      --> Using single dish fits header for wapp spectral line data..
;   toward the bottom of this page is a list of the current things
;   we are working on in the header.
;-
