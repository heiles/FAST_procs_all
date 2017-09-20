;-------------------------------------------------------------------------------
pro immossetup ,yymmdd,code,hardcopy,mos,file=filename
;-------------------------------------------------------------------------------
;
; setup for mosaics
;
;  bitsperpixel - for color hardcopy set to 8
;  /copy        - copies color table screen to postscript
;                 so you can mess with the color tables before printing
; keywords:
;  file
    if (n_elements(filename) eq 0) then filename= 'idl.ps'
    hor&ver
    bitsperpixel=4              ; set to 8 for color. used for ps
;
;   set the system variables
;
    !y.omargin=[0,1]            ; for title line
    !p.tickLen =-.02                ; ticks go out
    !p.charSize =1.5                
    !p.charThick=1
    if hardcopy ne 0 then begin 
        !p.charThick=3 
        !x.margin   = [8,2]
        !y.margin   = [1,2]     ; bottom,top
     endif else begin
        !x.margin=[10,3]        ; left,right
        !y.margin=[3,2]     ; bottom,top
    endelse

    mos={numrows:0,numcols:0,charSizeTsys:1.,title:' ',xtitle:' ',ytitle:' ',$
        winypix:0, yOffMainTitle: 1.0}

    case code of
        1 : begin 
                mos.ytitle='pwr [dbm]'
                title     ='Daily Average'
            end
        2 : begin 
                mos.ytitle='Hour of day'
                title     ='time/freq Images'
            end
        3 : begin 
                mos.ytitle='Rms/Mean'
                title     ='RMS(frqChn)/MEAN(frqChn)'
            end
    endcase
    mos.title=string(format='("Arecibo Obs RFI ",a," for ",i6.6)',$
                            title,yymmdd)

    mos.xtitle= 'freq [Mhz]'
    mos.numrows      = 5
    mos.numcols      = 2
    mos.winypix      =850
    mos.yOffMainTitle=.99
    mos.charSizeTsys=1.0
    if hardcopy ne 0 then begin 
        psFontSize=14
        psYOffset = .5              ;  offset  from bottom. 1.0 for mela
        psYsize   = 10.             ; 9 inches for mela
;       psYOffset = 3               ;  offset  from bottom. 1.0 for mela
;       psYsize   = 5.          ; 9 inches for mela
        mos.charSizeTsys=.86
        ps,filename,/inches,yoffset=psYoffset,ysize=psYsize,$
                font_size=psFontSize,bits=bitsperpixel
    endif 
    return
end
