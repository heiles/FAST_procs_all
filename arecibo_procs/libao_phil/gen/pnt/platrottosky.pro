;+
;NAME:
;platrottosky - convert platform rotation to sky rotation.
;SYNTAX: skyRot=platrottosky(za,platRotD,protradius=protradius,retI=retI)
;ARGS:
;   za[n]: float    zenith and in degrees for feed.
;platRotD: float    rotation angle for platform (degrees)
;KEYWORDS:
; protradius: float veritcal distance from paraxial surface (za=0) where
;                   platform rotates. default is 61 feet (close to the
;                   connection plane of the main cables.. 
;RETURNS:
;skyRot[n]: float   Angular motion on the sky (in degrees)
;retI     : {}      return a structure with the za start,za end,
;                   inital platform angle
;
;DESCRIPTION:
;   
;    Given platform rotation angle, compute the angle moved on the sky.
;The rotation angle on the sky is smaller since:
; 1.the radius center of curvature to feed is 435 feet.
; 2.the radius from center of platform rotation to feed is
;   60 to 100 feed (it changes as a function of za).
;
;   I've assumed the rotation is about the plane where the main cables
;connect (giving a vertical distance of 61 feet paraxial surface to center
;of platform rotation). I'm not sure if this is correct or not. 
;If you don't like that value, use the keyword protradius= to change it...
;
;   The value changes slightly with za. You can enter an array for
;za and you will get back an array in skyRot. 
;
;-
function platrottosky,za,platRot,protradius=protradius,retI=retI
;
;
; Coc= center of curvature
; PS = paraxial surface
; PlRP= platform rotation point.
;
nza=n_elements(za)
retI={ $
       radCocToPs: 0.,$
       radCocToPlRp: 0.,$
       zaStart : za,$
       zaEnd   : za,$
       platAngl1: za,$ ; starting platform angle
       x1      : fltarr(nza),$;x hor before move
       y1      : fltarr(nza),$;vertial before move
       x2      : fltarr(nza),$;x hor after move
       y2      : fltarr(nza)};y vertial after move
        
radCocToPS=435.         ; radius to Paraxial Surface 1/2 radius of curvature
;
; if they don't specify a rotation radius, use 61 feet. that is the
; vertical distance from paraxial surface to plane of main cable pins
; at za=0.
;
; distance center of curvature to platform rotation pnt (vertical za=0)
;
radCocToPlRP=(keyword_set(protradius))? radCocToPs-protradius $
                                          : (radCocToPs - 61.)
;
;   x,y position for feed before platform rotation.
;
x1=sin(za*!dtor)*radCocToPS
y1=cos(za*!dtor)*radCocToPS
;
; radius for rotation about platform point o
;
radPlRpToFeed= sqrt(x1*x1 + (y1- radCocToPlRp)^2.)  
;
plAngle   =atan(x1/(y1-radCocToPlRp))*!radeg
plAngleNew=plAngle + platRot

;
; get new x2,y2 position relative to Coc
;
x2=radPlRpToFeed*sin(plAngleNew*!dtor)
y2=radPlRpToFeed*cos(plAngleNew*!dtor) + radCocToPlRp
;
skyRot=atan(x2/y2)*!radeg - za
retI.radCocToPs= radCocToPs
retI.radCocToPlRp= radCocToPlRP
retI.platAngl1   = plAngle
retI.zaStart     = za
retI.zaEnd       = skyRot + za
retI.x1        =x1
retI.y1        =y1
retI.x2        =x2
retI.y2        =y2
return,skyRot
end

