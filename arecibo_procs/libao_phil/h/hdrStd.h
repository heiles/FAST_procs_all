;
; standard header ..
;
a={strsec,    inp:          0L,         $
             iflo:          0L,         $
             proc:          0L,         $
             time:          0L,         $
              pnt:          0L,         $
             misc:          0L}

a={hdrstd,hdrMarker:  bytarr(4,/nozero),$
           hdrlen:          0L,         $
           reclen:          0L,         $
               id:    bytarr(8,/nozero),$
          version:    bytarr(4,/nozero),$
             date:          0L,         $
             time:          0L,         $
        expNumber:          0L,         $
       scanNumber:          0L,         $
        recNumber:          0L,         $
       stScanTime:          0L,         $
              sec:    {strsec},         $
           free14:          0L,         $
           free13:          0L,         $
           free12:          0L,         $
           free11:          0L,         $
           grpNum:          0L,         $
       grpTotRecs:          0L,         $
        grpCurRec:          0L,         $
         dataType:    bytarr(4,/nozero),$
            azTTD:          0L,         $
            grTTD:          0L,         $
            chTTD:          0L,         $
          posTmMs:          0L,         $
            free1:          0L,         $
            free2:          0L}

