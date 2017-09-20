;+
;NAME:
;pdevopen - open pdev file for reading.
;SYNTAX: istat=pdevopen(filename,desc,fnmI=fnmI,fnumhdr=fnumhdr)
;ARGS:
;   filename: string    filename to open (unless fnmI is specified)
;
;KEYWORDS:
;   fnmI    : {]        returned from pdevfilelist. if provided,
;                       then ignore filename and use this as the
;                       file to open.
;   fnumhdr: string     If the file you are openning is not the first file
;                       of a run of multiple files, then fnumhdr specifies
;                       the file number for the first file of the set (which
;                       contains the header). See below for how to use this.
;RETURNS:
;   istat: 0 ok
;          -1 could not open file.
;          -2 could not open header file in multi file set
;          -3 error reading headerfile
;          -4 header file didn not contain a header
;          -5 header file didn not contain an sp1  header
;          -6 unknown status from pdevgethdr()
;   desc : {}  file descriptor to pass to the i/o routines.
;
;DESCRIPTION:
;	Open a .pdev file. The format for a pdev file is a 
;1024 byte header followed by data. The data can be spectra or time domain
;samples.
;	If multiple files were written during 1 scan then only the first file 
;has the 1024 byte header.  The first file of a scan always starts with a
;number that is a multiple of 100.
;
;	When you are done processing a file call pdevclose,desc to close the
;file. You can use pdevclose,/all to close all open files. If you 
;are reading a multifile scan sequentially then the next pdevopen() will 
;close the previous file for you.
;
;	If you have multiple files in a scan, pdevopen() trys to guess which 
;file has the header. The algorithm it uses is:
;   1. if you open files sequentially from the first header file,
;      then pdevopen() stashes info in the desc. structure
;   2. if you specify fnumhdr= then it uses that number as the file
;      with the header.
;   3. if the filenumber is not divisible by 100 then it will take the lowest
;      number that is a multiple of 100 from the current file num and assume
;      that is the header.
; 	A problem can arrive in step 3. if there are > 100 files in the scan
;and you don't specify fnumhdr=.. 
;      eg: - scan starts at 1200
;          - 150 scans in file
;          - You want to open file 1305 without using fnumhdr=
;          - pdevopen() will take int(1305/100)*100=1300 as the header
;            instead of 1200. In this case you need to specify fnumdhr=1200
;
;Examples:
;1. To open the first file of a scan (which contains the header):
;
;  file='/share/pdata1/pdev/moon.20080605.b0s1g0.01200.pdev'
;  istat=pdevopen(file,desc)
;   .. process the file
;2. To open a file in the above scan that was not the first file:
;   a. If you have already opened the first file:
;  	   file='/share/pdata1/pdev/moon.20080605.b0s1g0.01203.pdev'
;      istat=pdevopen(file,desc)
;      - In this case don't bother to close the previous file, pdevopen()
;        will do it for you.
;   b. If you want to open the 3rd file of the set:
;  	   file='/share/pdata1/pdev/moon.20080605.b0s1g0.01203.pdev'
;      istat=pdevopen(file,desc)
;      - pdevopen will try to figure out which file had the header.
;   b. If you want to open the 3rd file of the set, and pdevopen() can't
;      figure out which file was the header file:
;  	   file='/share/pdata1/pdev/moon.20080605.b0s1g0.01203.pdev'
;      istat=pdevopen(file,desc,fnumhdr=1200)
;
;-
function pdevopen,filename,desc,fnmI=fnmI,fnumhdr=fnumhdr
;
;
;
   common pdevcom,pdevnluns,pdevlunar

    forward_function pdevbitrevind
;
; 	if  desc still present see if descriptor lun is really open
;
	descLunOpen=0
	if keyword_set(desc) then begin
		fsDesc=fstat(desc.lun)
		descLunOpen=fsdesc.open ne 0
	endif
	
	retstat=0
	lunhdr=-1
	lun=-1
    err=0
    fname=(keyword_set(fnmI))$
           ? fnmI.dir + fnmI.fname : filename   
    openr,lun,fname,/get_lun,error=err
    if err ne 0 then begin
       print,!error_state.msg
       retstat=-1
	   goto,errout
    endif
    fs=fstat(lun)
;
; 	parse the filename we just openned
;
   istat=pdevparsfnm(fname,fnmIL)
;
; 	see if we are opening the next file in the scan sequence
;   and desc is already setup
;
	if (keyword_set(desc) ) then begin
	 	if descLunOpen then pdevclose,desc
		if (desc.fnmI.dir     eq fnmIL.dir) and $
		   (desc.fnmI.proj    eq fnmIL.proj) and $
		   (desc.fnmI.date    eq fnmIL.date) and $
		   (desc.fnmI.bm      eq fnmIL.bm    ) and $
		   (desc.fnmI.band    eq fnmIL.band ) and $
		   ((desc.fnmI.num+1) eq fnmIL.num) then begin
;		free_lun,desc.lun
			desc.lun=lun
			desc.fnmI=fnmIL
        	desc.curRecPos=1
			desc.hdrOffB=0L			; data starts at the beginning.
            desc.bytesfile=fs.size
	    	desc.recsTot=(fs.size - desc.hdrOffB)/desc.reclenB
;
;    remember lun in case pdevclose,/all
;
    		ind=where(pdevlunar eq 0,count)
    		if count gt 0 then begin
        		pdevlunar[ind[0]]=lun
        		pdevnluns=pdevnluns+1
    		endif
        	return,0
		endif
	endif
;
;   if they specified fnumhdr or , open the hdr file
;
	usefnumhdr=0
	tryFnumhdr=(fnmIL.num/ 100)*100
	if n_elements(fnumhdr) gt 0 then begin 
		usefnumhdr=1
		tryfnumhdr=fnumhdr
	endif 
	if (tryFnumhdr ne fnmIl.num) then begin
		fnameHdr=fnmIL.dir + string(format=$
  	    	'(a,".",i8,".","b",i1,"s",i1,"g",i1,".",i05,".pdev")',$
			fnmIL.proj,fnmIL.date,fnmIL.bm,fnmIL.band,fnmIL.grp,$
			tryfnumhdr)	
		openr,lunhdr,fnameHdr,/get_lun,error=err
    	if err ne 0 then begin
       	 	print,"could not open specified headerfile:",fnamehdr
       	 	print,!error_state.msg
       	    retstat=-2
			goto,errout
		endif
   	 endif else begin
		lunhdr=lun     ; just try the current file
	 endelse
;
	istat=pdevgethdr(lunhdr,hdrpdev,hdrsp,hdrao,pdevver)
		
	fout=(lunhdr ne lun)?fnamehdr:fnmIL.dir + fnmIL.fname
	case istat of
		0  : break
		-1 : begin
       	 	print,"Error reading hdrfile:",fout
       	 	print,!error_state.msg
			retstat=-3
			goto,errout
			end
		-2 : begin
       	 	print,"The header file did not contain a header:",fout
			retstat=-4
			goto,errout
			end
		-3 : begin
       	 	print,"The header file did not contain an sp1 header:",fout
			retstat=-5
			goto,errout
			end
		else: begin
       	 	print,"unknown status:",istat," returned from pdevgethdr:",fout
			retstat=-6
			goto,errout
		    end
	endcase
	hdrOffBytes=1024L
	if lunhdr ne lun then begin
			free_lun,lunhdr
			lunhdr=-1
		    hdrOffBytes=0L
	endif
    psrvphilL= (hdrpdev.resv1 and 1) ; psrv phil sets this bit to 1
    nobitrevL=psrvphilL
;
;   see if we have time domain data
;   there is no 8byte header for time domain data..
;
    timeDomainData=(hdrsp.hrmode eq 1) and (hdrsp.hrlpf ne 0)
    if (timeDomainData) then begin
        nsbc=((hdrsp.hrlpf and 4) ne 0)?2:1 ; polA or a,b
        bits= 2^(hdrsp.hrlpf and 3)*2  ; 4,8,16 bits
        nchan=(hdrpdev.blksize)/((bits*2)/8 *nsbc)
        type1=(bits eq 16)?2:1
        nobitrevL=1                     ; do not bit reverse..
        itemp=(bits eq 4)?nsbc:nsbc*2   ; 4 bits has i,q 1 byte 
;;        inbuf={ datU: make_array(itemp,nchan,type=type1), h:bytarr(8)}
          inbuf={ datU: make_array(itemp,nchan,type=type1)}

    endif else begin
;
;   figure out the nunber of channels and header for each read..
;
        case hdrsp.fmttype of
            0: nsbc=1
            1: nsbc=2
            2: nsbc=4
        endcase
        nchan=(hdrsp.chndump2-hdrsp.chndump1)+1L 
;
;   need to create an  input  struct to read so we can read it
;   all at once (multiple data types...beware..  if stokes, last 2
;   are unsigned..  first two are signed..
;   ---> error<---- idl does not have a signed char...so u,v byte
;   need to be fixed up..
; fmtwidth: 0 8bit
;           1 16 bit
;           2 32 bits
; fmttype:
;           0 - I ( unsigned)
;           1 - polA,polB  (unsigned)
;           2 - PolA,polB, (U,V signed)
;
;  FIX  ... 1 byte stokes.. need to fix u,v to be usigned in read routine.
;
        case hdrsp.fmtwidth of
        0: begin                            
            type1=1& type2=1            ; both unsigned char
            bits=8
           end
        1: begin
            type1=12 & type2=2          ; ushort,short
            bits=16
           end
        else: begin
            type1=13 & type2=3          ; ulong,long
            bits=32
           end
        endcase
;
        case  nsbc of 
        1:  inbuf={ datU: make_array(nchan,type=type1) , h:bytarr(8)}
        2:  inbuf={ datU: make_array(2,nchan,type=type1), h:bytarr(8)}
        4:  if (hdrsp.fmtwidth ne 2 ) then begin  ; byte,short...
            a={   s0s1: make_array(2,type=type1),$
                  s2s3: make_array(2,type=type2)}
            inbuf={dat: replicate(a,nchan),$
                     h:bytarr(8)}
            endif else begin
            inbuf={datU: make_array(2,nchan,type=type1),$
                   datS: make_array(2,nchan,type=type2),$
                     h:bytarr(8)}
            endelse
  
        endcase
    endelse
    inbufLenB=n_tags(inbuf,/data_length)
    istat=pdevparsfnm(fname,fnmIL)

    desc={$
            lun : lun   ,$  ; of open file
            fnmI: fnmIL  ,$  ; info from file name
            hdev: hdrpdev,$;
            hdevVer: pdevVer,$; 1,2 ..
             hsp: hdrsp , $
             hao: hdrao , $
             nsbc:nsbc,   $
             nchan:nchan, $ ; we actually kept each spectra
             hdrLenB: 1024,$ ; at start of file
             hdrOffB: hdrOffBytes,$ ; at start of file
             recLenB: inbufLenB,$; len inbuf in bytes.
			 recsTot: 0l,$;
             tmd: timeDomainData, $ ; 1 if time domain data.
             bits:  bits*1L     , $ ; 4,8,16,32
			bytesFile:0ll       , $ bytes in file
            noBitRev: nobitrevL,$; not zero--> no need to bit reverse data.
            psrvPhil: psrvphilL,$; taken with psrvphil..
             curRecPos :0LL,$; cur rec we're positioned to read. cnt from 1
;                             0 --> need to position .. 
             inprec: inbuf, $ ; read data into here
         bitRevTbl:(nobitrevL)?lindgen(hdrsp.chndump2-hdrsp.chndump1 + 1) $
               :(pdevbitrevind(hdrsp.fftlen))[hdrsp.chndump1:hdrsp.chndump2]$
    }
	desc.bytesFile=fs.size 
	desc.recsTot=(fs.size - desc.hdrOffB)/desc.reclenB
    point_lun,desc.lun,desc.hdrlenB
    desc.curRecPos=1
;
;    remember lun in case pdevclose,/all
;
    ind=where(pdevlunar eq 0,count)
    if count gt 0 then begin
        pdevlunar[ind[0]]=lun
        pdevnluns=pdevnluns+1
    endif
    return,0
errout:
	if lunhdr ne -1  then begin
		free_lun,lunhdr
		if lun eq lunhdr then lun=-1
	endif
	if lun ne -1 then free_lun,lun
	return,retstat
end
