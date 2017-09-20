pro getvlsr, freq_line, freq_line_obs, src, vel0, vel1, freq0, freq1, $
             freq_bb= freq_bb, del_chnl=del_chnl

;+
; GETVLSR: get the vlsr vector for freq-sw data
;
; CALLING SEQUENCE:
;       GETVLSR, freq_line, freq_line_obs, src, vel0, vel1, freq0, freq1, $
;             freq_bb= freq_bb, del_chnl=del_chnl
;
;INPUTS:
;       FREQ_LINE: the freq of the line for which you want the vel,
;       units are Hz
;       FREQ_LINE_OBS: the line freq used in the observing script, units
;       are Hz
;       SRC: the array of src structures
;
;OUTPUTS:
;       VEL0, VEL1: the vector of velocities for LO0, LO1 (km/s)
;       FREQ0, FREQ1: the vector of rf freqs in the vel frame (Hz)
;
;KEYWORD OUTPUTS:
;       FREQ_BB, the vector of baseband frequencies. In Hz
;       DEL_CHNL, the freq-switching interval in units of channels
;COMMENTL
;       I'm not sure the src.velocity is correctly done...
;-

lightspeed= 2.9979250d8

freq_bb = src[0].subscan[0].bwsign*$
             ((dindgen(src[0].nchan) $
               / (src[0].nchan-1)-0.5)*src[0].subscan[0].bandwdth)

fswitch= src[0].subscan[0].freq[1]-src[0].subscan[0].freq[0]
delfchnl= src[0].subscan[0].bandwdth/ src[0].nchan
del_chnl= fswitch/ delfchnl

;stop

;freq0= freq_line+ 0.5d0*fswitch+ freq_bb- $
freq0= freq_line_obs+ 0.5d0*fswitch+ freq_bb- $
       freq_line* src[0].velocity/lightspeed
freq1= freq_line_obs- 0.5d0*fswitch+ freq_bb- $
       freq_line* src[0].velocity/lightspeed
;freq0= freq_line_obs+ 0.5d0*fswitch+ freq_bb- $
;       src[0].velocity/1.d5*freq_line/lightspeed
;freq1= freq_line- 0.5d0*fswitch+ freq_bb- $
;freq1= freq_line_obs- 0.5d0*fswitch+ freq_bb- $
;       src[0].velocity/1.d5*freq_line/lightspeed
vel0= 1.d-3*(freq_line- freq0)* lightspeed/ freq_line
vel1= 1.d-3*(freq_line- freq1)* lightspeed/ freq_line

return
end
