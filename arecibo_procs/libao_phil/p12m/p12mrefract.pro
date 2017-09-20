;+
;NAME: p12mmodelrefract - compute refraction correction;
;SYNTAX: elRD=p12mmodelrefract(elD);
;ARGS:
;elD[n]: float/double elevation in degreed
;RETURNS:
;elDR[n]: double  refraction corrected elevation (in deg)
;-
function p12mrefract,elD

	ddtor=!dpi/180d
	return,(elD + (.0019279D + $
             1.02D/(tan(ddtor*(elD + (10.3D/(elD+5.1D))))))/60d)
end

