;----------------------------------------------------------------------------
; isecmidhms3 - convert integer sec midnite to h m s
;
pro isecmidhms3 , secmid,h,m,s
    i=long(secmid)
    h=i/3600
    m =(i - (h*3600))/60
    s =i   mod 60
    return
end
