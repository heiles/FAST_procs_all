;+
;NAME:
;pdevgethdr - read a pdev header from file
;SYNTAX: istat=pdevgethdr(lun,hdrpdev,hdrsp1,hdrao,pdevver)
;ARGS:
;   lun: int            for file to read
;RETURNS:
;   istat: 0  got headers
;          -1 could not read file
;          -2 file does not contain a header
;          -3 not an sp1 file header (maybe an rdev file?)
;hdrpdev: {}   pdev main header
;hdrsp1 : {}   sp1 header
;hdrao  : {}   ao hdr
;pdevver: int  version number 1,2, ...
;
;DESCRIPTION:
;	Read the pdev header from the pdevfile. The file has already
;been open (with lun  the logical unit number for the open file).
;	This routine is normally called only by pdevopen();
;-
function pdevgethdr,lun,hdrpdev,hdrsp1,hdrao ,pdevver
;

;
;   get the file header read 32*8 longs of version2
;
	on_ioerror,ioerror
    point_lun,lun,0          ;position to start of file
    hdrpdev={pdev_hdrpdev}
    readu,lun,hdrpdev
;
;   check the magic number
;
	pdevhdrao_present=0
    PDEVHDR_AO_MAGIC_VAL='12345678'XUL
    case (hdrpdev.magic_num) of 
;
;       if version 1 reposition to end of 8th long, 
    'deadbeef'xul: begin        ; version 1
                point_lun,lun,4*8 ; only 8 longs version 1
;                     last one is fill array do it separately
                for i=8,n_tags(hdrpdev)-2 do  hdrpdev.(i)=0L
                for i=0,n_elements(hdrpdev.fill)-1 do  hdrpdev.fill[i]=0L
                pdevver=1
                   end
    'feffbeef'xul: begin
                pdevver=2
				if hdrpdev.pdevaomagic eq PDEVHDR_AO_MAGIC_VAL then $
	 				pdevhdrao_present=1
                end
    else:          begin
				return,-2			; not a pdev header
                   end
    endcase

    MAGIC_SP1_VAL='2e83fb01'XUL
    if (hdrpdev.magic_sp ne magic_sp1_val) then begin
        return,-3
    endif
;
;   then get the sp header
;
    hdrsp1={pdev_hdrsp1}
    readu,lun,hdrsp1
;
;  if pdevhdr_ao present, get it and update strings
;
	if pdevhdrao_present then begin
		hdraob={pdev_hdraob}
		hdrao ={pdev_hdrao }
        readu,lun,hdraob
		struct_assign,hdraob,hdrao
		hdrao.hdrver  =string(hdraob.hdrver)
		hdrao.object  =string(hdraob.object)
		hdrao.frontEnd=string(hdraob.frontEnd)
	endif else begin
		hdrao ={pdev_hdrao }
		hdrao.hdrver=''
	endelse
    return,0
ioerror:
	on_ioerror,NULL
	return,-1
end
