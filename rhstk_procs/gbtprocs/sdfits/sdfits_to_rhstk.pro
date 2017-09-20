pro sdfits_to_rhstk_initialize_rhstk_struct, them, si, poln_vec, $
   us, BINDOWN=bindown

; HOW MANY SPECTRAL CHANNELS...
Nchan = (N_elements(BINDOWN) gt 0) ? bindown : si.n_channels

; HOW MANY STATES, SWITCHING AND CALON/OFF...
Nstate = si.n_cal_states * si.n_sig_states

; DEFINE THE STRUCTURE FOR EACH INTEGRATION...
SubScanStruct = create_struct(['SubScanNum', $
                               ; ALL VALUES ARE FOR *CENTER* OF INTEGRATION...
                               'MJD', $      ; MODIFIED JULIAN DATE
                               'UTD', $      ; UT DATE
                               'UTC', $      ; UTC [HOURS]
                               'LST', $      ; LST [HOURS]
                               'CRA2000', $  ; RA  J2000 [DEG]
                               'CDEC2000', $ ; DEC J2000 [DEG]
                               'AZ', $       ; AZIMUTH ANGLE  [DEG]
                               'ZA', $       ; ZENITH  ANGLE  [DEG]
                               'AZoffset', $ ; AZIMUTH OFFSET [DEG]
                               'ZAoffset', $ ; ZENITH  OFFSET [DEG] 
                               'BandWdth', $ ; BANDWIDTH [HZ]
                               'BWSign', $  ; FORWARDS(+1)/BACKWARDS(-1)
                               'Freq',     $ ; CENTRAL FREQUENCY [HZ]
                               'Spec', $     ; SPECTRA
                               'CalState', $ ; CAL STATE [OFF(0)/ON(1)]
                               'SigRef', $   ; SIGNAL(0)/REFERENCE(1)
                               'Duration' $  ; DURATION OF STATE [SEC]
                              ], $
                              0L, 0D, 0D, 0D, 0D, $
                              0D, 0D, 0D, 0D, 0D, 0D, $
                              0D, 0.0, $
                              DBLARR(NState), $
                              FLTARR(NChan,NState,4), $
                              BYTARR(NState), $
                              BYTARR(NState), $
                              DBLARR(NState))

; DEFINE THE SCAN STRUCTURE...
ScanData = create_struct(['ProjID', $   ; PROJECT ID
                          'ScanNum', $  ; SCAN NUMBER
                          'NSubScan', $ ; NUMBER OF SUBSCANS
                          'NChan', $    ; NUMBER OF CHANNELS IN SPECTRA
                          'NState', $   ; NUMBER OF STATES
                          'NPort', $    ; NUMBER OF SPECTRAL PROCESSOR PORTS
                          'MJDStart', $ ; STARTING MJD
                          'ActvSurf', $ ; WAS THE ACTIVE SURFACE ON?
                          'SWState', $  ; SWITCH STATE
                          'SNAME', $    ; SOURCE NAME
                          'SRA', $      ; SOURCE RA
                          'SDEC', $     ; SOURCE DEC
                          'SEpoch', $   ; SOURCE EPOCH
                          'Velocity', $ ; SOURCE VELOCITY [m/s]
                          'VelDef', $   ; VELOCITY DEFINITION AND REST FRAME
                          ; THE FOLLOWING 4 KEYWORDS BECAME NECESSARY WHEN
                          ; KAREN GAVE US A SCRIPT THAT OBSEREVED 19 
                          ; POSITIONS BUT EACH POSITION HAD THE SAME
                          ; SOURCE NAME...
                          'PROCName', $ ; NAME OF OBSERVING PROCEDURE
                          'PROCSeqN', $ ; SCAN SEQUENCE NUMBER
                          'PROCSize', $ ; NUMBER OF SCANS IN PROCEDURE
                          'AntLong', $  ; ANTENNA LONGITUDE [West Long]
                          'AntLat', $   ; ANTENNA LATITUDE
                          'AntEl', $    ; ANTENNA ELEVATION
                          'IntTime', $  ; INTEGRATION TIME
                          'Pol', $      ; POLARIZATION PRODUCTS
                          'BackEnd', $  ; BACKEND
                          'Rcvr', $     ; RECEIVER
                          'HighCal', $  ; WAS THE HIGH CAL SET?
                          'TCalXX', $   ; TCAL FOR XX
                          'TCalYY', $   ; TCAL FOR YY
                          'SubScan' $   ; THE SUBSCAN STRUCTURE
                         ], $ 
                         '', $
                         0l, $
                         0l, $
                         0l, $
                         0l, $
                         0l, $
                         0d0, $
                         0b, $
                         '', $
                         '', $
                         0d0, $
                         0d0, $
                         0.0, $
                         0.0, $
                         '', $
                         '', $
                         0l, $
                         0l, $
                         0d0, $
                         0d0, $
                         0d0, $
                         0d0, $
                         ['','','',''], $
                         '', $
                         '', $
                         0b, $
                         0d0, $
                         0d0, $
                         replicate(SubScanStruct,si.n_integrations))

; ACTUALLY POPULATE THE SCAN STRUCTURE...

us = ScanData

us.projid = them.projid
us.scannum = them.scan_number
us.nsubscan = si.n_integrations
us.nchan = nchan
us.nstate = si.n_cal_states * si.n_sig_states
us.nport = si.n_polarizations
us.mjdstart = them.mjd
us.actvsurf = 0                 ; this is not stored anywhere
us.swstate = them.switch_state
us.sname = them.source
us.sra = them.target_longitude
us.sdec = them.target_latitude
us.sepoch = them.equinox
us.velocity = them.source_velocity
; WHAT WE HAD STORED WAS THE VEL_DEF KEYWORD FROM GO FITS FILE...
;VELDEF
;    The velocity definition and frame (8 characters). The first 4
;    characters describe the velicity definition. Possible definitions
;    include:
;    RADI
;        radio 
;    OPTI
;        optical 
;    RELA
;        relativistic 
;
;    The second 4 characters describe the reference frame (e.g. ``-LSR'',
;    ``-HEL'', ``-OBS''). If the frequency-like axis gives a frame, then
;    the frame in VELDEF only applies to any velocities given as columns or
;    keywords (virtual columns).
us.veldef = them.velocity_definition
us.procname = them.procedure
us.procseqn = them.procseqn
us.procsize = them.procsize
; OUR FILLER GRABBED THE VALUE FROM THE ANTENNA FITS FILE HEADER, WHICH IS
; DEFINED AS WEST LONGITUDE AND IS POSITIVE; SDFITS STORES THE NEGATIVE OF
; THIS NUMBER AND IS DEFINED THEREFORE AS THE EAST LONGITUDE OF THE SITE.
; FOR CONSISTENCY WE CONTINUE TO STORE WEST LONGITUDE...
us.antlong = -them.site_location[0]
us.antlat = them.site_location[1]
us.antel = them.site_location[2]
us.inttime = them.duration
us.pol = poln_vec
us.backend = them.backend
us.rcvr = them.frontend
us.highcal = them.caltype eq 'HIGH'

; GET THE TCAL VALUES...
;TCalPath = '/zeeman/robishaw/projects/gbt/acs_xpol/sdfits_fix/polcal/tcal_data'
;case strupcase(us.rcvr) of
;   'RCVR1_2' : CalFitsFile =TCalPath+'/Rcvr1_2/2005_05_27_00:00:00.fits'
;   'RCVR4_6' : CalFitsFile =TCalPath+'/Rcvr4_6/2003_03_27_00:00:00.fits'
;   'RCVR8_10': CalFitsFile =TCalPath+'/Rcvr8_10/2004_08_25_00:00:00.fits'
;   else : message, 'No TCal data for this receiver.'
;endcase
;FitsFiles = {Rcvr:CalFitsFile}
;gettcal, FitsFiles, them.Reference_Frequency, us.highcal, TCalXX, TCalYY
;us.tcalxx = TCalXX
;us.tcalyy = TCalYY

end ; sdfits_to_rhstk_initialize_rhstk_struct

;OBSFREQ
;    The observed frequency (Hz) at the reference pixel of the frequency-like axis.

;   OBSERVED_FREQUENCY
;                   DOUBLE       1.4204066e+09
;   REFERENCE_FREQUENCY
;                   DOUBLE       1.4204066e+09
;   REFERENCE_CHANNEL
;                   DOUBLE           8192.0000
;   FREQUENCY_INTERVAL
;                   DOUBLE           762.93945
;   FREQUENCY_RESOLUTION
;                   DOUBLE           923.15674

; freq = REFERENCE_FREQUENCY + (indgen(N_channels)+1 - REFERENCE_CHANNEL) * FREQUENCY_INTERVAL

;=========================

pro sdfits_to_rhstk, filesin, BINDOWN=bindown, PSWITCH=pswitch, outpath=outpath
;+
; NAME:
;       SDFITS_TO_RHSTK
;
; PURPOSE:
;       Converts SDFITS files to IDL sav files in the format of
;       Robishaw/Heiles GBT polarization observations.
;
; CALLING SEQUENCE: 
;       SDFITS_TO_RHSTK, filesin [, BINDOWN=bindown][, /PSWITCH][, 
;                        OUTPATH=outpath]
;
; INPUTS:
;       FILESIN = fully-qualified path to input SDFITS file(s); can be a
;                 scalar or vector of strings.
;
; KEYWORD PARAMETERS:
;       BINDOWN = number of elements to bin down the spectra to. Often, the
;                 spectrometer will store spectra at a higher resolution
;                 than is needed creating huge data sets.  You can bin down
;                 to an integer factor of the original number of spectral
;                 channels.  E.g., BINDOWN=512 can cause a spectrum with
;                 16,384 channels to be binned down to 512 channels.
;
;       /PSWITCH - set this keyword if you made position-switched GBT
;                  observations.  Do not set if you made standard
;                  frequency-switched observations or polarization
;                  calibration ("spider scan") observations.  This
;                  is necessary because nothing is stored in our
;                  SDFITS data that tells us whether position
;                  switching was the observing mode.
;
;       OUTPATH - the path where the output file will be
;                 written. Default is the subdir from which the program
;                 is being run.
;
; OUTPUTS:
;       None.
;
; SIDE EFFECTS: 
;       An IDL sav file of the appropriate (automatically generated) name
;       will be stored in the OUTPATH subdirectorhy. The file name is:
;         bgpos11_acs_Rcvr1_2_12.5_0_09Dec30_21:43:56.sav* (FILENAME)
;         srcname_backend_rcvr_bandwidth_bandpass_date.sav (MEANING)
;
; RESTRICTIONS:
;       Run this from GBTIDL
;
; EXAMPLE:
;       Convert from SDFITS files to IDL sav files while binning spectra
;       down to 512 channels:
;
;       GBTIDL -> sdfits_to_RHSTK, filesin, BINDOWN=512
;
;       If you wish, you can find SDFITS files for a project in gbtidl:
;       filesin = file_search(inpath+'/*.raw.acs.fits',COUNT=nfiles)
;
; MODIFICATION HISTORY:
;	Written by Tim Robishaw, Berkeley  08 Apr 2009
;               scanmin, scanmax, scankill added by Carl 19 JAN 2010
;       created sdfits_to_rhstk from sdfits_to_gbtpol. output path
;       modified. Carl Heiles, Zakopane Poland, Aug 2011.
;       chk comment labelled '16sep2011' -- pointer error for spider 
;       scan when plotting. deleted that plot command; makes things 
;       work fine.  eliminated the scanmin/scanmax/scankill stuff, which
;       was totally wrong.
;       Tim Robishaw, DRAO 18 May 2012, cleaned up documentation.
;       Tim Robishaw, DRAO 05 Jun 2012, save fswitch and pswitch data in
;       the same format.
;-

if n_elements( outpath) eq 0 then outpath= ''

linear_feeds = 'Rcvr'+['PF_1','1_2','2_3','4_6']

; GET THE SOURCE INFORMATION...
; NO LONGER NECESSARY...
;datapath = getgbtdatapath(xx[0].projid)
;GOfile = datapath + '/GO/' + xx[0].timestamp+'.fits'
;GOhdr = headfits(GOfile)
;equinox_src = sxpar(GOhdr,'EQUINOX')
;ra_src = sxpar(GOhdr,'RA')
;dec_src = sxpar(GOhdr,'DEC')

for i = 0, N_elements(filesin)-1 do begin
   
   print, 'File in : ', filesin[i]
   filein, filesin[i]

   ; GO THROUGH AND GRAB EACH SCAN...
   scans = get_scan_numbers(/UNIQUE)

   ; GET SCAN INFO FOR THE FIRST SCAN...
   si = scan_info(scans[0])

   ; TOM GOOFED UP AND WE HAD DUPLICATE SCAN NUMBERS ONE NIGHT...
   ; SO WE TAKE JUST THE FIRST VALUE...
   si = si[0]

   message, 'Number of IFs: '+strtrim(si.n_ifs,2), /INFO

   ; HOW MANY IFS...
   for ifnum = 0, si.N_ifs-1 do begin

;     GO THROUGH EACH SCAN...
      for j = 0, N_elements(scans)-1 do begin

         ; GET SCAN INFO FOR THIS SCAN...
         si = scan_info(scans[j])
         ;print, 'j = ', j

         polns = si.polarizations
         print, si.scan, si.procseqn, si.procedure, si.n_integrations, $
                FORMAT="('Scan: ',I4,'  |  Procseqn: ',I4,'  |  Procedure: '"+$
                ",A-14,'  |  Ints: ',I4)" 

         ; READ IN THE CHUNK OF DATA FOR THIS SCAN...
         scandata = getchunk(SCAN=scans[j],IFNUM=ifnum)

         ; GO THROUGH EVERY INTEGRATION...
         for int = 0, si.N_integrations-1 do begin
            
            allpols = scandata[where(scandata.integration eq int)]

            ; IS RECEIVER NATIVE LINEAR OR CIRCULAR...
            poln_vec = (total(strmatch(linear_feeds,allpols[0].frontend,$
                                       /FOLD_CASE)) gt 0) $
                       ? ['XX','XY','YY','YX'] $
                       : ['RR','RL','LL','LR']

            ; PULL OUT THE AUTO AND CROSS SPECTRA...
            xx = allpols[where(allpols.polarization eq poln_vec[0])]
            xy = allpols[where(allpols.polarization eq poln_vec[1])]
            yy = allpols[where(allpols.polarization eq poln_vec[2])]
            yx = allpols[where(allpols.polarization eq poln_vec[3])]

            ; INITIALIZE SCAN STRUCTURE...
            if (int eq 0) then $
               sdfits_to_rhstk_initialize_rhstk_struct, $
               allpols[0], si, poln_vec, us, BINDOWN=bindown

            us.tcalxx = xx[0].mean_tcal
            us.tcalyy = yy[0].mean_tcal

            ; POPULATE SUBSTRUCTURE...
            us.subscan[int].SubScanNum = int + 1 ; needed for consistency
            us.subscan[int].MJD = xx[0].mjd
            us.subscan[int].UTD = floor(xx[0].mjd)
            us.subscan[int].UTC = xx[0].utc/3.6d3 ; hours
            us.subscan[int].LST = xx[0].lst/3.6d3 ; hours

            ; GODDARD'S CT2LST ISN'T GIVING US THE SDFITS LST...
            if keyword_set(CHECK_LST) then begin
               ct2lst, our_lst, -us.AntLong, dummy, xx[0].mjd+24d5+0.5
               print, '   Our LST: ', our_lst*3600.
               print, 'SDFITS LST: ', xx[0].lst
            endif

            ; GET THE RIGHT ASCENSION AND DECLINATION OF ENCODERS...
            if (xx[0].coordinate_mode ne 'RADEC') then $
               message, 'Code not ready for non-equatorial coords!'
            ra = xx[0].longitude_axis
            dec = xx[0].latitude_axis

            ; GET RIGHT ASCENSION AND DECLINATION OF REQUESTED POSITION...
            ; MAKE SURE RA_SRC IS IN DEGREES... THIS CHANGED WITH TURTLE!!!
            ra_src = xx[0].target_longitude
            dec_src = xx[0].target_latitude

            ; PRECESS COORDINATES TO J2000...
            equinox_src = xx[0].equinox
            if (xx[0].equinox ne 2000.0) then begin
               precess, ra_src, dec_src, equinox_src, 2000.0
               precess, ra, dec, xx[0].equinox, 2000.0
            endif
            
            us.subscan[int].CRA2000 = ra
            us.subscan[int].CDEC2000 = dec

            ; HAVE TO CONVERT THE ANTENNA EQUATORIAL COORDINATES TO
            ; HORIZON COORDINATES...
            hadec2altaz, 15d0*us.subscan[int].LST - ra, dec, $
                         us.AntLat, el, az

            us.subscan[int].AZ = az
            us.subscan[int].ZA = (90d0 - el)

            ; NOW GET THE HORIZON COORDINATE OF THE SOURCE POSITION...
            hadec2altaz, 15d0*us.subscan[int].LST - ra_src, dec_src, $
                         us.AntLat, el_src, az_src  

            ; CALCULATE THE AZIMUTH OFFSETS...
            AZOffSet = (az - az_src)

            ; DID WE CROSS ZERO AZIMUTH...
            AZOffSet = AZOffSet + 360.*(   float(AZOffSet lt -180.) $
                                         - float(AZOffSet gt +180.) )

            ; MAKE GREAT CIRCLE CORRECTION TO AZIMUTH OFFSET...
            us.subscan[int].AZoffset = AZOffSet*cos(!dtor*el)
            us.subscan[int].ZAoffset = ((90d0 - el) - (90d0 - el_src))
            
            ; ADD FREQUENCY INFORMATION...
            us.subscan[int].Bandwdth = xx[0].bandwidth
            us.subscan[int].BWSign = -1 + 2*(xx[0].frequency_interval ge 0)
            us.subscan[int].Freq = xx.reference_frequency

            ; OLD SCHEME WAS CALOFF=0/CALON=1; SIG=0/REF=1
            ; SDFITS SCHEME IS CALON=0/CALOFF=1; SIG=1/REF=0
            us.subscan[int].CalState = xx.cal_state
            us.subscan[int].SigRef = xx.sig_state XOR 1
            us.subscan[int].Duration = xx.exposure

            ; POPULATE THE SPECTRA...
            Nstates = si.n_cal_states * si.n_sig_states
            for k = 0, Nstates-1 do begin
               xx_spec = *xx[k].data_ptr
               xy_spec = *xy[k].data_ptr
               yy_spec = *yy[k].data_ptr
               yx_spec = *yx[k].data_ptr

               ; THIS WAS ONLY NECESSARY *BEFORE* THEY FIXED SDFITS...
               ; CORRECT THE CROSS-POLARIZATION SPECTRA...
               ;gbt_acs_cross_correct, xy_spec, yx_spec, $
               ;                       xy[k].zero_channel, yx[k].zero_channel,$
               ;                       xy_spec, yx_spec

               ; DO WE NEED TO BIN THE DATA DOWN...
               if (N_elements(BINDOWN) gt 0) then begin
                  xx_spec = rebin(xx_spec,bindown)
                  xy_spec = rebin(xy_spec,bindown)
                  yy_spec = rebin(yy_spec,bindown)
                  yx_spec = rebin(yx_spec,bindown)
               endif

               us.subscan[int].spec[*,k,0] = xx_spec
               us.subscan[int].spec[*,k,1] = xy_spec
               us.subscan[int].spec[*,k,2] = yy_spec
               us.subscan[int].spec[*,k,3] = yx_spec
            endfor

            ; CONSTRUCT THE FREQUENCY AXIS...
            ; FOR AN 8192-CHANNEL SPECTRUM, THE SDFITS FILES STORES CRPIX1
            ; AS CHANNEL 4097 AND RECALL THAT THE FITS PIX VALUES ARE
            ; 1-BASED...
            ; THE GBTIDL STUFF IS ALL 0-BASED, SO THE REFERENCE_CHANNEL
            ; VALUE IS NOW 4096...
            freq = xx[0].REFERENCE_FREQUENCY $
                   + (lindgen(si.N_channels) - xx[0].REFERENCE_CHANNEL) $
                   * xx[0].FREQUENCY_INTERVAL

            ; BIN DOWN THE FREQUENCY AXIS...
            if (N_elements(BINDOWN) gt 0) then begin
               freq = rebin(freq,bindown)
               reference_channel = bindown/2
               reference_frequency = freq[bindown/2]
            endif

            continue

            ; PLOT SOME RESULTS TO CHECK FOR PROPER BEHAVIOR...
            for k = 0, Nstates-1 do begin
               plot, us.subscan[int].spec[*,k,*], xs=19, ys=19, /nodata, $
                     XR=[0,si.n_channels], $
                     YR=[-0.6,2.0], $
                     ;YR=[-0.2,0.2], $
                     TITLE='Scan: '+strtrim(scans[j],2)+'; Int: '+strtrim(int,2)
               oplot, us.subscan[int].spec[*,k,0], co=!cyan
               oplot, us.subscan[int].spec[*,k,2], co=!yellow
               oplot, us.subscan[int].spec[*,k,1], co=!red
               oplot, us.subscan[int].spec[*,k,3], co=!green
               io = get_kbrd(1)
            endfor

         endfor ; int

         ; FREE THE DATA POINTERS IN SCANDATA STRUCTURE...
         data_free, scandata

         ; ADD THE POPULATED US STRUCTURE TO LINKED LIST...
         DataArr = (j eq 0) ? ptr_new(us) : [DataArr,ptr_new(us)]

         ; ARE WE LOOKING AT A SPIDER SCAN...
         if strmatch(us.procname,'spider*',/FOLD_CASE) then begin
            ; FORGET ABOUT THE CAL SCANS...
            if ((us.procseqn+1) mod 3 ne 0) then continue
            ; IF THIS IS START OF PATTERN, DEFINE NEW PATTERN...
            if (us.procseqn eq 2) then begin
               ; PLOT INCOMPLETE PATTERN...
;the following line gives pointer error 16sep2011...
;               if (N_elements(pattern) lt 4) AND (N_elements(pattern) gt 0) $ 
;                  then plotspider, pattern
               ; DEFINE NEW PATTERN...
               pattern = DataArr[N_elements(DataArr)-1L]
            endif else begin
               ; ADD THIS TO THE PATTERN...
               pattern = (N_elements(pattern) eq 0) $
                         ? DataArr[N_elements(DataArr)-1L] $
                         : [pattern,DataArr[N_elements(DataArr)-1L]]
               ; PLOT THE COMPLETE PATTERN...
               if (N_elements(pattern) eq 4) $
                  then plotspider, pattern
            endelse
         endif 

      endfor ; scans

      ; GET THE DATE AND TIME OF OBSERVATION...
      daycnv, (*DataArr[0]).MJDStart+24d5+0.5, y, m, d, h
      date = string(y-2000,month_cnv(m,/Short),d,sixty(h), $
                    format="(I2.2,A3,I2.2,'_',I2.2,':',I2.2,':',I2.2)")

      ; GET THE BACKEND...
      case 1 of
         strmatch(us[0].backend,'spectrometer',/FOLD_CASE) : backend = 'acs'
         ;strmatch(us[0].backend,'spectral processor',/FOLD_CASE) : backend = 'sp'
         strmatch(us[0].backend,'spectralprocessor',/FOLD_CASE) : backend = 'sp'
      endcase

      ; GET THE BANDWIDTH...
      bw = us[0].subscan[0].bandwdth/1d6
      if (bw mod 1) eq 0 $
         then bw = string(bw,format='(I0.0)') $
         else bw = string(bw,format='(F0.1)')

      ; BUILD THE SAV FILE NAME...
      ; FOR POSITION-SWITCHED OBSERVATIONS, WE HAVE OFF POSITIONS THAT ARE
      ; NAMED SOURCENAME_off, SO WE'LL GET RID OF THE _off...
      srcname = strsplit((*DataArr[0]).sname,'_off',/REGEX,/EXTRACT)

      filename = srcname + '_' + $             ; SOURCE
                 backend + '_' + $              ; BACKEND
                 strtrim(us.Rcvr,2) + '_' + $   ; RECEIVER
                 bw + '_' + $                   ; BANDWIDTH
                 strtrim(ifnum,2) + '_' + $     ; BANDPASS
                 date + '.sav'                  ; DATE

      path_filename = outpath+ filename
      print, 'File out: ', path_filename

      ; ARE WE FREQUENCY-SWITCHING...
      FSWITCH = strmatch(us.swstate,'FSWITCH',/FOLD_CASE)

      ; DID WE OBSERVE USING THE LSFS METHOD...
      LSFS = strmatch(us.procname,'LSFS',/FOLD_CASE)

      ; SAVE THE DATA TO IDL SAV FILES...
      case 1 of

         ; WE HAVE DECIDED TO SAVE FSWITCH AND PSWITCH DATA IN THE SAME WAY...
         keyword_set(PSWITCH) : SaveFreqPosSwitch_rhstk, DataArr, path_filename
         keyword_set(FSWITCH) : SaveFreqPosSwitch_rhstk, DataArr, path_filename
         keyword_set(LSFS) : SaveLSFS_rhstk, DataArr, path_filename
         else : begin

            ; THIS IS SOME KIND OF KLUDGE LEFT OVER FROM SPECTRAL PROCESSOR
            ; DAYS; MIGHT AS WELL LEAVE IT SINCE IT GETS THE JOB DONE...
            for k = 0, N_elements(DataArr)-1 do $
               procname = (N_elements(procname) eq 0) $
               ? (*DataArr[k]).ProcName $
               : [procname,(*DataArr[k]).ProcName]
            
            if (total(strmatch(procname,'*map',/FOLD_CASE)) eq 0) $
               then savespider_rhstk, DataArr, path_filename $
               else savemap_rhstk, DataArr, path_filename
         end
      endcase

      ; FREE THE DATA POINTERS...
      ptr_free, DataArr

      help, /heap, out=hout
      print
      print, hout[0:2]
      print
      
   endfor ; ifnum

   ; GET RID OF PATTERN VARIABLE...
   delvarx, pattern

endfor ; files

end ; sdfits_to_rhstk
