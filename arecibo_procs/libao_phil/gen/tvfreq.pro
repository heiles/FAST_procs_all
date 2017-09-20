;+
;NAME:
;tvfreq - return tv channels and frequencies
;
;SYNTAX: tvfreq,chan1,chan2,chan,freq,sound=sound,chroma=chroma,cenfrq=cenfrq
;ARGS:
;       chan1   - int first channel number (2-69)
;       chan2   - int last  channel number (2-69)
;RETURNS:
;       chan[]  - long  channel numbers
;       freq[]  - float frequencies 
;
;KEYWORDS:
;   sound   : int if set then return the sound carrier frequency
;   chroma: : int if set then return the color carrier
;   cenfrq: : int if set then return the center of the band. This should
;                 be used for digital channels. 
;DESCRIPTION:
;   return the frequencies and channel numbers for the tv channels between
;chan1 and chan2 (inclusive). Return the channel numbers in chan and the
;frequencies in freq. By default the picture carrier frequency is returned 
;(1.25 Mhz above the lower edge). If the sound keyword is set then return 
;the frequency of the sound carrier (5.75 mhz above the lower edge). If the
;chroma keyword is set then return the color carrier (3.579656 mhz above
;the picture carrier)..
;
;EXAMPLE:
;   tvfreq,2,20,chan,freq
;   chan[] will contain the numbers 2-20
;   freq[] will contain the picture carriers for each channel.
;-
pro tvfreq,chn1,chn2,chn,freq,sound=sound,chroma=chroma,cenfrq=cenfrq

    pictureOffset=1.25
    chromaOffset =pictureOffset+3.579545
    soundOffset  =pictureOffset+4.5
    cenfrqOffset =3.

    nchn=chn2-chn1+1
    chn=findgen(nchn)+chn1
    freq=fltarr(nchn)
;
;   2-4
;
    ind=where((chn ge 2) and (chn le 4),count)
    if count gt 0 then begin
        freq[ind]=54+ 6*(chn[ind]-2)
    endif
;
;   5,6
;
    ind=where((chn ge 5) and (chn le 6),count)
    if count gt 0 then begin
        freq[ind]=78+ 6*(chn[ind]-5)
    endif
;
;   7-13
;
    ind=where((chn ge 7) and (chn le 13),count)
    if count gt 0 then begin
        freq[ind]=174+ 6*(chn[ind]-7)
    endif
;
;   14-69
;
    ind=where((chn ge 14) and (chn le 69),count)
    if count gt 0 then begin
        freq[ind]=470+ 6*(chn[ind]-14)
    endif
;
    offset=pictureOffset
    if keyword_set(sound)  then offset=soundOffset
    if keyword_set(chroma) then offset=chromaOffset
    if keyword_set(cenfrq) then offset=cenfrqOffset
    freq=freq+Offset
    return
end
