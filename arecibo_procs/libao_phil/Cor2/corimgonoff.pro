;+
;NAME:
;corimgonoff - make image of an on off pair
;SYNTAX ball=corimgonoff(lun,scan,ver=ver,clip=clip,col=col,red=red,han=han,$
;                        bon=bon,boff=boff,sl=sl,cont=cont,_extra=e,$
;                        brdlist=brdlist,pol=pol)
;ARGS:
;   lun :int    logical unit number for file that is already open.
;   scan:long   scannumber for the on position scan
;KEYWORDS:
;   ver[2]: float vertical scale (min,max) for the line plot superimposed
;                 on the image: (on/off -1)-median(on/off-1). The default
;                 value is +/- .005 Tsys.
;  clip[2]: float min/max clipping value for the image (on/off-1).;
;                 The default value is .02 Tsys
;   col[2]: int   columns of image to use for flattening in the time direction
;                 0 through nchannels-1.
;   han   :       if set,then hanning smooth the data on input
;   bon[] :{corget} pass in on  scan rather than input it
;   boff[]:{corget} pass in off scan rather than input it
;   sl[]  :{sl}   scanlist array returned from sl=getsl(lun) that can be used
;                 for direct access i/o.
;  red    :       if set then the on/off-1 graph will be red rather than 
;                 white
;  cont   :       don't remove the continuum info from on/off-1 plot
; brdlist :       sbc to use. 1,2,12,1234..default is all
; pol     :       to use.1,2 12, default is all
;  _extra : e     pass args to corimgdisp
;RETURNS:
;   ball[]:{corget} all of the on,off records.
;
;DESCRIPTION:
;   corimgonoff will read in an on/off position switch pair of scans from
;the file pointed to by lun. scan should be the scan number for the on
;position. It will then call corimgdisp passing in the on and off records
;so an image of frequency versus records will be made for each board.
;The off records will be used for the bandpass normalization for the entire
;image. Time for each image goes from bottom to top so the on records start 
;at the bottom of each image.
;
;   The routine computes y=(avg(on)/avg(off)-1.) where avg() averages over
;the individual records. If multiple polarizations are present, they will
;also be averaged. The routine then plots:
;   y= y - median(y)
; on top of the corresponding image.
;
;   The options sl,ver,col,han,clip  are passed to corimgdisp. If the
;col=[colmin,colmax] is used to flatten the image in time, then dashed
;lines will be superimposed on the plot showing the range that was used.
;
;   The line plot will normally be done in white (the largest lookup table 
;value). If the /red keyword is set then the line plot will appear as red.
;This looks nicer but it will probably be changed to black if you play with 
;the color lookup table (via xloadct) after making the image.
;
;   The routine pfcorimnonoff will loop through a file calling this
;routine for every onoff pair in the file.
;EXAMPLES:
;   1. default processing:
;     suppose on scan is 127300099L and lun has already been opened.
;     hanning smooth the data. Call getsl() once to get the scanlist for
;     random access.
;       sl=getsl(lun)   
;       scan=127300099L
;       ball=corimgonoff(lun,scan,sl=sl,/han)
;   2. blowup the vertical scale of the line plot and make it red.
;       ball=corimgonoff(lun,scan,sl=sl,/red,ver=[-.002,.002],/han)
;   3. Add to 2., scaling of the image in the time dimension using columns
;      625 through 675 .
;       ball=corimgonoff(lun,scan,sl=sl,/red,ver=[-.002,.002],/han,$
;                       col=[625,675])
;
;SEE ALSO:
;corimgdisp,imgdisp,imgflat,pfcorimgonoff
;-
function corimgonoff,lun,scan,sl=sl,ver=ver,col=col,han=han,red=red,clip=clip,$
                     bon=bon,boff=boff,cont=cont,pol=pol,brdlist=brdlist,$
                    _extra=e
;
    common colph,decomposedph,colph
    on_error,1
    ymin=-.005
    ymax=.005
    cs=1.8
    if n_elements(sl) eq 0 then sl=0
    if not keyword_set(red) then red=0
    if n_elements(ver) eq 2 then begin
        ymin=ver[0]
        ymax=ver[1]
    endif
    if n_elements(col) ne 2 then col=0
    if (n_elements(bon) le 1) and (n_elements(boff) le 1) then begin
        istat =corinpscan(lun,bon ,han=han,sl=sl,scan=scan)
        istat=corinpscan(lun,boff,han=han,sl=sl)
    endif
    nrecson =n_elements(bon)
    nrecsoff=n_elements(boff)
    ball=corallocstr(bon[0],nrecson+nrecsoff)
    ball[0:nrecson-1]=bon
    corstostr,boff,nrecson,ball
    bpc=coravgint(ball[nrecson:nrecson+nrecsoff-1])
    img=corimgdisp(ball,bpc=bpc,yrange=[ymin,ymax],col=col,clip=clip,$
                brdlist=brdlist,_extra=e)
    ver,ymin,ymax
    hor
    nbrds=ball[0].b1.h.cor.numbrdsused
    ldcolph,max=3
    color=2
    if (n_elements(brdlist) eq 0) then begin
        brdlistL=''
        for i=0,nbrds-1 do begin
            brdListL=brdListL + string(format='(i0)',i+1)
        endfor
        nbrdsL=nbrds
    endif else begin
            brdListL=string(brdlist,format='(i0)')
            nbrdsL=strlen(brdListL)
    endelse
    for i=0,nbrdsL-1 do begin
        !p.multi=[nbrdsL-i,1,nbrdsL]
        j=long(strmid(brdlistL,i,1)) - 1
        frq=corfrq(ball[0].(j).h)
        if (ball[0].(j).h.cor.numsbcout eq 2) then begin
            if n_elements(pol) gt 0 then begin
                ipol=0
                if (size(pol,/type) eq 7) then begin
                    if (strlowcase(pol) eq 'a') then ipol=0
                    if (strlowcase(pol) eq 'b') then ipol=1
                endif else begin
                    ipol=pol-1
                endelse
                y=total(ball[0:nrecson-1].(j).d[*,ipol],2)/  $
                  total(ball[nrecson:nrecson+nrecsoff-1].(j).d[*,ipol],2)
            endif else begin
            y=(total(ball[0:nrecson-1].(j).d[*,0],2) + $
               total(ball[0:nrecson-1].(j).d[*,1],2))/ $
              (total(ball[nrecson:nrecson+nrecsoff-1].(j).d[*,0],2) + $
               total(ball[nrecson:nrecson+nrecsoff-1].(j).d[*,1],2))
            endelse
        endif else begin
            y=total(ball[0:nrecson-1].(j).d[*,0],2)/ $
              total(ball[nrecson:nrecson+nrecsoff-1].(j).d[*,0],2)
        endelse
        if not keyword_set(cont) then begin
            y=y-median(y)
        endif else begin
            y=y-1.
        endelse
        plot,frq,y,charsize=cs,color=colph[color],xstyle=5,ystyle=5,/noerase
        if n_elements(col) eq 2 then begin
            flag,[frq[col[0]],frq[col[1]]],linestyle=2,color=colph[color]
        endif
    endfor
    return,ball
end
