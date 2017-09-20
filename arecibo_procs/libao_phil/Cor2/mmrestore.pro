;+
;NAME:
;mmrestore - input the muellar structure arrays. 
;SYNTAX: @mmrestore
;ARGS:   none 
;RETURNS:
;   mm[] : {mueller} all the data in a single array. sorted by receiver and
;                    then source
;   mm1[] : {mueller} the 327 data
;   mm2[] : {mueller} the 430 data
;   mm3[] : {mueller} the 610 data
;   mm5[] : {mueller} the lbw data
;   mm6[] : {mueller} the lbn data
;   mm7[] : {mueller} the sbw data
;   mm9[] : {mueller} the cband data
;  mm12[] : {mueller} the sbn data
; mm100[] : {mueller} the 430ch data
;
;DESCRIPTION:
;   mmrestore will input the mueller structure arrays for all of the
;receivers that have been reduced in the sep00 calibration run. All it 
;does is :
;restore,'/proj/x102/cal/mmdata.sav',/verbose
;
;   If you have run mmdoit() and created a save file of a different
;set of data, you can input that data with:
;   restore,'filename',/verbose
;(you do not need to use this routine).
;
;The structure format returned is described below. Those variables with
;(I) in the comments fiels refer to total power I and not a single
;polarization (eg Tsys ...... (I)).
;
;
;IDL> help,mm,/st
;** Structure MUELLER, 20 tags, length=372:
;   SRCNAME         STRING      'B0300+162'
;   SRCFLUX         FLOAT          -1.00000 Jy (1 pol)
;   SCAN            LONG           26500134   
;   RA1950          FLOAT           3.00748 hours
;   DEC1950         FLOAT           16.2511 degrees
;   RCVNUM          LONG                  3
;   RCVNAM          STRING            '610' .. receiver name. valid names are:
;                                           327,430,610,lbw,lbn,sbn,sbw,cband,
;                                           430ch
;   UTSEC           LONG                  6 ut second from midnight
;   JULDAY          FLOAT           51808.8 (MJD + .5) or (JD-2400000)
;   BANDWD          FLOAT           1.56250 Mhz
;   CFR             FLOAT           612.000 Mhz
;   BRD             INT                0    corr brd #. 0-3
;   CALTEMP         FLOAT          Array[2] deg K
;   LST             FLOAT           1.88105 hours
;   AZ              FLOAT          -86.4037 degrees
;   ZA              FLOAT           16.8460 degrees
;   PARANGLE        FLOAT          -56.4730 degrees (paralactic angle)
;   ASTRONANGLE     FLOAT            0.0000 degrees feed to astromical system
;   PASRC           FLOAT           74.1880 deg position angle source on sky
;   PASRC_ERR       FLOAT             .2780 deg ..error
;   POLSRC          FLOAT             .0391 source fractional linear pol
;   POLSRC_ERR      FLOAT             .0004 err
;   BMWIDSCAN       FLOAT           8.00000 Amin
;   MMCOR           INT              2      muelcorrection.0=no,1-toaz/za,2=sky
;   FIT             STRUCT    -> MUELLERFITI 
;   FITQ            STRUCT    -> MUELLERFITPOL
;   FITU            STRUCT    -> MUELLERFITPOL
;   FITV            STRUCT    -> MUELLERFITPOL
;   MMPARM          STRUCT    -> MUELLERPARAMS params used for mueller matrix
;
;the total power fit info is:
;
;IDL> help,mm.fit,/st
;** Structure MUELLERFITI, 29 tags, length=132:
;   TSYS            FLOAT           268.714 degK (I)
;   TSYS_ERR        FLOAT          0.121488 degK (I)
;   GAIN            FLOAT          -41.4766 K/Jy (1 pol)
;   DTSYSDZA        FLOAT          0.673788 K/Degza
;   DTSYSDZA_ERR    FLOAT          0.248539 K/Degza
;   TSRC            FLOAT           82.9533 K (I)
;   TSRC_ERR        FLOAT          0.358256 K (I)
;   SIGMAPNTS       FLOAT           1.47459 K
;   AZERR           FLOAT         -0.507198 Amin
;   AZERR_ERR       FLOAT         0.0310421 Amin
;   ZAERR           FLOAT         0.0396541 Amin
;   ZAERR_ERR       FLOAT         0.0375799 Amin
;   BMWIDAVG        FLOAT           7.65640 Amin (max+min)/2
;   BMWIDAVG_ERR    FLOAT         0.0395753 Amin
;   BMWIDDELTA      FLOAT          0.556200 Amin (max-min)/2
;   BMWIDDELTA_ERR  FLOAT         0.0418182 Amin
;   BMPHI           FLOAT           92.4938 deg
;   BMPHI_ERR       FLOAT           2.17635 deg
;   COMA            FLOAT        0.00683132 hpbw
;   COMA_ERR        FLOAT         0.0153134 hpbw
;   COMAPHI         FLOAT          -44.1549 deg
;   COMAPHI_ERR     FLOAT           129.217 deg
;   SLHGT           FLOAT            .02    fraction of MainBeam 
;   SLCOEF          COMPLEX   Array[8]      coef from fft of sdlbHgt/mainBeam
;   ETAMB           FLOAT          -2.69011 main beam efficiency
;   ETASL           FLOAT         -0.243481 sidelobe efficiency
;   CALPHASE        FLOAT     Array[2]      a+b*(freq-cfr) Rd/Mhz
;   CALPHASE_ERR    FLOAT     Array[2]
;   SRCPHASE        FLOAT     Array[2]      a+b*(freq-cfr) Rd/Mhz
;   SRCPHASE_ERR    FLOAT     Array[2]
;
; The polarized fit info is:
;
;IDL> help,mm.fitq,/st
;** Structure MUELLERFITPOL, 14 tags, length=56:
;   OFFSET          FLOAT         0.0201661 zero offset degK
;   OFFSET_ERR      FLOAT         0.0593501 
;   DOFFDZA         FLOAT          0.623669 degK/degza
;   DOFFDZA_ERR     FLOAT          0.134090
;   SRC             FLOAT           5.66668 src deflection. fraction of I
;   SRC_ERR         FLOAT          0.179385     fraction of I
;   SQUINTAMP       FLOAT         0.0571257 Amin
;   SQUINTAMP_ERR   FLOAT         0.0115344
;   SQUINTPA        FLOAT           25.4974 position angle deg
;   SQUINTPA_ERR    FLOAT           11.8336 
;   SQUASHAMP       FLOAT          0.169447 arcmin hpbw
;   SQUASHAMP_ERR   FLOAT         0.0293442
;   SQUASHPA        FLOAT          -82.4178 position angle deg
;   SQUASHPA_ERR    FLOAT           4.51572
; 
; there are 3 arrays of polarized data:
;
; mm.fitq
; mm.fitu
; mm.fitv
;
; mm.parameters used for mueller matrix correction
;help,mm.mmparm,/st
;** Structure MUELLERPARAMS, 6 tags, length=24:
;   DELTAG          FLOAT        -0.0230000
;   EPSILON         FLOAT        0.00600000
;   ALPHA           FLOAT        0.00872665
;   PHI             FLOAT           1.37183
;   CHI             FLOAT           1.57080
;   PSI             FLOAT           2.61799
;
;SEE ALSO
;   mmget
;-
restore,'/proj/x102/cal/mmdata.sav',/verbose
