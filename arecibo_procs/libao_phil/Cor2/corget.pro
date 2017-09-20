;+
;NAME:
;corget - input next correlator record from disc
;
;SYNTAX: istat=corget(lun,b,scan=scan,noscale=noscale,sl=sl,han=han)
;
;ARGS:
;     lun: logical unit number to read from.
;
;RETURNS:
;     b: structure holding the data input
; istat: 1 ok
;      : 0 hiteof
;      :-1 i/o error..bad hdr, etc..
;
;KEYWORDS:
;     noscale : if set, then do not scale each sub correlator to the 
;               9level corrected 0 lag.
;     scan    : if set, position to start of scan first..
;      han    : if set, then hanning smooth the data
;      sl[]   : {sl} array used to do direct access to scan.
;               This array is returned by the getsl procedure.
;
;DESCRIPTION:
;
;   Read the next group of correlator data from the file pointed to 
; by lun. If keywords scan is present, position to scan before reading.
;
; A group is the data from a single integration. Each correlator board 
; is written with a separate hdr and data array. The structure returned will
; contain 1 to 4 elements depending on the number of boards being used.
;  b.b1
;  b.b2
;  b.b3
;  b.b4
;  each bN will have:
;    b.b3.h     - complete header for this board 
;    b.b3.p[2]  int. 1-polA,2->polB, 0, no data this sbc
;    b.b3.accum double   . accumulate scale factor (if used)
;    b.b3.d[nfreqchan,nsbc] the data. nsbc will be 1 or 2 depending on
;                 how many sbc are using in this board.
;    use pol to determine what pol each sbc is. It will also tell you if
;    there is only 1 sbc pol[1] = 0. It will not compensate for
;    zeeman switching..
;
;  The header will contain:
;      .h.std - standard header
;      .h.cor - correlator portion of header
;      .h.pnt - pointing portion of header
;      .h.iflo- if,lo    portion of header
;      .h.dop - doppler frequency/velocity portion of header
;      .h.proc- tcl procedure portion of header
;
; The data is returned in increasing frequency order as floats.
;
; If an i/o error occurs (hit eof) or the hdrid is incorrect (you are not
; correctly positioned at the start of a header), then an error message
; is output and the file is left positioned at the position on entry to the
; routine.
;
;
;EXAMPLE:
;   .. assume 2 boards used, pola,b per board (lagconfig 9)
;   istat=corget(lun,b)
;   b.b1.h        - header first board
;   b.b2.d[*,0]    - data from 2nd board, polA
;
;SEE ALSO:
;    posscan,corgethdr
;-
; history:
; 18jun00 - before this time it was not scaling by the power values.
;           after this date scale by the power values. so carl H.. better
;           switch to /noscale
; 19jun00 - switched to be a function.
; 30jun00 - switched to return a single structure
;  0jul00 - added pol
; 31aug00 - test for divide by zero in scaling..
; 07sep00 - if they don't set noscale, scale the stoke too.
; 11aug04 - switched from corhflipped to corhflippedh . The header
;           variable was not always being set correctly.
;           corhflippedh recomputes the flip from the freq,lo's, filters
;           in the header..
; 13nov04 - added option to read in cor files with up to 8 boards.
;           needs for rms data writen out in ic format
; 05mar05 - added noflip option. if set then do not flip data on input even
;           if header says to. needed for corrms data that was written
;           out then read back in..
;
function corget, lun,b,noscale=noscale,scan=scan,sl=sl,han=han,noflip=noflip,$
                _extra=ex
;
; input correlator group  
;
    forward_function corhflippedh
;;    on_error,2
    on_ioerror,ioerr
    noscale=keyword_set(noscale)
    hdr1={hdr}
    doswap=0
;
;   see if we position before start
;
    if keyword_set(scan) then begin
        if keyword_set(sl) then  begin
            istat=posscan(lun,scan,1,sl=sl)
        endif else begin
            istat=posscan(lun,scan,1)
        endelse
        if istat ne 1 then begin
            print,'can not position to scan:',scan
            return,-1 
        endif
    endif
    point_lun,-lun,curpos
    readu,lun,hdr1              ; get first header
    if chkswaprec(hdr1.std) then begin
        doswap=1
        hdr1=swap_endian(hdr1)
    endif
    case hdr1.cor.numbrdsused of
        1: begin
            tmp1=fltarr(hdr1.cor.lagsbcout,hdr1.cor.numsbcout,/nozero)
            readu,lun,tmp1
            if doswap then tmp1=swap_endian(tmp1)
            b={b1:  {h:hdr1,$
                     p:intarr(2),$
                 accum: 0.D,$
                     d:tmp1}}
            end
        2: begin
            hdr2={hdr}
            tmp1=fltarr(hdr1.cor.lagsbcout,hdr1.cor.numsbcout,/nozero)
            readu,lun,tmp1
            if doswap then tmp1=swap_endian(tmp1)
            readu,lun,hdr2
            if doswap then hdr2=swap_endian(hdr2)
            tmp2=fltarr(hdr2.cor.lagsbcout,hdr2.cor.numsbcout,/nozero)
            readu,lun,tmp2
            if doswap then tmp2=swap_endian(tmp2)
            b={b1:{h:hdr1 ,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp1}, $
               b2:{h:hdr2,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp2}}
            end
        3: begin
            hdr2={hdr}
            hdr3={hdr}
            tmp1=fltarr(hdr1.cor.lagsbcout,hdr1.cor.numsbcout,/nozero)
            readu,lun,tmp1
            if doswap then tmp1=swap_endian(tmp1)
            readu,lun,hdr2
            if doswap then hdr2=swap_endian(hdr2)
            tmp2=fltarr(hdr2.cor.lagsbcout,hdr2.cor.numsbcout,/nozero)
            readu,lun,tmp2
            if doswap then tmp2=swap_endian(tmp2)
            readu,lun,hdr3
            if doswap then hdr3=swap_endian(hdr3)
            tmp3=fltarr(hdr3.cor.lagsbcout,hdr3.cor.numsbcout,/nozero)
            readu,lun,tmp3
            if doswap then tmp3=swap_endian(tmp3)
            b={b1:{h:hdr1,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp1},$
               b2:{h:hdr2,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp2},$
               b3:{h:hdr3,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp3}}
            end
        4: begin
            hdr2={hdr}
            hdr3={hdr}
            hdr4={hdr}
            tmp1=fltarr(hdr1.cor.lagsbcout,hdr1.cor.numsbcout,/nozero)
            readu,lun,tmp1
            if doswap then tmp1=swap_endian(tmp1)
            readu,lun,hdr2
            if doswap then hdr2=swap_endian(hdr2)
            tmp2=fltarr(hdr2.cor.lagsbcout,hdr2.cor.numsbcout,/nozero)
            readu,lun,tmp2
            if doswap then tmp2=swap_endian(tmp2)
            readu,lun,hdr3
            if doswap then hdr3=swap_endian(hdr3)
            tmp3=fltarr(hdr3.cor.lagsbcout,hdr3.cor.numsbcout,/nozero)
            readu,lun,tmp3
            if doswap then tmp3=swap_endian(tmp3)
            readu,lun,hdr4
            if doswap then hdr4=swap_endian(hdr4)
            tmp4=fltarr(hdr4.cor.lagsbcout,hdr4.cor.numsbcout,/nozero)
            readu,lun,tmp4
            if doswap then tmp4=swap_endian(tmp4)
            b={b1:{h:hdr1,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp1},$
               b2:{h:hdr2,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp2},$
               b3:{h:hdr3,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp3},$
               b4:{h:hdr4,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp4}}
            end
          5: begin
            hdr2={hdr}
            hdr3={hdr}
            hdr4={hdr}
            hdr5={hdr}
            tmp1=fltarr(hdr1.cor.lagsbcout,hdr1.cor.numsbcout,/nozero)
            readu,lun,tmp1
            if doswap then tmp1=swap_endian(tmp1)
            readu,lun,hdr2
            if doswap then hdr2=swap_endian(hdr2)
            tmp2=fltarr(hdr2.cor.lagsbcout,hdr2.cor.numsbcout,/nozero)
            readu,lun,tmp2
            if doswap then tmp2=swap_endian(tmp2)
            readu,lun,hdr3
            if doswap then hdr3=swap_endian(hdr3)
            tmp3=fltarr(hdr3.cor.lagsbcout,hdr3.cor.numsbcout,/nozero)
            readu,lun,tmp3
            if doswap then tmp3=swap_endian(tmp3)

            readu,lun,hdr4
            if doswap then hdr4=swap_endian(hdr4)
            tmp4=fltarr(hdr4.cor.lagsbcout,hdr4.cor.numsbcout,/nozero)
            readu,lun,tmp4
            if doswap then tmp4=swap_endian(tmp4)

            readu,lun,hdr5
            if doswap then hdr5=swap_endian(hdr5)
            tmp5=fltarr(hdr5.cor.lagsbcout,hdr5.cor.numsbcout,/nozero)
            readu,lun,tmp5
            if doswap then tmp5=swap_endian(tmp5)
            b={b1:{h:hdr1,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp1},$
               b2:{h:hdr2,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp2},$
               b3:{h:hdr3,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp3},$
               b4:{h:hdr4,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp4} ,$
               b5:{h:hdr5,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp5}}
            end
         6: begin
            hdr2={hdr}&hdr3={hdr}&hdr4={hdr}&hdr5={hdr}&hdr6={hdr}
            tmp1=fltarr(hdr1.cor.lagsbcout,hdr1.cor.numsbcout,/nozero)
            readu,lun,tmp1
            if doswap then tmp1=swap_endian(tmp1)
            readu,lun,hdr2
            if doswap then hdr2=swap_endian(hdr2)
            tmp2=fltarr(hdr2.cor.lagsbcout,hdr2.cor.numsbcout,/nozero)
            readu,lun,tmp2
            if doswap then tmp2=swap_endian(tmp2)
            readu,lun,hdr3
            if doswap then hdr3=swap_endian(hdr3)
            tmp3=fltarr(hdr3.cor.lagsbcout,hdr3.cor.numsbcout,/nozero)
            readu,lun,tmp3
            if doswap then tmp3=swap_endian(tmp3)

            readu,lun,hdr4
            if doswap then hdr4=swap_endian(hdr4)
            tmp4=fltarr(hdr4.cor.lagsbcout,hdr4.cor.numsbcout,/nozero)
            readu,lun,tmp4
            if doswap then tmp4=swap_endian(tmp4)

            readu,lun,hdr5
            if doswap then hdr5=swap_endian(hdr5)
            tmp5=fltarr(hdr5.cor.lagsbcout,hdr5.cor.numsbcout,/nozero)
            readu,lun,tmp5
            if doswap then tmp5=swap_endian(tmp5)

            readu,lun,hdr6
            if doswap then hdr6=swap_endian(hdr6)
            tmp6=fltarr(hdr6.cor.lagsbcout,hdr6.cor.numsbcout,/nozero)
            readu,lun,tmp6
            if doswap then tmp6=swap_endian(tmp6)
            b={b1:{h:hdr1,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp1},$
               b2:{h:hdr2,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp2},$
               b3:{h:hdr3,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp3},$
               b4:{h:hdr4,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp4} ,$
               b5:{h:hdr5,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp5} ,$
               b6:{h:hdr6,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp6}}
            end
          7: begin
            hdr2={hdr}&hdr3={hdr}&hdr4={hdr}&hdr5={hdr}&hdr6={hdr}&hdr7={hdr}
            tmp1=fltarr(hdr1.cor.lagsbcout,hdr1.cor.numsbcout,/nozero)
            readu,lun,tmp1
            if doswap then tmp1=swap_endian(tmp1)
            readu,lun,hdr2
            if doswap then hdr2=swap_endian(hdr2)
            tmp2=fltarr(hdr2.cor.lagsbcout,hdr2.cor.numsbcout,/nozero)
            readu,lun,tmp2
            if doswap then tmp2=swap_endian(tmp2)
            readu,lun,hdr3
            if doswap then hdr3=swap_endian(hdr3)
            tmp3=fltarr(hdr3.cor.lagsbcout,hdr3.cor.numsbcout,/nozero)
            readu,lun,tmp3
            if doswap then tmp3=swap_endian(tmp3)

            readu,lun,hdr4
            if doswap then hdr4=swap_endian(hdr4)
            tmp4=fltarr(hdr4.cor.lagsbcout,hdr4.cor.numsbcout,/nozero)
            readu,lun,tmp4
            if doswap then tmp4=swap_endian(tmp4)

            readu,lun,hdr5
            if doswap then hdr5=swap_endian(hdr5)
            tmp5=fltarr(hdr5.cor.lagsbcout,hdr5.cor.numsbcout,/nozero)
            readu,lun,tmp5
            if doswap then tmp5=swap_endian(tmp5)

            readu,lun,hdr6
            if doswap then hdr6=swap_endian(hdr6)
            tmp6=fltarr(hdr6.cor.lagsbcout,hdr6.cor.numsbcout,/nozero)
            readu,lun,tmp6
            if doswap then tmp5=swap_endian(tmp6)

            readu,lun,hdr7
            if doswap then hdr7=swap_endian(hdr7)
            tmp7=fltarr(hdr7.cor.lagsbcout,hdr7.cor.numsbcout,/nozero)
            readu,lun,tmp7
            if doswap then tmp7=swap_endian(tmp7)
            b={b1:{h:hdr1,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp1},$
               b2:{h:hdr2,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp2},$
               b3:{h:hdr3,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp3},$
               b4:{h:hdr4,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp4} ,$
               b5:{h:hdr5,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp5} ,$
               b6:{h:hdr6,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp6} ,$
               b7:{h:hdr7,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp7}}
            end
          8: begin
            hdr2={hdr}&hdr3={hdr}&hdr4={hdr}&hdr5={hdr}&hdr6={hdr}&hdr7={hdr}
            hdr8={hdr}
            tmp1=fltarr(hdr1.cor.lagsbcout,hdr1.cor.numsbcout,/nozero)
            readu,lun,tmp1
            if doswap then tmp1=swap_endian(tmp1)
            readu,lun,hdr2
            if doswap then hdr2=swap_endian(hdr2)
            tmp2=fltarr(hdr2.cor.lagsbcout,hdr2.cor.numsbcout,/nozero)
            readu,lun,tmp2
            if doswap then tmp2=swap_endian(tmp2)
            readu,lun,hdr3
            if doswap then hdr3=swap_endian(hdr3)
            tmp3=fltarr(hdr3.cor.lagsbcout,hdr3.cor.numsbcout,/nozero)
            readu,lun,tmp3
            if doswap then tmp3=swap_endian(tmp3)

            readu,lun,hdr4
            if doswap then hdr4=swap_endian(hdr4)
            tmp4=fltarr(hdr4.cor.lagsbcout,hdr4.cor.numsbcout,/nozero)
            readu,lun,tmp4
            if doswap then tmp4=swap_endian(tmp4)

            readu,lun,hdr5
            if doswap then hdr5=swap_endian(hdr5)
            tmp5=fltarr(hdr5.cor.lagsbcout,hdr5.cor.numsbcout,/nozero)
            readu,lun,tmp5
            if doswap then tmp5=swap_endian(tmp5)

            readu,lun,hdr6
            if doswap then hdr6=swap_endian(hdr6)
            tmp6=fltarr(hdr6.cor.lagsbcout,hdr6.cor.numsbcout,/nozero)
            readu,lun,tmp6
            if doswap then tmp5=swap_endian(tmp6)

            readu,lun,hdr7
            if doswap then hdr7=swap_endian(hdr7)
            tmp7=fltarr(hdr7.cor.lagsbcout,hdr7.cor.numsbcout,/nozero)
            readu,lun,tmp7
            if doswap then tmp7=swap_endian(tmp7)

            readu,lun,hdr8
            if doswap then hdr8=swap_endian(hdr8)
            tmp8=fltarr(hdr8.cor.lagsbcout,hdr8.cor.numsbcout,/nozero)
            readu,lun,tmp8
            if doswap then tmp8=swap_endian(tmp8)
            b={b1:{h:hdr1,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp1},$
               b2:{h:hdr2,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp2},$
               b3:{h:hdr3,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp3},$
               b4:{h:hdr4,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp4} ,$
               b5:{h:hdr5,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp5} ,$
               b6:{h:hdr6,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp6} ,$
               b7:{h:hdr7,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp7},$
               b8:{h:hdr8,$
                   p:intarr(2),$
                 accum: 0.D,$
                   d:tmp8}}
          end
    endcase
;
;   for each board, we need to scale and optionally flip it by sbc
;   if an odd number hi sidelos(decreasing freq order) flip by sbc
;   as long as it is not stokes (lagconfig=10) and they did not set noscale,
;   This scales the spectra to the 9 level corrected 0 lag. if you don't do
;   this then you haven't done the 9-level correction. 3level data is
;   already corrected in the correlator cpu.
;   the units should be linear in power and are the measured/optimum power.
;   
    for i=0 , hdr1.cor.numbrdsused-1 do begin
        scale=1.
        lagconfig=b.(i).h.cor.lagConfig
        pol=1
        if (lagconfig eq 1) or (lagconfig eq 7) then pol=2
        for  j=0,b.(i).h.cor.numSbcOut-1  do begin
            if j le 1 then begin
                b.(i).p[j]=pol
                pol=pol+1
            endif
             if  not ((noscale eq 1) or (lagconfig eq 10)) then begin
                tot=total(b.(i).d[*,j],/double);
                if tot lt 1e-5 then  begin
                    scale=1. 
                endif else begin
                   scale=float(b.(i).h.cor.lag0PwrRatio[j]*$
                    double(b.(i).h.cor.lagSbcOut)/total(b.(i).d[*,j],/double))
                endelse
            endif
;print,'j:',j," lag0pwrrateio:",b.(i).h.cor.lag0PwrRatio[j],' scl:',scale
            if (hdr1.cor.numbrdsused gt 4 ) then begin
                if scale ne 1. then b.(i).d[*,j]=b.(i).d[*,j]*scale
            endif else begin
                if (  corhflippedh(b.(i).h,i+1) and (not keyword_set(noflip))) $
                        then begin
                    b.(i).d[*,j]=reverse(b.(i).d[*,j])*scale
                endif else begin
                    if scale ne 1. then begin
                    b.(i).d[*,j]=b.(i).d[*,j]*scale
                endif
            endelse
            endelse
        endfor
    endfor
    if keyword_set(han) then  corhan,b
    return,1
;
ioerr: ; seems that we need a null line or the jump screws up
    hiteof=eof(lun)
    on_ioerror,NULL
    point_lun,lun,curpos
    if ( not hiteof ) then begin
            print, !ERR_STRING
            return,-1
    endif else  return,0
end
