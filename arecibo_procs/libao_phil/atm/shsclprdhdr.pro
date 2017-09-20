;-
;NAME:
;shsclprdhdr: read .hdr file from clp decoding
;SYNTAX:istat=shsclprdhdr,file,hdr
;ARGS:
;file: string	header filename  xxxx.hdr
;KEYWORDS:
;RETURNS:
;istat:	0 ok -1 error
;hdr  : {}    header holding info
;DESCRIPTION:
;	Read the .hdr file created by the clp decoding (clp1shs).
;Return info in struct hdr
;Take info from the .hdr file (it should be in the same directory
;as the .dcd file.
;-
;
function shsclprdhdr,hdrfile,hdr
;
; warning.. the order var in tmI in the struct needs to match the
;           order of the toks in the line in  the ascii file
tmI={          wstS:  0.	, $; secs waited before start 
               fftU:  0.	, $; usecs for 1 fft 
              accumU: 0.	, $; usecs for power and accum 1 height
                ippS: 0.	, $; secs for 1 ipp
                inpS: 0.	, $; secs for input
                outS: 0.	, $; write out time secs
                tmTot:0.}   ; tot tm secs this block

	 hdr={ fileNum:     0L,$
	        blkInFile:   0L,$
	       nippsAccum:  0L,$
	      cumIppStart:  0L,$
	        smpTmUsec:  0.,$
	      hghtResUsec:  0.,$
	            nchan:  0l,$
	           nhghts:  0l,$	; that were decoded and in .dcd fiel
         hghtDelayUsec: 0.,$	; for first height taken
;                                 does not include any tx offset at start
                fftlen: 0l,$	; fftlen used
              txSmpIpp: 0l,$	; txsmp taken in ipp for datataking
             hghtSmpIpp: 0l,$	; height samples taken datataking
            codeLenUsec: 0.,$	; codelen usecs
               thrIndex: 0L,$	; thread index
               thrIter:  0L,$	; thread index iteration num
               date   :  0L,$	; yyyymmdd ast start of datablock
               secMid :  0L,$	;  ast start of datablock
				   az :  -1.,$   ;  az pos
			   zagreg :  -1.,$   ;  greg za
			   zach   :  -1.,$   ;  ch za
				tmI   : tmI}
;
;   hdr needs same order as this.. same with file
;
;  12apr12 added pos_azgrch
	hdrI=[["FILE_NUM","I"],$
          ["BLK_IN_FILE","I"],$  
          ["NIPPS_ACCUM","I"],$
          ["CUM_IPP_START","I"],$
		  ["SMP_TM_USEC"  ,"F"],$
		  ["HGHT_RES_USEC","F"],$
          ["NUM_CHAN"     ,"I"],$ 
		  ["NUM_HGHTS"    ,"I"],$
          ["HGHT_DELAY_USEC","F"],$
		  ["FFTLEN"         ,"I"],$
	      ["TX_SMP_IPP"     ,"I"],$
	      ["HGHT_SMP_IPP"   ,"I"],$
          ["CODE_LEN_USEC"  ,"F"],$
          ["THRIND_ITERATION"  ,"I I"],$
          ["DATE_SECMID"  ,"I I"],$
          ["POS_AZGRCH"   ,"F F F"]$
		]
		

	n=readasciifile(hdrfile,inp)
	if (n le 0) then begin
		print,'hdrfile does not exist:',hdrfile
		return,-1
	endif
	nn=n_elements(hdrI[0,*])
	numSingle=nn-3			; number of single elements in header
	if (strmid(inp[nn-1],0,3) ne 'POS') then begin
		hdrI=hdrI[*,0:nn-2]
		nn=nn-1
	    numSingle=nn-2			; number of single elements in header
	endif
	if ((nn+1) gt (n)) then begin
		print,"hdrfile not enough entries:",hdrfile 
		return,-1
	endif
	for i=0,nn-1 do begin
		a=strsplit(inp[i],/extract)
		len=strlen(a[0])
	    if (hdrI[0,i] ne a[0]) then begin
			print,"Bad hdrEntry. expected,read:"+hdrI[0,i],+" / " + $
				a[0]
		    return,-1
		endif
		if (i lt  numSingle) then begin 
			hdr.(i)=(hdrI[1,i] eq "I")?long(a[1]):float(a[1])
		endif else begin
			case 1 of
			(a[0] eq "THRIND_ITERATION"):begin
						hdr.thrIndex=long(a[1])
						hdr.thrIter=long(a[2])
					end
			(a[0] eq "DATE_SECMID"):begin
						hdr.date=long(a[1])
						hdr.secMid=long(a[2])
					end
			(a[0] eq "POS_AZGRCH"):begin
						hdr.az=float(a[1])
						hdr.zagreg=float(a[2])
						hdr.zach =float(a[3])
					end
			else: begin
					print,"Bad hdrEntry. expected,read:"+hdrI[0,i],+" / " + a[0]
		    		return,-1
				end
			endcase
		endelse
	endfor
;
;  get the total times
;
	a=strsplit(inp[nn],/extract);
	if (a[0] ne "AvgTMING") then begin
			print,"Bad hdrEntry. expected,read:AvgTMING / "+ a[0]
		return,-1
	endif
	ii=[2,4,6,8,10,12,14]
	for i=0,n_elements(ii)-1 do hdr.tmI.(i)=float(a[ii[i]])
	return,0
end
