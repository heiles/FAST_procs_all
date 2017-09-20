;+
;NAME:
;velLsrProj - lsr velocity along a given direction in J2000 .
;SYNTAX: projVel=velLsrProj(dirJ2000,helioVelProj,packed=packed)
;ARGS:
;   dirJ2000[3] : double 3 vector for J2000 position (unless packed keyword
;                        set.
;   helioVelProj: double The observers heliocentric velocity projectd
;                        along the dirJ2000 direction units:v/c
;KEYWORDS:
;   packed:       if set then dirJ2000 is an array of 2 that holds
;                        [hhmmss,ddmmss] ra and dec.
;RETURNS:
;   projVel     : double observers lsr velocity projected onto the direction.
;                        units: v/c. Positive velocities move away from the
;                        coordinate center.
;DESCRIPTION
;
;Return the projected lsr velocity for an observer given the direction
;in J2000 coordinates and their projected helioCentric velocity
;(see velGHProj).
;output:
;The position for the lsr is:
;         ra          dec
;1900  18:00:00,dec:30:00:00
;J2000 18:03:50.279,30:00:16.8 from rick fischer.
; raRd:4.7291355  decRd: 0.52368024
;
; Then I converted from angles to 3vec and multiplied by 20km/sec / c
;
;EXAMPLE:
;   Suppose you observered an object with 8km/sec topocentric doppler
;shift, but you really wanted 8 km/sec lsr doppler shift. Here's how to
;fix it (and that's why i wrote this!):
;1. get the ra,dec J2000 from the pntheader.
;   raRd =b.b1.h.pnt.r.raJcumRd
;   decRd=b.b1.h.pnt.r.decJcumRd
;2. convert to 3 vec
;   vec=anglestovec3(raRd,decRd)
;3. get the observers heliocentric velocity projected onto the direction
;   obshelVel=b.b1.h.pnt.r.HELIOVELPROJ ; this is v/c units
;4. get the projected lsr velocity of observer
;   obsLsrVelProj=velLsrProj(vec,obshelvel) ; this routine
;5. take difference object velocity, user velocity (- since we 
;   are interested in the relative difference of the obj,user)
;   vel=objVel/C - obsLsrVelProj
;6. compute the doppler correction:
;   dopCor=(1./(1.+vel))        ; this is what should have been used.
;7. Get the doppler correction used from the header
;   dopCorUsed=b.b1.h.dop.factor
;8. compute the frequency error we made
;   frqErr=restFreq*(dopCor-dopCorUsed)
;9. The expected line will be at frequency:dopCor*restFreq rather than 
;   the center of the band: dopCorUsed*restFreq
;   cfrSbcUsed
;
;NOTE:
;   To use this routine do a addpath,'gen/pnt' before calling it.
;-
;MODHISTORY:
;20aug02 - checking rick fischers home page i see that the lsr J2000
;          is incorrect. The b1900 position is the same, and the  precesion
;          from B1950 to J2000 matches what NED gives so the problem must
;          be mike davis's precesion of  1900 to 1950B..
;          I updated the routine to the new values and then recompiled
;          the pointing program.
;The position for the lsr is:
;         ra          dec
;1900  18:00:00,dec:30:00:00
;1950B 18:01:53.35 ,29:59:53.1 1900->1950 by mmd
;J2000 18:03:48.579,30:00:05.6 1950B ->j2000 by phil
;Converting to radians gives:
; raRd:4.72901171, decRd:.52362597
; Then i converted from angles to 3vec and multiplied by 20km/sec / c
;
function velLsrProj,dirJ2000,helioVelProj,packed=packed
    forward_function hms1_rad,dms1_rad,anglestovec3

    VEL_OF_LIGHT_KMPS=299792.458
    lsrvelSun=[0.29003057D, -17.31726483D,10.00141095D]
;   lsrvelSun=[0.2878963D , -17.31784326D,10.00047102] ; pre 20aug02

    if keyword_set(packed) then begin
        vec=anglestovec3(hms1_rad(dirJ2000[0]),dms1_rad(dirJ2000[1]))
    endif else begin
        vec=dirJ2000
    endelse
    return,total(lsrvelSun*vec)/VEL_OF_LIGHT_KMPS  + helioVelProj 
end
