function get_xlegendre, xin, xmin=xmin, xmax=xmax, nxd=nxd


;+
;NAME:
;GET_XLEGENDRE -- transform XIN to optimum range of x valuesfor legendre fitting
;(called XLEGENDRE). For details of the legeenddre fittting, see the doc for
;'legendrefit.pro'

;For Legendre fitting, the XLEGENDRE must lie between -1 and 1. This
;procedure resacles XIN to an optimum range and also provides the
;scaling parameters. If the scaling has not yet been determined, this
;proc determines the scaling from the input array XIN and provides the
;one-to-one corresponding XLEGENDRE values as output; it also provides the
;scalling parameters XIN_MIN, XIN_MAX, and N_XIN. If the scaling has been
;determined, you provide the scaling parameters and the values of XIN,
;and it provides XLEGENDRE.

;If the XIN are uniformly spaced, then the optimum arrangement is for
;the end points of the XLEGENDRE to lie half a bin away from the (-1,1) ends.

;If the XIN are nonuniformly spaced, then we adopt a reasonable
;compromise in which the end points are half a bin away and the nr of
;bins is equal to the nr of XIN values. 
;
;CALLING SEQUANCE:
;	RESULT= get_xlegendre( xin, xmin=xmin, xmax=xmax, nxd=nxd)
;
;If xmin, xmax, and nxd are equal to zero or unspecified, then the proc
;uses the XIN values to obtain XLEGENDRE. If these optional inputs are
;specified, then you can enter any arbitrary XIN and the proc applies
;the supplied scaling parameters to obtain XLEGENDRE.
;
;INPUTS:
;	XIN, the x values for which transformed valuse of XLEGENDRE are desired

;OPTIONAL INPUTS, OR VALUES SUPPLIED
;	XMIN, the minimum value of X for the transformation
;	XMAX, the maximum value of X for the transformation
;	NXD, the number of data points used in the scaling. 
;
;OUTPUT:
;	XLEGENDRE, the transformed values of the inputs.  For a uniformly
;spaced array containing NRT elements, the values of XLEGENDRE lie between
;[-(nrt-1)/nrt] and [+(nrt-1)/nrt]
;
;HISTORY - simplfied and documented 13jul2007 by CH
;-

if keyword_set( xmin) eq 0 and keyword_set( xmax) eq 0 and $
  keyword_set( nxd) eq 0 then begin
xmax= max( xin)
xmin= min( xin)
nxd= n_elements( xin)
endif

xdiff= xmax- xmin
xsum= xmax+ xmin
xlegendre= (nxd- 1.d)* (2.d* xin- xsum)/( xdiff* nxd)
return, xlegendre

end

