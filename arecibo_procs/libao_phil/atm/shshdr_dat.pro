;+
;NAME:
;shshdr_dat - get data header for table
;SYNTAX: istat=shshdr_dat(lun,dhdr,ahdr=ahdr)
;ARGS:
;   lun: int        lun assigned to file vis shsopen. desc.lun
;RETURNS:
;  istat: int   1 - got header
;               0 - i/o error or eof
;              -1 - never saw start of header "HEADER:"
;              -2 - did not find end of header "]"
;   dhdr: {}    strucuture holding primary header
; adhr[]: string array holding ascii lines input
;
;DESCRIPTION:
;   Read in the primary header from the file pointed to by desc.lun. The
;file will be rewound before reading is started. The file will be 
;left positioned after the start of the primary header.
;
;-
function shshdr_dat,lun,dhdr,ahdr=ahdr
;
;
    dhdr={$
        tablerec    : 0L,$; 0 based.. rec within table
        tablesize   : 0L,$; in units of data width
        datawidth   : 0 ,$; in bytes
        datatype    : '',$; <short>
        numdims     : 0 ,$; of data 
        dim0        : 0L,$; length dimension 1 in datawidth units
        dim1        : 0L,$; length dimension 2 in datawidth units
         numchannels: 0 ,$;  divide 1 sec into this many sections.
;
; note.. xxStart is in units of datawidth before any 
;        subsetting of ipp is done. 
;        to find out where things are in the 
;        table you need to add aup txlen,datalen,noiselen
;        remember that these lengths are bigger than sample by datawidth.
;
          txStart   : 0L,$;  in units of datawidth
          txLen     : 0L,$;  in units of datawidth 
          dataStart : 0L,$;  in units of datawidth 
          dataLen   : 0L,$;  in units of datawidth 
          noiseStart: 0L,$;  in units of datawidth 
          noiseLen  : 0L,$;  in units of datawidth 
          systime   : '',$;  ast current  
          az        : 0.,$;
          zagreg    : 0.,$;
          zach      : 0.}

    on_ioerror,ioerr
    f2st=19                 ; field 2 start (data
    f2len=17                ; field 2 max len
    inp=''
    done=0
    use_ahdr=arg_present(ahdr)
    if use_ahdr then ahdr=''
    idim=0                  ; dimension to load
    gothdr=0
    linecnt=0L
    maxline=30
    while (not done) do begin
        readf,lun,inp 
        case strmid(inp,0,10) of 
            'HEADER:   ': gothdr=1
            'TABLENUM: ': dhdr.tablerec =long(strtrim(strmid(inp,f2st,f2len)))
            'TABLESIZE:': dhdr.tablesize=long(strtrim(strmid(inp,f2st,f2len)))
            'DATAWIDTH:': dhdr.datawidth=fix(strtrim(strmid(inp,f2st,f2len)))
            'DATATYPE: ': dhdr.datatype =strtrim(strmid(inp,f2st,f2len))
            'NUMDIMS:  ': dhdr.numdims  =fix(strtrim(strmid(inp,f2st,f2len)))
            'Dim0:     ': dhdr.dim0     =long(strtrim(strmid(inp,f2st,f2len))) 
            'Dim1:     ': dhdr.dim1     =long(strtrim(strmid(inp,f2st,f2len)))
            'NUMCHANNEL': dhdr.numchannels=fix(strtrim(strmid(inp,f2st,f2len)))
            'TX START  ': dhdr.txStart  =long(strtrim(strmid(inp,f2st,f2len)))
            'TX SIZE   ': dhdr.txLen    =long(strtrim(strmid(inp,f2st,f2len)))
            'DATA START': dhdr.dataStart =long(strtrim(strmid(inp,f2st,f2len)))
            'DATA SIZE ': dhdr.dataLen   =long(strtrim(strmid(inp,f2st,f2len)))
            'NOISE STAR': dhdr.noiseStart=long(strtrim(strmid(inp,f2st,f2len)))
            'NOISE SIZE': dhdr.noiseLen  =long(strtrim(strmid(inp,f2st,f2len)))
            'SYSTIME   ': dhdr.systime  =strtrim(strmid(inp,f2st,f2len))
            'AZIMUTH   ': dhdr.az       =float(strtrim(strmid(inp,f2st,f2len)))
            'GREGPOS   ': dhdr.zagreg   =float(strtrim(strmid(inp,f2st,f2len)))
            'CARRPOS   ': dhdr.zach     =float(strtrim(strmid(inp,f2st,f2len)))
            ']         ': done=1
            else        : begin
                            if linecnt gt maxline then begin
                                if  gothdr eq 0 then return, -1
                                return,-2
                            endif
                          end
        endcase
        linecnt=linecnt+1
        if use_ahdr then ahdr=(ahdr[0] eq '')?inp:[ahdr,inp]
    endwhile
    return,1
ioerr:
;
;   backto start pos
;
    return,0
end
