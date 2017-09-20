;+
;NAME:
;gendoc - routine list (single line)
;
;abssq            - compute absolute value then square
;addpath          - add a directory to the start of the path variable
;alfamoninit      - initialize to alfa dewar monitor routines
;alfatsysget      - return alfa Tsys for the requested positions
;alfatsysinpData  - input alfa tsys fits.
;alfawappharm     - compute alfa,wapp harmonics
;aobeampatcmp     - compute ao beam pattern from bessel function
;aocatinp         - input an ao source catalog
;aodefdir         - AO base directory for idl routines.
;arrpltazzaerr    - arrow plot of azerr,zaerr vs az,za
;avgrms           - avgerage then compute rms for data set
;avgrobbychan     - compute the robust average by chan for 2d array.
;basename         - return directory and basename of file
;bdwfinit         - initialize to use the idl bdwf (brown dwarf routines).
;bitreverse       - bit reverse data
;blmask           - interactively create a mask for baseline fit
;bluser           - interactively baseline a function.
;bpcmpbychan      - compute a band pass from set of spectra
;bytesleftfile    - return the unread bytes left in a file
;calget           - return the cal value given hdr,freq.
;calget1          - return the cal value given rcvr,frq,type.
;calget1fit       - return linear fit to cal values
;calInpData       - input cal data for rcvr/calType.
;calmfit          - fit curves to cal on/off data
;calonofffind     - find all of the cal on/offs in  file
;calval           - return the cal value for a given freq.
;calvalfit        - fit calvalues to a freq range
;cataloginp       - input a pointing catalog
;cgeninit         - initialize to use cummings generator routines
;chebeval         - evaluate chebyshev polynomial
;chebfit          - chebyshev polynomial fit to data
;checkkey         - check if any keys have been pressed
;chkswaprec       - check hdrlen to see if the record needs to be swapped
;cmpbflytwiddle   - compute butterfly twiddle factors
;colorinfo        - return info on current color setup.
;condblevels      - compute db contouring levels for a map
;contourph        - phil's interface to idl contour routine.
;cor3lvlstokes    - to 3 level correction for stokes data
;corbychan        - auto/xcorrelate dynamic spc by chan.
;corinit          - initialize to use the idl correlator routines.
;corinit1         - initialize to use the idl correlator routines (no lut load).
;covarnorm        - normalize the covariance matrix
;cp               - read cursor position after button press.
;cumfilter        - cumfilter routine from carl heiles.
;daynotodm        - convert daynumber to day,month
;daynotojul       - convert daynumber,year to julday
;daysinmon        - return number of days in this month
;dbit             - convert to db's
;delpath          - remove pathname from the path variable.
;digmixtmd        - digitally mix a complex timedomain waveform
;digmixtmdinit    - initialize structure for digital mixing
;dms1_deg         - convert ddmmss.sss as a double to degrees.
;dms1_dms3        - convert deg,min,secs 1 word to deg,min,sec separate words
;dms1_rad         - convert ddmmss.sss as a double to radians.
;dmtodayno        - convert day,mon,year to daynumber
;dmytoyymmdd      - convert ddMonyy to yymmdd
;dopcorbuf        - offline doppler correct voltage data
;dopcorbuf        - init for dopcorbuf()
;dotprod          - compute the dot product of two vectors
;drawcircle       - draw a circle
;ephmaord         - read in an ao ephmeris file.
;explain          - list documentation
;fftint           - integer based fft routine
;fftinterp        - fft interpolation of real data
;fignum           - put figure number on the page
;file_exists      - check if a file name exists
;fisecmidhms3     - secs from midnite to hh:mm:ss
;fitazza          - fit function to azimuth and zenith angle
;fitazzaeval      - evaluate the fitazza fit at az,za positions.
;fitazzalog       - write fitazza info in tabular form to a file
;fitazzaplres     - plot residuals from az,za fit
;fitazzapr        - print/plot info on the az,za fit
;fitazzaprcov     - print out the covariance matrix
;fitazzarob       - robust fit of function to azimuth and zenith angle
;fitngauss        - fit n gaussians
;fitngaussfunc    - function for fitting n gaussians
;fitngaussnc      - fit n gaussians (no coma)
;fitngaussncfunc  - function for fitting n gaussians
;fitsin           - fit to Asin(Nx-phi) where N=1 to 6. or 123
;fitsineval       - evaluate the fitsin() fit
;fitsinn          - fit to terms of  Asin(nx-phi)
;fitsinneval      - evaluate the fitsinn fit
;fitsinnl         - nonlinear least squares fit to a sin
;flag             - flag a set of vertical lines
;fluxfitvla       - return source flux using vla formula
;fluxkuehr        - compute flux given kuehr et al. coefficients
;fluxsrc          - return source flux
;fluxsrclist      - return list of source names in flux file
;fluxsrcload      - load source flux into common block
;foldtmseries     - fold a time series
;fromsecs1970     - convert from  unixsecs 1970, to ymd,hms
;fwhm2tosig2f     - FWHM^2 to sigma^2 factor.
;fwhmtosigf       - convert factor fwhm to sigma
;gainget          - return telescope gain(az,za,freq) for rcvr.
;gainInpData      - input gain data for rcvr.
;getscanind       - get indices for start of each scan
;getscanindx      - extract scan from array.
;getsl            - scan a corfile and return the scan list.
;pncodeinfo       - initialize the code info for the gpsl2c med,long codes
;gs               - generate a gaussian
;gs2d             - generate a 2d gaussian
;gseval           - evaluate a gausian at the requested positions.
;gsfit2d          - cross pattern 2d fit to total power az,za stripsI
;gsfit2dc         - cross pattern 2d fit to az,za stripsI with coma
;gsfit2deval      - evaluate coef returned from gsfit2d
;hansmo           - hanning smooth a dataset
;hardcopy         - flush the postscript data to disc.
;hdrget           - input headers
;hexpr            - hex printout
;hms1_hms3        - convert hour,min,secs 1 word to hour,min,sec separate words
;hms1_hr          - convert hhmmss.sss as a double to hours.
;hms1_rad         - convert hhmmss.sss as a double to radians.
;hor              - set horizontal scale for plotting.
;iflohrfnum       - return the receiver # for this record
;ifloh10gchybrid  - return true if 10 ghz hybrid in use
;iflohcaltype     - return the type of cal used.
;iflohlbwpol      - check if hybrid used on lband wide.
;iflohstat        - decode status words for iflo
;imgdisp          - display a 2-d array as an image.
;imgflat          - flatten an image.
;imgflaty         - flatten an image in the y direction
;imghisteq        - histogram equalize an image. return byte array
;imghline         - draw horizontal line on an image
;intermods        - compute intermods between 2 freq.
;intm_pdevalfa    - compute alfa/pdev mixer intermods
;intm_pdevalfa_pr - print out intm_pdevalfa intermod info
;inverf           - compute inverse error function
;isleapyear       - check if year is a leap year.
;lbgain           - compute lband gain as a function of az,za
;ldcolph          - load phil's colors into the lookup table
;lutcycle         - cycle through all the idl luts..
;masinit          - initialize to use the mock spectrometer fits routines
;maskbyrms        - create mask using rms of fit residuals.
;matrot           - generate 1 or more rotation matrices
;mav              - multiply an array by a vector
;mcalinp          - input data for meascal routine.
;meanrob          - robust mean for 1d array
;meanrun          - compute the running mean of a 1 or 2d array
;medianbychan     - median 2d array by chan.
;mkallidldoc      - create all html documentation.
;mkazzagrid       - make a grid of az,za values.
;mksin            - make a sine wave
;mm0ninit         - initialize for the new mueller 0 processing
;mm0ninitwas      - initialize for the new mueller 0 processing
;monname          - return month name given month number
;montonum         - convert ascii month to number 1-12
;note             - write a string at the requested line on the plot.
;p8               - set frame buffer to pseudo color.
;pagesize         - set the postscript page size.
;pdevinit         - initialize to use the pdev spectrometer
;pltazzausage     - plot the 2D az,za coverage.
;pltbits          - plot a timing diagram of the input data
;pltbycol         - plot values by color
;pncodeinfo       - initialize the code info for the pncodes
;pnthgrmaster     - return 1 if greg is master, 0 if ch master
;pnthcoordsys     - return coordinate system code
;polyffteval      - evaluate the fit from robfit_polyfft
;posscan          - position to a scan/record on disc
;prfgainall       - compute fractional gain do to pitch,roll,focus
;printpath        - print out the path variable
;ps               - send plot output to postscipt file.
;pscol            - send plot output to color postscipt file.
;psimage          - prepare to send image output to a postscript file.
;psrfinit         - initialize to use the psrfits  mock spectrometer routines
;pupfinit         - initialize to use the pupfits  mock spectrometer routines
;pupiinit         - initialize to use the pupi  routines
;puprinit         - initialize to use the puppi raw file routines
;pwrlawdist       - generate a power law distribution.
;prwspc           - compute the power spectrum of the input signal..
;rcvnumtonam      - convert receiver number to receiver name.
;rdcur            - read cursor position multiple times
;rdcurdif         - read cursor position difference multiple times
;rdevinit         - initialize to use the pdev radar processor
;readasciifile    - read an ascii file into strarr
;recombfreq       - compute recombination line freq for atoms
;recombsearch     - search  for recombination lines within a freq range.
;rfname           - given the rfnumber, return the standard receiver name
;rms              - compute the mean and standard deviation
;rmsbychan        - compute the rms/mean  by chan for 2d array.
;robfit_poly      - robust polyfit for 1d array
;robfit_polyfft   - automatic baselining of a function
;rotvec           - rotate a vector through an angle (in deg)
;rsspecanainp     - input R&S spectrum from save file
;ruze             - evaluate the ruze formula for losses from surface errors.
;satinit          - initialize to use the satellite prediction routines.
;sbinit           - initialize to use the sband tx idl routines
;scanlist         - list contents of  data file
;scantype         - return the type of scan
;searchhdr        - position to the next available hdr in the file.
;secs1970tojd     - convert  unixsecs(1970,mjd=mjd) to jd
;sefdget          - return telescope sefd(az,za,freq) for rcvr.
;sefdInpData      - input sefd data for rcvr.
;select           - select elements from an array
;shcolsym         - show the default colors and symbols
;shiftregcmp      - compute a shift register code
;sixtyunp         - unpack hhmmss.s or ddmmss.s to hh mm ss.s or dd mm ss.s
;smofrqdm_1d      - freq domain smoothing (1d)
;spcanainit       - initialize to use the spectrum analyzer routines
;spwrinit         - initialize to use the site power idl  routines.
;stripmask        - interactively make masks for strips in a map.
;strips           - plot strips with offset and increment versus sample.
;stripsxy         - plot strips with offset and increment verus x.
;strtovarnam      - modify a string to be a valid variable name
;SVDFITpp         - Perform a general least squares fit. patched version
;symcircle        - create a circle symbol for plots
;tempplot         - plot temperature in turret room for a range of days.
;tempread         - read receiver room temperature data
;tosecs1970       - convert to unixsecs(from 1970)
;tsysinit         - initialize idl to process system temperature monitoring data.
;tvfreq           - return tv channels and frequencies
;usrprojinit      - addpath holding routines to user projects
;ver              - set vertical scale for plotting.
;waitnxtgrp       - wait for next group from the file to become available
;wappinit         - initialize to use the idl wapp pulsar routines.
;wggrpvel         - compute waveguide group velocity vs freq
;wincos4          - generate a cos^4 window
;windinit         - initialize idl to process wind monitoring data.
;windowfunc       - make a window function
;wst              - initialize to use idl weather station routines
;wuse             - set window for plotting
;x                - set output to xwindows device
;x102combineps    - combine x102 ps files into 1 file.
;x111init         - initialize idl to process x111 data.
;xvisualquery     - query x visual information
;ybt250inp        - input ybt250 spectrum from save file
;yymmddtodmy      - convert yymmdd to ddMonyy
;yymmddtojulday   - convert yymmdd to julian day
;-
