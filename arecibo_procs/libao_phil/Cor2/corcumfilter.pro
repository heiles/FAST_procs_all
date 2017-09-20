;+
;NAME:
;corcumfilter - cumfilter a correlator dataset.
;SYNTAX: cmask=corcumfilter(b,limit,lengthfract,edgefract=edgefract)
;ARGS: 
;     b[n]:  {corget} data to cumfilter
;    limit:  float    max deflection to allow
;lengthfract:float    fration of channels to use for filtering.
;KEYWORDS:
;   edgefract: float    fraction of channels to ignore on each side
;                       (in case band pass still present)
;
;  RETURNS: 
;   cmask[n]:{cormask} hold results of cumfiltering. 
;
;DESCRIPTION:
;   cumfilter is a routine written by carl heiles to remove outliers
;from a dataset. The routine:
; 1. sorts the data by amplitude
; 2. selects length points (length=lengthfract*numpoints) 
;    about the center of the sorted list
; 3. keeps all the points within limit*maxdeviation of the length
;    points from the center value.
;   
;   The routine returns a cormask data structure that has a 0 for
;points that were rejected and a 1 for points that were kept.
;   If b[n] is an array of structures then n cormask structures will
;be returned (1 for each element of b).
;
;EXAMPLE:
;   
;   limit=2.
;   length=.5
;   print,corget(lun,b)
;   cmask=corcumfilter(b,rnage,length,edgefract=.08)
;   cmask is a single structure
;
;   You can then use cmask in basline fitting or operations:
;   istat=corbl(b,blfit,maskused,/auto,deg=1,mask=cmask,/sub)
;
;   print,corgetinpscan(lun,b)
;   cmask=corcumfilter(b,limit,length,edgefract=.08)
;   cmask is an array of cmask structures.
;
;WARNING:
;   if b[] is an array , then corcumfilter will create and array of
;masks. Some of the other cor routines (corplot,corstat, etc..) will
;only accept single element cormasks so you need to be careful passing
;any arrays of cmasks to other routines.
;
;-
;modhistory
function corcumfilter,b,limit,lengthfract,edgefract=edgefract
;
;
;on_error,2
;
; create the return mask structure:
;
    nbrds=n_tags(b[0])
    npolar=intarr(nbrds)
    for i=0,nbrds-1 do begin
       npolar[i]=((size(b[0].(i).d))[0] eq 1)?1:2
    endfor
    if not keyword_set(edgefract) then edgefract=.08
    cmask=cormaskmk(b,edgefract=edgefract)
    nrecs=n_elements(b)
    for ibrd=0,nbrds-1 do begin
        ind1=where(cmask.(ibrd)[*,0] gt .1,count)
        len=n_elements(ind1)
        range=lengthfract*len
        for irec=0,nrecs-1  do begin
            if npolAr[ibrd] eq 1 then begin
                cumfilter,b[irec].(ibrd).d[ind1],range,limit,indxgood,indxbad,$
                        countbad
                if countbad gt 0 then cmask[irec].(ibrd)[ind1[indxbad]]=0
            endif else begin
                cumfilter,b[irec].(ibrd).d[*,0],range,limit,indxgood ,indxbad,$
                        countbad
                if countbad gt 0 then cmask[irec].(ibrd)[ind1[indxbad,0]]=0
                cumfilter,b[irec].(ibrd).d[*,1],range,limit,indxgood ,indxbad
                        countbad
                if countbad gt 0 then cmask[irec].(ibrd)[ind1[indxbad,1]]=0
            endelse
        endfor
    endfor
    return,cmask
end
