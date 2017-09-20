;+
;NAME:
;cormapsclK - scale a map to Kelvins.
;
;SYNTAX: istat=cormapsclK(m,cals,tsys,use1cal=use1cal)
;
;ARGS:   
;   m[pol,smpPerStrip,nstrips] : map array input from cormapinp.
;                  cals[ncals] : cals data input with cormapinp.
;
;KEYWORDS:
;   use1cal:    int 1 or 2. if two cals per strips you can should to use
;                       only the first or 2nd cal by setting use1cal to 1 or 2.
;
;RETURNS:
;                          m.d : will be scaled to kelvins
;  tsys[2,smpPerStrip,nstrips] : average system temp each sample
;                        istat : 1 ok, 0.. trouble
;
;DESCRIPTION:
;  Scale the map data to kelvins. To use this routine the data must
;have been taken with 1 or 2 cals per strip. For each strip in the map
;the cals.calscl scale factor is used to convert from correlator counts
;to kelvins. If two cals per strip were taken then the cal values are
;interpolated across the strip.
;  The original data in m.d is overwritten with the new values.
;The location m.calscl is also updated if we have 2 cals/strip. The 
;interpolated value is used instead of the average that was loaded in
;cormapinp.
;EXAMPLE:
;   istat=cormapinp(lun,scan,brda,brdB,m,cals)
;   istat=cormapsclk(m,cals,tsys)
;
;   When calling this routine, make sure that the data array m is still
;in correlator units (as returned by cormapinp). If you call cormapbc()
;to bandpass correct the data, then the returned data array is no 
;longer in correlator units and this routine should not be used with
;that data array.
; 
;NOTE:
;1.   Since the original data is overwritten, you do not want to run this
;   routine more than once on the same array. The conversion only works if
;   the input data is in correlator counts.
;
;2. This is normally the first routine called.  After calling the routine,
;   you will notice that the system temperatures in tsys are smaller than
;   the central portion of the spectra. This is because the bandpass correction
;   has not yet been done. Tsys is the average of the entire spectra. Since
;   the spectra falls off at the edges (because of the bandpass) the
;   center or the spectra will be higher than the average. You will have
;   the correct temperatures only after the bandpass correction is done (
;   by dividing through by a normalized bandpass). 
;      This implies that scaling to kelvin and then fitting a baseline
;   will not give the correct temperatures. If this is really what is 
;   wanted, then the scaling factor from correlator units to kelvins
;   should be computed over the central part of the spectra.
;   
;-
;modhistory
;31jun00 - checked for corget updates.. no change..
function cormapsclK,m,cals,tsys,use1cal=use1cal
;
;   
    a=size(m)
    nstrips=(a[0] eq 2) ? 1: a[3]
    pntstrip=a[2]
    ncals  =(size(cals))[1]
    nlags  = n_elements(m[0].d)
    if not keyword_set(use1cal) then use1cal=0
    case 1 of 
        (ncals eq nstrips): begin
            interp=0 
            inc=1
            off=0
            end
        ((ncals eq (2*nstrips)) and use1cal eq 0) : begin
             interp=2
             inc=0
             off=0
             end
        ((ncals eq (2*nstrips)) and ((use1cal eq 1) or (use1cal eq 2))): begin
             interp=0
             inc=2
             off=use1cal-1
             end
        else : begin
            print,"cormapscl. numcals !=numstrips or 2*numstrips" 
            return,0
            end
    endcase
    tsys=fltarr(2,pntstrip,nstrips)
    j=off
    for i=0,nstrips-1 do begin
        if interp eq 0 then begin
            m[0,*,i].d=m[0,*,i].d*cals[j].calscl[0]
            m[1,*,i].d=m[1,*,i].d*cals[j].calscl[1]
            tsys[0,*,i]= total(m[0,*,i].d,1)/nlags
            tsys[1,*,i]= total(m[1,*,i].d,1)/nlags
            J=j+inc
        endif else begin
            ascl=interpol([cals[j].calscl[0],cals[j+1].calscl[0]],pntstrip)
            bscl=interpol([cals[j].calscl[1],cals[j+1].calscl[1]],pntstrip)
;            print,"strip:",i+1
            sym=(i mod 2)*2
;            if i eq 0 then begin
;                    plot,ascl,color=(i mod 10) + 1,psym=-sym
;            endif else begin
;                oplot,ascl,color=(i mod 10) + 1,psym=-sym
;            endelse
;
;       this should probably be a vector multiply??
;
            m[0,*,i].calscl=reform(ascl,1,pntstrip)
            m[1,*,i].calscl=reform(bscl,1,pntstrip)
            for k=0,pntstrip-1 do begin
                m[0,k,i].d=m[0,k,i].d*ascl[k]
                m[1,k,i].d=m[1,k,i].d*bscl[k]
                tsys[0,k,i]= total(m[0,k,i].d)/nlags
                tsys[1,k,i]= total(m[1,k,i].d)/nlags
            endfor
            j=j+2
         endelse
    endfor
    return,1
end
