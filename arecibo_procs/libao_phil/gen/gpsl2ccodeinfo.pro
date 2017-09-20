;+
;NAME:
;pncodeinfo - initialize the code info for the gpsl2c med,long codes
;SYNTAX: maxcodes=gpsl2ccodeinfo(gpsl2ccodeI,longcode=longcode)
;KEYWORDS:
;	longcode: 	if set then return setupinfo for the gpsl2 cl codes:
;               767250 chips. By default return the gpsl2 cm code info:
;				10230 chips.
;RETURNS:
;maxcodes: long	number of different codes we know of (satellites)
;gpsl2ccodI[maxcodes]: {} codeinfo struct for each code:
;DESCRIPTION:
;	Initialize the codeInfo structure for the gps l2c codes for the 37 
;assigned gps prn satellites
;IDL> help,pncodeI,/st
;** Structure CODEINFO, 4 tags, length=92, data length=92:
;   prn             int         1   ; satellite number
;   NUM_REG         LONG        1
;   LEN             LONG        1
;   NUM_FDBACK      LONG        1
;   FDBACK          LONG      Array[20]
;   galois          int         i   ; 0==> fibonnaci, 1==> galois lfsr
;   startVal        ulong		0   ; for galois
;   endVal          ulong		0   ; for galois
;
;	The codeinfo struct gets passed to the routine that generates the
;code.
; Note that the fdback register positions are 1 based. When we use them
;in the shiftregcmp routine we subtract one to get the 0 based index into
;the shift register.
;	When calling shiftregcmp() on the long codes, the routine is slow since
;idl doesn't have circular bit shifts,.
; (about 20 secs..). 
;-
function gpsl2ccodeinfo,gpsl2ccodeI,longcode=longcode
;
;  struct to hold the pncode info
    a={$ 
		prn    :         0 , $ ; satellite number
        num_reg:        27L, $ ; number of registers for this code
            len:         0L, $ ; length of this code
     num_fdback:        11L, $ ; number of feedbacks this code
         fdback: lonarr(11),$ ; 
		 galois:         1L,$ ; 
	   startVal:        0UL,$ ; 
		 endVal:        0UL}
;
	numSat=37
	uselong=keyword_set(longcode)
	gpsl2ccodeI=replicate(a,numSat)
	if uselong then begin
;	   prn    startVal       endVal
          cminfo=[$
       [1, "624145772, "267724236],$
       [2, "506610362, "167516066],$
       [3, "220360016, "771756405],$
       [4, "710406104, "047202624],$
       [5, "001143345, "052770433],$
       [6, "053023326, "761743665],$
       [7, "652521276, "133015726],$
       [8, "206124777, "610611511],$
       [9, "015563374, "352150323],$
       [10, "561522076, "051266046],$
       [11, "023163525, "305611373],$
       [12, "117776450, "504676773],$
       [13, "606516355, "272572634],$
       [14, "003037343, "731320771],$
       [15, "046515565, "631326563],$
       [16, "671511621, "231516360],$
       [17, "605402220, "030367366],$
       [18, "002576207, "713543613],$
       [19, "525163451, "232674654],$
       [20, "266527765, "641733155],$
       [21, "006760703, "730125345],$
       [22, "501474556, "000316074],$
       [23, "743747443, "171313614],$
       [24, "615534726, "001523662],$
       [25, "763621420, "023457250],$
       [26, "720727474, "330733254],$
       [27, "700521043, "625055726],$
       [28, "222567263, "476524061],$
       [29, "132765304, "602066031],$
       [30, "746332245, "012412526],$
       [31, "102300466, "705144501],$
       [32, "255231716, "615373171],$
       [33, "437661701, "041637664],$
       [34, "717047302, "100107264],$
       [35, "222614207, "634251723],$
       [36, "561123307, "257012032],$
       [37, "240713073, "703702423]]
	endif else begin
;		   prn    startVal       endVal

          cminfo=[$
          [  1,  "742417664UL, "552566002UL],$
          [  2,  "756014035UL, "034445034UL],$
          [  3,  "002747144UL, "723443711UL],$
          [  4,  "066265724UL, "511222013UL],$
          [  5,  "601403471UL, "463055213UL],$
          [  6,  "703232733UL, "667044524UL],$
          [  7,  "124510070UL, "652322653UL],$
          [  8,  "617316361UL, "505703344UL],$
          [  9,  "047541621UL, "520302775UL],$
          [ 10,  "733031046UL, "244205506UL],$
          [ 11,  "713512145UL, "236174002UL],$
          [ 12,  "024437606UL, "654305531UL],$
          [ 13,  "021264003UL, "435070571UL],$
          [ 14,  "230655351UL, "630431251UL],$
          [ 15,  "001314400UL, "234043417UL],$
          [ 16,  "222021506UL, "535540745UL],$
          [ 17,  "540264026UL, "043056734UL],$
          [ 18,  "205521705UL, "731304103UL],$
          [ 19,  "064022144UL, "412120105UL],$
          [ 20,  "120161274UL, "365636111UL],$
          [ 21,  "044023533UL, "143324657UL],$
          [ 22,  "724744327UL, "110766462UL],$
          [ 23,  "045743577UL, "602405203UL],$
          [ 24,  "741201660UL, "177735650UL],$
          [ 25,  "700274134UL, "630177560UL],$
          [ 26,  "010247261UL, "653467107UL],$
          [ 27,  "713433445UL, "406576630UL],$
          [ 28,  "737324162UL, "221777100UL],$
          [ 29,  "311627434UL, "773266673UL],$
          [ 30,  "710452007UL, "100010710UL],$
          [ 31,  "722462133UL, "431037132UL],$
          [ 32,  "050172213UL, "624127475UL],$
          [ 33,  "500653703UL, "154624012UL],$
          [ 34,  "755077436UL, "275636742UL],$
          [ 35,  "136717361UL, "644341556UL],$
          [ 36,  "756675453UL, "514260662UL],$
          [ 37,  "435506112UL, "133501670]]
	endelse
;
	gpsl2ccodeI.fdback=[3,4,5,6,9,11,13,16,19,21,24]
	gpsl2ccodeI.len=(useLong)?767250L:10230L
	gpsl2ccodeI.prn     =reform(cminfo[0,*])
	gpsl2ccodeI.startVal=reform(cminfo[1,*])
	gpsl2ccodeI.endVal  =reform(cminfo[2,*])
	return,numSat
end
