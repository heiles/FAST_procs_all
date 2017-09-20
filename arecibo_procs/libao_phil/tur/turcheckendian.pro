;+
;NAME:
;turcheckendian - check whether the data needs to be flipped or not.
;SYNTAX: needsflip=turcheckendian(d)
;ARGS:
;	d	: 	{turloginp} data to check for endian nes..
;RETURNS:
;	needsflip: int	1 need to flip data, 0 data in current machine format.
;DESCRIPTION:
;	turcheckendian will check if the data needs to be flipped (via swap_endian)
;or not.
;=
function turcheckendian,d
;
	if ((d[0].tickMsg.tmMs lt -1)  or (d[0].tickMsg.tmMs gt 86500000L) or $
	   (d[0].dat.aO_velCmd lt 0)  or (d[0].dat.ao_velCmd gt 4096))  then $
		return,1
	return,0
end
