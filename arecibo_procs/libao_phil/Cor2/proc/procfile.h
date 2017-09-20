;
; used by procsrc
; srcnum : index 0 thru numstrips
; srcsym : 0 thru n.. different symbols for different sources.
; srccol : 0--> polA,polB different. > 0 --> color for this source polA and B
;
s={pfsrcinfo,  name: ' ',filenm: ' ',scanst:0L,npair:0L,flux:fltarr(4),$
				srcnum:0L,srcsym:0L,srccol:0L}
s={pfsrcout , h:{hdr},srcnum : 0, t:{cortmp},flux: fltarr(4)}
;
; used by routine that reads in all headers of a file
;
a={pfhdrstr, 	$ 
		    fileind     :   0L,$   ; index into filename array
			grpperscan  :   0L,$   ; number of groups per scan
			nbrds       :   0 ,$   ; number of boards this scan
			hst		    : replicate({hdr},4), $; first header of scan
			hend	    : replicate({hdr},4), $; last  header of scan
			avglag0pwr  : fltarr(2,4),$; hold averaged power info
			pol			:intarr(2,4)};1 polA, 2 polB, 0 no data
a={pfcalonoff, $
			  hind:          0L,$;index into hdrstr array for cal on
			  bind:          0L,$;board index 
			  sind:          0L,$;sbc index 0,1
			   pol:          0 ,$;1-polA, 2-polb
			calval:	         0.,$;used
			calscl:	         0.,$;K/(calon-caloff)
			tsyson:          0.,$; cal on tsys
		   tsysoff:          0.} ; cal off tsys

a={pfmhdr, $
			     h:         {hdr},$; header
            offset:          0L  ,$; location in file, brd 0, this integration
               brd:          0L  ,$; which board 0,1,2,3
             nbrds:          0L  } ;boards in rec
