;+
;NAME:
;cormask - interactively create a mask for each correlator board
; 
;SYNTAX: cormask,b,cmask,edgefract=edgefract
;
;ARGS:   
;       b: {corget} correlator data
;KEYWORDS:   
;   edgefract[n]: float . if provided then create a mask ignoring
;                     lagsPerSbc*edgefract lags on each edge of the bandpass. 
;                     In this case the routine returns immediately with no
;                     user interaction.
;                     If edgeFraction is a single number, then use it
;                     on both sides of the bandpass. If n=2 then
;                     use edgefraction[0] for the left side and
;                     use edgefraction[1] for the right side.
;                     
;RETURNS :
; cmask  : {cormask} structure holding a mask for each board
;
;DESCRIPTION:
;   cormask lets the user interactively create a mask for each board of 
;a correlator dataset. The routine will pass back a cormask structure that 
;contains 1 mask for each board. If the user does not specify a mask for a
;sbc, the last mask entered will be duplicated. If no masks are ever defined,
;then masks with all 1's will be returned. The program menu is:
;
; KEY  ARGS     FUNCTION
; m             .. define mask for current board
; h       h1 h2 .. change horizontal scale for plot to h1,h2
; v       v1 v2 .. change vertical  scale for plot to v1,v2
; b     boardnum.. board number to process (1..nbrds)
; q             .. quit
;
;By default the first board is displayed on entry. The user should adjust the 
;horizontal and vertical scale with h h1 h2 and v v1 v2. Each time one of
;these is entered the plot will be redisplayed with the new limits 
;(do not use commas here..).
;
;When the plot shows the correct limits, enter m to define the mask. The
;leftmost mouse button is used to define the starting and ending portions 
;of the data that will be used for the mask. You can have as many of these
;sections as you want. When you are done with the mask, click the right
;mouse button. The routine will then autoincrement to the next board. You
;can change the order of the next board or redo a board with the b key.
;
; q  is how you exit the routine.
;
; Suppose you have 2 boards with 1024 and 2048 lags. Then the cormask structure
;returned will be:
;
;   int cmask.b1[1024]
;   int cmask.b2[2048]
;
;It is an anonymous structure whose elements will change depending on the
;{corget} structure passed in.
;-
;history:
pro cormask,b,cmask ,edgefract=edgefract
; 
;    on_error,2
    common colph,decomposedph,colph
    nbrds=n_tags(b)
    case nbrds of
        1 : cmask={b1:fltarr(b[0].b1.h.cor.lagsbcout)}
        2 : cmask={b1:fltarr(b[0].b1.h.cor.lagsbcout) ,$
                   b2:fltarr(b[0].b2.h.cor.lagsbcout)}
        3 : cmask={b1:fltarr(b[0].b1.h.cor.lagsbcout) ,$
                   b2:fltarr(b[0].b2.h.cor.lagsbcout) ,$ 
                   b3:fltarr(b[0].b3.h.cor.lagsbcout)}
        4 : cmask={b1:fltarr(b[0].b1.h.cor.lagsbcout) ,$
                   b2:fltarr(b[0].b2.h.cor.lagsbcout) ,$ 
                   b3:fltarr(b[0].b3.h.cor.lagsbcout) ,$ 
                   b4:fltarr(b[0].b4.h.cor.lagsbcout)}
    endcase
    if n_elements(edgefract)  ne 0 then begin 
        edg1=edgefract[0]
        edg2=edgefract[0]
        if n_elements(edgefract) gt 1 then edg2=edgefract[1]
        for i=0,nbrds-1 do begin
            nlags=n_elements(cmask.(i))
            i1=((long(edg1*nlags+.5)) > 0) < (nlags/2-1)
            i2=((long(edg2*nlags+.5)) > 0) < (nlags/2-1)
            i2=nlags-i2-1
            if i1 le i2 then cmask.(i)[i1:i2]=1.
        endfor
        return
    endif
    !p.multi=0
    !x.style=1
    !y.style=1
    ldcolph                     ; load the color map
    lnstyle=2
    colmask=5
    brdsdone=intarr(nbrds)
    curbrd=0
    maskHght=.25
    lastReq=' '
    newbrd=1
    maskCur=fltarr(4096)+1.
    brdsToDo=['brd1 ','brd2 ','brd3 ','brd4 ']
    if nbrds lt 4 then brdsToDo[nbrds:*]=''
    while 1 do begin
        if newbrd then begin
            nlags=b.(curbrd).h.cor.lagsbcout
            nsbc=b.(curbrd).h.cor.numsbcout
            x=findgen(nlags)
            if nsbc gt 1 then begin
                y =b.(curbrd).d[*,0]
                y2=b.(curbrd).d[*,1]
            endif else begin
                y=b.(curbrd).d[*,0]
            endelse
            newbrd=0
        endif
        plot,x,y,_extra=e,/ystyle,/xstyle,title='current board:'+$
                string(curbrd+1)
        if nsbc gt 1 then oplot,x,y2,color=colph[2]    
        if (brdsdone[curbrd]) then begin
           oplot,x,cmask.(curbrd)*(!y.crange[1]-!y.crange[0])*maskHght + $
           !y.crange[0],_extra=e,color=colph[colmask],linestyle=2
        endif

        print,' '
        print,'KEY  ARGS     FUNCTION'
        print,'m          .. define mask'
        print,'h    h1 h2 .. change horizontal scale for plot to h1,h2'
        print,'v    v1 v2 .. change vertical  scale for plot to v1,v2'
        print,'b    brd   .. switch to board..1->nboards'
        print,'q          .. quit'
        print,'     current board:',curbrd+1
        print,'      brdsLeftToDo:',brdsToDo
        line=' '
        read,'?',line
        line=strtrim(strlowcase(line),1)
        itemp=strpos(line,' ')
        len=strlen(line)
        if (itemp ne -1) and ((itemp+1) le len) then begin
            lineargs=strmid(line,itemp+1,len-(itemp))
        endif else begin
            lineargs=''
        endelse
;
        newboard=0
        case strmid(line,0,1) of
            'q': goto,done
            'm': begin
                 print,'use cursor to specify mask'
                 if nsbc gt 1 then begin
                    istat=blmask(x,y,maskCur,_extra=e,y2=y2)
                 endif else begin
                    istat=blmask(x,y,maskCur,_extra=e)
                 endelse
                 if istat eq 1 then begin
                    brdsToDo[curbrd]=' '
                    brdsdone[curbrd]=1  
                    cmask.(curbrd)=maskCur
                    ind=where(brdsdone eq 0,count)
                    if count gt 0 then begin
                        curbrd=ind[0]
                        newbrd=1
                    endif
                 endif
                 end
            'h': begin
                  if lineargs ne '' then begin
                    reads,lineargs,h1,h2
                     hor,h1,h2
                 endif else begin
                     hor
                 endelse
                 end
            'v': begin
                  if lineargs ne '' then begin
                    reads,lineargs,v1,v2
                     ver,v1,v2
                 endif else begin
                     ver
                 endelse
                 end
            'b': begin
                  if lineargs ne '' then begin
                    reads,lineargs,i
                    if (i gt 0) and (i le nbrds) then begin
                        curbrd=i-1
                        nlags=b.(curbrd).h.cor.lagsbcout
                        x=lindgen(nlags)
                        y=b.(curbrd).d[*,0]
                        newbrd=1
                    endif
                  endif
                end
            else:print,'bad input.. enter:m,h,v,b, or q'
        endcase
botloop:
    endwhile
done:
; 
;   fill in any undone boards with the last mask
;
    for i=0,nbrds-1 do begin
        if brdsdone[i] eq 0 then begin
            cmask.(i)=maskCur
        endif
    endfor
    return
end
