;+
;NAME:
;atmget - input 1 or more atm records
;SYNTAX: istat=atmget(lun,d,nrec=nrec,rectype=rectype,usercodelen=usercodelen,
;				      raw=raw,scan=scan,sl=sl,search=search,
;					  contiguous=continguous)
;
;ARGS: lun    : unit number for file (already opened)
;      d[]    : {atmrec} return data here.
;
;KEYWORDS:
; nrec   : long   number of records to return. The default is 1. If nrec is
;                 greater than 1, the routine will skip over any records that
;                 do not match the requested record type.
;                 Note: The routine will return when: nrec records 
;                 of the same type are read,  eof is hit, or a record of
;                 the same record type but with a different number of 
;                 data elements is found.
;                        
;rectype : string record type to return. The default is the next 
;                 available record. The possible values are:
;                 'pwr' : power profile (ap version)
;                 'clp' : codedlong pulse (ap version)
;                'mracf': mracf (ap version)
;                 'dspc': dynamic spectra (ap version)
;               'rawdat': raw dat program (any data program)
;                'rpwrb': rawDat barker code power profile 
;               'rpwr88': rawDat 88 len code (power profile or d-region use)
;               'r52code': rawDat 52 length code 
;               'rmracf': rawDat mracf;
;               'ruser' : rawDat user specified code. You must also
;						  set usrcodelen=usercodenlen keyword to the
;                         length of the code in bauds
;               'rclp': rawDat coded long pulse
;               note: rmracf,rpwrb,rpwr88,r52code use the codename to 
;                     determine the type of record.
;usercodelen: long  if rectype is ruser, you must also set usercodelen
;				   to the baud length of the code you want to read
;     raw:        if set then return the data in a single float array.
;                 By default the routine splits the data in each
;                 record into tx,data,noise,cals, etc..
;                 (but rawdat,rpwr,rmracf always return just the data)
;    scan: long   scan to position to before reading the data.
;    sl[]: {scanlist} array returned from getsl(lun). This can be used
;                  for random access of files (see generic routines: getsl())
;  search:        if set then search for the start of the first header.
;                 use this in if the first rec of the file does not start
;                 with a header.
; contiguous:     if set then the records returned will be contiguous
;                 in time. This is handy when a single file has different types
;                 of records in it. Suppose the file holds:
;                     200 rclp recs,
;                    1024 'rpwr88' recs
;                     200 rclp recs,
;                    1024 'rpwr88' recs
;                     etc.
;                 If you set rectype='rpwr88' and ask for 2000 records, then
;                 it will return with 1024 records. If contiguous is not set, 
;                 then it will read 1024 recs of the first block and then 
;                 read the rest from the second 1024 block. This can be a 
;                 problem if doing pulse to pulse spectra.
;           

;                 nrecs=1000. If after
; RETURNS:
;  istat : int
;           1 - requested number of records found
;           2 - req number of recs not found, hit eof, at least 1 record found
;           3 - req number of recs not found, hit rec with different data len,
;               at least 1 record found
;           0 - hit eof, no data returned
;          -1 - could not position to scan/rec
;          -2 - bad header id in hdr
;          -3 - bad program id in header
;          -4 - requested rectype='ruser' but forgot to set usercodelen
;NOTE:
;   For now the rmracf,r
;
;DESCRIPTION:
;   Read the next nrec atm records from lun. Start at the current
;record position unless the scan keyword is present. Atm files contain
;more than 1 kind of data records (eg. pwr, mracf, clp, etc). By default
;the record type returned is determined by the first record of the current
;read. The user can use the rectype keyword to specify a particular kind
;of record type to return.
;
;   The file is left positioned after the last successful record read. If
;eof() is hit while trying to complete the current request, the file will
;be left positioned at the last successful read of the requested record
;type. If the file does not end in this particular record type, then this
;will not be at the end of the file.
;
;   The data is returned in an array of structures d[nrec]. Each element
;of the structure will contain the header followed by the data arrays. By
;default the data arrays are split into tx,data,noise,cals, etc. The
;raw keyword will return the data in each record as a single float array.
;
;EXAMPLES:
;   To use this routine:
;   0. idl
;   1. make sure the path to aodefdir() is in your path directory:
;       at ao just enter @phil or
;       !path='/home/phil/idl/gen' + !path  
;       You can also put this in your IDL_STARTUP file if you like.
;   2. @atminit     .. sets up the paths, headers for atm processing.
;   3. openr,lun,'/share/aeron2/29jun03qz09.greg',/get_lun
;
;    --> get 10 pwr records
;    istat=atmget(lun,d,rectype='pwr',nrecs=10)
;
;    --> get 20 mracf records, return in raw mode without splitting
;        up the data into tx,data,cals,etc.
;    istat=atmget(lun,d,rectype='mracf',nrecs=20,/raw)
;
; If you want to see each record of a file try:
;   rew,lun
;   scanlist,lun,/verb,/std
;rec:  1 scn:        0 grp:  251 Id:clp      pos:        0 h,dlen:   444 154112
;rec:  2 scn:        0 grp:  501 Id:clp      pos:   154556 h,dlen:   444 154112
;   The position is the byteoffset in the file for the start of the record.
;   h,dlen are the header,data lengths in bytes.
;
; -------------------------------------------------------------------------
;RESTRICTIONS:
;
;1. This routine currently works for the data taken in "raw datataking" mode.
;   This uses the pc datataking system in raw datataking mode with the
;   processing of the data being done in the PC via asp. The routine 
;   will probably not work for the older data taken with the vme array
;   processors (the record formats/header info was changed).
;
;2. The routine needs to be positioned at the start of a header. If a 
;   file starts with a partial record, use:
;      rew,lun
;      searchhdr(lun)
;   This will position you at the start of the first header. The scan keyword
;   allows for random positioning within the file. Unfortunatley, it uses 
;   the scannumber keyword in the header and this header element is not
;   filled in by the processing programs.
;
;3. Be careful how many records you ask for. You need to have enough
;   memory to hold all of them. Typical record lenghths are:
;   pwr  : 8628  bytes/rec
;   mracf: 11404 bytes/rec  128 spclen by 21  
;   clp  : 154556 byes/rec (64 spclen by 602)
;
;   
;4. I've tested the routine with mracf,clp, and pwr. Record types of:
;   tpsd, dspc are not yet implemented. Raw data (meteors etc..) using rectype
;   rawdat will probably work.
; -------------------------------------------------------------------------
;DATA FORMAT:
;
;   A typical record will contain a header followed by data. The data 
;format will depend on the type of record (pwr,mracf,...) unless the
;/raw keyword is used. An example for a power record is:
;
;   d.h               STRUCT    -> HDRPWR Array[1] header
;   d.tx              FLOAT     Array[46]          tx samples   
;   d.d               FLOAT     Array[1600]        height data
;   d.calon           FLOAT     Array[200]         cal on
;   d.caloff          FLOAT     Array[200]         cal off
;
; The same record read using /raw will look like:
;   d.H               STRUCT    -> HDRPWR Array[1] header
;   d.D1              FLOAT     Array[2046]        all the data
;   
; -------------------------------------------------------------------------
;HEADERS:
;
;   Each record will have a header containing generic and program specific
;entries. The generic parts are :
; h.std (standard header), h.ri , h.sps.
; The program specific headers are:
; h.pwr, h.mracf, h.tpsd,h.clp 
;
;   A description of the generic headers are listed below
;
; IDL> help,d.h,/st
; ** Structure HDRPWR, 4 tags, length=444, data length=444:
;   STD             STRUCT    -> HDRSTD Array[1]    standard header
;   RI              STRUCT    -> HDRRIV2 Array[1]   ri header
;   PWR             STRUCT    -> HDRSECPWR Array[1] program header (pwr )
;   SPS             STRUCT    -> HDRSECSPSBG Array[1] sps header
;
; -------------------------------------------------------------------------
;THE STD HEADER:
; ** Structure HDRSTD, 26 tags, length=128, data length=128:
;   HDRMARKER       BYTE    Array[4]        'hdr_'
;   HDRLEN          LONG         444        header len bytes
;   RECLEN          LONG        8628        reclen bytes
;   ID              BYTE     Array[8]       prog id: 'pwr','mracf',etc
;   VERSION         BYTE     Array[4]       version
;   DATE            LONG           2003185  yyyyddd where ddd is daynumber
;   TIME            LONG             70263  time in seconds from midnite ast
;   EXPNUMBER       LONG                 0
;   SCANNUMBER      LONG                 0
;   RECNUMBER       LONG                 0
;   STSCANTIME      LONG                 0
;   SEC             STRUCT    -> STRSEC Array[1]
;   GRPNUM          LONG               500  first record of scan for this data
;   GRPTOTRECS      LONG                 1  
;   GRPCURREC       LONG                 1
;   DATATYPE        BYTE          Array[4]
;   AZTTD           LONG           1156032  az pointing direction in .0001 deg
;   GRTTD           LONG            150000  za greg in .0001 deg units
;   CHTTD           LONG            150002  za ch in .0001 deg units
;   POSTMMS         LONG          70262024  millisec from midnite for positions
;
; -------------------------------------------------------------------------
;THE RI HEADER:
; ** Structure HDRRIV2, 12 tags, length=48, data length=48:
;   EXTTIMING       LONG                 1  using sps
;   SMPMODE         LONG                 1  use gw pulses
;   PACKING         LONG                12  12 bit sampling
;   MUXANDSUBCYCLDE LONG                 0 
;   FIFONUM         LONG                12  use both chan 1,2 (dual beam)
;   SMPPAIRIPP      LONG              2046  total samples 1 ipp
;   IPPSPERBUF      LONG                 2  ipps per output rec
;   IPPNUMSTARTBUF  LONG               999  ipp number from start
;   IPP             FLOAT           10000.0 ipp in usec
;   GW              FLOAT           2.00000 gw in usec
;   STARTON         LONG                 0
;   FREE            LONG         544368000
;   note: some of the ri header is duplicated in the sps header.
;         when in doubt, use the sps header info.
; -------------------------------------------------------------------------
;THE SPS HEADER:
; ** Structure HDRSECSPSBG, 16 tags, length=212, data length=212:
;   ID              BYTE      Array[4]       section id
;   VER             BYTE      Array[4]       version
;   IPP             FLOAT           10000.0  ipp in usecs
;   GW              FLOAT           2.00000  sample time in usecs
;   BAUDLEN         FLOAT           4.00000  baudlen of code in usecs
;   BWCODEMHZ       FLOAT          0.250000  bandwidth of code in mhz
;   CODELENUSEC     FLOAT           52.0000  codelen in usecs
;   TXIPPTORFON     FLOAT           373.000  tx ipp to rf on in usecs
;   RFLEN           FLOAT           52.0000  rf len in usecs
;   NUMRFPULSES     LONG                 1   number of rf pulses
;   MPUNIT          FLOAT           52.0000  multipulse unit
;   MPSEQ           LONG      Array[20]      multipulse seq (if mpunt gt 1)
;   CODENAME        BYTE      Array[20]      name of code used
;   SMPINTXPULSE    LONG                46   samples taken in tx pulse
;   NUMRCVWIN       LONG                 2   number of receive windows.
;   RCVWIN          STRUCT    -> HDRSPSRCVWIN Array[5]
;
;   The SPS.RCVWIN structure:
;  IDL> help,d.h.sps.rcvwin,/st
;  ** Structure HDRSPSRCVWIN, 3 tags, length=12, data length=12:
;   STARTUSEC       FLOAT           300.000  usecs from start of rf on
;   NUMSAMPLES      LONG              1600   number of sample taken
;   NUMSAMPLESCAL   LONG                 0   number samples that are cal samples
;
; -------------------------------------------------------------------------
;POWER PROFILE RECORDS:
;
;  istat=atmget(lun,d,rectype='pwr',nrec=10)
;  help,d,/st
;  Structure <829c52c>, 5 tags, length=8628, data length=8628, refs=1:
;   H               STRUCT    -> HDRPWR Array[1] header
;   TX              FLOAT     Array[46]      tx samples
;   D               FLOAT     Array[1600]    data samples
;   CALON           FLOAT     Array[200]     cal ON samples
;   CALOFF          FLOAT     Array[200]     cal off samples
;
;   the pwr header d.h.pwr contains:
;IDL> help,d.h.pwr,/st
;** Structure HDRSECPWR, 14 tags, length=56, data length=56:
;   ID              BYTE      Array[4]
;   VER             BYTE      Array[4]
;   PROGMODE        LONG              1000
;   DCDMODE         LONG                 0
;   RECTYPE         LONG                 0
;   TXSMPSCALE      FLOAT           0.00000
;   SPCRECSPERGRP   LONG                 0
;   SPCCURREC       LONG                 0
;   HIPPSAVGED      LONG              1000
;   SPCNUMHEIGHT    LONG                 0
;   SPC1STHEIGHT    LONG                 0
;   SPCLENFFT       LONG                 0
;   SPCAVGED        LONG                 0
;   SPCTHISREC      LONG                 0
;   only the hippsavged (number of ipps averaged) is filled in.
;
; -------------------------------------------------------------------------
;MRACF RECORDS:
;   print,atmget(lun,d,rectype='mracf')
;   IDL> help,d,/st
; * Structure <8266f94>, 5 tags, length=11404, data length=11404, refs=1:
;   H               STRUCT    -> HDRMRACF Array[1]  header
;   TXSPC           FLOAT     Array[128]            spectra of tx samples
;   DSPC            FLOAT     Array[128, 16]        16 data spectra of 128 pnts
;   NSPC            FLOAT     Array[128, 4]         4 noise spectra of 128 pnts
;   DC              FLOAT     Array[46]             dc points (not returned)
;   note: the last data spectra d.dspc[*,15] is not computed correctly 
;         (it is overlapped with the first noise spectra).
;
;   The mracf header d.h.mracf contains:
;   IDL> help,d.h.mracf,/st
;** Structure HDRSECMRACF, 20 tags, length=80, data length=80:
;   ID              BYTE      Array[4]
;   VER             BYTE      Array[4]
;   IPPSAVGDATA     LONG              1000      ipps averaged
;   IPPSAVGNOISE    LONG                 0
;   NUMIFFREQ       LONG                 0
;   NUMHEIGHTS      LONG                20      number of heights
;   NUMLAGS         LONG                64      number of lags. spclen=2*numlags
;   NUMDCPNTS       LONG                 0
;   FIRSTTXSMP      LONG                 0
;   RECISDATAREC    LONG                 0
;   HEIGHTSTHISREC  LONG                 0
;   DCPNTSTHISREC   LONG                 0
;   TXSPIPP         LONG                 0
;   TXHEIGHT        LONG                 0
;   NUMFREQSW       LONG                 0
;   TXFRQOFF1       FLOAT           0.00000
;   TXFRQOFF2       FLOAT           0.00000
;   TXFRQOFF3       FLOAT           0.00000
;   TXFRQOFF4       FLOAT           0.00000
;   FR3             LONG                 0
;   the only elements returned are the 3 listed.
;
; -------------------------------------------------------------------------
;CODED LONG PULSE RECORDS:
;   print,atmget(lun,d,rectype='clp')
;   IDL> help,d,/st
;   * Structure <82630e4>, 2 tags, length=154556, data length=154556, refs=1:
;   H               STRUCT    -> HDRCLP Array[1]  header 
;   DSPC            FLOAT     Array[64, 602]      602 spectra of len 64
;
;   The coded long pulse header contains:
;   IDL> help,d.h.clp,/st
;   *Structure HDRSECCLP, 14 tags, length=56, data length=56:
;   ID              BYTE      Array[4]
;   VER             BYTE      Array[4]
;   IPPSAVG1FREQ    LONG              1000   ipps averaged
;   NUMIFFREQ       LONG                 0
;   NUMHEIGHTS      LONG               602   number of heights
;   SPC1STHEIGHT    LONG                 0
;   SPCHEIGHTSTEP   LONG                 0
;   DECIMATEFACTOR  LONG                 8
;   ZEROEXTDXFORM   LONG                 0
;   FIRSTTXSMP      LONG                 0
;   SPCLEN          LONG                64   length of spectra
;   DECIMATEDCODELEN
;                   LONG                 0
;   SPCTHISREC      LONG                 0
;   FILL            LONG                 0
;   note: the current implementation assumes there are no tx or cal
;         samples returned.
; -------------------------------------------------------------------------
;RAWDAT RECORDS:
;   print,atmget(lun,d,rectype='rawdat')
;   IDL> help,d,/st
;   * Structure <827d394>, 3 tags, length=123268, data length=123268, refs=1:
;   H               STRUCT    -> HDRRD Array[1]  header
;   D1              COMPLEX   Array[7680]        channel 1 ch if dual beam
;   D2              COMPLEX   Array[7680]        channel 2 gr if dual beam
; 
;   The rawdat header contains: 
;   IDL> help,d.h,/st
;   * Structure HDRRD, 3 tags, length=388, data length=388:
;   STD             STRUCT    -> HDRSTD Array[1]
;   RI              STRUCT    -> HDRRIV2 Array[1]
;   SPS             STRUCT    -> HDRSECSPSBG Array[1]
;   
;   The rawdat program always returns the data as a complex array. It does
;not split the data up into cal or noise (as if /raw was always set).
;
;-
; modification history:
; 03jul03 - started
; 02oct06 - added r52len, and ruser with usercodelen
;
function  atmget, lun, dar,scan=scan,sl=sl,nrecs=nrecs,rectype=rectype,raw=raw,$
                  search=search,verb=verb,contiguous=contiguous,$
				  usercodelen=usercodelen

;
;   on_error,1
;
;   used codenm to figure out the different kinds of rawdat bufs
;   
    codeNmPwr88b   ='stdl46d88'
    codeNm52b      ='stdl26d52'
    codeNmPwrBarker='barker'
    codeNmMracf    ='mracf'
    codeNmClp      ='codedlp'
    codeNmRuser     ='user'

    maxreclen=2L^18         ; for header search
    on_ioerror,ioerr
    retstat=1
    curPos=-1L

    if not keyword_set(rectype) then rectype=''
    if n_elements(nrecs) eq 0 then nrecs=1
	if n_elements(usercodelen) eq 0 then usercodelen=0
    if not keyword_set(verb) then verb=0
     
;
;   see if they want a particular kind of rawdat rec. if so
;   set prog to rawdat and remember the type they want.
;
    progToGet=strlowcase(rectype)
    reqRdMracf=0 & reqRdPwrB=0 & reqRdPwr88=0 & reqRdClp=0 & reqRd52=0 
	reqRuser=0
    case progToGet of 
      'rmracf' : reqRdMracf=1
      'rpwrb'  : reqRdPwrB =1
      'rpwr88' : reqRdPwr88 =1
      'r52code': reqRd52    =1
        'rclp' : reqRdclp   =1
       'ruser' : begin
				 if usercodelen eq 0 then begin
					print,$
'When using rectype="ruser" you must also set usercodelen=usercodelenInBauds'
				return,-4
				endif
                reqRuser   =1
				end
        else   :
    endcase
    reqRdSpc= reqRdMracf or reqRdPwrB or reqRdPwr88  or reqRdClp or reqRd52 $
					or reqRuser
    if reqRdSpc then progToGet='rawdat'
    reqRd=progToGet eq 'rawdat'
;
; if rawdat program , read the entire header
; if old ap program, just read the std header
; keep track of which we've read via reqRd (request rawdat)
;
    hdr=(reqRd)? {hdrRd} : {hdrStd} 

    dLenfloat=-1l
    recsRead=0L
    foundDiffDataLen=0
;
;    position before we start?
;
    if  keyword_set(scan)  then begin
        istat=posscan(lun,scan,1L,sl=sl)
        case istat of
            0: begin 
                print,$
                'atmget: position to:',scan,', but found increasing scannumber'
                retstat=-1
               end 
           -1: begin
                print,'atmget:position did not find scan:',scan
                retstat=-1
               end
         else: 
         endcase
    endif
    if retstat ne 1 then goto,done
    swapdata=0
    point_lun,-lun,curPos       ; current position
;
;   loop over the requested number of records
;
    useMracf=0&useRd=0&useClp=0&usePwr=0&useTpsd=0
    useRiGet=0
    hdrsrch=0
    cntr=0L
    for irec=0L,nrecs-1 do begin
;
;       loop till we get the rectype we want or eof
;
        point_lun,-lun,tmpPos       ; current position
        while 1 do begin
retryhdr:
            readu,lun,hdr
            cntr=cntr+1L
            if verb and ((cntr mod 100 ) eq 0) then print,cntr
;
;           check header
;
            hdrMarker=(reqRd)?string(hdr.std.hdrMarker) :string(hdr.hdrMarker)
            if  strcmp('hdr_',hdrMarker) eq 0  then begin
                if keyword_set(search) and (irec eq 0) and (hdrsrch eq 0) $
                                then begin
                   istat=searchhdr(lun,maxlen=maxreclen)
                   if istat eq 1 then begin
                       hdrsrch=1
                       point_lun,-lun,tmpPos
                       goto,retryhdr 
                    endif
                endif
                retstat=-2
                goto,done
           endif
;
;    get some info from header. depends if rawdat or other..
;
            if reqRD then begin     ; we have rd complete hdr
                progId=strtrim(string(hdr.std.id))
                hdrSwap= abs(hdr.std.hdrlen) ge 65536L
                reclen=(hdrSwap)?swap_endian(hdr.std.reclen):hdr.std.reclen
                hdrLen=(hdrSwap)?swap_endian(hdr.std.hdrlen):hdr.std.hdrlen
            endif else begin        ; we have just the std hdr
                progId=strtrim(string(hdr.id))
                hdrSwap= abs(hdr.hdrlen) ge 65536L
                reclen=(hdrSwap)?swap_endian(hdr.reclen):hdr.reclen
                hdrLen=(hdrSwap)?swap_endian(hdr.hdrlen):hdr.reclen
            endelse
;
;           if we wanted the first rec type we found
;
            if progToGet eq '' then begin
                progToGet=strlowcase(progId) ; use first progId we find
                if progToGet eq 'rawdat' then begin
                       reqRd=1
                       point_lun,lun,tmpPos ; need to reread entire header
                       hdr={hdrRd}
                       readu,lun,hdr
                endif
            endif
;
;           See if this rec matches what we wanted
;   
            if progId eq progToGet then begin   ; matched the req rectype
                gotit=1
                if reqRdSpc then begin
                    codeNmInp=strtrim(string(hdr.sps.codename))
                    case 1 of 
                        reqRdMracf : gotit= codeNmInp eq codeNmMracf
                        reqRdPwrB  : gotit= codeNmInp eq codeNmPwrBarker 
                        reqRdPwr88 : gotit= codeNmInp eq codeNmPwr88b
                        reqRd52    : gotit= codeNmInp eq codeNm52b
                        reqRdClp   : gotit= codeNmInp eq codeNmClp
                        reqRuser   : begin
									 if (codeNmInp eq codeNmRuser) then begin	
			 		    codelenusec=(hdrswap)?swap_endian(hdr.sps.codelenUsec):$
			                       (hdr.sps.codelenUsec)
			 			baudlenusec=(hdrswap)?swap_endian(hdr.sps.baudlen):$
			                       (hdr.sps.baudlen)
								   codelen=long(codelenusec/baudlenusec + .5)
								      gotit= (codelen eq usercodelen)
									endif else begin
									   gotit=0
									endelse
									end
                        else:  gotit=0  ; unknown rd request
                    endcase
                endif
                if gotit then goto,gothdr
            endif
            if keyword_set(contiguous) and (irec gt 0) then goto,done 
            tmpPos=long64(tmpPos)+reclen
            point_lun,lun,tmpPos                    ; skip to next record
        endwhile
gothdr:

        nfloat=(reclen-hdrlen)/4l
        if dLenFloat eq -1 then dLenFloat=nfloat
        if dLenFloat ne nfloat then begin ; hit same rectype different datalen
            print,'Warning hit rec with different datalen. req,read:',$
                        dLenFloat,nfloat
            point_lun,lun,curPos        ; last successful read
            foundDiffDataLen=1
            goto,done
        endif
;
;   first time, define the data record to read in from the prog type    
;
        if irec eq 0 then begin
            case 1 of 
            strcmp(progId,'rawdat'):begin
;                        hdr={hdrRd} .. already did this..
                        useRiGet=1
                        useRd=1
                        end
            strcmp(progId,'mracf'):begin
                        d={     h:{hdrMracf},$
                               d1:fltarr(nfloat,/nozero)$
                          } 
                        useMracf=1
                        end
            strcmp(progId,'pwr'):begin
                        d={     h:{hdrPwr},$
                               d1:fltarr(nfloat,/nozero)$
                          } 
                        usePwr=1
                        end
            strcmp(progId,'clp'):begin
                        clpsec=(hdrswap)?swap_endian(hdr.sec.proc):$
                                        hdr.sec.proc 
                        if (clpsec and 'fff'XL) eq 52 then begin
                            d={     h:{hdrClp52},$
                                d1:fltarr(nfloat,/nozero)$
                              } 
                        endif else begin
                            d={     h:{hdrClp},$
                                d1:fltarr(nfloat,/nozero)$
                            }   
                        endelse
                        useClp=1
                        end
            strcmp(progId,'topside'):begin
                        d={     h:{hdrTpsd},$
                               d1:fltarr(nfloat,/nozero)$
                          }  
                         usetpsd=1
                        end
            else : begin
                    retstat=-3
                   end
            endcase
            if retstat ne 1 then goto,done
        endif
;
;       we read the stdHdr... position to start of rec again
;
        point_lun,lun,tmpPos        
        if useRiGet then begin
            complex=not keyword_set(raw)
            retstat=riget(lun,dar,hdr=hdr,complex=complex,numrecs=nrecs,$
                verb=verb)
            recsRead=(retstat gt 0)?retstat:0
			hiteof=eof(lun)
            case 1 of
                retstat eq nrecs: retstat=1
                (retstat gt 0) and (retstat ne nrecs) and (hiteof): retstat=2
               (retstat gt 0) and (retstat ne nrecs) and (not hiteof): retstat=3
                else : retstat=retstat
            endcase
            goto,done
        endif else begin
            readu,lun,d
            if hdrswap then d=swap_endian(d)
        endelse
        recsRead=recsRead+1
;
;       if we return a dimensioned structure , look at the header and figure out
;       the structure layout here
;
        if not keyword_set(raw) and (irec eq 0) then begin
            case 1 of
                useRd: begin
                       end
;
;                mracf strcucture
;
                useMracf:begin
                    spclen=d.h.mracf.numlags*2
                    nhghts =d.h.mracf.numheights
                    txhght=(d.h.sps.smpintxpulse gt 0)?1:0
                    dcpnts=nfloat-spclen*(nhghts+txhght)
                    noisehghts=(d.h.sps.numrcvwin gt 1) ? $
                        ((d.h.sps.rcvwin[1].numsamples)/spclen)-1 $
                        :0
                    dhghts=nhghts-noisehghts
                    if txHght gt 0 then begin
                        if noisehghts gt 0 then begin
                            d1={ h:d.h ,$
                            txspc:d.d1[0:spclen-1],$
                            dspc :reform(d.d1[spclen:spclen*(dhghts+1)-1],$
                                                            spclen,dhghts),$
                            nspc :reform(d.d1[spclen*(dhghts+1L):$
                                    spclen*(nhghts+1)-1],spclen,noisehghts),$
                             dc  :d.d1[nfloat-dcpnts:*] $
                                }
                        endif else begin
                            d1={ h     : d.h ,$
                             txspc:d.d1[0:spclen-1],$
                             dspc :reform(d.d1[spclen:spclen*(dhghts+1L)-1],$
                                                             spclen,dhghts),$
                             dc  :d.d1[nfloat-dcpnts:*] $
                                }
                        endelse
                    endif else begin
                        if noisehghts gt 0 then begin
                            d1={ h     : d.h ,$
                             dspc :reform(d.d1[0:spclen*dhghts-1L],spclen,$
                                                                    dhghts),$
                             nspc :reform(d.d1[spclen*dhghts:spclen*nhghts-1],$
                                    spclen,noisehghts),$
                             dc  :d.d1[nfloat-dcpnts:*] $
                                }
                        endif else begin
                            d1={ h     : d.h ,$
                             dspc  : reform(d.d1[0:spclen*dhghts-1L],spclen,$
                                                                    dhghts),$
                             dc  :d.d1[nfloat-dcpnts:*] $
                                }
                        endelse
                    endelse
                    d=temporary(d1)
                    end
;
;                power strcucture
;
                usePwr:begin
                    txpnt = d.h.sps.smpintxpulse 
                    calpnt=(d.h.sps.numrcvwin gt 1) ?  $
                                (d.h.sps.rcvwin[1].numsamples) $
                                :0
                    calonpnt=(calpnt gt 0)? $
                            d.h.sps.rcvwin[1].numsamplescal:0
                                
                    dpnt  =nfloat-(txpnt+calpnt)
                    if txpnt gt 0 then begin
                        if calpnt gt 0 then begin
                            d1={ h:d.h ,$
                                tx:d.d1[0:txpnt-1],$
                                 d:d.d1[txpnt:txpnt+dpnt-1],$
                            calOn :d.d1[txpnt+dpnt:txpnt+dpnt+calonpnt-1],$
                            calOff:d.d1[txpnt+dpnt+calonpnt:*]$
                                }
                        endif else begin
                            d1={ h:d.h ,$
                                tx:d.d1[0:txpnt-1],$
                                 d:d.d1[txpnt:*]$
                            }
                        endelse
                    endif else begin
                        if calpnt gt 0 then begin
                            d1={ h:d.h ,$
                                 d:d.d1[0:dpnt-1],$
                             calOn:d.d1[dpnt:dpnt+calonpnt-1],$
                            calOff:d.d1[dpnt+calonpnt:*]$
                                }
                        endif else begin
                            d1={ h:d.h ,$
                                 d:d.d1 $
                            }
                        endelse
                    endelse
                    d=temporary(d1)
                    end
;
;                coded long pulse structure
;               for now assume no tx samples, no cal
;
                useClp:begin
                    spclen=d.h.clp.spclen
                    nhghts =d.h.clp.numheights
                    d1={ h:d.h ,$
                      dspc:reform(d.d1,spclen,nhghts)}
                    d=temporary(d1)
                    end

                else :
            endcase
        endif

        if nrecs gt 1 then begin 
            if irec eq 0 then dar=replicate(d,nrecs)
            dar[irec]=d
        endif else begin
            dar=d
        endelse
        point_lun,-lun,curPos       ; current for next read
    endfor
;
done:
    if recsRead gt 0 then begin
        if not useRiGet then begin      ; ignore, we already did it
           if recsRead ne nrecs then begin
              if retstat eq 0 then retstat=2        ; hit Eof
              if foundDiffDataLen then retstat=3    ; found different data len
           endif else begin
              retstat=1
           endelse
           if (nrecs gt 1 ) and (recsRead lt nrecs) then dar=dar[0:recsRead-1]
        endif
    endif else begin
        d=''
        if  (curPos ne -1) then point_lun,lun,curPos        
    endelse
    return,retstat
ioerr:
    hiteof=eof(lun)
    on_ioerror,NULL
    if (not hiteof) then begin
        message, !ERR_STRING, /NONAME, /IOERROR
     endif else begin
        retstat=0 
    endelse
    goto,done
end
