;+
;NAME:
;dwtempall - input ascii data from rmall routine.
;SYNTAX: nrecs=dwtempall(lun,d,maxrec=maxrec)
;ARGS:
;   lun :   int file containing data to read
;KEYWORDS:
;   maxrec: long  max number of recs to read in. def 10000.
;RETURNS:
;   nrecs : long    number of records input.
;   d[nrecs]:{dwtempall} data input from file
;DESCRIPTION:
;   rmall rcvnum will query all of the info from the receiver monitoring
;package online. This info can be recorded to disc. dwtempall() will input
;and parse this ascii data. Before calling this routine you should call
;@dwinit
;
;EXAMPLE:
;   suppose the data has been written to rmtemp.dat.
;@dwinit 
;   openr,lun,'rmtemp.dat',/get_lun
;   nrecs=dwtempall(lun,d)
;   free_lun,lun
;help,d,/st
;** Structure RMALL, 14 tags, length=108:
;   TM              LONG             41510
;   VOLTS           FLOAT     Array[2, 4]
;   CUR             FLOAT     Array[2, 4]
;   TEMP16K         FLOAT           14.3800
;   TEMP70K         FLOAT           85.7600
;   TEMPOMT         FLOAT           97.5200
;   LEDHEMTA        INT              0
;   LEDHEMTB        INT              0
;    DWP15           FLOAT           15.1800
;  DWN15           FLOAT          -15.3000
;   POSTAMPP15      FLOAT           15.0000
;   LKSHOREDISP     INT              1
;   POSTAMPCURA     FLOAT           1000.00
;   POSTAMPCURB     FLOAT           1000.00
;-
function dwtempall,lun,d,maxrec=maxrec
;
    on_ioerror,done
    if n_elements(maxrec) eq 0 then maxrec=10000L

a={rmall, tm        :        0L   ,$; seconds from midnite 
         volts      : fltarr(2,4) ,$;
          cur       : fltarr(2,4) ,$;
          temp16K   :         0.  ,$;
          temp70K   :         0.  ,$;
          tempomt   :         0.  ,$;
          ledhemtA  :         0   ,$; 
          ledhemtB  :         0   ,$; 
          dwP15     :         0.  ,$; dewar +15, -15
          dwN15     :         0.  ,$; dewar +15, -15
          postAmpP15:         0.  ,$; 
          lkShoreDisp:        0   ,$;
          postAmpCurA:        0.  ,$;
          postAmpCurB:        0.  }

ln=''
delim=' :()'
d=replicate(a,maxrec)
i=-1
while 1 do begin
    readf,lun,ln
    case 1 of
        (strmid(ln,0,2) eq '#1') : begin 
            str=strsplit(strmid(ln,2),delim,/extract)
            d[i].volts[0,0]= str[0]
            d[i].volts[1,0]= str[1]
            d[i].cur[0,0]  = str[2]
            d[i].cur[1,0]  = str[3]
            d[i].temp16K   = str[5]
            d[i].dwP15     = str[7]
            d[i].ledhemta  = str[9]
            end
        (strmid(ln,0,2) eq '#2') : begin 
            str=strsplit(strmid(ln,2),delim,/extract)
            d[i].volts[0,1]= str[0]
            d[i].volts[1,1]= str[1]
            d[i].cur[0,1]  = str[2]
            d[i].cur[1,1]  = str[3]
            d[i].temp70K   = str[5]
            d[i].dwN15     = str[7]
            d[i].ledhemtB  = str[9]
            end
        (strmid(ln,0,2) eq '#3') : begin 
            str=strsplit(strmid(ln,2),delim,/extract)
            d[i].volts[0,2]= str[0]
            d[i].volts[1,2]= str[1]
            d[i].cur[0,2]  = str[2]
            d[i].cur[1,2]  = str[3]
            d[i].tempOMT   = str[5]
            d[i].postAmpP15= str[7]
            d[i].lkShoreDisp= str[9]
            end
        (strmid(ln,0,2) eq '#4') : begin 
            str=strsplit(strmid(ln,2),delim,/extract)
            d[i].volts[0,3]= str[0]
            d[i].volts[1,3]= str[1]
            d[i].cur[0,3]  = str[2]
            d[i].cur[1,3]  = str[3]
            d[i].postAmpCurA  = str[5]
            d[i].postAmpCurB  = str[7]
            end
        (strmid(ln,0,2) eq 'rc') : begin 
            str=strsplit(ln,delim,/extract)
            i=i+1
            d[i].tm        = str[4]
            end
        else: begin
            i=i
            end
        endcase
endwhile
done:
    i=i+1
    if i  gt 0 then begin
        d=d[0:i-1]
    endif else begin
        d=''
    endelse
    return,i
end
