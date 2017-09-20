;+
;NAME:
;coracf - compute the acf from the spectra
;SYNTAX: bacf=coracf(b,/spectra)
;ARGS: 
;     b[n] :  {corget} spectra to convert
;KEYWORDS: 
;   spectra:           if set, then the input is acf's and they want spectra.
;RETURNS:
;   bacf[n]: {corget} spectra converted to acf
;
;DESCRIPTION:
;   Convert the spectra to acf's.
;
;-
;modhistory
;19oct02 - created
;01dec02 - switched to symeterize the acf
;
function coracf,b,spectra=spectra

;
    on_error,2
    nrecs=n_elements(b)
    nbrds=n_tags(b[0])
    bacf=b
    dir=-1
    if keyword_set(spectra) then begin
        dir=1
        fact1=.5
        fact2=1.
    endif else begin
        dir=-1
        fact1=1.
        fact2=2.
    endelse
    for j=0,nbrds-1 do begin
        a=size(b[0].(j).d)
        npol=a[0]
        len =a[1]
        x=complexarr(len*2)
        for i=0,nrecs-1 do begin
            x[0:len-1]=b[i].(j).d[*,0]
            x[len+1:*]=reverse(b[i].(j).d[1:*,0])
            x[len]=x[len-1]
            x[1:*]=x[1:*]*fact1
            bacf[i].(j).d[*,0]=float((fft(x,dir))[0:len-1])
;
;           this next step is needed because:
;           1. we symeterized so this doubled the total power
;           2. fft() with forward direction multplies by 1/N  =(2*len)
;           3. The 0 lag is ok since we multplied the power by 2 then 
;              diviede by 2*len
;           4. the other lags are too small by a factor of 2 since
;              they too get divided by 2*len but there amplitude was not
;              increased by the symeterization.
;              
            bacf[i].(j).d[1:*,0]= bacf[i].(j).d[1:*,0]*fact2
            if npol gt 1 then begin
                x[0:len-1]=b[i].(j).d[*,1]
                x[len+1:*]=reverse(b[i].(j).d[1:*,1])
                x[len]=x[len-1]
                x[1:*]=x[1:*]*fact1
                bacf[i].(j).d[*,1]=float((fft(x,dir))[0:len-1])
                bacf[i].(j).d[1:*,1]= bacf[i].(j).d[1:*,1]*fact2
            endif
        endfor
    endfor
    return,bacf
end
