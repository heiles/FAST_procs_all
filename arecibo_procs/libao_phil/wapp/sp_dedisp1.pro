;+
;NAME:
;sp_dedisp1 - dedisperse a buffer of wapp data.
;SYNTAX: sp_dedisp1,spc,f1,df,dm,timeSmp,smpOff,dedisp,refRf=refRf
;ARGS:
; spc[nchn,nspcSmp,nsmp]:float Spectra to dedisperse. If 2 dimensions then
;                 assume just 1 spectra per sample
;   f1  :double   center frequency of first channel (Mhz).
;   df  :double   Channel width (Mhz). The sign tells whether spc[*,]
;                 is increasing frequency (unflipped) or decreasing
;                 frequency (flipped).
;    dm : double  dispersion measure
;   tmSmp:double  time between samples (secs)
; smpOff :long    The sample number that spc starts at. This is for use when
;                 the routine is called multiple times
;
;KEYWORDS:
;   refRf:double   reference frequency to use for dedispersion. The default
;                  is the first bin of each band.
;
;RETURNS:
;   shiftAr[nchans]:long    shift values for each channel.
;   dedispA[n,nspcSmp]:float   the deddisped time series by spectra persample
; The dedisp  should be allocated to hold the max number of samples +
;                 the maxium sample delay across the band
;
;DESCRIPTION:
;   Dedisperse one input buffer of spectra (usually from wappget). f1,df,dm,
;timeSmp and optionally  refRf determine how to dedisperse spc. If you
;set f1 to be the highest frequency bin, then make df negative.
;
;   The dedispersed data is returned in dedisp[nsmp,Nspc]. You should
;dimension dedisp large enough to hold all of the dedispered data
;for however many calls you will make to sp_dedisp1. smpOff points
;to the offset in dedispwhere the first time sample of spc goes. The
;code checks the indices so that all dedispersed power before smpOff=0
;is thrown into smpOff=0. You need to dimension dedisp to hold any
;extra data at the end of the last time sample (from freq channels 
;above the reference frequency). 
;
;   This routine is normally calledl by sp_dedisp().
;
;SEE ALSO:
;   sp_dedsip,sp_dmdelay,sp_dmshift
;
;NOTES: this code was borrowed from duncan lorimer's sigproc routines.
;HISTORY:
;26MAY06:- changed arguments dedispA,dedispB to deDisp[nsmp,Nspc] to allow
;         for alfa data when you have multiple beams coming back from
;         1 board (1,2, or 4).
;-
;
;history:
;   26may06: on first time thru need to check that smpOff is greater
;            than max shiftar rather than assuming after the first
;            read we have taken more points than the max shift value.
;
;-->WARNING<-- I THINK
;                ii= (lind + (smpOff - shiftAr[ichn])) > 0
;  should be
;                ii= (lind + (smpOff + shiftAr[ichn])) > 0
; 

pro  sp_dedisp1,spc,f1,df,dm,timeSmp,smpOff,dedisp, refRf=refRf
;
;   figure out the number of frequency channels, pols etc, from array dim.
;   
    a=size(spc)
    ndim=a[0]
    nchan=a[1]
    nspcSmp=(ndim eq 3)?a[2]:1
    nsmp=(ndim eq 3)?a[3]:a[2]
;
;   compute the shifts
;   note that a channel with a positive shift needs to be moved
;   back in time (it is a lower frequency than the ref so it arrives 
;   later).
;
    shiftAr=sp_dmshift(f1,df,nchan,dm,timeSmp,refRf=refRf)
    maxshift=max(abs(shiftAr))
;
;   index array
;
    lind=lindgen(nsmp)
;
;   if freq is flipped just move right to left in freq array
;   we are assuming that df was positive....
;
;   loop over the channels.
;   for first call need to check for indices < 0 
;   in this case throw them into the first time sample
;   .. it will be off
;
    if smpOff lt maxshift then begin
        case nspcSmp of
          1: begin  
             for ichn=0,nchan-1 do begin
                ii= (lind + (smpOff - shiftAr[ichn])) > 0
                dedisp[ii]+=spc[ichn,*]
             endfor
             end
          2: begin
             for ichn=0l,nchan-1 do begin
                ii= (lind + (smpOff - shiftAr[ichn])) > 0
                dedisp[ii,0]  +=spc[ichn,0,*]
                dedisp[ii,1]  +=spc[ichn,1,*]
             endfor
             end
          4: begin 
             for ichn=0L,nchan-1 do begin
                ii= (lind + (smpOff - shiftAr[ichn])) > 0
                dedisp[ii,0]  +=spc[ichn,0,*]
                dedisp[ii,1]  +=spc[ichn,1,*]
                dedisp[ii,2]  +=spc[ichn,2,*]
                dedisp[ii,3]  +=spc[ichn,3,*]
             endfor
             end
        endcase
    endif else begin
         case nspcSmp of
            1: begin  
               for ichn=0L,nchan-1 do begin
                    ii= lind + (smpOff - shiftAr[ichn])
                    dedisp[ii]+=spc[ichn,*]
               endfor
               end 
            2: begin  
               for ichn=0L,nchan-1 do begin
                    ii= lind + (smpOff - shiftAr[ichn])
                    dedisp[ii,0]+=spc[ichn,0,*]
                    dedisp[ii,1]+=spc[ichn,1,*]
               endfor
               end 
            4: begin  
               for ichn=0L,nchan-1 do begin
                    ii= lind + (smpOff - shiftAr[ichn])
                    dedisp[ii,0]+=spc[ichn,0,*]
                    dedisp[ii,1]+=spc[ichn,1,*]
                    dedisp[ii,2]+=spc[ichn,2,*]
                    dedisp[ii,3]+=spc[ichn,3,*]
               endfor
               end 
          endcase
    endelse
;
    return
end
