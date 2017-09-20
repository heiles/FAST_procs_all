;+
;NAME:
;pdevinppfb - input polyphase filter bank filter
;SYNTAX: istat=pdevinplpf(filename,len,filter)
;ARGS:
;filename: string : name of file holding filter: pfb.8192.hamming
;len:      int    : length of filter. eg 8192.
;RETURNS:
;istat  : int     : 0 ok, -1 error
;filt[] : int     filter read in. It will be the symmetric about the center.
;DESCRIPTION:
;   Read in a polyphase filter. Pass in the filename (with directory if
;needed). Also include the length of the pfb (eg. 8192).
;Program will input and return the filter.
;
;-
function pdevinppfb,fn,length,filt
;
;   input
;
    overlap=4L
    openr,lun,fn,/get_lun
;
;   loop over the 4 overlap stages
;
    numint=0;
    filt=fltarr(length,overlap)
    for i=0L,overlap-1 do begin
        icur=overlap-1 -i               ; time goes right to left
        point_lun,lun,5L*8192L*i; 5byts/num xxxxNl, section offsets
        for ii=0 , length-1 do begin
            readf,lun,format='(z4)',numint
            filt[ii,icur]=numint
        endfor
    endfor
    free_lun,lun
    filt=reform(filt,length*overlap)
    return,0
end
