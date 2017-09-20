;+
;NAME:
;cgenpath - return path for cgen data
;SYNTAX: path=cgenpath()
;RETURNS:
;   path  : string path to cgen data
;DESCRIPTION:
;   return the path to the cgen data. Trailing / is in included.
;-
function cgenpath
;
	return,"/share/phildat/cummings/"
end
