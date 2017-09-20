;+
;NAME:
;correcinfo - print record info
;SYNTAX: correcinfo,b,inphdr=inphdr,outfd=outfd
;ARGS  :
;       b:    {corget} record to print info from
;KEYWORDS:  
;  inphdr:              if set, then b is a header rather than a correlator
;                       record: eg b.b1.h rather than b
;  outfd : int          if provided, then write the information to this
;                       file descriptor (logical unit number) instead of
;                       the terminal. You should open the desctripor with
;                       openw,outfd,filename,/get_lun before calling this
;                       routine.
;DESCRIPTION:
;   Print Info about the correlator rec passed in.
;An example output is:
;
;IDL> correcinfo,b
;scan:102000270 ra:16:45:42 dec:00:20:58 rcv: 5 azErr: -3.9 zaE:  0.4Asec
;yymmdd:  10120 dayno: 20 astTm:09:42:35 az,gr,ch: 386.024  17.800   8.834
;recNum:   1  sec/Rec:60
;brd cfr   bw    nchn lvl npol lagCf CorDb     lag0
; 1 1612.2  0.39 1024  9   2     9   11 11   1.27 1.52
; 2 1666.0  6.25 1024  9   2     9   10 12   1.49 1.42
; 3 1665.4  0.39 1024  9   2     9    8  9   1.31 1.33
; 4 1667.3  0.39 1024  9   2     9   11  9   1.37 1.41
;src:J1645+021 pattern:onoff
;on nrecs:  1  cal:1 movTmSec: 60
;
;-
;modhistory
;15aug03 - added inphdr option.
;
pro correcinfo,b,inphdr=inphdr,outfd=outfd
    if not keyword_set(outfd) then outfd=-2
;
    forward_function iflohrfnum
;
;------------------------------   
;scan:xxxxxxxx ra:hhmmss.s dec:ddmmss.s rcv:xx azErr:xxx.x zaE:xxx.x "asec"
;yymmdd:yymmdd dayno: astTm:hh:mm:ss az:xxx.xxx gr:xx.xxx ch:xx.xxx
;recNum:dddd sec/Rec:dd
;brd  cfr   bw    nchn lvl npol lagCf CorDb     lag0
;  b xxxx.x xx.xx xxxx  x   x    dd   xx xx  xx.xx xx.xx
;  b xxxx.x xx.xx xxxx  x   x
;  b xxxx.x xx.xx xxxx  x   x
;  b xxxx.x xx.xx xxxx  x   x
;pattern: 
;src:xxxxxxxxxxx pattern:xxxxxxxxxxxxxxxx

    usewas=wascheck(junk,b=b[0])
    if keyword_set(inphdr) then begin
        h=b[0]
    endif else begin
        h=b[0].b1.h
    endelse
    printf,outfd,'----------------------------------------------------'
    za=h.std.grttd*.0001
    ln=string(format=$
'("scan:",i9," ra:",A," dec:",a," rcv:",i2," azErr:",f5.1," zaE:",f5.1,"Asec")',$
    h.std.scannumber,$
    fisecmidhms3(h.pnt.r.rajcumrd*86400/(2*!PI)),$
    fisecmidhms3(h.pnt.r.decjcumrd*!radeg*3600.),$
    iflohrfnum(h.iflo),$
    h.pnt.errazrd*!radeg*3600.*sin(za*!dtor),$
    h.pnt.errzard*!radeg*3600.)
    printf,outfd,ln
;
    yr   =h.std.date/1000L
    dayno=h.std.date mod 1000L
    dm=daynotodm(dayno,yr)
    yymmdd=(yr mod 100)*10000L + dm[1]*100+dm[0]
    ln=string(format=$
'("yymmdd: ",i6," dayno:",i3," astTm:",a," az,gr,ch: ",f7.3,1x,f7.3,1x,f7.3)',$
        yymmdd,dayno,$
        fisecmidhms3(h.std.stscantime),$
        h.std.azttd*.0001,$
        h.std.grttd*.0001,$
        h.std.chttd*.0001)
    printf,outfd,ln
;
    ln=string(format=$
'("recNum:",i4,"  sec/Rec:",i2)',$
        h.std.grpnum,$
        h.cor.dumpsPerinteg* (h.cor.dumplen/50000000.))
    printf,outfd,ln
;
    printf,outfd,$
'brd cfr    bw    nchn lvl npol lagCf CorDb     lag0'
    nbrds=h.std.grptotrecs
    if keyword_set(inphdr) then nbrds=1
;
    for i=0,nbrds-1 do begin
        if keyword_set(inphdr) then begin
            hl=h
            npol=(hl.cor.lagsbcout eq 1)? 1 : 2
        endif else begin
            hl=b[0].(i).h
            ind=where(b[0].(i).p ne 0,npol)
        endelse
        bw=((usewas) and (hl.cor.bwnum eq 0))?100.:$
                                              50./(2^(hl.cor.bwnum-1))
        ln=string(format=$
'(i2,1x,f6.1,1x,f6.2,i5,i3,i4,3x,i3,3x,i2,i3,2x,f5.2,f5.2)',$
    i+1,$
    corhcfrtop(hl),$
    bw,$
    hl.cor.lagsbcout,$
    ((hl.cor.state and '10000000'xl) eq 0) ? 3 : 9,$
    npol,$
    hl.cor.lagconfig,$
    hl.cor.attnDb,$
    hl.cor.lag0pwrratio)
    printf,outfd,ln
    endfor
;
;
    ln=string(format=$
'("src:",a," pattern:",a)',$
    string(h.proc.srcname),$
    string(h.proc.procname))
    printf,outfd,ln
;
;   checkpattern
;   
    case string(h.proc.procname) of
;
    'calonoff': begin
;
        ln=string(format=$
'(a," sectoInteg:",i3)',$
    string(h.proc.car[*,0]),$
           h.proc.iar[0])
        printf,outfd,ln
        end
;
    'onoff': begin
;
        ln=string(format=$
'(a," nrecs:",i3,1x," cal:",i1," movTmSec:",i3)',$
    string(h.proc.car[*,0]),$
           h.proc.iar[0],$
           h.proc.iar[1],$
           h.proc.iar[2])
        printf,outfd,ln
        end
;
    'on': begin
;
        ln=string(format=$
'(" numInteg:",i3," cal:",i1)',$
            h.proc.iar[0],$
            h.proc.iar[1])
        printf,outfd,ln
        end
;
;totStrips:ddd 1stStrip:ddd curStrip:ddd integ/Strip:dd stripSt:hh:hh:hh 
;map  :RaOff:ddd.d DecOff:ddd.d decStep:dd.d (Amin) secPerInteg:dd.d code:0Xxxx
;strip:raOff:ddd.d decOff:ddd.d raRate:ss.s Amin/sec
;

    'cormap1': begin
        ln=string(format=$
'("totStrip:",i3," 1stStrip:",i3," curStrip:",i3," integ/Strip:",i3," stripSt:",a)',$
            h.proc.iar[1],$ 
            h.proc.iar[2],$ 
            h.proc.iar[4],$ 
            h.proc.iar[3],$ 
    fisecmidhms3(h.proc.iar[5]))
    printf,outfd,ln
    ln=string(format=$
'("map   RaOff:",f6.1," DecOff:",f6.1," decStep:",f4.1,"(Amin) secPerInteg:",f4.1," code:0x",z3.3)',$
            h.proc.dar[1],$ 
            h.proc.dar[2],$ 
            h.proc.dar[3],$ 
            h.proc.dar[0],$ 
            h.proc.iar[0])
    printf,outfd,ln
    ln=string(format=$
'("strip raOff:",f6.1," decOff:",f6.1,"(Amin) raRate:",f6.2," Amin/sec")',$
            h.proc.dar[6]*!radeg*60,$ 
            h.proc.dar[7]*!radeg*60,$ 
            h.proc.dar[5]*!radeg*60)
    printf,outfd,ln
    end
;totStrips:ddd 1stStrip:ddd curStrip:ddd integ/Strip:dd stripSt:hh:hh:hh
;map  :RaOff:dd.d DecOff:dd.d decStep:dd.d (Amin) secPerInteg:dd.d code:0Xxxx
;strip:raOff:dd.d decOff:dd.d decRate:ss.s Amin/sec
;

    'cormapdec': begin
        ln=string(format=$
'("totStrip:",i3," 1stStrip:",i3," curStrip:",i3," integ/Strip:",i3," stripSt:", a)',$
            h.proc.iar[1],$
            h.proc.iar[2],$
            h.proc.iar[4],$
            h.proc.iar[3],$
    fisecmidhms3(        h.proc.iar[5]))
    printf,outfd,ln
    ln=string(format=$
'("map   RaOff:",f6.1," DecOff:",f6.1," raStep:",f4.1,"(Amin) secPerInteg:",f4.1," code:0x",z3.3)',$
            h.proc.dar[1],$
            h.proc.dar[2],$
            h.proc.dar[3],$
            h.proc.dar[0],$
            h.proc.iar[0])
    printf,outfd,ln
    ln=string(format=$
'("strip raOff:",f6.1," decOff:",f6.1,"(AminLC) decRate:",f6.2," Amin/sec")',$
            h.proc.dar[6]*!radeg*60,$
            h.proc.dar[7]*!radeg*60,$
            h.proc.dar[5]*!radeg*60)
    printf,outfd,ln
    end

;totStrips:ddd 1stStrip:ddd curStrip:ddd integ/Strip:dd stripSt:hh:hh:hh
;map  :AzOff:dd.d ZaOff:dd.d zaStep:dd.d (Amin) secPerInteg:dd.d code:0Xxxx
;strip:AzOff:dd.d zaOff:dd.d azRate:ss.s Amin/sec

  'cormapbm': begin
        ln=string(format=$
'("totStrip:",i3," 1stStrip:",i3," curStrip:",i3," integ/Strip:",i3," stripSt:", a)',$
            h.proc.iar[1],$
            h.proc.iar[2],$
            h.proc.iar[4],$
            h.proc.iar[3],$
    fisecmidhms3(h.proc.iar[5]))
    printf,outfd,ln
    ln=string(format=$
'("map   azOff:",f6.1,"  zaOff:",f6.1," za Step:",f4.1,"(Amin) secPerInteg:",f4.1," code:0x",z3.3)',$
            h.proc.dar[1],$
            h.proc.dar[2],$
            h.proc.dar[3],$
            h.proc.dar[0],$
            h.proc.iar[0])
    printf,outfd,ln
    ln=string(format=$
'("strip azOff:",f6.1,"  zaOff:",f6.1,"(Amin) azRate:",f6.2," Amin/sec")',$
            h.proc.dar[6]*!radeg*60,$
            h.proc.dar[7]*!radeg*60,$
            h.proc.dar[5]*!radeg*60)
    printf,outfd,ln
    end
;
;
; cordrift 
;totStrips:ddd strip/stp:dd curStrip:ddd integ/Strip:dd stripSt:hh:hh:hh
;map  :HaOff:dd.d DecOff:dd.d decStep:dd.d (Amin) secPerInteg:dd.d code:0Xxxx
;strip:xxxxx:dd.d decOff:dd.d 
;

    'cordrift': begin
        ln=string(format=$
'("totStrip:",i3," strip/stp:",i2," curStrip:",i3," integ/Strip:",i3," stripSt:",a)',$
            h.proc.iar[1],$
            h.proc.iar[7],$
            h.proc.iar[4],$
            h.proc.iar[3],$
    fisecmidhms3(        h.proc.iar[5]))
    printf,outfd,ln
    ln=string(format=$
'("map   HaOff:",f6.1," DecOff:",f6.1," decStep:",f4.1,"(Amin) secPerInteg:",f4.1," code:0x",z3.3)',$
            h.proc.dar[1]*!radeg*60.,$
            h.proc.dar[2],$
            h.proc.dar[3],$
            h.proc.dar[0],$
            h.proc.iar[0])
    printf,outfd,ln
    ln=string(format=$
'("strip      :      DecOff:",f6.1,"(Amin)")',$
            h.proc.dar[4])
    printf,outfd,ln
    end


    else: 
    endcase
    
    return
end
