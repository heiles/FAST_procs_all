pro gbt_to_ao, quan

;+
;PURPOSE:
;
;	take the ordering of the strips at gbt and convert them to
;those at arecibo. this is required so that the inputs to the beam
;analysis programs conform to the original arecibo-style ls fits.
;
;	quan is an array of [nrptsperstrip, 4]. there are 4 strips.
;the 4 strips have to be in the proper order, and the directions of
;increasing az,za have to be in the proper order. for the gbt data, it is
;only necessary to interchange quan[ *,2] and quan[ *,3] (fortunately!).
;-

;THE FOLLOWING WAS FOR ROSHI'S SCRIPT...
;quan[ *,1]= reverse( quan[ *,1])

;THE FOLLOWING IS FOR THE NEW SCRIPT...
quan_old= quan

quan[ *,0]=  reverse( quan_old[ *,0])
quan[ *,1]=  quan_old[ *,2]
quan[ *,2]=  reverse( quan_old[ *,1])
quan[ *,3]=  quan_old[ *,3]


return
end


