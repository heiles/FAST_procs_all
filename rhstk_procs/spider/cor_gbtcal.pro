pro cor_gbtcal, board, scndata,  $
                calbefore, strip, calafter, $
                noplott, nrc, $
                tcalxx, tcalyy, $
                a, fp, b_0, hb_arr, $
                beamin, beamin_arr, $
                beamout, beamout_arr, $
                mm_corr= mm_corr, mm_pro_user= mm_pro_user, $
                m_rcvrcorr= m_rcvrcorr, m_skycorr= m_skycorr, $
                m_astro= m_astro, $
                phaseplot= phaseplot, totalquiet=totalquiet

;+
;PURPOSE: Read the corfile and produce calibrated output data and
;positions for the crosses. 
;
;calling sequence:
;	cor_newcal, board, filename, beamin
;
;INPUTS:
;	BOARD, the board number to process: 0 to 3
;
;	SCNDATA, the structure containing various info about scan,
;required for processing.

;	NOPLOTT: if equal to one, no plots are produced as the data
;are processed

;OUTPUTS:

;	B_0 and B_arr, a copy and an array of copies of phil's 'b' 
;structure

;	BEAMIN, BEAMIN_ARR, the data structure that will be used as cross data
;for subsequent beam fitting routines. 

;PROCEDURES CALLED:
;	CROSS_GBTCAL, which reads the corfile, produces calibrated stokes
;parameters, and generates header data we wish to save
;	GET_OFFSETS_GBTCAL, which generates angular offsets of each observed
;point in the cross.
;
;HISTORY:
;	revision of original version software on 17 oct 2002.
;       robishaw added comments and cleaned it up; 10 ocr 2006
;-

;NR OF PATTERNS...
nrcmax= n_elements( strip)/4

; LOOP THROUGH AND DO ALL CROSSES IN THE FILE...
;stop, 'stop0'
FOR NRC=0, NRCMAX-1 DO BEGIN
   internal_scan_nr= 4* nrc

   ; PROCESS ALL FOUR STRIPS OF SPIDER SCAN...
   ; CALIBRATES THE STOKES PARAMETERS...
   cross3_gbtcal, board, scndata, nrc,  $
                  calbefore, strip, calafter, $
                  tcalxx, tcalyy, cfr, scannr0, sourcename, stokesc1, $
                  calphase_zero, calphase_slope, srcphase_zero, $
                  srcphase_slope, $
                  azmidpnt, zamidpnt, $
                  cumcorr=cumcorr, phaseplot= phaseplot, totalquiet=totalquiet

   ; POPULATE THE BEAMIN STRUCTURE...
   beamin.calphase_zero= calphase_zero
   beamin.calphase_slope= calphase_slope
   beamin.srcphase_zero= srcphase_zero
   beamin.srcphase_slope= srcphase_slope

   beamin.tcalxx= tcalxx
   beamin.tcalyy= tcalyy
   beamin.antlong= strip[0].antlong
   beamin.antlat= strip[0].antlat

   beamin.scannr= scannr0
   ;beamin.stokesc1= stokesc1[ *, *, 4*scndata.ptsperstrip:*]
   
   gbtrcvr,  strip[ 4*nrc].rcvr, rcvrnr ; GET RCVR NUMBER

   ; GET THE BACKEND...
   case strtrim(strip[0].backend,2) of
      'SpectralProcessor' : beamin.backend = 'SP'
      'Spectrometer' : beamin.backend = 'ACS'
      else : message, 'Unkown GBT Backend'
   endcase

   beamin.rcvrn= rcvrnr
   beamin.rcvrname= strip[ 4*nrc].rcvr
   beamin.hpbw_guess= 9.5* (1420./cfr)
   beamin.cfr= cfr
   
   beamin.bw= strip[ 4*nrc].subscan[0].bandwdth/1.0e6
   beamin.bwsign= strip[ 4*nrc].subscan[0].bwsign

   beamin.azencoders= strip[4*nrc:4*nrc+3].subscan[0:scndata.ptsperstrip-1].az
   beamin.zaencoders= strip[4*nrc:4*nrc+3].subscan[0:scndata.ptsperstrip-1].za

;stop, 'stop1'
   ;vvvvvvvvvvvvvvvv MM-CORRECT THE STOKESC1 DATA IF REQUESTED vvvvvvvvvvvvv
   mcorr=0
   IF ( KEYWORD_SET( MM_CORR)) THEN BEGIN
      
      ;GET RECEIVER INFO...
      gbtrcvr, strip[ 4*nrc].rcvr, rcvrn, nocorrcal, circular, $
               mmprocname=mmprocname
      
      ;CHECK FOR USER-SPECIFIED MMCORR PROCNAME...
      if ( (n_elements( mm_pro_user) ne 0) and (mm_pro_user ne '')  ) $ 
         then mmprocname= mm_pro_user
            
      IF (MMPROCNAME NE '') THEN BEGIN
         if keyword_set( totalquiet) ne 1 then  $
            print, 'MUELLER-CORRECTING USING mmprocname = ', mmprocname
         call_procedure, mmprocname, cfr, m_tot, m_astron, $
                         deltag, epsilon, alpha, phi, chi, psi, $
                      angle_astron ;;;;, /zero_deltag
         mcorr= 1+ 2*keyword_set( m_skycorr)+ 4*keyword_set( m_astro)
         
         ;stop
         sz= size( stokesc1)
         stokesc1= reform( stokesc1, sz[1], sz[2], sz[3]* sz[4])
         azmidpnt= reform( azmidpnt, sz[3]* sz[4])
         zamidpnt= reform( zamidpnt, sz[3]* sz[4])
         mm_corr_zmn, m_tot, m_astron, azmidpnt, zamidpnt, stokesc1, $
                      sz[3]*sz[4], m_skycorr=m_skycorr, m_astro=m_astro, antlat=beamin[0].antlat
         stokesc1= reform( stokesc1, sz[1], sz[2], sz[3], sz[4])
         
         ;stop
         
      ENDIF
   ENDIF
   ;^^^^^^^^^^^^ END MM CORRECT ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   ; GETS THE ANGULAR OFFSETS (IN ARCMIN) OF EACH POINT IN THIS SPIDER SCAN
   ; THEN POPULATES THE BEAMIN STRUCTURE WITH THE ANGULAR INFORMATION AND
   ; THE CALIBRATED STOKES PARAMETERS...
   get_offsets_gbtcal, scndata, beamin, $
                       calbefore, strip, calafter, $
                       nrc, stokesc1

   beamin_arr[ nrc]= beamin
   
ENDFOR

;stokesc1_cont= total(stokesc1,1)/256
;stokesc1_cont= stokesc1_cont[ *, 2:81,*]
;stop, 'stop2

;DEFINE STRUCTURES A, BEAMOUT...
;beamout_arr= replicate( beamout, nrc)
a= replicate( {mueller_carl}, nrc)
fp= replicate( {muellerfitpol}, 3)

;INSERT QUANTITIES INTO BEAMOUT...
beamout_arr.tcalxx= tcalxx
beamout_arr.tcalyy= tcalyy
beamout_arr.antlong= strip[0].antlong
beamout_arr.antlat= strip[0].antlat

beamout_azzapa, nrcmax, beamin_arr,  $
        calbefore, strip, calafter, $
	beamout_arr
beamout_arr.sourcename= sourcename

;GET THE SOURCEFLUX...
sourceflux= fluxsrc( sourcename, cfr) 
;SET THE SOURCEFLUX NEGATIVE IF IT WASN'T FOUND...
if ( sourceflux eq 0.) then sourceflux=-1.
beamout_arr.sourceflux= sourceflux

;INSERT QUANTITIES INTO BEAMIN...
;beamin_arr.hpbw_guess= reform( hb_arr[ 0, *].proc.dar[0])

internal_scan_nr= 0
a.cfr= cfr
a.bw= strip[ internal_scan_nr].subscan[0].bandwdth
a.bwsign= strip[ internal_scan_nr].subscan[0].bwsign

a.nchnls= strip[ internal_scan_nr].nchan
a.julday= strip[ internal_scan_nr].subscan[0].mjd
a.mmcor= mcorr

;stop, 'stop3'

return
end
