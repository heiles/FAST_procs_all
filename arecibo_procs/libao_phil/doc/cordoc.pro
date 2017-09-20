;+
;NAME:
;cordoc - routine list (single line)
;
;acorexample2     - Looking at calibration data by month.
;arch_getdata     - get cor data using the archive tbl arrays
;arch_getmap      - input a map from the archive
;arch_getmapinfo  - get info on maps from the archive
;arch_getonoff    - get on/off -1 data from archive
;arch_gettbl      - input table of scans from cor archive
;arch_openfile    - open a file using archive arrays
;chkcalonoff      - check that hdrs are a valid cal on,off.
;coraccum         - accumulate a record in a summary rec
;coracf           - compute the acf from the spectra
;corallocstr      - allocate an array of structures.
;coravg           - average correlator data.
;coravgint        - average multiple integrations.
;corbl            - baseline a correlator data set
;corblauto        - automatic baselining of a correlator data set
;corblautoeval    - evaluate corblauto fit
;corcalcmp        - given calon,off buffers, compute scale to kelvins
;corcalib         - intensity calibrate a single spectra
;corcalonoff      - process a cal on/off pair
;corcalonoffm     - process a cal on/off pair with a mask
;corchkstr        - check buffers for same structure
;corcmbsav        - combine save files with multiple sources.
;corcmpdist       - compute distance (ra/dec) for scans
;corcumfilter     - cumfilter a correlator dataset.
;cordfbp          - return the digital filter bandpasses.
;corfindpat       - get the indices for the start of a pattern
;corfrq           - compute the freq/vel array for a spectra
;corget           - input next correlator record from disc
;corgethdr        - return the correlator header for the next group
;corgetm          - input multiple correlator records to array.
;corhan           - hanning smooth correlator data.
;corhflippedh     - check if current data is flipped in freq.
;corhflipped      - Obsolete..check if current data is flipped in freq.
;corhcfrtop       - return the topocentric freq of band center.
;corhcfrrest      - return the rest freq of band center.
;corhcalval       - return the pol A/B  cal values for a sbc.
;corhcalrec       - check if an input rec is a cal rec.
;corhdnyquist     - check if rec taken in double nyquist mode
;corhintrec       - return integration time for a record
;corhgainget      - return the gain given a header
;corhsefdget      - return the sefd given a header
;corhstate        - decode status words for correlator header
;corhstokes       - check if record taken in stokes mode
;corimg           - create an image of freq vs time for 1 sbc.
;corimgdisp       - display a set of correlator records as an image
;corimgonoff      - make image of an on off pair
;corinpscan       - input a scans worth of data
;corinterprfi     - interpolate spectra across rfi.
;corlist          - list contents of correlator data file
;cormask          - interactively create a mask for each correlator board
;cormaskmk        - create the cormask structure from the corget structure
;cormath          - perform math on correlator data
;cormedian        - median filter a set of integrations
;cormon           - monitor data from file.
;cormonall        - monitor correlator data, bandpass,rms,img
;cormovie1d       - make a movie of 1d spectra
;cornext          - input and plot next rec from disc
;coronl           - open the online datafile
;coroutput        - output a cor data structure to disc
;corplot          - plot the correlator data.
;corplotrl        - plot correlator data flagging recomb lines.
;corplttpza       - plot total power vs za for each scan
;corposonoff      - process a position switch scan
;corposonoffm     - process a on/off scan using a mask
;corposonoffrfi   - process a position switch pair with rfi excision.
;corposonoffrfisep - process a position switch pair with rfi excision.
;corpwr           - return power information for a number of recs
;corpwrfile       - input the power information from the entire file.
;corradecj        - get ra,dec J2000 positions
;correcinfo       - print record info
;corrms           - compute rms/Mean  by channel
;corsavbysrc      - create arrays by source.
;corsclcal        - scale spectrum to K using the cals.
;corsmo           - smooth correlator data.
;corstat          - compute mean,rms by sbc
;corstokes        - input and intensity calibrate stokes data.
;corstostr        - move a structure to an array of structs.
;corstripch       - stripchart recording of total power
;corsubset        - make a copy of data keeping only specified boards
;cortblradius     - get indices for all positions within radius.
;cortpcaltog      - compute total power for toggling cals
;corwriteascii    - output an ascii dump of the correlator data
;mm0proc          - do mueller 0 processing of data in a file.
;mm0proclist      - do mueller 0 processing for a set of data files
;mm_chkpattern    - check if a mueller pattern is complete
;mm_mon           - monitor online datataking calibration scans
;mmbeammap        - generate beam map from mm data structure.
;mmcmpmatrix      - compute the mueller matrix from the parameters
;mmcmpsefd        - compute sefd for each entry in mm structure
;mmdoit           - input allcal sav files, convert to struct and sav
;mmfindpattern    - get the indices for the start of the patterns
;mmget            - extract a subset of mueller array by key
;mmgetarchive     - restore all or part of calibration archive
;mmgetparams      - input mueller matrix for rcvr.
;mmplot           - x,y plot using different colors for each receiver
;mmplotazza       - plot az,za coverage of dataset.
;mmplotbydate     - plot calibration observations by receiver and date
;mmplotcsme       - plot coma,SideLobeHght, and beam efficiencies.
;mmplotgtsb       - plot gain, Tsys, sefd, and beamWidth for sources
;mmplotpnterr     - plot pointing error.
;mmplotsrc        - x,y plot using different colors for each source
;mmrestore        - input the muellar structure arrays.
;mmtostr          - move  mueller processed arrays to a structure
;pfcalib          - intensity calibrate an entire file
;pfcalonoff       - extract calon/off scans and compute cal size and tsys.
;pfcorimgonoff    - make images of all on/off pairs in a file.
;pfposonoff       - process all position switch  onoffs in a file
;pfposonoffrfi    - process all position switch  onoffs in a file
;sl_mkarchive     - create scan list for a set of files
;sl_mkarchivecor  - create cor scan list for archive
;wascheck         - check if this call is for was data
;-
