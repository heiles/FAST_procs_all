function avg_angles, angles, avg

;+
;function avg_angles(angles, avg)
;
;input is angles, an array of angles. units are DEGREES
;function returns avg, the vector avg of the angles.
;-

x = total( cos( !dtor*angles))
y = total( sin( !dtor*angles))
avg= !radeg* atan( y,x)

return, avg
end
