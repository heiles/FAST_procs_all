;
;   correlator portion of header version 1
;11dec00 - updated mueller struct to new version
;        - polarized source,error now fractional polarization
;        - added fractional linear pol,error, src position angle and error.
;05jan02 - moved mueller matrix structures to hdrMueller.h
;02sep02 - added corstat struct
;24jun04 - increased sbc dim of corpwr to 8 for wapp data
;25jun04 - increased sbc dim of corstat to 8 for wapp data
;06jul04 - increased sbc dim of cortmp to 8 for wapp data
;
a={hdrcorv1,          id:  bytarr(4,/nozero), $
                   ver:  bytarr(4,/nozero), $
       masterClkPeriod:         0L,$
               dumpLen:         0L,$
         dumpsPerInteg:         0L,$
              lagSbcIn:         0L,$
             lagSbcOut:         0L,$
              numSbcIn:         0L,$;num sbc/board before processing
             numSbcOut:         0L,$;num sbc/board after processing
                 bwNum:         0L,$;1=maxband (1/masterClkPeriod), 9=min band
             lagConfig:         0L,$;for correlator
                levels:         0L,$; 3,9
                stokes:         0L,$; true/false
         doubleNyquist:         0L,$; true/false*/
          chipTestMode:         0L,$; true/false*/
       blankingEnabled:         0L,$;
               startOn:         0L,$;0-imd,1-1sectick,10-10sectick,99-exttick
            dataFormat:         0L,$;1 raw acfs, 2 combined acfs, 3 spectra
            totCntsInc:         0L,$; true/false included with data*/
             pwrCntInc:         0L,$; true/false included with data */
               boardId:         0L,$; board number 6,7,8,9*/
           numBrdsUsed:         0L,$;hc22 h54 number boards used*/
                attnDb:  lonarr(2,/nozero),$; correl attenuator values 0..15*/
                pwrCnt:  fltarr(2,/nozero),$; pwrcnt, i,q avg for intergration
          lag0PwrRatio:  fltarr(2,/nozero),$;meas/optimum pwr for level setting
                  free:  lonarr(2,/nozero)};current length 30*4=120 bytes

;
;   correlator portion of header version 2
;
a={hdrcorv2,        id:  bytarr(4,/nozero), $
                   ver:  bytarr(4,/nozero), $
       masterClkPeriod:         0L,$
               dumpLen:         0L,$
         dumpsPerInteg:         0L,$
              lagSbcIn:         0L,$
             lagSbcOut:         0L,$
              numSbcIn:         0L,$;num sbc/board before processing
             numSbcOut:         0L,$;num sbc/board after processing
                 bwNum:         0L,$;1=maxband (1/masterClkPeriod), 9=min band
             lagConfig:         0L,$;for correlator
                 state:         0L,$;bitmask
                frqBuf:         0L,$;freq buf num 1...4
              cycleLen:         0L,$;cyclelen for cal and freq
                calCyc:   bytarr(8,/nozero),$;y,n..
                frqCyc:   bytarr(8,/nozero),$;1,2,3,4 as ascii
               boardId:         0L,$; board number 6,7,8,9*/
           numBrdsUsed:         0L,$;hc22 h54 number boards used*/
                attnDb:  lonarr(2,/nozero),$; correl attenuator values 0..15*/
                pwrCnt:  fltarr(2,/nozero),$; pwrcnt, i,q avg for intergration
          lag0PwrRatio:  fltarr(2,/nozero),$;meas/optimum pwr for level setting
                calOff:  fltarr(2,/nozero),$;cal off pwr sbc 1,2
                 calOn:  fltarr(2,/nozero),$;cal on pwr  sbc 1,2
				state2:         0L,$;
				  fill:         0L,$;
			   baudLen:         0L,$;
			   codeLen:         0L,$;
		     codeDelay:         0L,$;
		        cohAdd:         0L,$;
                 fill2:  lonarr(4,/nozero)};filler
;
; here's the full header version 2
; 05jul02 the following are now in hdrGen.h
;@hdrStd.h
;@hdrPnt.h
;@hdrIfLo.h
;@hdrDop.h
;@hdrProc.h
a={hdr, std:{hdrstd}  ,$
        cor:{hdrcorv2},$
        pnt:{hdrpnt}  ,$
       iflo:{hdriflo} ,$
        dop:{hdrdop} ,$
       proc:{hdrproc} }

;
; to extract power monitoring
;
; 13sep01 .. added time
a={corpwr, scan:    0L,$; scan number
           rec :    0L,$; group number
		   time:    0L,$; seconds from midnite (end of rec)
           nbrds:   0L,$; number of boards
           az   :   0.,$; azimuth degrees end rec
           za   :   0.,$; za      degrees end rec
		   azErr:   0.,$; azErr little circle asecs end rec
		   zaErr:   0.,$; zaErr greate circle asecs end rec
           pwr  : fltarr(2,8) }
;
; returned by corcalonoff
;
a={corcal,    h :	     {hdr}, $; header cal on this board	  
         calval :	  fltarr(2),$; intepolated cal value
         calscl :	  fltarr(2)} ; value to scale correlatr to kelvins
;
; used  by pfcorcal
a={corcalpf,  scan  :0L,$;
            az:0.,$;
            za:0.,$;
         nbrds:0 ,$;
           cfr:fltarr(8),$; center freq board in Mhz (topocentric)
            bw:fltarr(8),$; bandwidth of board Mhz
          pols:intarr(2,8),$;[pols,brds] 0==>not used,1==>polA,2--> polB
        calScl:fltarr(2,8),$;[pols,brds] Kelvins/corCount
        calVal:fltarr(2,8),$;[pols,brds] cal value used in Kelvins
        tsys:fltarr(2,8) $;[pols,brds] Tsys in Kelvins cal off
    }

;
; record system temperatures on/off...
;
a={cortmp,    k :            0,$; units.1-->kelvins, 0--> tsysOff
		      p :  intarr(2,8),$; 1 - pola, 2-polb, 0, no data
            src :  fltarr(2,8),$;  on/off-1
             on :  fltarr(2,8),$;  on/off-1
            off :  fltarr(2,8),$;  on/off-1
		  calval:  fltarr(2,8),$; cal value in kelvins if k=1
		  calscl:  fltarr(2,8)} ; Kelvins/(calon-caloff) 
;
; corstat structure
;
a={corstat,  avg:  fltarr(2,8),  $; units.1-->kelvins, 0--> tsysOff
             rms:  fltarr(2,8),  $; units.1-->kelvins, 0--> tsysOff
       fractMask:  fltarr(8)  ,  $; fraction of whole bp mask covered
		      p :  intarr(2,8)}   ; 1 - pola, 2-polb, 0, no data
a={corstatp,  avg: fltarr(4,8),  $; units.1-->kelvins, 0--> tsysOff
             rms:  fltarr(4,8),  $; units.1-->kelvins, 0--> tsysOff
       fractMask:  fltarr(8)  ,  $; fraction of whole bp mask covered
		      p :  intarr(4,8)}   ; 1 - pola, 2-polb, 0, no data
;
;
; definitions for extended scanlist. used in cor archive.
;
a={ corsl,                     $
    scan      :         0L, $; scannumber this entry
    bytepos   :         0L,$; byte pos start of this scan
    fileindex :         0L, $; lets you point to a filename array
    stat      :         0B ,$; not used yet..
    rcvnum    :         0B ,$; receiver number 1-16
    numfrq    :         0B ,$; number of freq,cor boards used this scan
    rectype   :         0B ,$;1-calon,2-caloff,3-posOn,4-posOff
                            $ ;2-calOff
                            $ ;3-posOn 
                            $ ;4-posOff 
                            $ ;5-corOn .. tracking source

    numrecs   :         0L ,$; number of groups(records in scan)
    freq      :   fltarr(4),$;topocentric freqMhz center each subband
    julday    :         0.D,$; julian day start of scan
    srcname   :         ' ',$;source name (max 12 long)
    procname  :         ' ',$;procedure name used.
;
;   added for archive..
;
	projId    :         '' ,$; from the filename
	patId     :         0L ,$; groups scans beloging to a known pattern

   secsPerrec :         0. ,$; seconds integration per record
	channels  :   intarr(4),$; number output channels each sbc
	bwNum     :   bytarr(4),$; bandwidth number 1=50Mhz,2=25Mhz...
	lagConfig :   bytarr(4),$; lag config each sbc
	lag0      :  fltarr(2,4),$; lag 0 power ratio (scan average) 
	blanking  :         0B  ,$; 0 or 1

	azavg     :         0. ,$; actual encoder azimuth average of scan
	zaavg     :         0. ,$; actual encoder za      average of scan

	raHrReq	  :         0.D,$; requested ra , start of scan
	decDReq	  :         0.D,$; requested dec, start of scan J2000

;					    Delta end-start real angle for requested position
    raDelta   :         0. ,$; requested Arcminutes  real angle
   decDelta   :         0. ,$; requested Arcminutes real  angle
	azErrAsec : 		0. ,$; avg azErr Asecs great circle
	zaErrAsec : 		0.  $; avg zaErr Asecs great circle
	}
