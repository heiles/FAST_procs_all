;+
;NAME:
;pfcorimgonoff - make images of all on/off pairs in a file.
;SYNTAX: sl=pfcorimgonoff(lun,sl=sl,ver=ver,clip=clip,col=col)
;ARGS:
;       lun  :  int      logical unit number that points to file.
;KEYWORDS:
;       sl[] : {sl}   scan list array. If the user has already created a
;                     scan list of this file (getsl) then you can pass it in
;                     here so the call will not do it again.
;      ver[2]: float  vertical scale (min,max) for the line plot superimposed
;                     on the image: (on/off -1)-median(on/off-1). The default
;                     value is .005 Tsys.
;     clip[2]: float  min/max clipping value for the image (on/off-1).;
;                     The default value is .02 Tsys
;      col[2]: int    columns of image to use for flattening in the time 
;                     direction.. 0 through nchannels-1.
;RETURNS:sl[]: {sl}   return the scan list made by this routine (or the
;                     one passed in).
;DESCRIPTION:
;   The routine will first scan the entire file looking for all of the on/off
;pairs. It will then call corimgonoff() for each pair found. After
;displaying the image the user will be prompted to continue or quit. It will
;return the scan list made by the call. If you recall the routine with the
;same file, then you can pass in this sl array to speed up the processing
;(it takes a while to scan the file).
;
;   Before calling the routine be sure and call xloadct and setup the
;lut for greyscale. 
;
;EXAMPLES:
;   xloadct         .. then click on bw-linear for greyscale.
;   openr,lun,'/share/olcor/corfile.07jan02.a1511.2',/get_lun
;   .. show all of the images using the default settings. Scan the file
;      the first time.
;   sl=pfcorimgonoff(lun)
;   .. rerun the above using channels 900,950 to flatten the image
;      in the time direction. Rescale the line plot so the maximum is
;      .002 Tsys (the default was .005). Pass in the sl array we got from
;      the last call so we don't have to rescan the file.
;   sl=pfcorimgonoff(lun,sl=sl,ver=[-.002,.002],col=[900,950]
;   
;SEE ALSO:
;   corimgonoff
;-
function pfcorimgonoff,lun,sl=sl,ver=ver,col=col,clip=clip
;
    on_error,1
    if n_elements(sl) eq 0 then sl=getsl(lun)
;
; find all of the ons..
;
    indon=where(sl.rectype eq 3 ,count)
    if count le 0 then goto,nopairs
;
;   make sure an off follows the on and has the same number of records..
;
    ind=     where((sl[indon+1].rectype eq 4) and $
            (sl[indon].numrecs eq sl[indon+1].numrecs),count)
    if count le 0 then goto,nopairs
    indon=indon[ind]
;
;   loop through all of the pairs.
;
    print,'found ',n_elements(indon), 'pairs'
    for i=0,n_elements(indon)-1 do begin
        scan=sl[indon[i]].scan 
        ball=corimgonoff(lun,scan,/red,/han,sl=sl,ver=ver,col=col,clip=clip)
        print,'xmit or q'
        test=' '
        read,test
        if test eq 'q' then goto,done
    endfor
done:
    return,sl
nopairs:
        print,'no on/off pairs found in file'
        return,sl
end
