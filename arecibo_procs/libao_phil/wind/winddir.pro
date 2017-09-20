;+
;NAME:
;winddir - return the path to the wind directory
;
;SYNTAX: dirname=winddir()
;ARGS:
;RETURNS:
;	dirname: string directory name for wind data. It includes the trailing
;                   /
;DESCRIPTION:
;	Return the directory name for the wind directory:
;EXAMPLE:
;   print,winddir()
;   /share/megs2_u1/wind/
;-
function	winddir
;	
;
;	return,'/share/megs2_u1/wind/'
	return,'/share/phildat/wind/'
end
