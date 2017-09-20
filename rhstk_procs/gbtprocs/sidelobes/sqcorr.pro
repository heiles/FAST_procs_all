pro sqcorr, derivs, pa, delx_squint, squintangle, delx_squash, squashangle, $
squint, squash, thetaconst=thetaconst, thetamult=thetamult, theta_eq=theta_eq
;+
; NAME: SQCORR
;
; PURPOSE: predict squint and squash given angular derivatives and pa
;
; INPUTS: 
;DERIVS, the set of angular derivatives in order T0, dT/d(delta_x),
;dT/(delta_y), d2T/d(delta_x)2, d2T/d(delta_y)2,
;d2T/d(delta_x)d(delta_y) where delta_x, delta_y are great circle derivs
;in ra, dec respectively. This is the same order as the output of {\tt
;get_derivs_ch.pro}. if THIRD was set when deriving the derivatives in
;FIT_Z17, then the four third derivatives are appended to DERIVS,
;meaning that DERIVS has 10 elements instead of 6.
;
;PA, the set of parallactic angle at which to evaluate the squint and squash
;(these are used only if theta_eq is not set). units: DEGREES
;
;DELX_SQUINT, SQUINTANGLE, DELX_SQUASH, SQUASHANGLE, the
;beamsquint/squash amplitudes and angles. amplitudes in same units as
;derivs (which, for our pgms, is arcminutes), angles in DEGREES. These
;are the same units returned by squintfit_1420_aug2008.pro and
;squashfit_1420_aug2008.pro

;OPTIONAL INPUT: 
;
;THETA_EQ. These are the set of angles in equaatorial coordinates, units
; DEGREES. If these are given, the routine uses these. If they are not
; given, it calculates theta_eq from the sset of PA.  units: DEGREES
;
;SEE PROGRAM FOR OTHER OPTINAL INPUTS!!!!!
;
; OUTPUTS:
;SQUINT, the predicted sqint contribution averaged over the set of pa or theta_eq
;SQUASH, the squash contribution averaged over the set of pa or theta_eq
;
; MODIFICATION HISTORY:
;carlh, 17aug 2007. opinal input THETA_EQ added 27jun2008
;CH 9 aug2008, inserted theta_eq definition (see below)...
;-

if n_elements( thetaconst) then tconst= thetaconst else tconst= 0.
if n_elements( thetamult) then tmult= thetamult else tmult= 1.

;inserted the following 09aug2008...
if n_elements( theta_eq) eq 0 then theta_eq= 180.- pa

;assume that the important angle is 90 deg + pa...
if n_elements( theta_eq) eq 0 then begin
   theta_squint= !dtor* ( tconst+ tmult* pa- squintangle)
   theta_squash= !dtor* ( tconst+ tmult* pa- squashangle)
   endif else begin
   theta_squint= !dtor* ( theta_eq- squintangle)
   theta_squash= !dtor* ( theta_eq- squashangle)
endelse

;theta= theta_squint
;twotheta= 2.*theta_squash

;theta= !dpi* ( tconst+ tmult* pa+ squintangle)/180.d0
;twotheta= !dpi* 2.*( tconst+ tmult* pa+ squashangle)/180.d0
;derivs= double( derivs)
;delx_squint= double( delx_squint)
;delx_squash= double( delx_squash)

;get nr of chnls...
nchan= (size( derivs)) [1]

squint= fltarr( nchan)
squash= fltarr( nchan)
;squint1= fltarr( nchan)
;squash1= fltarr( nchan)


;;METHOD 1...ANALYTICAL SQUINT/SQUASH...
;;for nch= 0, nchan-1 do begin
;for nch= 100, 100 do begin
;squint[ nch]= total( derivs[ nch, 1]* 2.* cos( theta_squint) + derivs[ nch, 2]* 2.* sin( theta_squint) )
;squash[ nch]= total( ( derivs[ nch, 3]- derivs[ nch, 4])* cos( 2.*theta_squash)+ derivs[ nch, 5]* 2.* sin( 2.*theta_squash) )
;endfor
;squint= squint* delx_squint/n_elements( theta_squint)
;squash= squash* delx_squash^2/n_elements( theta_squint)

;METHOD 2...DIRECT CALC...ANALYTICAL SQUINT/SQUASH...
dx_squint= delx_squint* sin( theta_squint)
dy_squint= -delx_squint* cos( theta_squint)
dx_squash= delx_squash* sin( theta_squash)
dy_squash= -delx_squash* cos( theta_squash)

for nch= 0, nchan-1 do begin
;for nch= 100, 100 do begin
squint[ nch]= total( $
              z17_eval( reform(derivs[ nch,*]), dx_squint, dy_squint) - $
              z17_eval( reform(derivs[ nch,*]), -dx_squint, -dy_squint) )
squash[ nch]= total( $
              (z17_eval( reform(derivs[ nch,*]), dx_squash, dy_squash) + $
               z17_eval( reform(derivs[ nch,*]), -dx_squash, -dy_squash) ) - $
              (z17_eval( reform(derivs[ nch,*]), -dy_squash, dx_squash) + $
               z17_eval( reform(derivs[ nch,*]), dy_squash, -dx_squash) ) )
endfor
squint= squint/ n_elements( dx_squint)
squash= squash/ n_elements( dx_squash)

;stop

return
end
