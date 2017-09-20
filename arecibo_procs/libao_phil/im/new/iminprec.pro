;+
;NAME:
;iminprec - input 1 record from the data file
;SYNTAX: iminprec,lun,r
;ARGS:
;	lun: int	 logical unit not for file we are reading
;RETURNS:
;	   r:{imdrec} record of data input 
;DESCRIPTION:
;	Read in the next record from the data file. This routine is normally
;called from the routine iminpday. The returned record contains
; r.h the record header
; r.d the frequency data
;See iminpday for a descrption of the header/data.
;-
pro iminprec, lun,r
;
;
d={imirec}
r={imdrec}
readu,lun,d
if swap_endian(d.h.hdrlen) eq 44 then d=swap_endian(d)
r.h=d.h
r.d=(d.d*.01)
return
end
