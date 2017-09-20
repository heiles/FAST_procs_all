; aeronomy headers
;1. standard headers included
;2. aeronomy section headers
;3. aeronomy program headers
;
@hdrStd.h
@hdrRi.h
;-----------------------------------------------------------------------------
; POWER HEADER SECTION
; notes:
;-  PrgId in the standard header will be: "pwr"
;-  id in the power section is:           "PWR"
;-  The power profile can run in 1 of 3 modes:
; 	height profiles, spectra, or height and spectra (see progMode)
;-	There are different types of records that are written:
;		height recs, spectra, or DC record. see recType
;   For a given integration there may be more than 1 record output per
;   integration. eg: height,spectra, and dc. Suppose there are 3 records:
;	  h,spect,dc.
;	 then the generic header will have;
;   grpnum   grpRecTot  grpRecCur   power.recType 
;	  n         3         1          1  height rec
;	  n         3         2          2  spectral rec
;	  n         3         3          3  dc rec
;
;-  txSmpScale. This is the value that is used to scale the transmitter
;               samples when they are used for decoding. The the theoretical
;			    code is used, this value will be 1.
;
a={hdrsecpwr ,  id: bytarr(4,/nozero),$ ; "PWR "  not null terminated
    	    ver: bytarr(4,/nozero),$ ; " 2.1"
   	   progMode:       0L         ,$ ;1-heights,2-spectra,3-height&spectra
        dcdMode:       0L         ,$ ;1-xmter, 2-theoretical
        recType:       0L         ,$ ;this rec:1-hght,2=spectra,3-Dc rec
     txSmpScale:       0.         ,$ ;scale factor for xtmer samples
  spcRecsPerGrp:       0L         ,$ ;spectral recs in this group
      spcCurRec:       0L         ,$ ;count spectral recs 1..n
     hIppsAvged:       0L         ,$ ;heghts ipp's averaged
   spcNumHeight:       0L         ,$ ;number of height spectra
   spc1stHeight:       0L         ,$ ;height index 1st spectra. count from 1
      spcLenFft:       0L         ,$ ;length spectra  (if used)
       spcAvged:       0L         ,$ ;spectra averaged
     spcThisRec:       0L         }  ; number spectra this rec
;
;-----------------------------------------------------------------------------
; MRACF HEADER SECTION
; notes:
;-  PrgId in the standard header will be: "macf"
;-  id in the mracf section is:           "MACF"
;-  Data records have the rf pulse on, noise recs have the rf pulse off.
;-  When data and noise are taken, they are kept in separate rec(s).
;-  The output record size is fixed for data and noise. Zero padding
;   is done on the last record of the data and noise recs..
;
a={hdrsecmracf ,  id: bytarr(4,/nozero),$; "MACF"  not null terminated
              ver: bytarr(4,/nozero),$; "1.00"
	  ippsAvgData:        0L        ,$;# ipps avg all IF/RF data
     ippsAvgNoise:        0L        ,$;# ipps avg all IF/RF noise
        numIfFreq:        0L        ,$; 1 or 2 if 400/460 switching
       numHeights:        0L        ,$;# of heights requested
          numLags:        0L        ,$; they want returned
        numDcPnts:        0L        ,$;# of cmplx dc points 1 rf freq
       firstTxSmp:        0L        ,$;1st sample Tx to use cnt from 1
     recIsDataRec:        0L        ,$;1--> data rec, 0--> noise
   heightsThisRec:        0L        ,$;# of heights this record
    dcPntsThisRec:        0L        ,$;# of cmplx dc points this rec
          txspIpp:        0L        ,$;# of samples/pair/ipp trans ipp
         txHeight:        0L		,$;1-->transmiter spectra included
        numFreqSw:        0L        ,$;# tx freq to switch with sps
        txFrqOff1:        0.        ,$;frq offset 1st frqSwitch hz
        txFrqOff2:        0.        ,$;frq offset 2nd frqSwitch hz
        txFrqOff3:        0.        ,$;frq offset 3rd frqSwitch hz
        txFrqOff4:        0.        ,$;frq offset 4th frqSwitch hz
			  fr3:        0L        } ; padding to multiple of 8 bytes.
;-----------------------------------------------------------------------------
; coded long pulse HEADER SECTION
; notes:
;-  PrgId in the standard header will be: "clp"
;-  id in the mracf section is:           "CLP "
;
; two versions since mike sulzer added 4 bytes when he started the
; dual beam rawdat. clp52 (52 bytes) is the old vme version, clp is the current
a={hdrsecclp52 ,  id: bytarr(4,/nozero),$; "CLP "  not null terminated
              ver: bytarr(4,/nozero),$; " 1.0"
	 ippsAvg1Freq:        0L	    ,$;how many spectra added incoherently
        numIfFreq:        0L        ,$;1 or 2 if 400/460 switching
       numHeights:        0L        ,$;# of height spectra requested
     spc1stHeight:        0L        ,$;height index of 1st spectra. start at 1
    spcHeightStep:        0L        ,$;heights between returned spectra 
   decimateFactor:        0L        ,$;bandwidth decimation of spectra
    zeroExtdXform:        0L        ,$;1-->zero extend the transform
       firstTxSmp:        0L        ,$;1st tx sample for decoding cnt from 1
           spcLen:        0L        ,$;complex spectral length in record
 decimatedCodeLen:        0L        ,$;cmplx words code after decimation
       spcThisRec:        0L        } ;number of spectra this rec

a={hdrsecclp   ,  id: bytarr(4,/nozero),$; "CLP "  not null terminated
              ver: bytarr(4,/nozero),$; " 1.0"
	 ippsAvg1Freq:        0L	    ,$;how many spectra added incoherently
        numIfFreq:        0L        ,$;1 or 2 if 400/460 switching
       numHeights:        0L        ,$;# of height spectra requested
     spc1stHeight:        0L        ,$;height index of 1st spectra. start at 1
    spcHeightStep:        0L        ,$;heights between returned spectra 
   decimateFactor:        0L        ,$;bandwidth decimation of spectra
    zeroExtdXform:        0L        ,$;1-->zero extend the transform
       firstTxSmp:        0L        ,$;1st tx sample for decoding cnt from 1
           spcLen:        0L        ,$;complex spectral length in record
 decimatedCodeLen:        0L        ,$;cmplx words code after decimation
       spcThisRec:        0L        ,$;number of spectra this rec
             fill:        0L        } ;msulzer added 1 word
;-----------------------------------------------------------------------------
; sps generated buffer header section
; notes:
;-  id in the spsbgsection is:           "SPBG"
;
a={hdrspsrcvwin ,$
      startUsec: 0.   ,$;usecs since start of rf pulse
     numSamples: 0L   ,$;total # of samples in the window
  numSamplesCal: 0L   } ;#  of  cal samples in the window

a={hdrsecspsbg ,  id: bytarr(4,/nozero),$; "SPBG"  not null terminated
              ver: bytarr(4,/nozero),$; " 2.0"
              ipp:        0.        ,$;ipp in usecs
               gw:        0. 	    ,$;gw  in usecs
          baudLen:        0.        ,$;baudlen in usecs or 0 if no baud
        bwCodeMhz:        0.        ,$;1/baud or bw if no baud
      codeLenUsec:        0.        ,$;code length in usecs
      txIppToRfOn:        0.        ,$;txipp start to 1st rfOn
            rfLen:        0.        ,$;rf on to last rfOff in usecs
      numRfPulses:        0L        ,$;# of rfPulses
           mpUnit:        0.        ,$;multipulse unit in usecs(codeLenUsecs)
            mpSeq:   lonarr(20)     ,$;multipulse sequence in multipulse units
         codeName:    bytarr(20,/nozero),$;name of code used
     smpInTxPulse:        0L        ,$;samples in txPulse
        numRcvWin:        0L        ,$;# of rcv windows used
           rcvWin: replicate({hdrspsrcvwin},5)}; receive window info
;-----------------------------------------------------------------------------
; here are the program headers
;
a={hdrPwr	, std:{hdrstd} ,$
		       ri:{hdrriV2},$
			  pwr:{hdrsecpwr},$
			  sps:{hdrsecspsbg}}

a={hdrClp	, std:{hdrstd} ,$
		       ri:{hdrriV2},$
			  clp:{hdrsecclp},$
			  sps:{hdrsecspsbg}}
;
; note.. topside and mracf have the same header but stdheader has
;         topside rather than mracf in the progId
;
a={hdrTpsd , std:{hdrstd} ,$
		       ri:{hdrriV2},$
			 tpsd:{hdrsecmracf},$
			  sps:{hdrsecspsbg}}

a={hdrMracf , std:{hdrstd} ,$
		       ri:{hdrriV2},$
			mracf:{hdrsecmracf},$
			  sps:{hdrsecspsbg}}

a={hdrRd    , std:{hdrstd} ,$
		       ri:{hdrriV2},$
			  sps:{hdrsecspsbg}}
