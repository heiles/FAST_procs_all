;
; include file to define structures for rm mon procedures
;
;history:
;        26jun00- date-> float. hold daynumber.fract
;-------------------------------------------------------------------------------
; structures for data being read in  
;
;
a={tsysdat,    calV :     fltarr(2),          $
			 tsysV:     fltarr(2)           $
		}

a={tsysrec,    date  :  0.,						$; daynum.fract
             freq  :    0.,						$
			 az    :    0.,						$
			 za    :    0.,						$
             if1Pwr:   fltarr(2),				$
             if2Pwr:   fltarr(2),				$
             corPwr:   fltarr(2),				$
             corAttn:  intarr(2),				$
             ct :replicate({tsysdat},8)          $
	}
;
a={tsysrecAlfa, date  :  0.,                    $; daynum.fract
             year  :    0l,$
             freq  :    0.,                     $
             az    :    0.,                     $
             za    :    0.,                     $
			 lst   :    0.,                     $
             digrms:   fltarr(4,7),  $ ; iA,qA, Ib,Qb
             calval:   fltarr(2,7),  $ bm 0..6
             tsys  :   fltarr(2,7)   }  ; a,b by beam

;-------------------------------------------------------------------------------
; structures for a days worth of freq info .. allocate in iminpday
;  
;  typedef struct {
;	   float   date;
;      float   freq;
;      float   az;
;      float   za;
;      float   if1Pwr[2];
;      float   if2Pwr[2];
;      float   corPwr[2];
;      short   corAttn[2];
;      TSYSDAT ct;				/* caltype array data*/ 
;   }  TSYSREC
;
;  typedef struct {
; 			   short    calType;	/* 1-8, 0--> not used*/
;			   float    calVal[2];
;			   float    tsysVal[2];
;  		} TSYSDAT 
;
; typedef struct {
;		int	 	rcvnum;
;		int		numEntries;
;       int     calAvail[8];		/* 0 if no data this cal*/
;       TSYSREC d[maxentries];		/* hold info*/
;
