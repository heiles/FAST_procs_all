;+
;NAME:
;masgetcol - get a col from the fits file
;SYNTAX: n=masgetcol(desc,colNm,data,rows=rows)
;ARGS:
;   desc: {}      struct returned from masopen()
;  colNm: string  name of column. Same as help,b.h,/st structure tags
;                 (except for DATE-OBS, MJD-OBS) see below..
;KEYWORDS:
; rows[2]: long   rows to return. If not supplied then return all rows of 
;                 file. If single element then just return that row.
;                 If two elements then first,last row to return. 
;                 Row numbering starts at 1.
;RETURNS:
;   istat: n  number of rows returned, -1 if error.
;   data[n]:       date returned from file for this column.
;DESCRIPTION:
;	Return individual columns from the fits files. The cols correspond
;to the elements in the header struture returned by masget(desc.b) : b.h
;The colNm passed in should match one of the strucuture tag names of
;b.h. You can list them via: help,b.h,/st. The one  exception is the
;DATEXXOBS AND MJDXXOBS tagnames (see below). 
; 	By default all of the rows of the file are returned. You can limit 
;this by  using the rows= keyword to limit the number of rows returned.
;Row numbers starts at 1.
;	This routine is much faster than cycling through the file with
;masget() since the spectral/stat data is not read in.
;
;NOTES:
;1. It can not be used to return the data stored in the heap
;   . stat, or data. see masgetstat or masget for that.
;2. The two fits file column names: DATE-OBS and MJD-OBS are mapped to 
;   idl structure names .DATEXXOBS, .MJDXXOBS since - is an illegal
;   structure tag name. You need to input the actual fits column names
;   for these two: DATE-OBS and MJD-OBS 
;3. use upper case. 
;4. If rows are specified they start at 1.
;5. see desc.totrows for the number of rows in the file if you need it.
;6. To find the column names, use masget(desc,b) then help,b.h,/st
;-
function masgetcol,desc,colNm,data,rows=rows
;
;
;
	rowsL=-1
	case 1 of 
	 	n_elements(rows) eq 0: rowsL=-1
	 	n_elements(rows) eq 1: rowsL=rows
	 	n_elements(rows) eq 2: rowsL=rows
	 	n_elements(rows) gt 2: rowsL=rows[0:1]
	endcase
	if rowsL[0] ne -1 then begin
		if (rowsL[0] lt 1) or (rowsL[0] gt desc.totrows) then  begin
			print,"Rows are 1..",desc.totrows
			return,-1
		endif
		if (n_elements(rows) eq 2) then begin
		   if (rowsL[1] lt 1) or (rowsL[1] gt desc.totrows) then  begin
			  print,"Rows are 1..",desc.totrows
			  return,-1
			endif
		endif
	endif
	errmsg=''
	if rowsL eq -1 then begin
		fxbread,desc.lun,data,colNm,errmsg=errmsg
	endif else begin
		fxbread,desc.lun,data,colNm,rowsLerrmsg=errmsg
	endelse
	if errmsg ne '' then begin
		print,"masgetcol err:",errmsg
		return,-1
	endif
	return,n_elements(data)
end
