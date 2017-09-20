;+
;pfallocstr - alloc requested elements of hdrscn structure
;SYNTAX: hdrscn=pfallocstr(numtoAlloc)
;ARGS:
;	  numToalloc : long .. number of elements to allocate
;     hdrscn     : {pfhdrstr} alloc here
;-
function pfallocstr,numToAlloc
	return,replicate({pfhdrstr},numToAlloc)
end
