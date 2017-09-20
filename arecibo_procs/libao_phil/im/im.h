;
; include file to define structures for interference mon procedures
;
;-------------------------------------------------------------------------------
; structures for data being read in  
;
; iminprec input record . a single freq peak hold.
;
a={imhdr,    hdrMarker:     bytarr(4,/nozero),  $
                hdrlen:          0L,         	$
                reclen:          0L,         	$
               version:     bytarr(4,/nozero),  $
                  date:          0L,			$ 
                secMid:          0L,			$ 
            cfrDataMhz:          0.,			$ 
             cfrAnaMhz:          0.,			$ 
               spanMhz:          0.,			$ 
             integTime:          0L,			$ 
              srcAzDeg:          0L}

a={imirec,   h:{imhdr},  $
             d: intarr(401,/nozero)  }
a={imdrec,   h:{imhdr},  $
             d: fltarr(401,/nozero)  }
;-------------------------------------------------------------------------------
; structures for a days worth of freq info .. allocate in iminpday
;  
;  typedef struct {
;      int     cfr;
;	   int     startTm;
;      int     startDay;
;      int     numEnt;
;      float   dat[401,MAX_ENTRY];
;   }  FREQ_DAY
;  one days data
;  typedef struct {
;       int   num freq
