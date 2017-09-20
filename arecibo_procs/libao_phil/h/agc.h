;
; include file to define cblk ,fblk for vertex 
; there is the structure that maps into vertex definition:
;	cbInp,fbINp,cbfbInp
; then there are the structures that have been converted to
; normal units (degs, etc..)
;  cb,fb,cbfb
;
; 	input cblk in input format
;
a={cbInp ,  		      $
    timeMs			: 0L ,$; time in millisecs
    tmoffsetPTMs    : 0L ,$; time offset in millisecs
    freePTpos       : 0U ,$; freeprogram track stack positions
    genStat         : 0U ,$; general status
    modeAz          : 0U ,$; mode azimuth*/
    statAz          : 0U ,$; status azimuth
    modeGr          : 0U ,$; mode gregorian
    statGr          : 0U ,$; status gregorian
    modeCh          : 0U ,$; mode carriage house
    statCh          : 0U ,$; status carriage house
	vel             :intarr(3),$;velAz ,gr,ch 10^-4 deg/sec
    fill            : 0  ,$; to align sunstructs
    pos             :lonarr(3) }; az,gr,ch       position 10^-4 deg
;
; full block ..
;
a= {fbAxisInfo ,		  $
	  auxMode		: 0U ,$; if a motor/group shut down
      ampStat       : 0U ,$; amplifier status
      motorStat     : 0U ,$; motor status
      equipStat     : 0U }; equipment status

a= { fbInp ,            $
      timeMs        : 0L ,$; time in millisecs
	  ax            : replicate({fbaxisInfo},3),$; az,gr,ch
	  encPos        : lonarr(4),$; az1,az2,gr,ch
 
      measTorqAz    : uintarr(8), $;mot  11,12,51,52,41,42,81,82*/
      measTorqGr    : uintarr(8), $;mot  11,12,21,22,31,32,41,42*/
      measTorqCh    : uintarr(2), $;mot  1,2
 
      plcInpStat    : bytarr(20), $; input status bytes plc
      plcOutStat    : bytarr(24), $; ouput status bytes plc
	  posSetPnt     : lonarr(3) , $; pos setpoint az,gr,ch
	  velSetPnt     : intarr(3) , $; 4.06910^-4 az, e-5 gr,ch deg/sec
 
      bendingCompAz : 0 		, $;
      torqueBiasGr  : 0 		, $;
      gravityCompGr : 0 		, $;
      torqueBiasCh  : 0 		, $;
      gravityCompCh : 0 		, $;
 
	  posLim        : lonarr(2,3),$;[(pos,neglim),(az,gr,ch)]
	  encCor        : lonarr(3) , $; encoder correction az,gr,ch
      tmoutNoHostSec: 0			, $;
      fill          : bytarr(2) , $;
      tmElapsedSec  : 0L		}  ; elapsed time counter

a= {cbfbinp ,				$
		cb	 : {cbInp}, $;
		fb	 : {fbInp} };
;
; converted to float
;
a={cb ,              $
    time            : 0.D ,$; time in millisecs
    tmoffsetPT      : 0. ,$; time offset in secs
    freePTpos       : 0U ,$; freeprogram track stack positions
    genStat         : 0U ,$; general status
	mode			: uintarr(3),$; az,gr,ch
	stat			: uintarr(3),$; az,gr,ch
	vel			    : fltarr(3),$; az,gr, ch deg/sec
	pos			    : fltarr(3) } ; az,gr,ch degrees.

a= { fb ,            $
      time          : 0.D ,$; time in secs
      ax            : replicate({fbAxisInfo},3),$; axis info az,gr,ch
	  azEncDif      : 0. ,$; azEnc1-azEnc2 (deg)
      tqAz    : fltarr(8), $;mot  11,12,51,52,41,42,81,82*/
      tqGr    : fltarr(8), $;mot  11,12,21,22,31,32,41,42*/
      tqCh    : fltarr(2), $;mot  1,2

      plcInpStat    : bytarr(20), $; input status bytes plc
      plcOutStat    : bytarr(24), $; ouput status bytes plc
      posSetpnt     : fltarr(3) , $; az,gr,ch deg
      velSetPnt     : fltarr(3) , $;  deg/sec
      bendingCompAz : 0         , $;
      torqueBiasGr  : 0         , $;
      gravityCompGr : 0         , $;
      torqueBiasCh  : 0         , $;
      gravityCompCh : 0         , $;

	  posLim	    : fltarr(2,3),$; (max,min) az,gr,ch
      encCor        : fltarr(3)  ,$; az,gr,ch
      tmoutNoHostSec: 0         , $;
      tmElapsedSec  : 0L        }  ; elapsed time counter

a= {cbfb ,      $
	cb	: {cb} ,$
	fb	: {fb} }

a={agcarch,$
	jd : 0d    ,$; julian day to milli sec accuracy
	az : 0.    ,$; degrees (dome side)
	gr : 0.    ,$; degrees
	ch : 0.    }; degrees
