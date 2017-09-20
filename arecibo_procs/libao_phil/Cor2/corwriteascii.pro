;+
;NAME:
;corwriteascii - output an ascii dump of the correlator data
; 
;SYNTAX: istat=corwriteascii(b,outfilename)
;
;ARGS:   
;       b[n]: {corget} data to write.
;outfilename: string name of output file
;
;DESCRIPTION:
;   corwriteascii will output a correlator dataset in ascii to the specified
;filename. Data is printed by scan. Within each scan the data is printed by
;board. Each channel of spectral data will appear on a separate line with
;channelTopoFreq channelVel pol1Data pol2Data.
;
;   Keywords (which start the line with #) are used to separate the scans and 
;the boards of a scan. The keywords are:
;
;# scan: scannum srcname
;# brd: brdnum numlag numpols
;# com: other useful comments
;
;   The idea is that you could use a text processor (awk, perl) to scan
;the file and find out where the scans, records, and boards start.
;
;   The only header information is that in the keyword lines:
;scannumber, srcname, number of boards in the scan,number of lags
;in the board, and number of polarizations in the board.
;
;   An example file is listed below. The lines with --> are not part of the
;file format (I added them to put a few comments in this documentation).
;
; --> start of file.. list the keys so people remember the format
;# com:  keys: scan: scanNum nrecs srcName
;# com:  keys: rec: recnumber (1..nrecs)
;# com:  keys: brd: brdNumber(1-4) numlags numpol
;# com:  data: freq vel pol1 pol2
; -->    scanNum   numRecs   srcName
;# scan: 224801156    1 MAPS_P463_498572
;# rec:    1
; --> brd nlags 2pol
;# brd: 1 1024 2
; --> Freqchn1      velChn1          pol1Data     pol2Data
;  1.3300587E+03  2.0371273E+04  4.3640506E-01  2.3575836E-01
; --> channel 2 data
;  1.3300831E+03  2.0365396E+04  3.8925239E-01  2.0697139E-01
; --> ....  till end of this board
;# brd: 2 1024 2
;  1.3500587E+03  1.5628420E+04  3.6222970E-01  1.3802753E-01
;  1.3500831E+03  1.5622716E+04  3.0191767E-01  1.6439275E-01
; --> ... for the rest of the boards in this rec
; --> ... If  there are multiple records in the scan then rec 2 starts..
; --> ... else skip to the next scan
;# rec:    2
;# brd: 1 1024 2
; --> ... When all the recs of this scan are done, start the next scan
;# scan: 224801160    1 MAPS_P463_790971
;# rec:    1
;# brd: 1 1024 2
;  1.3300579E+03  2.0371298E+04 -2.0002886E-03  4.1539539E-04
;  1.3300823E+03  2.0365421E+04 -1.2376260E-03  1.9774768E-03
;
;EXAMPLE:
;   process onoff position switch data, convert to janskies then output
;   ascii file holding just this processed data.
;
;   scan=212300123
;   corposonoff(lun,b,t,cals,scan=scan,/han,/scljy,/sum)
;   nrecs=corwriteascii(b,'outfile.ascii')
;
;NOTES:
;   A scan with 1 record of 4 boards, each board having 2 polarizations of
;1024 lags each took .25 megabytes. The binary data was 32Kbytes so the file
;size gets blownup by about a factor of 8.
;-
;history: 10sep02 started
;
function corwriteascii,b,filename
; 
;    on_error,1
;
;   see if we already have it made.
;
    openw,lunout,filename,/get_lun
    scans=b.b1.h.std.scannumber
    getscanind,scans,scanStind,scanlen
    ind=uniq(scans,sort(scans))
    curscan=-1
    printf,lunout,"# com:  keys: scan: scanNum nrecs srcName
    printf,lunout,"# com:  keys: rec: recnumber (1..nrecs)
    printf,lunout,"# com:  keys: brd: brdNumber(1-4) numlags numpol
    printf,lunout,"# com:  data: freq vel pol1 pol2
    totrecs=0L
;
;   loop through each scan
;
    for iscan=0,n_elements(scanStInd)-1 do begin
        i1=scanStInd[iscan]
        nrecs=scanlen[iscan]
        i2=scanStInd[iscan]+nrecs-1

        lab=string(format='("# scan: ",i9,i5," ",a)',$
            b[i1].b1.h.std.scannumber,nrecs,string(b[i1].b1.h.proc.srcname))
        printf,lunout,lab
        nbrds=n_tags(b[i1])
;
;   loop thru each record of scan
;
        for irec=0,nrecs-1 do begin
            lab=string(format='("# rec: ",i4)',irec +1)
            printf,lunout,lab
;
;   loop through each board of a record
;
            for ibrd=0,nbrds-1 do begin
                npol=b[i1].(ibrd).h.cor.numsbcout
                nlags=b[i1].(ibrd).h.cor.lagsbcout

;# brd: n nlags npol

                lab=string(format='("# brd: ",i1,i5,i2)',ibrd+1,nlags,npol)
                printf,lunout,lab
                frq=corfrq(b[i1].(ibrd).h)
                vel=corfrq(b[i1].(ibrd).h,/retvel)
;
;   loop over the lags
;
                for ilag=0,nlags-1 do begin
                    lab=string(format='(6E15.7)',frq[ilag],vel[ilag],$
                        b[i1+irec].(ibrd).d[ilag,0:npol-1])
                    printf,lunout,lab
                endfor ; lags
            endfor     ; boards
            totrecs=totrecs+1L
        endfor         ; recs
    endfor             ; scans
    free_lun,lunout
    return,totrecs
end
