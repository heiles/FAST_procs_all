;+
;NAME:
;apsrfexample - Using ao psrfit idl routines.
;   
;   The pdev/mock spectrometers can generate psrfits fits files. The
;psrfxxxx idl routines let you input and look at the data in idl.
;
;USING the routines.
;   0. If not at AO, install phil's idl routines at your site
;       http://www.naic.edu/~phil/download/download.html
;       --> idlroutines to analyz ao data.
;   1. start idl
;      - at ao  idl or idl70
;      @phil    .. to include path to phil's routine in the search path
;      @psrfinit .. include the psrf and mas routines.
;
;   2. Open a single file and look at it:
;      filename='dir/x107.20090607.b0531+21.b0s1g0.03500.fits'
;      istat=psrfopen(filename,desc,fnmI=fnmi)
;;     look at contents of descriptor structure:
;      help, desc,/st
;** Structure <a8d5398>, 14 tags, length=3129776, data length=3129721, refs=1:
;   LUN             LONG               101
;   FILENAME        STRING    '/share/pdata1/pdev/x107.20090607.b0531+21.b0s'...
;   NEEDSWAP        BYTE         1
;   BYTESROW        LONG           1052268
;   TOTROWS         LONG                60
;   CURROW          LONG                32
;   BYTEOFFREC1     LONG             28800
;   BYTEOFFNAXIS2   LONG             20400
;   HPRI            STRUCT    -> <Anonymous> Array[1] .. primary fits header
;   HAOGEN          STRUCT    -> <Anonymous> Array[1] .. ao generic header
;   HPDEV           STRUCT    -> <Anonymous> Array[1] .. pdev header
;   HSUBINT         STRUCT    -> <Anonymous> Array[1] .. subint header
;   ROWSTR          STRUCT    -> <Anonymous> Array[1]
;   ROWSTRF         STRUCT    -> <Anonymous> Array[1]
;
;   3. input 1 row of file:
;       istat=psrfget(desc,b)
;;          look at contents of b
;      help,b,/st
;  IDL> help,b,/st
;   TSUBINT         DOUBLE           1.0000000
;   OFFS_SUB        DOUBLE          0.50000000
;   LST_SUB         DOUBLE           18175.386
;   RA_SUB          DOUBLE           83.632679
;   DEC_SUB         DOUBLE           22.014512
;   GLON_SUB        DOUBLE           184.55724
;   GLAT_SUB        DOUBLE          -5.7846698
;   FD_ANG          FLOAT           0.00000
;   POS_ANG         FLOAT           0.00000
;   PAR_ANG         FLOAT          -65.5061
;   TEL_AZ          FLOAT           242.726
;   TEL_ZEN         FLOAT           8.38640
;   DAT_FREQ        FLOAT     Array[512]
;   DAT_WTS         FLOAT     Array[512]
;   DAT_OFFS        FLOAT     Array[512]
;   DAT_SCL         FLOAT     Array[512]
;   DATA            INT       Array[512, 1000]
;   STAT            STRUCT    -> PDEV_HDRDUMP Array[1000]
;
;; Notes:
;;   - each row has multiple spectra (in this case 1000).
;;   - the freq is stored in data_freq (these are the centers of each bin)
;;   - stat structure has info on each spectra. In particular the number of 
;;     integrations that went into the accummulated spectra (stat.fftaccum)
;
;; 
;;  4. plot 1 spectra
;  plot,b.dat_freq,b.data[*,0]   
; 
;   5.  monitor set of files with dynamic spectra
;      - Use psrfmonimg()
;        .. the routine can automatically cycle through a set of files for one project
;           in 1 day..
;      - specifying where the files are at..
;       .. At AO the data files are stored by default in 
;          /share/pdataN/pdev   where N is 1..7 for beams 0..6
;          The routine can find these files by default, all you specify is the
;          date and projid.
;       .. If files are somewhere else (or another institution) then:
;          - files for different beams need the following directory structure:
;             /xx/yyyN/  where N is beamnumber +1
;          - then use the dirI[2] keyword
;              dirI[0] is the prefix, dirI[1] is the suffix of the directory
;              path with N 1..7 stuck in between:
;             suppose data in /data/ao/psrf/beam[1..7]
;             dirI[0]='/data/ao/psrf/beam'
;             dirI[1]='/'
;             This will generate searches in /data/ao/psrf/beam[1-7]/ for the datafiles
;
;       - calling the routine:
;         date=20090607
;         projid='x107'
;;        If at ao
;         psrfmonimg,projid=projid,date=date
;;        If not at ao..
;            dirI[0]='/data/ao/psrf/beam'
;            dirI[1]='/'
;         psrfmonimg,projid=projid,date=date,dirI=dirI
;
;       - In the routine.
;         - hitting a key  brings up a menu to choose from
;         - It starts with the last file of a day. 
;           Using the l keyword in the menu list the files for this beam
;           Using the fnum keyword moves to another file for the day
;           Using the date keyword changes date
;           Using the band keyword switches between the 2 bands
;           Using the beam keword swithces between the 2 beams.
;
;       - Misc notes.
;         - by default the routine maps the number of spectra in a row to the image using
;           congrid which resamples the data set (interpolation, not averaging).
;         - You can stretch the image (by grabbing an edge) to get more pixels in the image
;         - Using the zx=-n,zy=-m keyword on the call ti psrfmonimg() will shrink the image by
;           factors m,n using averaging so you get an increased signal to noise. 
;         - check out some of the other keyword calls and menu items in psrfmonimg()
;
;  6. Closing a file
;     psrfclose,desc,/all  
;         .. using the /all keyword closes all open files
;-
