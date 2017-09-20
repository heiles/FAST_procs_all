;+
;NAME:
;shshdr_pri - get primary header of file
;SYNTAX: istat=shshdr_pri(lun,phdr,ahdr=ahdr)
;ARGS:
;   lun: int        file descriptor pointing to data file
;RETURNS:
;   phdr: {}    strucuture holding primary header
; adhr[]: string array holding ascii lines input
;
;DESCRIPTION:
;   Read in the primary header from the file pointed to by lun. The
;file will be rewound before reading is started. The file will be 
;left positioned after the start of the primary header.
;
;-
function shshdr_pri,lun,phdr,ahdr=ahdr
;
;
    on_ioerror,ioerr
    phdr={$
        version     : '',$;
             lendian: 0 ,$; 0 no, 1 yes,
              date  : '',$; creation data of file 
              time  : '',$; creation time of file
          observer  : '',$;
          object    : '',$;
          telescope : '',$;
          bwmode    : '',$;
          chused    : '',$;
          colmode   : '',$;
          gatesrc   : '',$;
          gateplr   : '',$;
          burstcnt  : 0l,$;
          delaycnt  : 0l,$;
          sync      : '',$;
          dataformat: '',$;
          clockrate : 0d,$; Mhz
          decimate  : 0 ,$; Mhz
          outputrate: 0D,$; Mhz
          resampler : 0 ,$; 0 -off , 1 on Mhz
          ipp       : 0L,$; in millisecs
          nco1      : 0D,$; in Mhz
          nco2      : 0D,$; in Mhz
          nco3      : 0D,$; in Mhz
          nco4      : 0D,$; in Mhz
          sampletime: 0D $; 1/outputrate
        }
    f2st=19                 ; field 2 start (data
    f2len=17                ; field 2 max len
    inp=''
    rew,lun
    done=0
    use_ahdr=arg_present(ahdr)
    if use_ahdr then ahdr=''
    while (not done) do begin
        readf,lun,inp 
        case strmid(inp,0,10) of 
            'Simple Hea' : begin
                    ipos=strpos(inp,'version:')
                    phdr.version=(ipos lt 0)?'':strtrim(strmid(inp,ipos+8,5),2)
                    end
            'BYTEORDER:': phdr.lendian= (strmid(inp,16,1) eq 'L') 
            'DATE      ': phdr.date    =strtrim(strmid(inp,f2st,f2len))
            'TIME      ': phdr.time    =strtrim(strmid(inp,f2st,f2len))
            'OBSERVER  ': phdr.observer=strtrim(strmid(inp,f2st,f2len))
            'OBJECT    ': phdr.object  =strtrim(strmid(inp,f2st,f2len))
            'TELESCOPE ': phdr.telescope=strtrim(strmid(inp,f2st,f2len))
            'BWMODE    ': phdr.bwmode   =strtrim(strmid(inp,f2st,f2len))
            'CHUSED    ': phdr.chused   =strtrim(strmid(inp,f2st,f2len))
            'COLMODE   ': phdr.colmode  =strtrim(strmid(inp,f2st,f2len))
            'GATESRC   ': phdr.gatesrc  =strtrim(strmid(inp,f2st,f2len))
            'GATEPLR   ': phdr.gateplr  =strtrim(strmid(inp,f2st,f2len))
            'BURSTCOUNT': phdr.burstcnt =long(strtrim(strmid(inp,f2st,f2len)))
            'DELAYCOUNT': phdr.delaycnt =long(strtrim(strmid(inp,f2st,f2len)))
            'SYNC      ': phdr.sync     =strtrim(strmid(inp,f2st,f2len))
            'DATAFORMAT': phdr.dataformat=strtrim(strmid(inp,f2st,f2len))
            'CLOCKRATE ': phdr.clockrate=double(strtrim(strmid(inp,f2st,f2len)))
            'DECIMATION': phdr.decimate =   fix(strtrim(strmid(inp,f2st,f2len)))
            'OUTPUTRATE': phdr.outputrate=$
                            double(strtrim(strmid(inp,f2st,f2len)))
            'RESAMPLER ': phdr.resampler =(strmid(inp,f2st,2) eq 'ON')?1:0
            'IPP       ': phdr.ipp       =long(strtrim(strmid(inp,f2st,f2len)))
           'NCO1      ': phdr.nco1      =double(strtrim(strmid(inp,f2st,f2len)))
           'NCO2      ': phdr.nco2      =double(strtrim(strmid(inp,f2st,f2len)))
           'NCO3      ': phdr.nco3      =double(strtrim(strmid(inp,f2st,f2len)))
           'NCO4      ': phdr.nco4      =double(strtrim(strmid(inp,f2st,f2len)))
            ']         ': done=1
            else        :
        endcase
        if use_ahdr then ahdr=(ahdr[0] eq '')?inp:[ahdr,inp]
    endwhile
    if phdr.outputrate ne 0.  then phdr.sampletime=1D/phdr.outputrate
    return,1
ioerr:
    print,'io error reading primary header:',!error_state.msg
    return,0
end
