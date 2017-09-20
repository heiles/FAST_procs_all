;+
;NAME:
;acormapexamples - Examples using correlator mapping routines:
;
;   Starting idl.
;   - To use the correlator mapping routines you need to tell idl where to
;     look to get these procedures. You can do it manually each
;     time you run idl, or you can put it in an id startup file.
;     Manually:
;       idl
;       @phil
;       @corinit
;     Using a idl setup file:
;       Suppose your home directory is ~jones.
;       create the file ~jones/.idlstartup
;       add the line        
;          !path = '/home/phil/idl/gen:' + !path
;       to this file.
;       In your .cshrc file (if you run csh) add the line
;           setenv IDL_STARTUP ~/.idlstartup
;       You can then run idl with :
;           idl
;           @corinit 
;       You can also put any other commands in the startup
;       file that you want to be executed each time you 
;       start idl. My startup file contains:
;           !EDIT_INPUT=500
;           @phil!path = '/home/phil/idl/gen:' + !path
;       
;1.Which data can use these routines.
;   You should be able to process data taken with cormap1, cordrift, or 
;  cormapdec with these routines.
;
;2. Cookbook processing of a map: 
;   
;   A. inputing the spectra:
;     - If the entire map is in a single file used:
;     openr,lun,'/share/olcor/corfile.17dec00.a1397.1',/get_lun ; open the file
;     scan=35253227L                ; first scan of the map
;     istat=cormapinp(lun,scan,1,2,m,cals) ; input the map from brds 1,2
;     free_lun,lun
;     - If the map is spread over many files use:
;       stat=cormapinplist( )
;     - You can also input a map using the data archive. see 
;       arch_getmap in the correlator section.
;
;     m[2,nsmp,nstrips].d is in correlator power units
;   B. Scale to Kelvins
;     istat=cormapsclk(m,cals,tsys) ; scale to kelvins using the cals
;     .. m[2,nsmp,nstrips].d is in kelvins
;   C1. baseline the data.
;     mb=cormapbl(m,mask,polyDeg)  ; baseline the map
;   C2. bandpass correct the data:
;     numbpedge=2
;     mb=cormapbc(m,numbpedge)
;     .. This will:
;        1. Create an average bandpass for each strip. It can come from:
;           - bandpasses on the edge of each strip,
;           - averageing the entire strip.
;        2. For each spectra of the strip compute
;            spc[i]=spc[i]/normalized(spcBpc) 
;        3. Remove Tsys from each spectra by:
;           - interpolating by the spectra used for the band pass correction
;           - interpolate using all of the spectra in a strip
;           - remove Tsys from each spectra by computing the mean of each
;             spectra
;   D. gain correct the data
;     cmgaincor(mb,gaincor)        ; gain correct the map
;     .. mb.d is now gain corrected. gaincor[] holds the correction applied. 
;   E. Things to watch out for..
;     - cmgaincor assumes the data is in nongaincorrected Kelvins. Once
;       you've called it it is in true kelvins (or Jy). Don't recall it
;       with the new data..
;
;3. The data structures.
;   .. map data structure input by cormapinp
;   help,m
;   M              STRUCT    = -> <Anonymous> Array[2, 15, 15]
;                                          [npol,nsamplesperstrip,nstrips]
;     help,m,/st
;   H               STRUCT    -> HDR Array[1]. header (see cor documentation)
;   P               FLOAT           1.08431  ..total power
;   AZ              FLOAT           284.581  ..azimuth pos deg at end of sample
;   ZA              FLOAT           18.9583  ..za      pos deg at end of sample
;   AZERRASEC       FLOAT          0.256720  ..az tracking error asecs
;   ZAERRASEC       FLOAT          0.289800  .. za tracking error asecs
;   RAHR            FLOAT           3.26740  ..RA  in hours,middle of sample
;   DECDEG          FLOAT           12.5167  ..DEC in deg  ,middle of sample
;   D               FLOAT     Array[2048]    ..spectral data. correlator units.
;
;   .. cals data structure input by cormapinp:
;  help,cals1,/st
;  H               STRUCT    -> HDR Array[1] .. header for cal on record
;  CALVAL          FLOAT     Array[2]        .. pola,b cal value in Kelvins
;  CALSCL          FLOAT     Array[2]        .. pola,b. scale correlator
;                                               counts to kelvins.
;
;4. Displaying things:
;     .. average the bandpasses for the entire map
;     avgBpPolA=cmavgstrips(mbl,1)     
;     avgBpPolB=cmavgstrips(mbl,2)     
;     plot,avgBpPolA
;     oplot,avgBpPolB
;
;     .. average all spectra strips 3-10  counting from 1.
;     avgBpPolA=cmavgstrips(mbl,1,first=3,last=10)     
;     avgBpPolB=cmavgstrips(mbl,2,first=2,last=10)     
;
;     .. display whole map overplotting all spectra in each strip
;     ver,35,65
;     cmstrips,m,1,0,2             ;offset each strip by 2 kelvin
;     cmstrips,m,1,0,2,/freq       ;plot versus frequency
;     cmstrips,m,1,0,2,/vel        ;plot versus velocity
;   
;     .. plot individual spectra.
;     plot,m[0,1,3].d               ; pola,2nd sample,4th strip
;
;     .. average over a range of frequency channels then display as an
;        image.
;     pol=1                         ; do pol a
;     chn1=500                      ; first channel, count from 1
;     chn2=550                      ; last channel
;     avgchn=cmavgchn(mbl,pol,chn1,chn2); avgchn[nsmp,nstrips] 
;     xloadct                       ; start color widget, clip on grey scale
;     imgdisp,avgchn,zx=10,zy=10,/histeq  ; image display, zoom 10 by 10
;
;     ..Do an animation of the map. 
;       ..assume a 15,15 map with 2048 frequency channels.
;       ..display channels 951 thru 1100 (150) expanding the ra,dec dimensions
;         to also be 150,150
;       d=reform(mbl[0,*,*].d[951:1100],150,15,15); grab the data
;       dh=imghisteq(rebin(d,150,150,150)) ;interpolate,histogram equalize
;       xinteranimate,set=[150,150,150],/showload
;       for i=0,149 do xinteranimate,frame=i,image=reform(dh[i,*,*],150,150)
;       xinteranimate,/keep_pixmaps
;       .. click on the colors button to setup the colormap you want
;       .. click on the active slider to see which frame is displayed.
;       .. change the display rate with the top slider (frames/sec).
;
;5. Notes on scaling the map to kelvins.
;   istat=cormapsclk(m,cals,tsys)
;   .. m[2,n,m].d will now be in kelvins.
;   .. tsys[2,n,m] will be the system temperature measured at each spectra.
;   ..
;   .. You should examine the cals data to make sure that there are not
;   .. any bad cal samples. cals.calscl[0] should be a relatively constant
;   .. value since it is converting from correlator counts to kelvins
;   .. using  (calInKelvins)/(calon-caloff). Variation in these values
;   .. can come from the cal temperature changing with time, the gain
;   .. of the if/lo changing, or rfi in a cal on and not in the off.
;   .. The cals are temperature controlled. This value does change by 
;   .. about 1% per degree F change in the rotary floor room. 
;   .. This is probably some amplifier gains changing.
;   .. look at the values with:
;   plot,cals.calscl[0]  .. polA
;   plot,cals.calscl[1]  .. polB
;   .. If 2 cals/strip were taken then everyother strip has also
;   .. had it's cals flipped (along with the data samples).
;   .. Look at the system temperatures with:
;   plot,tsys[0,*,*] polA all strips
;-
