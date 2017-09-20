;+
;NAME:
;psrfopen - open psrfits file for reading
;SYNTAX: istat=psrfopen(filename,desc,fnmI=fnmI)
;ARGS:
;   filename: string    filename to open (unless fnmI is specified)
;KEYWORDS:
;   fnmI    : {]        returned from psrffilelist. if provided,
;                       then ignore filename and use this as the
;                       file to open.
;RETURNS:
;   istat: 0 ok
;          -1 could not open file.
;   desc : {}  file descriptor to pass to the i/o routines.
;DESCRIPTION:
; 	open  an ao psrfits file.
;-
function psrfopen,filename,desc,fnmI=fnmI
;
; names
; hdrPr_S     - string version of primary header
; hdrPr       - binary structre : primary header
;
; hdrExAG_S   - string version  aogen extension header
; hdrExAG     - binary structure aogen extension header
;
; hdrExPD_S   - string version  pdev extension header
; hdrExPD     - binary structure pdev extension header
;
; hdrExSI_S   - string version of subint header
; hdrExSI     - binary structure: subint header
;
;
   common psrfcom,psrfnluns,psrflunar

   exNmSI='SUBINT'
   exNmPD='PDEV'
   exNmAG='AOGEN'

    errmsg=''
    lun=-1
    fileLoc=(n_elements(fnmI) gt 0)?fnmI[0].dir+fnmI[0].fname:filename

;;  open file. we load the subint extension in the common block.

    fxbopen,lun,fileLoc,exNmSI,hdrExSI_S,errmsg=errmsg
    if errmsg ne '' then begin
        print,errmsg
        goto,errout
    endif
;   ---------------------------------------------------------------------------------------------
; 	now go back and read the primary hdu and any other extensions we've included
;   then move it to their structure
;
;   ---------------------------------------------------------------------------------------------
;   primary hdu
	 rew,lun
     fxhread,lun,hdrPr_S,status

; 	 need same letters as fits file to match keywords in fits header struct
;    except for OBS-DATE since - is an illegal structure name.
; ; fxpar(hdrPr_S,"",start=st)
; g/^\([^ ]*\)[ ]*=.*\/\(.*\)/s//\1 :fxpar(hdrExPD_S,"\1",start=st),$;\2/
;  
	st=0L
;  
; fxpar note: it returns float or double depending on how many ascii chars if finds.
; need to force doubles so  struct def doesn't change setup to setup.
;

	 hdrPr={$
        OBSERVER :fxpar(hdrPr_S,"OBSERVER",start=st),$
        PROJID   :fxpar(hdrPr_S,"PROJID",start=st),$
        TELESCOP :fxpar(hdrPr_S,"TELESCOP",start=st),$
        ANT_X    :double(fxpar(hdrPr_S,"ANT_X",start=st)),$
        ANT_Y    :double(fxpar(hdrPr_S,"ANT_Y",start=st)),$
        ANT_Z    :double(fxpar(hdrPr_S,"ANT_Z",start=st)),$
        NRCVR    :fxpar(hdrPr_S,"NRCVR",start=st),$; number of receiver pol channels
        FD_POLN  :fxpar(hdrPr_S,"FD_POLN",start=st),$;
        FD_HAND  :fxpar(hdrPr_S,"FD_HAND",start=st),$;
        FD_SANG  :double(fxpar(hdrPr_S,"FD_SANG",start=st)),$;
        FD_XYPH  :double(fxpar(hdrPr_S,"FD_XYPH",start=st)),$;
        FRONTEND :fxpar(hdrPr_S,"FRONTEND",start=st),$;
        BACKEND  :fxpar(hdrPr_S,"BACKEND",start=st),$;
        BECONFIG :fxpar(hdrPr_S,"BECONFIG",start=st),$;
        BE_PHASE :fxpar(hdrPr_S,"BE_PHASE",start=st),$;    0 / 0/+1/-1 BE cross-phase:0 unknown,+/-1 std/rev
        BE_DCC   :fxpar(hdrPr_S,"BE_DCC",start=st),$;    0 / 0/1 BE downconversion conjugation corrected
        BE_DELAY :double(fxpar(hdrPr_S,"BE_DELAY",start=st)),$; [s] Backend propn delay from digitiser input
        TCYCLE   :double(fxpar(hdrPr_S,"TCYCLE",start=st)),$; [s] On-line cycle time (D)
        OBS_MODE :fxpar(hdrPr_S,"OBS_MODE",start=st),$; (PSR, CAL, SEARCH)
        DATE_OBS :fxpar(hdrPr_S,"DATE-OBS",start=st),$; Date of observation (YYYY-MM-DDThh:mm:ss UTC)
        OBSFREQ  :double(fxpar(hdrPr_S,"OBSFREQ",start=st)),$; [MHz] Centre frequency for observation
        OBSBW    :double(fxpar(hdrPr_S,"OBSBW",start=st)),$; [MHz] Bandwidth for observation
        OBSNCHAN :fxpar(hdrPr_S,"OBSNCHAN",start=st),$; Number of frequency channels (original)
        SRC_NAME :fxpar(hdrPr_S,"SRC_NAME",start=st),$; Source or scan ID
        COORD_MD :fxpar(hdrPr_S,"COORD_MD",start=st),$; Coordinate mode (J2000, GAL, ECLIP, etc.)
        EQUINOX  :double(fxpar(hdrPr_S,"EQUINOX",start=st)),$; Equinox of coords (e.g. 2000.0)
        RA       :fxpar(hdrPr_S,"RA",start=st),$; Right ascension (hh:mm:ss.ssss)
        DEC      :fxpar(hdrPr_S,"DEC",start=st),$; Declination (-dd:mm:ss.sss)
        BMAJ     :double(fxpar(hdrPr_S,"BMAJ",start=st)),$; [deg] Beam major axis length
        BMIN     :double(fxpar(hdrPr_S,"BMIN",start=st)),$; [deg] Beam minor axis length
        BPA      :double(fxpar(hdrPr_S,"BPA",start=st)),$; [deg] Beam position angle
        TRK_MODE :fxpar(hdrPr_S,"TRK_MODE",start=st),$; Track mode (TRACK, SCANGC, SCANLAT)
        STT_CRD1 :fxpar(hdrPr_S,"STT_CRD1",start=st),$; Start coord 1 (hh:mm:ss.sss or ddd.ddd)
        STT_CRD2 :fxpar(hdrPr_S,"STT_CRD2",start=st),$; Start coord 2 (-dd:mm:ss.sss or -dd.ddd)
        STP_CRD1 :fxpar(hdrPr_S,"STP_CRD1",start=st),$; Stop coord 1 (hh:mm:ss.sss or ddd.ddd)
        STP_CRD2 :fxpar(hdrPr_S,"STP_CRD2",start=st),$; Stop coord 2 (-dd:mm:ss.sss or -dd.ddd)
        SCANLEN  :double(fxpar(hdrPr_S,"SCANLEN",start=st)),$; [s] Requested scan length (E)
        FD_MODE  :fxpar(hdrPr_S,"FD_MODE",start=st),$; Feed track mode - FA, CPA, SPA, TPA
        FA_REQ   :double(fxpar(hdrPr_S,"FA_REQ",start=st)),$; [deg] Feed/Posn angle requested (E)
        CAL_MODE :fxpar(hdrPr_S,"CAL_MODE",start=st),$; Cal mode (OFF, SYNC, EXT1, EXT2)
        CAL_FREQ :double(fxpar(hdrPr_S,"CAL_FREQ",start=st)),$; [Hz] Cal modulation frequency (E)
        CAL_DCYC :double(fxpar(hdrPr_S,"CAL_DCYC",start=st)),$; Cal duty cycle (E)
        CAL_PHS  :double(fxpar(hdrPr_S,"CAL_PHS",start=st)),$; Cal phase (wrt start time) (E)
        STT_IMJD :fxpar(hdrPr_S,"STT_IMJD",start=st),$; Start MJD (UTC days) (J - long integer)
        STT_SMJD :fxpar(hdrPr_S,"STT_SMJD",start=st),$; [s] Start time (sec past UTC 00h) (J)
        STT_OFFS :double(fxpar(hdrPr_S,"STT_OFFS",start=st)),$; [s] Start time offset (D)
        STT_LST  :double(fxpar(hdrPr_S,"STT_OFFS",start=st)) }; [s] Start LST (D)
;      
; 	strip off trailing blanks from string variables
	for i=0,n_tags(hdrPr)-1 do begin 
		if (size(hdrPr.(i),/type) eq 7) then hdrPr.(i)=strtrim(hdrPr.(i)) 
	endfor
;   ---------------------------------------------------------------------------------------------
;   aogen  hdu
; g/^\([^ ]*\)[ ]*=.*\/\(.*\)/s//\1 :fxpar(hdrExAG_S,"\1",start=st),$;\2/
     fxhread,lun,hdrExAG_S,status
     st=0L
	 hdrExAG={$
        FRONTEND :fxpar(hdrExAG_S,"FRONTEND",start=st),$; Receiver name 
        BACKEND  :fxpar(hdrExAG_S,"BACKEND" ,start=st),$; Backend name 
        BACKENDM :fxpar(hdrExAG_S,"BACKENDM",start=st),$; Backend mode description
        CALTYPE  :fxpar(hdrExAG_S,"CALTYPE" ,start=st),$; diode calibration mode hcorcal,hca
        OBSMODE  :fxpar(hdrExAG_S,"OBSMODE" ,start=st),$; Name of observation pattern (e.g. ONOFF) 
        SCANTYPE :fxpar(hdrExAG_S,"SCANTYPE",start=st),$; Type of scan (as part of pattern - e.g. ON OFF)
        PAT_ID   :fxpar(hdrExAG_S,"PAT_ID"  ,start=st),$; Unique number for obs pattern YDDDnnnnn 
        SCAN_ID  :fxpar(hdrExAG_S,"SCAN_ID" ,start=st),$; Unique number for scan YDDDnnnnn 
        PLTPWRA  :fxpar(hdrExAG_S,"PLTPWRA" ,start=st),$; platform power meter reading polA dbm
        PLTPWRB  :fxpar(hdrExAG_S,"PLTPWRB" ,start=st),$; platform power meter reading polB dbm
        CNTLPWRA :fxpar(hdrExAG_S,"CNTLPWRA",start=st),$; control room power meter polA dbm
        CNTLPWRB :fxpar(hdrExAG_S,"CNTLPWRB",start=st),$; control room power meter polB dbm
        SYN1     :fxpar(hdrExAG_S,"SYN1"    ,start=st),$; Platform synthesizer 1st lo (hz)
        SYN2     :fxpar(hdrExAG_S,"SYN2"    ,start=st),$; ctrlRoom 2nd lo synth value this band (hz)
        TCALNCF  :fxpar(hdrExAG_S,"TCALNCF" ,start=st),$; Number of coef. in polyFit for tcal 
        TCALACF0 :fxpar(hdrExAG_S,"TCALACF0",start=st),$; polyfit tcl polA constant (Ghz)
        TCALACF1 :fxpar(hdrExAG_S,"TCALACF1",start=st),$; polyfit tcl polA fr(Ghz)
        TCALACF2 :fxpar(hdrExAG_S,"TCALACF2",start=st),$; polyfit tcl polA f (Ghz)
        TCALACF3 :fxpar(hdrExAG_S,"TCALACF3",start=st),$; polyfit tcl polA f (Ghz)
        TCALBCF0 :fxpar(hdrExAG_S,"TCALBCF0",start=st),$; polyfit tcl polB constant (Ghz)
        TCALBCF1 :fxpar(hdrExAG_S,"TCALBCF1",start=st),$; polyfit tcl polB fr(Ghz)
        TCALBCF2 :fxpar(hdrExAG_S,"TCALBCF2",start=st),$; polyfit tcl polB f (Ghz)
        TCALBCF3 :fxpar(hdrExAG_S,"TCALBCF3",start=st),$; polyfit tcl polB f (Ghz)
        NUMBEAMS :fxpar(hdrExAG_S,"NUMBEAMS",start=st),$; Num beams in this observation (1,7,or 8)
        NUMIFS   :fxpar(hdrExAG_S,"NUMIFS"  ,start=st),$; Num subbands for this beam (1-8 or 1-2) 
        NUMPOLS  :fxpar(hdrExAG_S,"NUMPOLS" ,start=st),$; Num pols for this IF and this beam (1,2,or 4)
        BEAM     :fxpar(hdrExAG_S,"BEAM"    ,start=st),$; Num this beam (1, 0 - 6 or 0 - 7)
        PRFEED   :fxpar(hdrExAG_S,"PRFEED"  ,start=st),$; ALFA beam used as pointing center
        INPUT_ID :fxpar(hdrExAG_S,"INPUT_ID",start=st),$; 0..6 alfa, mixer num 0..6 for single pix
        MASTER   :fxpar(hdrExAG_S,"MASTER"  ,start=st),$; 0=Gregorian dome 1=Carriage house
        LBWHYB   :fxpar(hdrExAG_S,"LBWHYB"  ,start=st),$; 1=LBandWide Hybrid is in (for circular pol)
        SHCL     :fxpar(hdrExAG_S,"SHCL"    ,start=st),$; 1 if receiver shutter closed 
        SBSHCL   :fxpar(hdrExAG_S,"SBSHCL"  ,start=st),$; 1 if S-band receiver shutter closed 
        RFNUM    :fxpar(hdrExAG_S,"RFNUM"   ,start=st),$; Platform position of the receiver selector
        CALRCVMX :fxpar(hdrExAG_S,"CALRCVMX",start=st),$;
        ZMNORMAL :fxpar(hdrExAG_S,"ZMNORMAL",start=st),$; 1 straight thru, 0 flipped pols upstairs
        RFATTNA  :fxpar(hdrExAG_S,"RFATTNA" ,start=st),$; rf attenuator 0.11 db polA
        RFATTNB  :fxpar(hdrExAG_S,"RFATTNB" ,start=st),$; rf attenuator 0.11 db polB
        IF1ATTNA :fxpar(hdrExAG_S,"IF1ATTNA",start=st),$; if1 attenuator 0.11 db polA
        IF1ATTNB :fxpar(hdrExAG_S,"IF1ATTNB",start=st),$; if1 attenuator 0.11 db polB
        IF1SEL   :fxpar(hdrExAG_S,"IF1SEL"  ,start=st),$;10GHz1500,5-thru
        AC2SW    :fxpar(hdrExAG_S,"AC2SW"   ,start=st),$; Platform AC power to various instruments
        HYBRID   :fxpar(hdrExAG_S,"HYBRID"  ,start=st),$; 10Ghz Upconverter hybrid in use
        PHBSIG   :fxpar(hdrExAG_S,"PHBSIG"  ,start=st),$; 10Ghz Upconverter signal ph adjust
        PHBLO    :fxpar(hdrExAG_S,"PHBLO"   ,start=st),$; 10Ghz Upconverter LO phase adjust
        XFNORMAL :fxpar(hdrExAG_S,"XFNORMAL",start=st),$; 1 downstairs xfrer switch straight thru
        AMPGAINA :fxpar(hdrExAG_S,"AMPGAINA",start=st),$; Gain of control room amplifiers polA
        AMPGAINB :fxpar(hdrExAG_S,"AMPGAINB",start=st),$; Gain of control room amplifiers polB
        NOISE    :fxpar(hdrExAG_S,"NOISE"   ,start=st),$; Control room noise src in use
        INPFRQ   :fxpar(hdrExAG_S,"INPFRQ"  ,start=st),$; Control room input distributor position
        MIXER    :fxpar(hdrExAG_S,"MIXER"   ,start=st),$; Control room mixer source switches 
        VLBAINP  :fxpar(hdrExAG_S,"VLBAINP" ,start=st),$; Control room VLBA input switch position
        SYNDEST  :fxpar(hdrExAG_S,"SYNDEST" ,start=st),$; Control room synth destination for this brd
        CALSRC   :fxpar(hdrExAG_S,"CALSRC"  ,start=st),$; Control room cal mux source bit
        BLANK430 :fxpar(hdrExAG_S,"BLANK430",start=st)}; Control room 430 blanking on 
;   ---------------------------------------------------------------------------------------------
;   pdev hdu
; the regular expression to use on:
; /share/megs/phil/svn/pdev/pdev/include/psrfits_search_template.dat 
; after editing out the non pdev header lines.
;
; g/^\([^ ]*\)[ ]*=.*\/\(.*\)/s//\1 :fxpar(hdrExPD_S,"\1",start=st),$;\2/

;
     fxhread,lun,hdrExPD_S,status
     st=0L

	hdrExPD={$
        CALCTL   :fxpar(hdrExPD_S,"CALCTL"  ,start=st),$; 0:calAlwaysOff,1:calAlwaysOn, 2:winking cal    
        WCALON   :fxpar(hdrExPD_S,"WCALON"  ,start=st),$; winking cal dumps for calon                    
        WCALOFF  :fxpar(hdrExPD_S,"WCALOFF" ,start=st),$; winking cal dumps for caloff                   
        WCALPHAS :double(fxpar(hdrExPD_S,"WCALPHAS",start=st)),$; Position cal change in last dump.              
        ADRMS_AI :double(fxpar(hdrExPD_S,"ADRMS_AI",start=st)),$;d rms polA digI                              
        ADRMS_AQ :double(fxpar(hdrExPD_S,"ADRMS_AQ",start=st)),$;d rms polA digQ                              
        ADRMS_BI :double(fxpar(hdrExPD_S,"ADRMS_BI",start=st)),$;d rms polB digI                              
        ADRMS_BQ :double(fxpar(hdrExPD_S,"ADRMS_BQ",start=st)),$;d rms polB digQ                              
        ADMN_AI  :double(fxpar(hdrExPD_S,"ADMN_AI" ,start=st)),$;d mean polA digI                             
        ADMN_AQ  :double(fxpar(hdrExPD_S,"ADMN_AQ" ,start=st)),$;d mean polA digQ                             
        ADMN_BI  :double(fxpar(hdrExPD_S,"ADMN_BI" ,start=st)),$;d mean polB digI                             
        ADMN_BQ  :double(fxpar(hdrExPD_S,"ADMN_BQ" ,start=st)),$;d mean polB digQ                             
        BBMGN_A  :fxpar(hdrExPD_S,"BBMGN_A" ,start=st),$; bbm gain polA db                               
        BBMGN_B  :fxpar(hdrExPD_S,"BBMGN_B" ,start=st),$; bbm gain polB db 
        ADTIME   :fxpar(hdrExPD_S,"ADTIME"  ,start=st),$;d rms measured                
        PHMAINID :fxpar(hdrExPD_S,"PHMAINID",start=st),$; pdev hdr id                                    
        PHSP1ID  :fxpar(hdrExPD_S,"PHSP1ID" ,start=st),$; pdev sp1hdr id                                 
        PHADCF   :fxpar(hdrExPD_S,"PHADCF"  ,start=st),$;D freq read from pdev                        
        PHBSWAP  :fxpar(hdrExPD_S,"PHBSWAP" ,start=st),$; pdev byte swap code                            
        PHBLKSIZ :fxpar(hdrExPD_S,"PHBLKSIZ",start=st),$; pdev bytes in buffer                           
        PHNBLKS  :fxpar(hdrExPD_S,"PHNBLKS" ,start=st),$; pdev nblocks                                   
        PHBEAM   :fxpar(hdrExPD_S,"PHBEAM"  ,start=st),$; pdev beam 0..                                  
        PHSUBBND :fxpar(hdrExPD_S,"PHSUBBND",start=st),$; pdev subband. 0 low 1 hi                       
        PHLO1MIX :fxpar(hdrExPD_S,"PHLO1MIX",start=st),$; pdev lo1mix                                    
        PHLO2MX0 :fxpar(hdrExPD_S,"PHLO2MX0",start=st),$; pdev lo2mix subband 0                          
        PHLO2MX1 :fxpar(hdrExPD_S,"PHLO2MX1",start=st),$; pdev lo2mix subband 1                          
        PHADCCLK :fxpar(hdrExPD_S,"PHADCCLK",start=st),$; pdev adcclk from pnet.conf file                
        PHSTTIME :fxpar(hdrExPD_S,"PHSTTIME",start=st),$; pdev seconds from 1970                         
        PHRESV1  :fxpar(hdrExPD_S,"PHRESV1" ,start=st),$; pdev resv1 b0->psrvphil                        
        PHIF1    :fxpar(hdrExPD_S,"PHIF1"   ,start=st),$; pdev if1 from pnet.conf                 
        PHFMTWID :fxpar(hdrExPD_S,"PHFMTWID",start=st),$; pdev output bits 0-8,1=16,2=32                 
        PHFMTTYP :fxpar(hdrExPD_S,"PHFMTTYP",start=st),$; pdev 0-stokesI,1=S0,S1,2=s0,s1,s2,s3           
        PHFFTLEN :fxpar(hdrExPD_S,"PHFFTLEN",start=st),$; pdev fft length                                
        PHCHN1   :fxpar(hdrExPD_S,"PHCHN1"  ,start=st),$; pdev first chan to dump. cnt from 0            
        PHCHN2   :fxpar(hdrExPD_S,"PHCHN2"  ,start=st),$; pdev last chan to dump.cnt from 0              
        PHFFTACC :fxpar(hdrExPD_S,"PHFFTACC",start=st),$; pdev ffts to accumulate                        
        PHDRPACC :fxpar(hdrExPD_S,"PHDRPACC",start=st),$; pdev ffts to drop each accum                   
        PHARSEL  :fxpar(hdrExPD_S,"PHARSEL" ,start=st),$; pdev where A real signal originates            
        PHAISEL  :fxpar(hdrExPD_S,"PHAISEL" ,start=st),$; pdev where A img signal originates             
        PHBRSEL  :fxpar(hdrExPD_S,"PHBRSEL" ,start=st),$; pdev where B real signal originates            
        PHBISEL  :fxpar(hdrExPD_S,"PHBISEL" ,start=st),$; pdev where B img signal originates             
        PHARNEG  :fxpar(hdrExPD_S,"PHARNEG" ,start=st),$; pdev negate A real signal                      
        PHAINEG  :fxpar(hdrExPD_S,"PHAINEG" ,start=st),$; pdev negat A img signal                        
        PHBRNEG  :fxpar(hdrExPD_S,"PHBRNEG" ,start=st),$; pdev negate B real signal                      
        PHBINEG  :fxpar(hdrExPD_S,"PHBINEG" ,start=st),$; pdev negat B img signal                        
        PHPFBBYP :fxpar(hdrExPD_S,"PHPFBBYP",start=st),$; pdev bypass pfb                                
        PHPSHIFT :fxpar(hdrExPD_S,"PHPSHIFT",start=st),$; pdev PSHIFT for butterflys                     
        PHUPSHFT :fxpar(hdrExPD_S,"PHUPSHFT",start=st),$; pdev upshift after fft                         
        PHDSH_S0 :fxpar(hdrExPD_S,"PHDSH_S0",start=st),$; pdev S0 downshift before accum                 
        PHDSH_S1 :fxpar(hdrExPD_S,"PHDSH_S1",start=st),$; pdev S1 downshift before accum                 
        PHDSH_S2 :fxpar(hdrExPD_S,"PHDSH_S2",start=st),$; pdev S2 downshift before accum                 
        PHDSH_S3 :fxpar(hdrExPD_S,"PHDSH_S3",start=st),$; pdev S3 downshift before accum                 
        PHASH_S0 :fxpar(hdrExPD_S,"PHASH_S0",start=st),$; pdev S0 upshift 40bits accum                   
        PHASH_S1 :fxpar(hdrExPD_S,"PHASH_S1",start=st),$; pdev S1 upshift 40bits accum                   
        PHASH_S2 :fxpar(hdrExPD_S,"PHASH_S2",start=st),$; pdev S2 upshift 40bits accum                   
        PHASH_S3 :fxpar(hdrExPD_S,"PHASH_S3",start=st),$; pdev S3 upshift 40bits accum                   
        PHASH_SI :fxpar(hdrExPD_S,"PHASH_SI",start=st),$; pdev SI upshift 40bits accum                   
        PHDRPST  :fxpar(hdrExPD_S,"PHDRPST" ,start=st),$; pdev ffts to drop at start                     
        PHDLO    :fxpar(hdrExPD_S,"PHDLO"   ,start=st),$; pdev digial LO                                 
        PHDLOPH  :fxpar(hdrExPD_S,"PHDLOPH" ,start=st),$; pdev digital lo phase                          
        PHHRMODE :fxpar(hdrExPD_S,"PHHRMODE",start=st),$; pdev hiRes Mode                                
        PHHRDEC  :fxpar(hdrExPD_S,"PHHRDEC" ,start=st),$; pdev hiRes decimation                          
        PHHRSHIF :fxpar(hdrExPD_S,"PHHRSHIF",start=st),$; pdev hiRes shift                               
        PHHROFF  :fxpar(hdrExPD_S,"PHHROFF" ,start=st),$; pdev hiRes offset                              
        PHHRLPF  :fxpar(hdrExPD_S,"PHHRLPF" ,start=st),$; pdev timeDomain data code                      
        PHHRDWEL :fxpar(hdrExPD_S,"PHHRDWEL",start=st),$; pdev hiRes dwell                               
        PHHRINC  :fxpar(hdrExPD_S,"PHHRINC" ,start=st),$; pdev hiRes digital lo increment                
        PHBLKSEL :fxpar(hdrExPD_S,"PHBLKSEL",start=st),$;  gpio pin for extern blank 0xffff=none         
        PHBLKPER :fxpar(hdrExPD_S,"PHBLKPER",start=st),$; 0-use extBlnkTime.>0=# ticks blank afterPulse  
        PHADCTHR :fxpar(hdrExPD_S,"PHADCTHR",start=st),$; # adcOvf before blank. 0xffff=off              
        PHADCDWL :fxpar(hdrExPD_S,"PHADCDWL",start=st),$; extend adcovfBlank by this many ticks          
        PHCALSEL :fxpar(hdrExPD_S,"PHCALSEL",start=st),$; gpio pin for cal input. 0xf--> no cal          
        PHCALPH  :fxpar(hdrExPD_S,"PHCALPH" ,start=st),$; 0 to FCNT-1. when cal transitions in dump      
        PHCALCTL :fxpar(hdrExPD_S,"PHCALCTL",start=st),$; B1=1 --> winking cal else:B0=1 calOn,b0=0 calof
        PHCALON  :fxpar(hdrExPD_S,"PHCALON" ,start=st),$; # of dumps for winking calon (if enabled)      
        PHCALOFF :fxpar(hdrExPD_S,"PHCALOFF",start=st)}; # of dumps for winking caloff (if enabled)    

;   ---------------------------------------------------------------------------------------------
;   move the extension header to it's structure
;   Since start= is used.. need to have struct order same as file header
;   if not, get rid of start=
;
; fxpar(hdrExSI_S,"",start=start),$;
;   get starting byte for subIntExtStart
	point_lun,-lun,subIntExtStart
	start=0L
	istat=fxpar(hdrExSI_S,"NAXIS2",start=start); Number of rows in table (NSUBINT)              
	naxis2ByteOffset=subIntExtStart + (start-1)*80
	start=0L
	hdrExSI={$
		NAXIS1  : fxpar(hdrExSI_S,"NAXIS1",start=start) ,$; Number of bytes in rowle (NSUBINT)              
		NAXIS2  : fxpar(hdrExSI_S,"NAXIS2",start=start) ,$; Number of rows in table (NSUBINT)              
        NPOL    : fxpar(hdrExSI_S,"NPOL",start=start)   ,$; Nr of polarisations                            
		POL_TYPE: fxpar(hdrExSI_S,"POL_TYPE",start=start),$;Pol identifier (e.g., AABBCRCI, AA+BB)
		TBIN    : double(fxpar(hdrExSI_S,"TBIN",start=start)),$;  [s] Time per bin or sample                     
		NBIN    : fxpar(hdrExSI_S,"NBIN",start=start),$; Nr of bins (PSR/CAL mode; else 1)              
		NBIN_PRD: fxpar(hdrExSI_S,"NBIN_PRD",start=start),$; Nr of bins/pulse period (for gated data)       
		PHS_OFFS: double(fxpar(hdrExSI_S,"PHS_OFFS",start=start)),$; Phase offset of bin 0 for gated data           
		NBITS   : fxpar(hdrExSI_S,"NBITS",start=start),$; Nr of bits/datum (SEARCH mode 'X' data, else 1)
		NSUBOFFS: fxpar(hdrExSI_S,"NSUBOFFS",start=start),$; Subint offset (Contiguous SEARCH-mode files)   
		NCHAN   : fxpar(hdrExSI_S,"NCHAN",start=start),$; Number of channels/sub-bands in this file      
		CHAN_BW : double(fxpar(hdrExSI_S,"CHAN_BW",start=start)),$; [MHz] Channel/sub-band width                   
		NCHNOFFS: fxpar(hdrExSI_S,"NCHNOFFS",start=start),$; Channel/sub-band offset for split files        
		NSBLK   : fxpar(hdrExSI_S,"NSBLK",start=start) $; Samples/row (SEARCH mode, else 1)         
	}
;
;  bitScl: old 16 bits /sample  data stored as shorts
;        : new 4bits/sample     data stored as bytes.
;         So the number of new samples is twice the length of the byte ar 
	bitScl=(hdrExSI.nbits eq 4)?2L:1L ; short -> byte and 16bit -> 4bit.k
;
; 	strip off trailing blanks from string variables
;
	for i=0,n_tags(hdrExSI)-1 do begin 
		if (size(hdrExSI.(i),/type) eq 7) then hdrExSI.(i)=strtrim(hdrExSI.(i)) 
	endfor

	if hdrExSI.naxis2 le 0 then begin 
        print,"No rows in file:"
        goto,errout
    endif

;   read in colum byte offsets, datatype, form, number elements each col

	fxbtform,hdrExSI_S,colByteOffset,ttype,tform,tnumval

;   get the name of each col

	fxbfind,hdrExSI_S,"TTYPE",cols,tagAr,ncols
;
;    get offset start of rec
;    we position to end of col 1 (start of col 2)
;    take current postion - byteoffset col2 to be start of rec
;
    fxbread,lun,junk,1,1        ; read col 1 of first rec
    point_lun,-lun,pos          ; start col2 row 1
    rec1start=pos - colByteOffset[1] ;  
;
;   check swapping
;
    val1=1
    val2=1
    byteorder,val2,/htons
    needswap=val1 ne val2
;
;  generate structure for row read
;
	for i=0,ncols - 1 do begin 
    	icol=i+1 
    	tag=strtrim(tagAr[i]) 
    	len=(tnumval[i] > 2) 
    	val=make_array(len,type=ttype[i]) 
    	if tnumval[i] eq 1 then begin  ; make array doesn't work with scalars..
        	len=1 
        	val=val[0] 
    	endif 
    	if len gt 1 then begin 

;      check for dat_offs, dat_scl, data.. we want to redimension

       		if (((tag eq 'DAT_OFFS') or (tag eq 'DAT_SCL')) ) then begin 
         		if (hdrExSI.npol gt 1)  then  begin
					val=reform(temporary(val),hdrExSI.nchan,hdrExSI.npol,/overwrite) 
        		endif
			endif else begin 
      			if (tag eq 'DATA') then begin 
           			if hdrExSI.npol eq 1 then begin 
           				val =reform(temporary(val),hdrExSI.nchan,hdrExSI.nsblk/bitScl,/overwrite) 
						if (bitScl ne 1) then valF=fltarr(hdrExSI.nchan,hdrExSI.nsblk)
          			endif else begin 
           				val=reform(temporary(val),hdrExSI.nchan,hdrExSI.npol,hdrExSI.nsblk/bitScl,/overwrite) 
						if (bitScl ne 1) then valF=fltarr(hdrExSI.nchan,hdrExSI.npol,hdrExSI.nsblk)
           			endelse 
           			if (bitScl eq 1) then valF=float(val)
       			endif 
			endelse 
		endif
;
		if i eq 0 then begin 
        	str =create_struct(tag,val) 
        	strF=create_struct(tag,val) 
    	endif else begin	
			if (tag eq 'STAT') then begin
				ndump=hdrExSI.nsblk
				str =create_struct(temporary(str),tag,replicate({pdev_hdrdump},ndump)) 
				strF=create_struct(temporary(strF),tag,replicate({pdev_hdrdump},ndump)) 
			endif else begin
      			if (tag eq 'DATA') then begin 
        			str=create_struct(temporary(str),tag,val) 
        			strF=create_struct(temporary(strF),tag,valF) 
				endif else begin 
        			str=create_struct(temporary(str),tag,val) 
        			strf=create_struct(temporary(strF),tag,val) 
				endelse
			endelse
    	endelse 
	endfor

    desc={   lun     : lun       ,$;
		filename: fileLoc,$;
        needswap: needSwap,$;  1 if need to swap the data o nthe cpu
        bytesRow:  hdrExSI.naxis1   ,$; bytes 1 row
        totRows :  hdrExSI.naxis2   ,$; total number of rows in table
        curRow  : 0L        ,$;
        byteOffRec1:rec1start,$
        byteOffNaxis2:naxis2ByteOffset  ,$  ; bytes offset naxis 2 keyword
        hpri     : hdrPr  ,$   ; primary header
        haogen   : hdrExAG,$   ; primary header
		hpdev    : hdrExPD,$ ; pdev header
        hsubint  : hdrExSI,$ ; subInt table header
        rowStr   : str,$   ; template for records to read
        rowStrF  : strF}  ; template for float version
;
;    remember lun in case psrfclose,/all
;
    ind=where(psrflunar eq 0,count)
    if count gt 0 then begin
        psrflunar[ind[0]]=lun
        psrfnluns=psrfnluns+1
    endif
    return,0  
errout:
    if (lun gt -1) then  fxbclose,lun
    return,-1 
end
