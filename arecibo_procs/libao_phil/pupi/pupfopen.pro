;+
;NAME:
;pupfopen - open puppi psrfits file for reading
;SYNTAX: istat=pupfopen(filename,desc)
;ARGS:
;   filename: string    filename to open
;RETURNS:
;   istat: 0 ok
;          -1 could not open file.
;   desc : {}  file descriptor to pass to the i/o routines.
;DESCRIPTION:
; 	open  an ao pupfits file.
;   For  data order is nphasBin,freqbin,pol,smp/blk
;   we will want to store it : freqbin,npol,smp/blk or nbins s
;   so we have to shuffle a bit.
;  The search data comes back at bytes. Since idl's byte is
; unsigned, the get routine  will convert it to floats.
; The desc. will hold a struct that has all the row info up to the
; data. the get routine will then dynamically append the float data to
; this array
;-
function pupfopen,filename,desc
;
; names
; hdrPr_S     - string version of primary header
; hdrPr       - binary structre : primary header
;
;  .. not yet implemented polyco header
; hdrExSI_S   - string version of subint header
; hdrExSI     - binary structure: subint header
;
;
   common pupfcom,pupfnluns,pupflunar

   exNmSI='SUBINT'

    errmsg=''
    lun=-1
    fileLoc=filename

;;  open file. we load the subint extension in the common block.

    fxbopen,lun,fileLoc,exNmSI,hdrExSI_S,errmsg=errmsg
    if errmsg ne '' then begin
        print,errmsg
        goto,errout
    endif
;   ---------------------------------------------------------------------------------------------
; 	now go back and read the primary hdu and any other extensions we've included
;   then move it to their structure
;
;   ---------------------------------------------------------------------------------------------
;   primary hdu
	 rew,lun
     fxhread,lun,hdrPr_S,status

; 	 need same letters as fits file to match keywords in fits header struct
;    except for OBS-DATE since - is an illegal structure name.
; ; fxpar(hdrPr_S,"",start=st)
; g/^\([^ ]*\)[ ]*=.*\/\(.*\)/s//\1 :fxpar(hdrExPD_S,"\1",start=st),$;\2/
;  
	st=0L

	 hdrPr={$
        OBSERVER :fxpar(hdrPr_S,"OBSERVER",start=st),$
        PROJID   :fxpar(hdrPr_S,"PROJID",start=st),$
        TELESCOP :fxpar(hdrPr_S,"TELESCOP",start=st),$
        ANT_X    :fxpar(hdrPr_S,"ANT_X",start=st),$
        ANT_Y    :fxpar(hdrPr_S,"ANT_Y",start=st),$
        ANT_Z    :fxpar(hdrPr_S,"ANT_Z",start=st),$
        NRCVR    :fxpar(hdrPr_S,"NRCVR",start=st),$; number of receiver pol channels
        FD_POLN  :fxpar(hdrPr_S,"FD_POLN",start=st),$;
        FD_HAND  :fxpar(hdrPr_S,"FD_HAND",start=st),$;
        FD_SANG  :fxpar(hdrPr_S,"FD_SANG",start=st),$;
        FD_XYPH  :fxpar(hdrPr_S,"FD_XYPH",start=st),$;
        FRONTEND :fxpar(hdrPr_S,"FRONTEND",start=st),$;
        BACKEND  :fxpar(hdrPr_S,"BACKEND",start=st),$;
        BECONFIG :fxpar(hdrPr_S,"BECONFIG",start=st),$;
        BE_PHASE :fxpar(hdrPr_S,"BE_PHASE",start=st),$;    0 / 0/+1/-1 BE cross-phase:0 unknown,+/-1 std/rev
        BE_DCC   :fxpar(hdrPr_S,"BE_DCC",start=st),$;    0 / 0/1 BE downconversion conjugation corrected
        BE_DELAY :fxpar(hdrPr_S,"BE_DELAY",start=st),$; [s] Backend propn delay from digitiser input
        TCYCLE   :fxpar(hdrPr_S,"TCYCLE",start=st),$; [s] On-line cycle time (D)
        OBS_MODE :fxpar(hdrPr_S,"OBS_MODE",start=st),$; (PSR, CAL, SEARCH)
        DATE_OBS :fxpar(hdrPr_S,"DATE-OBS",start=st),$; Date of observation (YYYY-MM-DDThh:mm:ss UTC)
        OBSFREQ  :fxpar(hdrPr_S,"OBSFREQ",start=st),$; [MHz] Centre frequency for observation
        OBSBW    :fxpar(hdrPr_S,"OBSBW",start=st),$; [MHz] Bandwidth for observation
        OBSNCHAN :fxpar(hdrPr_S,"OBSNCHAN",start=st),$; Number of frequency channels (original)
        SRC_NAME :fxpar(hdrPr_S,"SRC_NAME",start=st),$; Source or scan ID
        COORD_MD :fxpar(hdrPr_S,"COORD_MD",start=st),$; Coordinate mode (J2000, GAL, ECLIP, etc.)
        EQUINOX  :fxpar(hdrPr_S,"EQUINOX",start=st),$; Equinox of coords (e.g. 2000.0)
        RA       :fxpar(hdrPr_S,"RA",start=st),$; Right ascension (hh:mm:ss.ssss)
        DEC      :fxpar(hdrPr_S,"DEC",start=st),$; Declination (-dd:mm:ss.sss)
        BMAJ     :fxpar(hdrPr_S,"BMAJ",start=st),$; [deg] Beam major axis length
        BMIN     :fxpar(hdrPr_S,"BMIN",start=st),$; [deg] Beam minor axis length
        BPA      :fxpar(hdrPr_S,"BPA",start=st),$; [deg] Beam position angle
        TRK_MODE :fxpar(hdrPr_S,"TRK_MODE",start=st),$; Track mode (TRACK, SCANGC, SCANLAT)
        STT_CRD1 :fxpar(hdrPr_S,"STT_CRD1",start=st),$; Start coord 1 (hh:mm:ss.sss or ddd.ddd)
        STT_CRD2 :fxpar(hdrPr_S,"STT_CRD2",start=st),$; Start coord 2 (-dd:mm:ss.sss or -dd.ddd)
        STP_CRD1 :fxpar(hdrPr_S,"STP_CRD1",start=st),$; Stop coord 1 (hh:mm:ss.sss or ddd.ddd)
        STP_CRD2 :fxpar(hdrPr_S,"STP_CRD2",start=st),$; Stop coord 2 (-dd:mm:ss.sss or -dd.ddd)
        SCANLEN  :fxpar(hdrPr_S,"SCANLEN",start=st),$; [s] Requested scan length (E)
        FD_MODE  :fxpar(hdrPr_S,"FD_MODE",start=st),$; Feed track mode - FA, CPA, SPA, TPA
        FA_REQ   :fxpar(hdrPr_S,"FA_REQ",start=st),$; [deg] Feed/Posn angle requested (E)
        CAL_MODE :fxpar(hdrPr_S,"CAL_MODE",start=st),$; Cal mode (OFF, SYNC, EXT1, EXT2)
        CAL_FREQ :fxpar(hdrPr_S,"CAL_FREQ",start=st),$; [Hz] Cal modulation frequency (E)
        CAL_DCYC :fxpar(hdrPr_S,"CAL_DCYC",start=st),$; Cal duty cycle (E)
        CAL_PHS  :fxpar(hdrPr_S,"CAL_PHS",start=st),$; Cal phase (wrt start time) (E)
        STT_IMJD :fxpar(hdrPr_S,"STT_IMJD",start=st),$; Start MJD (UTC days) (J - long integer)
        STT_SMJD :fxpar(hdrPr_S,"STT_SMJD",start=st),$; [s] Start time (sec past UTC 00h) (J)
        STT_OFFS :fxpar(hdrPr_S,"STT_OFFS",start=st),$; [s] Start time offset (D)
        STT_LST  :fxpar(hdrPr_S,"STT_OFFS",start=st) }; [s] Start LST (D)
;      
; 	strip off trailing blanks from string variables
	for i=0,n_tags(hdrPr)-1 do begin 
		if (size(hdrPr.(i),/type) eq 7) then hdrPr.(i)=strtrim(hdrPr.(i)) 
	endfor
;   ---------------------------------------------------------------------------------------------
;   move the extension header to it's structure
;   Since start= is used.. need to have struct order same as file header
;   if not, get rid of start=
;
; fxpar(hdrExSI_S,"",start=start),$;
;   get starting byte for subIntExtStart
	point_lun,-lun,subIntExtStart
	start=0L
	istat=fxpar(hdrExSI_S,"NAXIS2",start=start); Number of rows in table (NSUBINT)              
	naxis2ByteOffset=subIntExtStart + (start-1)*80
	start=0L
	hdrExSI={$
		NAXIS1  : fxpar(hdrExSI_S,"NAXIS1",start=start) ,$; Number of bytes in rowle (NSUBINT)              
		NAXIS2  : fxpar(hdrExSI_S,"NAXIS2",start=start) ,$; Number of rows in table (NSUBINT)              
        NPOL    : fxpar(hdrExSI_S,"NPOL",start=start)   ,$; Nr of polarisations                            
		POL_TYPE: fxpar(hdrExSI_S,"POL_TYPE",start=start),$;Pol identifier (e.g., AABBCRCI, AA+BB)
		TBIN    : fxpar(hdrExSI_S,"TBIN",start=start),$;  [s] Time per bin or sample                     
		NBIN    : fxpar(hdrExSI_S,"NBIN",start=start),$; Nr of bins (PSR/CAL mode; else 1)              
		NBIN_PRD: fxpar(hdrExSI_S,"NBIN_PRD",start=start),$; Nr of bins/pulse period (for gated data)       
		PHS_OFFS: fxpar(hdrExSI_S,"PHS_OFFS",start=start),$; Phase offset of bin 0 for gated data           
		NBITS   : fxpar(hdrExSI_S,"NBITS",start=start),$; Nr of bits/datum (SEARCH mode 'X' data, else 1)
		NSUBOFFS: fxpar(hdrExSI_S,"NSUBOFFS",start=start),$; Subint offset (Contiguous SEARCH-mode files)   
		NCHAN   : fxpar(hdrExSI_S,"NCHAN",start=start),$; Number of channels/sub-bands in this file      
		CHAN_BW : fxpar(hdrExSI_S,"CHAN_BW",start=start),$; [MHz] Channel/sub-band width                   
		NCHNOFFS: fxpar(hdrExSI_S,"NCHNOFFS",start=start),$; Channel/sub-band offset for split files        
		NSBLK   : fxpar(hdrExSI_S,"NSBLK",start=start) $; Samples/row (SEARCH mode, else 1)         
	}
;
; 	strip off trailing blanks from string variables
;
	for i=0,n_tags(hdrExSI)-1 do begin 
		if (size(hdrExSI.(i),/type) eq 7) then hdrExSI.(i)=strtrim(hdrExSI.(i)) 
	endfor

	if hdrExSI.naxis2 le 0 then begin 
        print,"No rows in file:"
        goto,errout
    endif

;   read in colum byte offsets, datatype, form, number elements each col

	fxbtform,hdrExSI_S,colByteOffset,ttype,tform,tnumval

;   get the name of each col &$

	fxbfind,hdrExSI_S,"TTYPE",cols,tagAr,ncols
;
;    get offset start of rec
;    we position to end of col 1 (start of col 2)
;    take current postion - byteoffset col2 to be start of rec
;
    fxbread,lun,junk,1,1        ; read col 1 of first rec
    point_lun,-lun,pos          ; start col2 row 1
    rec1start=pos - colByteOffset[1] ;  
;
;   check swapping
;
    val1=1
    val2=1
    byteorder,val2,/htons
    needswap=val1 ne val2
;
;  generate structure for row read
;
	for i=0,ncols - 1 do begin 
    	icol=i+1 
    	tag=strtrim(tagAr[i]) 
    	len=(tnumval[i] > 2) 
    	val=make_array(len,type=ttype[i]) 
    	if tnumval[i] eq 1 then begin  ; make array doesn't work with scalars..
        	len=1 
        	val=val[0] 
    	endif 
    	if len gt 1 then begin 

;      check for dat_offs, dat_scl, data.. we want to redimension

       		if (((tag eq 'DAT_OFFS') or (tag eq 'DAT_SCL')) ) then begin 
         		if (hdrExSI.npol gt 1)  then  begin
					val=reform(temporary(val),hdrExSI.nchan,hdrExSI.npol,/overwrite) 
        		endif
			endif else begin 
      			if (tag eq 'DATA') then begin 
;
;					search data has nbins=1,nsblk big, fold data: nbins=N, nsblk=1	?
					nn=hdrExSI.nbin*hdrEXSI.nsblk
           			if hdrExSI.npol eq 1 then begin 
           				inpdat =reform(temporary(val),hdrExSI.nchan,nn,/overwrite) 
          			endif else begin 
           				inpdat=reform(temporary(val),hdrExSI.nchan,hdrExSI.npol,nn,/overwrite) 
           			endelse 
       			endif 
			endelse 
		endif
;
		if i eq 0 then begin 
        	str =create_struct(tag,val) 
        	strF=create_struct(tag,val) 
    	endif else begin	
      		if (tag eq 'DATA') then begin 
				continue
			endif else begin 
       			str=create_struct(temporary(str),tag,val) 
       			strf=create_struct(temporary(strF),tag,val) 
			endelse
    	endelse 
	endfor

    desc={   lun     : lun       ,$;
		filename: fileLoc,$;
        needswap: needSwap,$;  1 if need to swap the data o nthe cpu
        bytesRow:  hdrExSI.naxis1   ,$; bytes 1 row
        totRows :  hdrExSI.naxis2   ,$; total number of rows in table
        curRow  : 0L        ,$;
        byteOffRec1:rec1start,$
        byteOffNaxis2:naxis2ByteOffset  ,$  ; bytes offset naxis 2 keyword
		obsMode  : hdrPr.obs_mode,$    ; SEARCH,CAL,PSR
	searchData   : hdrPr.obs_mode eq 'SEARCH',$   ; 1=search data. byte, nchan,npol,nblocks
        hpri     : hdrPr     ,$   ; primary header
        hsubint  : hdrExSI,$ ; subInt table header
        rowStr   : str,$   ; template for records to read minus the data
        inpdat   : inpdat }; to read in the data
;
;    remember lun in case pupfclose,/all
;
    ind=where(pupflunar eq 0,count)
    if count gt 0 then begin
        pupflunar[ind[0]]=lun
        pupfnluns=pupfnluns+1
    endif
    return,0  
errout:
    if (lun gt -1) then  fxbclose,lun
    return,-1 
end
