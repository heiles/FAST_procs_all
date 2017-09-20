;+
;NAME:
;pltbits  - plot a timing diagram of the input data
;SYNTAX: pltbits,x,y,bitmask,col=col,maxbits=maxbits,over=over,$
;                 off=off,lab=lab,inc=inc,_extra=e,gaps=gaps  
;ARGS:
;   x[] :   x values for the data
;   y[] :   array holding the bits to plot
;bitmask:  long  bits to extract and plot
;
;KEYWORDS:
;   col[]: long colors for each bit to plot
;maxbits : long max number of bits you want to plot. This is used to
;               compute the vertical positioning of the y axis. Use
;               this with off, if you want override the default
;               positioning of the traces.
;   over : if set then overplot from previous call
;   off  : float . add to vertical position of each bit.Default is
;                  .06
;lab[]   : string. labels for each bit.
;gaps    : float   if provided, then an extra trace will be provided at the
;                  top of the plot. Any points that have an x difference
;                  >= gaps will have a transition from 1 to 0. This lets
;                  you see where there is valid data.
;DESCRIPTION:
;   Suppose an int or long array holds status information that is
;packed bit by bit. An example would be the vertex data that has
;motor status bits encoded into a single int. This routine will
;plot 1 or more of the bits versus the x axis..
;EXAMPLE:
;   Suppose dat[100] has status info in bit0 and bit5. To plot them
;versus input use:
; x=finggen(100)
; pltbits,x,dat,'21'x 
;Bit 0 will be plotted versus x with bit 5 plotted above it versus x.
;-
pro pltbits,x,y,bitmask,col=col,maxbits=maxbits,over=over,$
            _extra=e,off=off,inc=inc,lab=lab,loff=loff,gaps=gaps
;
;   see how many bits in bitmask are provided.
;
    common colph,decomposedph,colph
    labfract=.06
    if n_elements(loff) ne 0 then labfract=loff
	
    if not keyword_set(off) then off=0
    if not keyword_set(inc) then inc=2
    if not keyword_set(col) then col=1
	gapsL=(n_elements(gaps) gt 0)?gaps:-1.
	useGaps=gapsL gt 0
    lbitmask=long(bitmask)
    len=n_elements(x)
    overl=0
    if keyword_set(over) then overl=1
    if overl eq 0 then begin
        if not keyword_set(maxbits)  then begin
            mask=1L
            maxbits=0
            for i=0,31 do begin
                if  (mask and lbitmask) ne 0 then maxbits=maxbits+1
                mask=ishft(mask,1)
            endfor
        endif
        ymin=-[inc/2.]
        ymax=(maxbits+1)*(inc)
;		if useGaps then ymax+=inc
;        print,'ymin,max:',ymin,ymax
        plot,[x[0],x[len-1]],[ymin,ymax],/nodata,_extra=e,ystyle=5
    endif
    xlen=[x[len-1]-x[0]]
    mask=1L
    k=0
    for i=0,31 do begin
        if (lbitmask and mask) ne 0 then begin
            val= (mask and y) ne 0
;            print,'val0,off:',val[0],off
            plots,x[0],off,psym=-2,color=colph[col] ; put * at 0 level
            plots,x[0],val[0]+off,color=colph[col]
            is=0
            for j=1L,len-1 do begin
                if (val[j] ne val[is]) then begin 
                    plots,x[j],val[j-1]+off,color=colph[col],/continue
                    plots,x[j],val[j]+off,color=colph[col],/continue
                    is=j
                endif
            endfor
            if val[len-2] eq val[len-1] then plots,x[len-1],val[len-1]+off,$
                        /continue,color=colph[col]
            if n_elements(lab) gt i then begin
                xyouts,x[0]-(xlen*labfract),off+.1,lab[i],color=colph[col]
                k=k+1
            endif
            col= ( col  mod 10 ) + 1
            off=off+inc
        endif
        mask=ishft(mask,1)
    endfor
;
; 	if they want to plot the line with gaps, do it here.
;   we will insert a short section [x[i]+eps,x[i+1]-eps] of zeros
;   between each gap that start at x[i]
;
	if useGaps then begin
        eps=[x[len-1]-x[0]]*1e-4
		ones=lonarr(len) + 1
        xg=x[0]
        yg=1
        xdif=shift(x,-1) - x
        xdif[len-1]=eps*.01			; always include last point
        jmps=(where(xdif ge gapsL,njmps)) > 0 ; start of jumps
        
;       for each jump insert 2 0 entries in xg,yg

        il=0
        if njmps gt 0 then begin
            for ijmp=0,njmps-1 do begin
                    ii=jmps[ijmp]
                    xg=[xg,x[il:ii],x[ii]+eps,x[ii+1]-eps]
                    yg=[yg,ones[il:ii],0,0]
                    il=ii+1
            endfor
            if il le (len-1) then begin
                xg=[xg,x[il:*]]
                yg=[yg,ones[il:*]]
            endif
        endif
;
;  		now plot as a solid line at top with goodDataLabel
;
        plots,x[0],off,psym=-2,color=colph[1] ; put * at 0 level
		if n_elements(xg) lt 2 then begin
			oplot,[0,1e6],[yg[0],yg[0]]+off
	    endif else begin 
			oplot,xg,yg+off
		endelse
        xyouts,x[0]-(xlen*labfract),off+.1,"GoodData",color=colph[1]
    endif
    return
end
