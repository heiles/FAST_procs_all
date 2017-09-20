;+
;NAME:
;getsl  - scan a wapp fits file  and return the scan list.
;SYNTAX: sl=getsl(desc)
;ARGS:
;       desc:   {} assigned to open file
;                   default: 5000L
;RETURNS:
;      sl[nscans]:{sl} holds scan list info
;DESCRIPTION
;   This routine reads a wapp fits file and returns an array of scanlist
;structures.
;This array contains summary information for each scan of the file:
;
;   sl.scan       - long   scan number for this scan
;   sl.bytepos    - unsigned long for start of this scan
;                          for fits data this is the starting row of the
;                          scan in the file, not the byte offset.
;   sl.stat       - .. not used yet..
;   sl.rcvnum     - byte receiver number 1-16
;                   note: ch is rcvnum 100
;   sl.numfrq     - byte  .. number of freq,cor boards used this scan
;   sl.rectype    - byte 1 -calon
;                        2 -caloff
;                        3 -onoff on  pos
;                        4 -onoff off pos
;                        5 -coron (stdon) (track just on position)
;                        6 -cormap1 (radecmap)
;                        7 -cormapdec (decramap)
;                        8 -cordrift  (driftmap)
;                        9 -corcrossch (spidera0 thru a7)
;                       10 -x111auto (rfi monitoring)
;                       11 -one      murrays on with calon/off at the null
;                       12 -onoffbml murrays on, off and cal at null
;                       20 -spidera0
;                       21 -spidera1
;                       22 -spidera2
;                       23 -spidera3
;                       24 -spidera4
;                       25 -spidera5
;                       26 -spidera6
;                       25 -wappcrossmap
;                       26 -wapphexmap  
;                       27 -altdriftmap 
;                       28 -fixedazdrift
;                       29 -basketweave
;                       30 -CROSSA0
;                       31 -CROSSA1
;                       32 -CROSSA2
;                       33 -CROSSA3
;                       34 -CROSSA4
;                       35 -CROSSA5
;                       36 -CROSSA6
;                       40 -dps On-T
;                       41 -dps Off-T
;                       42 -dps On-B
;                       43 -dps Off-B
;                       
;   sl.numrecs    - long  .. number of groups(records in scan)
;   sl.freq[4] float- topocentric frequency center each subband
;   sl.julday  double- julian date start of scan
;   sl.srcname  string  - source name (max 12 long)
;   sl.procname string  - procedure name used.
;
;   Some routines can use the sl structure to perform random access to
;files (bypassing the need to search for a scan). The sl[] array can
;also be used with the where() command to rapidly extract subsets of a
;file.
;
;EXAMPLE:
;   openr,lun,'/share/olcor/corfile.02nov00.x101.1',/get_lun
;   sl=getsl(lun)
;   1. process all of the lband wide data in a file:
;       ind=where(sl.rcvnum eq 5,count)
;       for i=0,n_elements(ind)-1
;           print,corinpscan(lun,b,scan=sl[ind[i]].scan,sl=sl)
;           .. process
;       endfor
;   2. Find all of the on/off patterns in a file. Make sure that the
;      number of records in the on equals the number in the off.
;      indon=where(sl.rectype eq 3 ,count)
;      if count le 0 then goto,nopairs
;;   make sure an off follows the on and has the same number of records..
;;   (actually this will fail if the last rec of the file is an on since
;;   indon+1 will go beyond the end of the sl array..)
;      ind=  where((sl[indon+1].rectype eq 4) and $
;            (sl[indon].numrecs eq sl[indon+1].numrecs),count)
;      if count le 0 then goto,nopairs
;      indon=indon[ind]
;   3. plot all of the cal on/off records in a file with cormon().
;       ind=where(sl.rectype le 2)
;       cormon,lun,sl=sl[ind]
;
;Note this will not work with files > 2gigabytes since it is
;using a 32 bit integer.
;-
;history:
;14jul04 - copied from gen/getsl.pro modified to work with  fits data.
;          only record types: onoff, cal, spider have been implented
;          (i don not yet know the other coding schemes fits is using).
;          ignore, scan,maxscans keywords..
;
function getsl,desc,scan=scan,maxscans=maxscans
;
    mjdtojd=2400000.5D
    on_error,1
    nscans=desc.totscans
    sl=replicate({sl},nscans)
    sl.scan     =desc.scanI.scan
    sl.fileindex=0L
    sl.stat     =0L
    sl.bytepos=desc.scanI.rowstartind   ; start index row,not byte..
    sl.numfrq =desc.scanI.nbrds
    sl.numrecs=desc.scanI.recsInScan    ; should be rows???
;
    sl.rcvnum  = 0 
    sl.rectype = 0
    sl.freq    = 0.     ; need to change 4 to 8
    sl.julday  = 0.     ; start of scan
    sl.srcname = ''     ; sourcename
    sl.procname=''      ; procedure name
;
; missing:
;
;   loop thru each scan getting the info that is not in the
;   descr structure
;
    errmsg=''
    lun=desc.lun
    for i=0,nscans-1 do begin
        rowInd=desc.scanI[i].rowStartInd
        fxbread,lun,itemp,'RFNUM',rowInd+1,errmsg=errmsg

        fxbread,lun,frontend ,'FRONTEND',rowInd+1, errmsg=errmsg ;byte
        if strlowcase(frontend) eq 'alfa' then itemp=17

        sl[i].rcvnum = itemp

        fxbread,lun,dtemp,desc.colI.jd,rowInd+1,errmsg=errmsg
        sl[i].julday = dtemp 
        if sl[i].julday lt 2400000.D then sl[i].julday+= mjdtojd

        fxbread,lun,srcnm,'OBJECT',rowInd+1,errmsg=errmsg
        sl[i].srcname  = srcnm

        fxbread,lun,procnm,desc.colI.patnam,rowInd+1,errmsg=errmsg
        if strmid(procnm,0,6) eq 'SPIDER' then procnm='SPIDER'
        sl[i].procname = procnm
;
        fxbread,lun,obsname,desc.colI.scanType,rowInd+1,errmsg=errmsg

;       
;       get the topo freq..
;
        ilast=(desc.scanI[i].nbrds < 4)
        for j=0,ilast-1 do begin
            irow=rowInd  + desc.scanI[i].ind[0,j]
            fxbread,lun,frq,'CRVAL1',irow + 1,errmsg=errmsg
            sl[i].freq[j] = frq*1d-6
        endfor
;
;       rectype
;
        case procnm of
;
;       onoff position switching.
;
            'ONOFF': begin
                    sl[i].procname='onoff'
                    case  1 of
                     obsname eq "ON" : sl[i].rectype=3
                     obsname eq "OFF": sl[i].rectype=4
                     else            : sl[i].rectype=0
                     endcase
                    end
            'CAL'  : begin
                    sl[i].procname='calonoff'
                    case 1 of
                     obsname eq 'ON' :sl[i].rectype=1
                     obsname eq 'OFF':sl[i].rectype=2
                     else            :sl[i].rectype=0
                     endcase
                     end
            'DPS'  : begin
                    sl[i].procname='dps'
                    case 1 of
                     obsname eq 'On-T' :sl[i].rectype=40
                     obsname eq 'Off-T':sl[i].rectype=41
                     obsname eq 'On-B' :sl[i].rectype=42
                     obsname eq 'Off-B':sl[i].rectype=43
                     else            :sl[i].rectype=0
                     endcase
                     end
;
;                  corcrossch
;
            'SPIDER': begin
                        sl[i].procname='corcrossch'
                        sl[i].rectype=9
                      end
;       
;            on only
;
             'on'   : sl[i].rectype=5
;
;                  cormap1
;
            'cormap1' : sl[i].rectype=6
;
;                  cormapdec
;
            'cormapdec': sl[i].rectype=7
;
;                  cordrift
;
            'cordrift' : sl[i].rectype=8
;
;                  x111auto rfi monitoring
;
            'x111auto'  : sl[i].rectype=10
;
;                  one murrays on , then calon/off at the null
;
            'one'        : sl[i].rectype=11
;
;                  onoffbml . position on , off in null  then calonoff
;
        'onoffbml' : sl[i].rectype=12
              else : sl[i].rectype=0
        endcase
    endfor 
return,sl
end
